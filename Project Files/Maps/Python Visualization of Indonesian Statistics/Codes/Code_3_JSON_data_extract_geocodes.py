#This python script will extract the data from json output previously fetched from google

#################################### Import Libraries ####################################

import sqlite3, re, json, os, ast

#################### Connect to SQLite database to input the codes #######################

conn=sqlite3.connect('indonesian_locations_raw.sqlite')
cur=conn.cursor()

########### Set path for Geonames text file to look up if location is in file ############

script_dir=os.path.dirname('/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Programming/Python/Course 5 - Capstone/Capstone Project/')

rel_path='source_data'

abs_path=os.path.join(script_dir, rel_path)

fname=abs_path+'/geonames.txt'

############ Define functions that will be used in the main part of the code ##############

#This function will read the geonames file and look for a match to grab the lon,lat

def search_file(polity,name,adm,*var_arg):
    
    #check the Kab code, if it is greater than 70 it is a Kota so add that polity 
    if len(var_arg)>0:
        if var_arg[0]>70: name_1='Kota '+name
        else: name_1=polity+' '+name
    else: name_1=polity+' '+name
    found=False
    with open(fname) as features:
        #use the for-else construct
        for line in features:
            line=ast.literal_eval(line)
            if adm==line[-1] and re.search(name_1+'|'+name,line[0]):
                lat=line[1][0]; lon=line[1][1]; found=True
                return (lat,lon,found)
                break
        else: return (None,None,found)

#This function will write into the (variable arguments must enter as (lat,lon,lowest level adm -> highest level)

def write_SQL(polity,flag,db_args):
    
    #set the identifiers for SQLite
    if polity=='Province': input="WHERE id=?"
    elif polity=='Kabupaten': input="WHERE id=? AND prov_id=?"
    else: input="WHERE id=? AND kab_id=? AND prov_id=?"
    
    #update or delete rows from the databse
    if flag=='update':
        cur.execute("UPDATE "+polity+" SET lat=?,lon=? "+input, db_args)
    else:                    
        cur.execute("DELETE FROM "+polity+" "+input, db_args)

############## Set up the list to cycle through the json data in database ################

polities=['Province','Kabupaten','Kecamatan']

#to increment the step count for column fields in table (since lat, lon, geodata shift column positions by 1 in
#each table)
step=0

for polity in polities:
    
    #grab the information form the database
    cur.execute("SELECT * FROM "+polity)
    
    rows=cur.fetchall()
    
    if polity=='Province': adm='1'
    elif polity=='Kabupaten': adm='2'
    else: adm='3'

    #cycle through the rows
    for row in rows:
    
        #name
        name=str(row[0]).title()
       
        #check that the current row does not have anything in lat and lon
        try:
            lat=row[2+step]
            lon=row[3+step]
            
            if not((lat is None) and (lon is None)):
                print "Found",name,"in table",polity
                continue
        except:
            pass
            
        #grab the JSON data that has the geocodes in it
        data=row[4+step]
    
        #deserialise the data
        js=json.loads(str(data))
        
        
        #if the JSON data does not contain andy geocodes it is because the polity was found in the geonames file
        #grab the lat,lon from this file; otherwise grab the data from the JSON file, if a mismatch, recall the
        #geonames file
        
        #initialise: was the polity's JSON seemingly valid (adm level matches, country matches)?
        found=False
        
        if 'status' not in js or js['status']!='OK' or js['status']=='ZERO_RESULTS':
        
            lat,lon,found = search_file(polity,name,adm)
        
            if found==True: print "Success","name"

        else:

            #Check the address components to make sure that:
            #1: Provinces have administrative level 1 and country is Indonesia
            #2: Kabupaten have administrative level 2 and country is Indonesia
            #3: Kecamatan have administrative level 3 or 4 and country is Indonesia
            
            admin_level=js["results"][0]["address_components"][0]["types"][0]
            
            country=js["results"][0]["formatted_address"]
            
            if polity=='Province':
                
                bps_codes=(row[1],)
            
                if re.search(adm,admin_level) and re.search('Indonesia',country):
                    
                    lat=js["results"][0]["geometry"]["location"]["lat"]
                    lon=js["results"][0]["geometry"]["location"]["lng"]
                
                    found=True
                
                else:
                    
                    #search the file 
                    lat,lon,found=search_file(polity,name,adm)
        
                    if found==True: print "Successfully found",name,"in geofile and updated geocodes in",polity
            
            elif polity=='Kabupaten':
            
                bps_codes=(row[1],row[2])
                
                if re.search(adm,admin_level) and re.search('Indonesia',country):
                    
                    lat=js["results"][0]["geometry"]["location"]["lat"]
                    lon=js["results"][0]["geometry"]["location"]["lng"]
                    
                    found=True
                         
                else:
                    
                    #search the file
                    lat,lon,found=search_file(polity,name,adm,bps_codes[0])

                    if found==True: print "Successfully found",name,"in geofile and updated geocodes in",polity

            else:
                
                bps_codes=(row[1],row[2],row[3])
                
                #search for either the third or fourth administration level within Kecamatan

                if re.search(adm+'|4',admin_level) and re.search('Indonesia',country):
                    
                    lat=js["results"][0]["geometry"]["location"]["lat"]
                    lon=js["results"][0]["geometry"]["location"]["lng"]
                        
                    found=True
       
                else:
        
                    #search the file and try to find a match
                    lat,lon,found=search_file(polity,name,adm)

                    if found==True: print "Successfully found",name,"in geofile and updated geocodes in",polity

            
        #update the databse
        if found==True:
            geo_codes=(lat,lon)
            arg_in=geo_codes+bps_codes
            #Update the table with the lat and long information   
            write_SQL(polity,'update',arg_in)
        else:
            print 'Deleting',name,'from',polity
            write_SQL(polity,'delete',bps_codes) 
        
    #update the column index counter
    step += 1

#commit changes
conn.commit()
        
cur.close()
