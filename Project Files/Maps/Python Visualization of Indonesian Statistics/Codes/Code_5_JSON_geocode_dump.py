#This python script will extract the data from IFLS text file to create a new survey table

#################################### Import Libraries ####################################

import sqlite3, re, codecs

################################ Connect to SQLite database ##############################

conn=sqlite3.connect('indonesian_locations.sqlite')
cur=conn.cursor()

############################# Input the age at which to get data #########################

input=raw_input('Please enter if the age is exact (enter 0), "greater than or equal to" (enter 1), or anything to quit: ')
input_2=raw_input('Please enter the age, or any letter/blank to quit: ')

try:
    #test that age is an integer/number
    age=int(input_2)
    #test that an integer/number was entered
    input=int(input)
    if input==0:
        sign='='
        fname=str(age)
    elif input==1:
        sign='>='
        fname='above_'+str(age)
    else:
        quit()
except:
    quit()

############ Query the database to obtain the desired dataset to visualize ###############

# Select from the Kabupaten table the geocodes and the names of the locations, and from the Migration table count all people who have a valid province,kabupaten identifier at age=0 to to obtain the frequencies of locations. Then create a new table that selects only those kabupaten names and geocodes that are located in the migration data. This will be the information that will placed in a json file to visualize in googlemaps.

cur.execute('''
select 
Kabupaten.name,
Kabupaten.lat,
Kabupaten.lon,
count(*) as density
from Migration
inner join Kabupaten on Kabupaten.prov_id=Migration.prov_id and  Kabupaten.id=Migration.kab_id 
where migration.age'''+sign+str(age)+'''
group by 
Migration.prov_id, Migration.kab_id
order by MIgration.prov_id,Migration.kab_id 
''')

############################### Create the JSON output file ##############################

fhand = codecs.open('age_'+fname+'_locations.json','w', "utf-8")

#Start the json list
fhand.write("myData = [\n")

######################## Cycle through rows to write into file ###########################

#for line breaks
count=0

for row in cur:
    
    name=row[0]
    lat=row[1]
    lon=row[2]
    density=row[3]
    
    #create the output string to write into json file
    output="["+str(lat)+","+str(lon)+","+str(density)+",'"+str(name)+"']"
    
    count = count + 1
    
    if count>1: fhand.write(",\n") #write in a line break
    
    #write file
    fhand.write(output)
        
fhand.write("\n];\n")
cur.close()
fhand.close()

print count, "records written to where.json"
print "Open where.html to view the data in a browser"         