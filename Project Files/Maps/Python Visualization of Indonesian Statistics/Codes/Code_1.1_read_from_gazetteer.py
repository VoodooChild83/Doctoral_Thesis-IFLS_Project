#This python script will grab from the gazeteer file all the administration level string 
#data

#################################### Import Libraries ####################################

import re, codecs, os #library is for working with files in different directories

########################## Open file with data ###########################################

#Set the path to the dataset
script_dir=os.path.dirname('/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Programming/Python/Course 5 - Capstone/Capstone Project/')

rel_path_1='source_data/ID'
rel_path_2='source_data'

abs_path_1=os.path.join(script_dir, rel_path_1)
abs_path_2=os.path.join(script_dir, rel_path_2)

fname_1=abs_path_1+'/ID.txt'
features=open(fname_1)

######################## Open files to write in the geonames and codes ###################

fname_2=abs_path_2+'/geonames.txt'
geonames=codecs.open(fname_2,'w', encoding=None)

################## Cycle through the text to grab lines with ADM in them #################

for line in features:

    #look for administrative regions in the line
    if re.search('ADM1|ADM2|ADM3', line):
        
        #Grab up to the part of the string up to the country code (ID) 
        entry=re.findall('^\d*(.*)\s*ID',line)
        
        #from entry grab the string of known names
        names=re.findall('^(\D*\s*)\d+',entry[0])
        
        if re.search("'",names[0]):
            names[0]=re.sub("'","",names[0])

        #grab the geocodes and the administration number (this regex grabs all floating numbers
        #and/or integers)
        geocodes=re.findall('[-+]?\d*[.]*\d+',entry[0])
        
        #if the length of the geocodes list is more than 3 then we only want only the last 
        #three entries (lat, long, admin level)
        if len(geocodes)>3:
            geocodes=geocodes[-3:]
            
        #write the entry into the text file as a list so that we can read it later (since the names of places 
        #have the string designator - apostrophe - within it, use quotes within the string constructor to keep
        #designate items as strings that may contain apostrophes in them (doing this in the opposite way will 
        #string syntax issues, since the ' within a place name will lead to a perception that a string is there))
        output='["'+names[0].strip()+'",['+geocodes[0]+','+geocodes[1]+'],"'+geocodes[2]+'"]'+"\n"

        #write into the corresponding file
        geonames.write(output)	

    else: continue
	
geonames.close()		
