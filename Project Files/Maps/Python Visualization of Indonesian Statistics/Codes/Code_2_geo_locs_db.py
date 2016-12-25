#This python script will create a database for the raw input of GoogleMap locations

#################################### Import Libraries ####################################

import sqlite3, re, json, ssl, urllib, os
import pickle as p

################# Set path for pickling the lists scraped from the web ###################

script_dir=os.path.dirname('/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Programming/Python/Course 5 - Capstone/Capstone Project/')

rel_path='source_data/Pickled Data'

abs_path=os.path.join(script_dir, rel_path)

#Unpickling data location

fname_admin_regions=abs_path+'/admin_regions.pkl'

#Pickling data location

fname_failloc=abs_path+'/failed_locations.pkl'

##################### API to use to grab the geo data: Google Maps #######################

serviceurl = "http://maps.googleapis.com/maps/api/geocode/json?"

# Deal with SSL certificate anomalies Python > 2.7
# scontext = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
scontext = None

##################### Create a SQLite database to input the codes ########################

conn=sqlite3.connect('indonesian_locations_raw.sqlite')
cur=conn.cursor()

cur.executescript('''
CREATE TABLE IF NOT EXISTS Province (
    name       TEXT, 
    id         INTEGER,
    lat        FLOAT,
    lon        FLOAT,
    geodata    TEXT,
    PRIMARY KEY (id)
);  

CREATE TABLE IF NOT EXISTS Kabupaten (
    name       TEXT,
    id         INTEGER, 
    prov_id    INTEGER,
    lat        FLOAT, 
    lon        FLOAT,
    geodata    TEXT,
    PRIMARY KEY (prov_id, id)
);

CREATE TABLE IF NOT EXISTS Kecamatan (
    name       TEXT,
    id         INTEGER, 
    kab_id     INTEGER,
    prov_id    INTEGER,
    lat        FLOAT, 
    lon        FLOAT,
    geodata    TEXT,
    PRIMARY KEY (prov_id, kab_id, id)
)
''')

########################## Unpickle the administrative regions ###########################

#Unpickle the administrative regions for cycling
unpickle=open(fname_admin_regions)
rebar=p.load(unpickle)
unpickle.close()

######################## Cycle through the entries to org into DB ########################

#Initialise counters
count_rl=0          #rate limit/day counter

#Initialise the list that will be used to pack the failed locations for pickling
failloc=[]

#Cycle through the various lists
for l in xrange(len(rebar)):

    for entry in rebar[l]:

        #assign the name of the location, second element in tuple
        name=entry[1]    

        #see if the information is in the database (since records may repeat since I 
        #filled in missing values I need to identify the record with the BPS codes)
        if l==0:
            #assign the value(s) in the first element to bps_codes
            prov_code=int(entry[0])
            #try to execute a select command
            cur.execute("SELECT geodata FROM Province WHERE id= ?", (prov_code, ))
        elif l==1:
            #assign the value(s) in the first element to bps_codes
            prov_code=int(entry[0][0])
            kab_code=int(entry[0][1])
            #try to execute a select command
            cur.execute("SELECT geodata FROM Kabupaten WHERE id= ? AND prov_id=?", (kab_code,prov_code))
        else:
            #assign the value(s) in the first element to bps_codes
            prov_code=int(entry[0][0])
            kab_code=int(entry[0][1])
            kec_code=int(entry[0][2])
            #try to execute a select command
            cur.execute("SELECT geodata FROM Kecamatan WHERE id=? AND kab_id=? AND prov_id=?", (kec_code,kab_code,prov_code))

        #try to grab the first row of data, if unable continue down to code
        try:
            data = cur.fetchone()[0]
            print "Found in database ",name
            continue
        except:
            pass

        #grab the text data from Google Maps

        #resolve the url
        url=serviceurl + urllib.urlencode({"sensor":"false", "address": name})

        #open and read in the url
        data=urllib.urlopen(url, context=scontext).read()

        #print the rate limiter counter
        count_rl += 1
        print count_rl

        #try to deserialise with JSON; if fail record into text file
        try: 
            js = json.loads(str(data))
        except: 
            print '==== Failure To Retrieve JSON Data ===='
            print entry[0],entry[1]
            continue

        #if we've reached our limit, commit the data to DB, close files, and exit   
        if js['status']=='OVER_QUERY_LIMIT': 
			print "==== Failure To Retrieve Location: Google Rate Limit Reached ====\n"

			break

        #if the results contain an error or the status is not acceptable, record and skip
        elif 'status' not in js or js['status']!='OK' or js['status']=='ZERO_RESULTS': 
            print '==== Failure To Retrieve Location ===='
            print entry[0],entry[1]

            #append the entry into the failloc list
            failloc.append(entry)

            continue 

        #insert into database (strip name pieces to take out the long forms of names)
        if l==0:
            name=re.findall('^(.*)Province',name)
            name=name[0].strip()
            cur.execute('''INSERT INTO Province (name, id, geodata) VALUES ( ?, ?, ? )''', ( buffer(name),prov_code,buffer(data) ) )
        elif l==1:
            name=re.findall('^Kabupaten (.*)|^(.*) City District',name)
            name=[tuple(j for j in i if j)[-1] for i in name]
            name=name[0].strip()
            cur.execute('''INSERT INTO Kabupaten (name, id, prov_id, geodata) VALUES ( ?, ?, ?, ? )''', ( buffer(name),kab_code,prov_code,buffer(data) ) )
        else:
            name=re.findall('^Kecamatan (.*),\s*\D*',name)
            #name=[tuple(j for j in i if j)[-1] for i in name]
            name=name[0].strip()
            cur.execute('''INSERT INTO Kecamatan (name, id, kab_id, prov_id, geodata) VALUES ( ?, ?, ?, ?, ? )''', ( buffer(name),kec_code,kab_code,prov_code,buffer(data) ) )

#commit the data to the database
conn.commit() 
cur.close()

#Pickle the failed locations
pickle_failloc=open(fname_failloc,"w")
p.dump(failloc,pickle_failloc)
pickle_failloc.close()
