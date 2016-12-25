#This python script will grab directly from a public website the location codes of indonesian administrative divisions and store them in lists to use in other python scripts.

#################################### Import Libraries ####################################

from bs4 import BeautifulSoup as BS
import re, urllib, os #library is for working with files in different directories
import pickle as p #for pickling the 

########################## Open file or website ##########################################

#Grab data directly from website
host='https://github.com/benangmerah/wilayah/blob/master/datasources/permendagri-18-2013/buku-induk.tabula-processed.csv'

html=urllib.urlopen(host)

################# Set path for pickling the lists scraped from the web ###################

script_dir=os.path.dirname('/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Programming/Python/Course 5 - Capstone/Capstone Project/')

rel_path='source_data/Pickled Data'

abs_path=os.path.join(script_dir, rel_path)

fname=abs_path+'/admin_regions.pkl'

################################ Activate beautiful soup #################################

#Generate the soup: use 'lxml' parser as it is faster
soup=BS(html, "lxml")

################# Grab location codes, fill in missing when appropriate ##################

#Find all the tags that have 'td' in them
tags=soup.find_all('td')

#Initialise dictionaries and lists to store the data. Lists are for storing the raw information to cycle and fill in blanks. I store within the lists tuples (list of location codes, name of location)

prov_codes={}

kab_lst=[]     
kec_lst=[]

######################## Cycle through the tags to grab the codes ########################

for i in range(len(tags)):

    #grab the text from within the hashtags to get the data
    code=tags[i].text

    #the first 'td' tags in any sequence are always empty, skip these
    if code=='': continue
    
    #if the tag has the following text patterns, skip it
    #these are useless identifiers that have no bearing on coded regions
    elif re.search('^"","", \d+|^"", \d+',code): 
        continue
    
    #if the tag has the following, catalog it as a province directly into its dictionary
    elif re.search('^([A-Z]+),',code): 
            
        #split the text to get the components
        prov=code.split(',')
        
        #Get rid of DAISTA from Yogyakarta name, and rename Papua to get rid of spaces
        if re.search('DAISTA',prov[2]): 
            prov[2]=re.sub(u'DAISTA',u'',prov[2]).strip()
        elif re.search('P A P U A',prov[2]): 
            prov[2]=re.sub(u'P A P U A',u'PAPUA',prov[2]).strip()
        elif re.search('^(KEP[.])',prov[2]): 
            prov[2]=re.sub(u'^(KEP[.])',u'Kepulauan',prov[2]).strip()
         
        #Adjust name to add Province to get a correct read from google maps
        prov[2]=prov[2].title()+' Province'
        
        #write into the dictionary the provinces
        prov_codes[prov[2]]=prov[1]
        
    #otherwise, the rest will work to grab the kabupaten and kecamatan codes
    else:
        #split the text to get the components
        sub=code.split(',')
        
        #check that there are no "" in the first position and delete it if there is
        if len(sub)==3: sub=[sub[1],sub[2]]
        
        #make clear: first part is the indonesian code for the location, second is name
        bps_code=sub[0]
        name=sub[1]
        
        #split the textualized code (not the name of the location) for later use
        bps_str=bps_code.split('.')  
         
        ################################ KABUPATENS ##################################### 
        #if the tag has the following it is a kabupatan: place them into the kap list,
        #and fill in missing
        if re.search('KAB|KOTA',code): 
        
            #grab the name of the location (the second component in the list); recall
            #the output of this code is a tuple
            kab_name=re.findall('\s*\d*(KAB .*)|\s*\d*(KAB[.] .*)|\s*\d*(KOTA .*)',name)
            
            #remove the tuple and extract the location name into a one element list
            kab_name=[tuple(j for j in i if j)[-1] for i in kab_name]
            
            #now, fix problematic Kabupatan names
            if re.search('ADM.',kab_name[0]):
                kab_name[0]=re.sub(u'ADM.',u"",kab_name[0]).strip()
            
            elif re.search('LUBUK LINGGAU',kab_name[0]):
                kab_name[0]=re.sub(u'LUBUK LINGGAU',u'LUBUKLINGGAU',kab_name[0])
            
            elif re.search('FAK FAK',kab_name[0]):
            	kab_name[0]=re.sub(u'FAK FAK',u'FAKFAK',kab_name[0])
                
            elif re.search('BOLAANG MONGONDOW',kab_name[0]):
                kab_name[0]=re.sub(u'BOLAANG MONGONDOW TI',u'BOLAANG MONGONDOW TIMUR',kab_name[0]).strip()
                
                kab_name[0]=re.sub(u'BOLAANG MONGONDOW UT',u'BOLAANG MONGONDOW UTARA',kab_name[0]).strip()

                kab_name[0]=re.sub(u'BOLAANG MONGONDOW SE',u'BOLAANG MONGONDOW SELATAN',kab_name[0]).strip()

            elif re.search('PALANGKARAYA',kab_name[0]):
                kab_name[0]=re.sub(u'PALANGKARAYA',u'PALANGKA RAYA',kab_name[0]).strip()
                
            elif re.search('SAWAHLUNTO',kab_name[0]):
                kab_name[0]=re.sub(u'SAWAHLUNTO',u'SAWAH LUNTO',kab_name[0]).strip()
                
            elif re.search('OKU',kab_name[0]):
                kab_name[0]=re.sub(u'OKU SELATAN',u'OGAN KOMERING ULU SELATAN',kab_name[0]).strip()
                
                kab_name[0]=re.sub(u'OKU TIMUR',u'OGAN KOMERING ULU TIMUR',kab_name[0]).strip()
           
            elif re.search('KEP. SIAU TAGULANDANG B',kab_name[0]):
            	kab_name[0]=re.sub(u'KEP. SIAU TAGULANDANG B',u'KEPULAUAN SIAU TAGULANDANG BIARO',kab_name[0])
            
                     
            #Remove the KAB., KAB, and KOTA designations and assign the english versions
            if re.search('^KAB.|^KAB',kab_name[0]):
                kab_name[0]=re.sub(u'^KAB.|^KAB',u"",kab_name[0]).strip()
                kab_name[0]='Kabupaten '+kab_name[0].title()
            elif re.search('^KOTA',kab_name[0]):
                kab_name[0]=re.sub(u'^KOTA',u"",kab_name[0]).strip()
                kab_name[0]=kab_name[0].title()+' City District'
                  
            #check that the kabupatan does not have a missing code
            if bps_code!='""':
                #append to the list
                kab_prev=bps_str
                kab_lst.append((kab_prev,kab_name[0]))
                #keep the current kabupatan in that it needs to be used to update missing
                #data
                
                
            #missing kabupatens, update codes
            else:
                #first, split the text
                #kab_str=kab_prev.split('.')
                #second, take the second number and increment by 1
                increment=int(kab_prev[1])+1
                #third, form the new code by concatenating
                new_code=[kab_prev[0],unicode(str(increment))]
                #finally, replace into the first position
                kab_lst.append((new_code,kab_name[0]))
                #keep the current kabupatan to be used to update missing data
                kab_prev=new_code
    
        ################################## KECAMATANS ####################################
        #grab the kec codes and fill in missing information as needed
        else: 
            #grab the name of the location (the second component in the list): recall this
            #is a list
            kec_name=re.findall('^\s*\d*\s*(.*)',name)
            
            if re.search('Fak-Fak',kec_name[0]):
            	kec_name[0]=re.sub(u'Fak-Fak',u'Fakfak',kec_name[0]).strip()
            
            elif re.search('Kep[.]',kec_name[0]):
                kec_name[0]=re.sub(u'Kep[.]',u'Kepulauan',kec_name[0]).strip()
            	
            #add KEC to the names so that future geo location does not get confused
            kec_name[0]='Kecamatan '+kec_name[0].strip()+', '+kab_name[0]
            
            #append the kec codes but first...... 
            
            #append in if the bps code is not missing
            if bps_code!='""': 
                #append directly
                kec_lst.append((bps_str,kec_name[0].strip()))
                #keep the kec value to help fill in missing code should it be needed
                kec_prev=int(bps_str[-1])
                
            #if the kec codes are missing (starting from when the KAB/KOTA is identified), 
            #fill in the kab code and concatenate by reinitialising kec_prev_int
            elif re.search('KAB|KOTA',tags[i-2].text) and bps_code=='""':
                #initialise kec_prev_int back to 1
                kec_prev=1
                #create the new code using the current kab code, and append
                new_code=kab_prev+[unicode(str(kec_prev))]
                kec_lst.append((new_code,kec_name[0].strip()))
            
            #fill in any successive missing value accordingly
            else:
                #increase the kec code
                kec_prev=kec_prev+1
                #create the new code with the current kab code and append
                new_code=kab_prev+[unicode(str(kec_prev))]
                kec_lst.append((new_code,kec_name[0].strip()))
        
########################### Harmonize up the Papua codes #################################

prov_codes['Papua Province']=u'94'
prov_codes['Papua Barat Province']=u'91'

#Update lists to replace the code
rebar=[kab_lst,kec_lst]
for i in range(len(rebar)):
    for entry in rebar[i]:
        if entry[0][0].startswith(u'91'):
            new_code=re.sub(u'91',unicode('94'),entry[0][0])
            entry[0][0]=str(new_code)
        elif entry[0][0].startswith(u'92'):
            new_code=re.sub(u'92',unicode('91'),entry[0][0])
            entry[0][0]=str(new_code)

#Convert the dictionary to a list of tuples            
prov_lst=[(v,k) for k,v in prov_codes.items()]; del prov_codes

################# Pickle the list and dictonaries for use in later files ################

#Place the province list into rebar for packaging
rebar.insert(0,sorted(prov_lst))

#Pickle the list
fh=open(fname,"w")
p.dump(rebar,fh)
fh.close()
