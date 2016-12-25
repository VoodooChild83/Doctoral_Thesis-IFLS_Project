#This python script will run a second pass of the failed locations to update database

#################################### Import Libraries ####################################

import sqlite3, re, json, ssl, urllib, codecs, ast, os
import pickle as p

##################### API to use to grab the geo data: Google Maps #######################

serviceurl = "http://maps.googleapis.com/maps/api/geocode/json?"

# Deal with SSL certificate anomalies Python > 2.7
# scontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
scontext = None

#################### Connect to SQLite database to input the codes #######################

conn=sqlite3.connect('indonesian_locations_raw.sqlite')
cur=conn.cursor()

########################## Set path for pickling and reading  ##############################

script_dir=os.path.dirname('/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Programming/Python/Course 5 - Capstone/Capstone Project/')

rel_path='source_data'

abs_path=os.path.join(script_dir, rel_path)

#Geonames location
fname_geonames=abs_path+'/geonames.txt'
features=open(fname_geonames)

#Unpickling data location
fname_failloc=abs_path+'Pickled Data/failed_locations.pkl'

########################## Unpickle the administrative regions ###########################

#Unpickle the administrative regions for cycling
unpickle=open(fname_failloc)
failloc=p.load(unpickle)
unpickle.close()

################### Cycle through the locations, removing KAB and KEC ####################

#Initialise counters
count_rl=0          #rate limit/day counter

#Cycle through the various lists
for entry in failloc:
    
    #Adjust name and set the variables
    
    if re.search('^.*(Province)',entry[1]):

        adm='1'
    
        name=re.findall('(.*)Province',entry[1])
        name=name[0].strip()
        
        #used in googlemaps
        name_1=name+', Indonesia'
    	
    	#assign the value(s) in the first element to bps_codes
        prov_code=int(entry[0])
    
        #try to execute a select command
        cur.execute("SELECT geodata FROM Province WHERE id=?", (prov_code,))
    
    elif re.search('^(Kabupaten).*|^[^Kecamatan].*(City District)',entry[1]):

        adm='2'

		#go through for Kabupaten and Kota individually
        if re.search('^(Kabupaten).*',entry[1]):

            name=re.findall('^Kabupaten (.*)',entry[1])
            name=name[0].strip()
        
            #this will be used for checking within the geonames
            rename=entry[1]

        else:

            name=re.findall('^(.*)City District',entry[1])
            name=name[0].strip()

            #rename the original entry into Kota to check the geoname file
            rename='Kota '+name

        #this will be used to check google maps
        name_1=name+', Indonesia'
		
		#assign the value(s) in the first element to bps_codes
        prov_code=int(entry[0][0])
        kab_code=int(entry[0][1]) 

        #try to execute a select command
        cur.execute("SELECT geodata FROM Kabupaten WHERE id=? AND prov_id=?", (kab_code,prov_code))
       
    else:
        
        adm='3'
        
        #assign the name of the location, second element in tuple
        name=re.findall('^Kecamatan(.*),.*',entry[1])
        name=name[0].strip()

        #adjust name: recall Kecamatan entries from failed locations file (entry[0]) looks 
        #like 'Kecamatan X, Kabupaten X' or 'Kecamatan X, X City District' --> need to
        #adjust entry[1] to be able to check within the geoname file 
        rename='Kecamatan '+name
        
        #name_1: the Kecamatan will be googled directly (along with country name, just 
        #in case
        name_1=rename+', Indonesia'
        
        #assign the value(s) in the first element to bps_codes
        prov_code=int(entry[0][0])
        kab_code=int(entry[0][1])
        kec_code=int(entry[0][2])
    
        #try to execute a select command
        cur.execute("SELECT geodata FROM Kecamatan WHERE id=? AND kab_id=? AND prov_id=?", (kec_code,kab_code,prov_code))


    #try to grab the first row of data, if unable continue down to code
    try:
        data = cur.fetchone()[0]
        print "Found in database ",name,"\n"
        continue
    except:
        pass


    #grab the text data from Google Maps
    #resolve the url
    url=serviceurl + urllib.urlencode({"sensor":"false", "address": name_1})

    #open and read in the url
    data=urllib.urlopen(url, context=scontext).read()

    #print the rate limiter counter
    count_rl += 1
    print count_rl

    #deserialise the data
    js = json.loads(str(data))
    
    #initialize the found boolean
    found=False
    
    #if we've reached our limit, exit the program and try another VPN server 
    if js['status']=='OVER_QUERY_LIMIT': 
        print "==== Failure To Retrieve Location: Google Rate Limit Reached ====\n"
        
        break

    #if the results contain an error or the status is not acceptable, record and skip
    elif 'status' not in js or js['status']!='OK' or js['status']=='ZERO_RESULTS': 
       
        print '=== Unable to find in Google API ==='
        
        #check that the location is in the geonames file
            
        print '==== Checking Geonames file for the admin region ==='
        
        #use the for-else construct to see if there is a match in the dataset, else write into the output file
        #and move on
        for line in features:
            
            line=ast.literal_eval(line)
            
            if adm==line[-1] and re.search(rename+'|'+name,line[0]):
                found=True
                print '=== Found',name,'in the file ===\n'
                break
        else:
        
            print '==== Failure To Retrieve Location ===='
            print entry[0],rename,"\n"
    
            continue

    #insert into database
    if adm=='1':
        cur.execute('''INSERT INTO Province (name, id, geodata)
            VALUES ( ?, ?, ?, ? )''', ( buffer(name),prov_code,buffer(data) ) )
    elif adm=='2':
        cur.execute('''INSERT INTO Kabupaten (name, id, prov_id, geodata) 
            VALUES ( ?, ?, ?, ? )''', ( buffer(name),kab_code,prov_code,buffer(data) ) )
    else:
        cur.execute('''INSERT INTO Kecamatan (name, id, kab_id, prov_id, geodata) 
            VALUES ( ?, ?, ?, ?, ? )''', ( buffer(name),kec_code,kab_code,prov_code,buffer(data) ) )

#commit the data to the database and close file and the cursor
conn.commit()
features.close()
cur.close()
