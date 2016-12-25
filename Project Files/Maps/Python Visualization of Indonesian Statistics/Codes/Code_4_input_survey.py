#This python script will extract the data from IFLS text file to create a new survey table

#################################### Import Libraries ####################################

import sqlite3, re, os

############################## Set path files and database ###############################

script_dir=os.path.dirname('/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Programming/Python/Course 5 - Capstone/Capstone Project/')

rel_path_data='source_data'
rel_path_database='Final_Databases/Final Usable Database'

abs_path_data=os.path.join(script_dir, rel_path_data)
abs_path_database=os.path.join(script_dir,rel_path_database)

fname_data=abs_path_data+'/migration_data.txt'
fname_database=abs_path_database+'/indonesian_locations_with_geocodes.sqlite'

################################ Connect to SQLite database ##############################

conn=sqlite3.connect(fname_database)
cur=conn.cursor()

############################ Create new tables for the data ##############################

cur.executescript('''
CREATE TABLE IF NOT EXISTS Participants (
    id         INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
    pidlink    TEXT UNIQUE
);  

CREATE TABLE IF NOT EXISTS Migration (
    person_id  INTEGER NOT NULL, 
    age        INTEGER,
    kec_id     INTEGER,
    kab_id     INTEGER,
    prov_id    INTEGER
)
''')

######################### Open a file the text file with the data ########################

fhand=open(fname_data)

############### Cycle through the data and place into the DB table in SQLite #############

for line in fhand:
    
    #parse the string into component parts - delimiter = ;
    line=line.split(';')
    
    #remove the '\n' from the last component
    line[-1]=re.sub(u'\n',"",line[-1])

    pidlink=str(line[0])
    pidlink=pidlink.strip()
    line=line[1:]
    
    #make into integer values the codes; fill in None if empty
    for i in range(len(line)):
        
        try:
            line[i]=int(line[i])
        except:
            line[i]=None
    
    #place data into tables
    
    #place participant into participant tabel and then grab the user id
    cur.execute('''INSERT OR IGNORE INTO Participants (pidlink) 
            VALUES ( ? )''', ( pidlink, ) )
    cur.execute('SELECT id FROM Participants WHERE pidlink = ? ', (pidlink, ))
    person_id=cur.fetchone()[0]
    
    #place data into migration table
    cur.execute('''INSERT INTO Migration (person_id,age,kec_id,kab_id,prov_id)
            VALUES ( ?,?,?,?,? )''', ( person_id, line[0], line[1], line[2], line[3]))
    
conn.commit()
fhand.close()
cur.close()          