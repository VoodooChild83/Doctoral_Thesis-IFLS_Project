// Building of the Dataset - Roster and Demographic observables

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************

use "$maindir$wave_5/ptrack.dta", clear

drop *98* ar02_07

* Clean person weights in seperate file
preserve
qui do "$maindir$project$Do/Master Tracker of individuals/Master Track Cleaner - Person Weights.do"
restore

* keep only desired variables
keep pidlink hhid* pid* sex ar01a* ar02* member* mainresp* msured93970007 cov8b5 bth_year age_*
drop hhid14_* ar02_14
* Merge in the person weights

*three multiple pidlinks.....drop one of the duplicates
bys pidlink: drop if _n>1

merge 1:1 pidlink using "$maindir$tmp/Person Longitudinal Weights.dta", nogen
erase "$maindir$tmp/Person Longitudinal Weights.dta"

// 1) Order the data to collect values that are necessary

order pidlink hhid14 pid14 hhid07 pid07 hhid00 pid00 hhid97 pid97 hhid93 pid93 sex ar01a_14 ar02b_14 ar01a_07 ar02b_07 ar01a_00 ar02b_00 ar01a_97 ar02_97 ar02_93 member14 member07 member00 member97 member93

// label all variables from the codebook labels. Define Labels

label define male 1 "male" 3 "female" 		// sex label for: SEX

#delimit ;
label define liveinhh 0 "Dead"   			//living in hh label for: ar01a_xx (xx is year)                              
                   	1 "Yes = in HH"                                      
                   	2 "ART comeback"                             
                   	3 "No = not in HH"                                      
                   	5 "New HH mem"                  
                   	6 "Duplicate"                                    
                   	11 "Yes = ent aft Int" ;

label define relation 1 "Head of the household"                     
                      2 "Husband/wife"                               
                   	  3 "Child (biological)"                      
                   	  4 "Child (step/adopted)"                    
                   	  5 "Sons/daught-in-law"                     
                  	  6 "Parents"                                     
                   	  7 "dad/mom-in-law"                      
                  	  8 "Siblings"                                    
                  	  9 "Bro/sis-in-law"                      
                 	  10 "Grandchild"                               
                 	  11 "Grandparents"                                
                  	  12 "Uncles/aunts"                                
                  	  13 "Nephews/nieces"                            
                  	  14 "Cousins"                                     
                  	  15 "Servants"                                   
                   	  16 "Relative"                                    
                 	  17 "Non-relative"                               
                 	  18 "Tenant"                                   
                   	  19 "Friend"                                      
                      21 "Ex spouse"                                   
                      22 "Family of Ex spouse"                          
                      99 "Missing"; 
                          
label define resident 0 "No = not res" 1 "Yes = Res";

label define childrelation 1 "mother"                                   
                   		   2 "father"                                     
                	       3 "sibling"                                     
                		   4 "aunt/uncle"                                   
              		       5 "grandparent"                                  
              		       6 "child him/herself";    
              		       
label define mainresp 0 "No = Not Main Res" 1 "Yes = Main Resp"; 

label define measured 0 "No = Not Measured" 1 "Yes = Measured";          		               

#delimit cr         

// Apply Labels

label values sex male

label values ar01a_14 ar01a_97 ar01a_00 ar01a_07 liveinhh

label values ar02b_14 ar02b_07 ar02b_00 ar02_97 ar02_93 relation

label values member14 member93 member97 member00 member07 resident

label values cov8b5 childrelation

label values mainresp07 mainresp

label values msured93970007 measured

*save "$maindir$project/MasterTrack.dta", replace
********************************************************************************

// 2) Merge the HH urban/rural indicator variable for each wave

// Open all relevant files first
preserve
use "$maindir$wave_5/bk_sc1.dta", clear
use "$maindir$wave_4/bk_sc.dta", clear
use "$maindir$wave_3/bk_sc.dta", clear
use "$maindir$wave_2/hh97bk/bk_sc.dta", clear
drop version
save "$maindir$tmp/bk_sc_97.dta"
use "$maindir$wave_1/bukksc1.dta", clear
restore


// Note: for this variable (sc05) coming from the sc module the unique identifier is the hhid of the wave year since this is a household level observation

// Merge Fifth Wave
merge m:1 hhid14 using "$maindir$wave_5/bk_sc1.dta", keepusing(sc05 sc01* sc02* sc03*) keep(1 3) nogen

rename (sc05 sc01_14_14 sc02_14_14 sc03_14_14) (sc05_14 sc01_14 sc02_14 sc03_14)
label variable sc05_14 "Urban/Rural (2014)"


// Merge Fourth Wave
merge m:1 hhid07 using "$maindir$wave_4/bk_sc.dta", keepusing(sc05 sc010707 sc020707 sc030707) keep(1 3) nogen

rename (sc05 sc010707 sc020707 sc030707) (sc05_07 sc01_07 sc02_07 sc03_07)
label variable sc05_07 "Urban/Rural (2007)"

*save "$maindir$project/MasterTrack.dta", replace


// Merge Third Wave
merge m:1 hhid00 using "$maindir$wave_3/bk_sc.dta", keepusing(sc01 sc02 sc03 sc05) keep(1 3) nogen

rename (sc01 sc02 sc03 sc05) (sc01_00 sc02_00 sc03_00 sc05_00)
label variable sc05_00 "Urban/Rural (2000)"

*save "$maindir$project/MasterTrack.dta", replace


// Merge Second Wave
merge m:1 hhid97 using "$maindir$tmp/bk_sc_97.dta", keepusing(sc01 sc02 sc03 sc05) keep(1 3) nogen

rename (sc01 sc02 sc03 sc05) (sc01_97 sc02_97 sc03_97 sc05_97)
label variable sc05_97 "Urban/Rural (2000)"

*save "$maindir$project/MasterTrack.dta", replace

erase "$maindir$tmp/bk_sc_97.dta"


//Merge First Wave
merge m:1 hhid93 using "$maindir$wave_1/bukksc1.dta", keepusing(sc01 sc02 sc03 sc05) keep(1 3) nogen

rename (sc01 sc02 sc03 sc05) (sc01_93 sc02_93 sc03_93 sc05_93)
label variable sc05_93 "Urban/Rural (2000)"

label values sc05_07 sc05_00 sc05_93 sc05_97 sc05_14

*save "$maindir$project/MasterTrack.dta", replace


********************************************************************************

// 5) Rename variable in preperation for reshape 

// First, rename variable to generate common suffixes related to wave years

rename hhid14 hhid2014
rename pid14 pid2014
rename hhid07 hhid2007
rename pid07 pid2007
rename hhid00 hhid2000
rename pid00 pid2000
rename hhid97 hhid1997
rename pid97 pid1997
rename hhid93 hhid1993
rename pid93 pid1993
rename ar01a_14 ar01a2014
rename ar02b_14 ar02b2014
rename ar01a_07 ar01a2007
rename ar02b_07 ar02b2007
rename ar01a_00 ar01a2000
rename ar02b_00 ar02b2000
rename ar01a_97 ar01a1997
rename ar02_97 ar02b1997
rename ar02_93 ar02b1993
rename member14 member2014
rename member07 member2007
rename member00 member2000
rename member97 member1997
rename member93 member1993
rename sc05_14 sc052014
rename sc05_07 sc052007
rename sc05_00 sc052000
rename sc05_97 sc051997
rename sc05_93 sc051993
rename sc01_93 provmov1993
rename sc02_93 kabmov1993
rename sc03_93 kecmov1993
rename sc01_97 provmov1997
rename sc02_97 kabmov1997
rename sc03_97 kecmov1997
rename sc01_00 provmov2000
rename sc02_00 kabmov2000
rename sc03_00 kecmov2000
rename sc01_07 provmov2007
rename sc02_07 kabmov2007
rename sc03_07 kecmov2007
rename sc01_14 provmov2014
rename sc02_14 kabmov2014
rename sc03_14 kecmov2014
rename age_00 age2000
rename age_93 age1993
rename age_97 age1997
rename age_07 age2007
rename age_14 age2014


********************************************************************************

// 6) Merge Variables from the Roster Module (bkAR1)

// 1993 wave

preserve

use "$maindir$wave_1/bukkar2.dta", clear

rename hhid93 hhid1993
rename pid93 pid1993
rename ar18 ar18c

foreach x in ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18c {

		rename `x' `x'1993
		}

save "$maindir$tmp/bk_ar1_1993.dta", replace

// 1997 wave

use "$maindir$wave_2/hh97bk/bk_ar1.dta", clear
drop version

foreach x in hhid pid ar18h ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18c ar18eyr ar18f ar18i{

		rename `x' `x'1997
		}


save "$maindir$tmp/bk_ar1_1997.dta", replace

// 2000 wave

use "$maindir$wave_3/bk_ar1.dta", clear

rename hhid00 hhid2000
rename pid00 pid2000

foreach x in ar18h ar10 ar11 ar12 ar13 ar14 ar15 ar16 ar17 ar18c ar18eyr ar18f ar18i{

		rename `x' `x'2000
		}

save "$maindir$tmp/bk_ar1_2000.dta", replace

// 2007 wave

use "$maindir$wave_4/bk_ar1.dta", clear

// rewrite key variables by wave years to facilitate merging in long format

rename hhid07 hhid2007
rename pid07 pid2007

foreach x in ar18h ar10 ar11 ar12 ar13 ar14 ar15 ar15d ar16 ar17 ar18c ar18eyr ar18f ar18i{

		rename `x' `x'2007
		}
		

save "$maindir$tmp/bk_ar1_2007.dta", replace

// 2014 wave

use "$maindir$wave_5/bk_ar1.dta", clear

// rewrite key variables by wave years to facilitate merging in long format

rename hhid14 hhid2014
rename pid14 pid2014

foreach x in ar18h ar10 ar11 ar12 ar13 ar14 ar15 ar15d ar16 ar17 ar18c ar18eyr ar18f ar18i{

		rename `x' `x'2014
		}
		

save "$maindir$tmp/bk_ar1_2014.dta", replace

restore

// Merge Education and other Familial Identifiers from the previous temp files

foreach year in 1993 1997 2000 2007 2014{

	merge 1:1 pidlink hhid`year' pid`year' using "$maindir$tmp/bk_ar1_`year'.dta", keepusing(*`year') keep(1 3) nogen
	erase "$maindir$tmp/bk_ar1_`year'.dta"

}

********************************************************************************

// Merge the information from the HTRACK files contained in the mover variable and the comm variable

// 1993 htrack from 1997htrack

preserve

use "$maindir$wave_2/hh97bk/htrack.dta", clear

keep hhid93 commid93
 
rename (hhid93 commid93) (hhid1993 commid1993) 

destring hhid1993, gen(hhid1993_2) force

drop if hhid1993_2==.
drop hhid1993_2

sort hhid1993

save "$maindir$tmp/htrack1993.dta", replace

// 1997 htrack

use "$maindir$wave_2/hh97bk/htrack.dta",clear

keep hhid97 commid97 mover97

rename (hhid97 commid97 mover97) (hhid1997 commid1997 mover1997) 

sort hhid1997

save "$maindir$tmp/htrack1997.dta", replace

// 2000 htrack

use "$maindir$wave_3/htrack.dta", clear

keep hhid00_9 commid00  mover00

rename (hhid00_9 commid00 mover00) ( hhid2000 commid2000 mover2000)  

destring hhid2000, gen(hhid2000_2) force

drop if hhid2000_2==.
drop hhid2000_2

sort hhid2000

save "$maindir$tmp/htrack2000.dta", replace

//2007 htrack

use "$maindir$wave_4/htrack.dta", clear

keep hhid07 commid07 mover07

rename (hhid07 commid07 mover07) (hhid2007 commid2007 mover2007)

destring hhid2007, gen(hhid2007_2) force

drop if hhid2007_2==.
drop hhid2007_2

sort hhid2007

save "$maindir$tmp/htrack2007.dta", replace

//2014 htrack

use "$maindir$wave_5/htrack.dta", clear

keep hhid14 commid14 mover14

rename (hhid14 commid14 mover14) (hhid2014 commid2014 mover2014)

destring hhid2014, gen(hhid2014_2) force

drop if hhid2014_2==.
drop hhid2014_2

sort hhid2014

save "$maindir$tmp/htrack2014.dta", replace

restore

// Merge the data

*use "$maindir$project/MasterTrack1.dta"

foreach year in 1993 1997 2000 2007 2014{
    
    sort hhid`year'
	
	merge m:1 hhid`year' using "$maindir$tmp/htrack`year'.dta", keep(1 3) nogen
	
	erase "$maindir$tmp/htrack`year'.dta"
	}
	
********************************************************************************
// Append the IFLS East Master Tracker Information

preserve
	qui do "$maindir$project$Do/IFLS_East/IFLS East Master.do"
restore

append using "$maindir$tmp/IFLS_East/Master_Track_IFLS_East.dta"
erase "$maindir$tmp/IFLS_East/Master_Track_IFLS_East.dta"
********************************************************************************
// Reshape data into long format

reshape long hhid@ pwt@ commid@ mover@ pid@ age@ ar01a@ ar02b@ member@ sc05@ provmov@ kabmov@ kecmov@ ar18h@ ar10@ ar11@ ar12@ ar13@ ar14@ ar15@ ar15d@ ar16@ ar17@ ar18c@ ar18eyr@ ar18f@ ar18i@, i(pidlink) j(wave)

sort pidlink wave

order pidlink wave pwt hhid commid pid mover

********************************************************************************
// Incorporate birth year and age information	

preserve
	quietly do "$maindir$project$Do/Birthday Cleaning.do"
restore

	//merge in the birth year and age data

	merge m:1 pidlink using "$maindir$project/birthyear.dta", keep(1 3) nogen
	sort pidlink wave
	
	* Clean up Birth Year

	by pidlink: egen BirthYr1=max(birthyr)
	
	replace birthyr=BirthYr1 if birthyr==.
	drop BirthYr1
	
	replace birthyr=bth_year if birthyr==. // replace with the last observed one in 2014 ptrack
	drop bth_year

	* Correct Age
	gen flag_ImpAge=1 if abs((birthyr+age)-wave)>1 & age!=.  // 1 = Age Corrected; 0 = Age Imputed
	* Impute missing Ages that did not require a correction
	replace flag_ImpAge=0 if age==. & ar01a!=0 & ar01a!=.
	
	replace age=wave-birthyr if flag_ImpAge!=.
	
order pidlink-mover birthyr age flag_ImpAge

********************************************************************************
// Label the data

// recode 1993 school level for kindergarten from 11 to 90

recode ar16 11=90 if wave==1993

label drop AR16

// Label the Levels of schooling

#delimit ;
label define schoollevel 1 "1=Unschooled"                                
                   		 2 "2=Grade school"                             
                         3 "3=General jr. high"                          
                   	     4 "4=Vocational jr. high"                         
                         5 "5=General sr. high (SLA)"                    
                         6 "6=Vocational sr. high (SMK)"
						 7 "7=Diploma (D1,D2)-1993,1997 wave"
						 8 "8=Diploma (D3)-1993,1997 wave"
						 9 "9=University (BA/MA/PhD)-1993,1997 wave"
						 10 "10=Other, specify"
                         11 "11=Education A"                                
                         12 "12=Education B"                                
                         13 "13=Open University"                             
                         14 "14=Moslem School (Pesantren)"                  
                         15 "15=Education C"                                
                         17 "17=School for the disabled"                    
                         60 "60=Diploma (D1,D2,D3)"                      
                         61 "61=University S1"                            
                         62 "62=University S2"                              
                         63 "63=University S3" 
						 70 "70=Islamic Madrasah, general"
                         72 "72=Islamic grade school" 
                         73 "73=Islamic jr. high"                      
                         74 "74=Islamic sr. high1"
                         90 "90=Kindergarten"                               
                         95 "95=Other, specify"                            
                         98 "98=Don't know"                                
                         99 "99=Missing";

label define MoverStat   0 "did not move"                               
                   		 1 "within same desa"                             
                   		 2 "within same kec."                          
                         3 "within same kab."                            
                         4 "within same prov."                         
                         5 "other IFLS prov."                           
                         6 "other prov."
                         98 "missing";
                         
label define ParentStat  51 "Out of HH"
						 52 "Dead";

label define Marriage    1 "Unmarried"                                
                   		 2 "Married"                                 
                   		 3 "Separated, estranged"                        
                   		 4 "Divorced"                                
                   		 5 "Widow, widower"                          
                   		 8 "Don't know"                                 
                   		 9 "Missing";
                   		 
label define InSch	     1 "Yes"                                     
                   		 3 "No"                                       
                   		 6 "Not yet in school/Not Applicable"
                   		 9 "Missing";                  	
                   		 
#delimit cr                         

label values ar16 schoollevel
label values mover MoverStat
label values ar10 ParentStat
label values ar11 ParentStat
label values ar12 ParentStat
label values ar13 Marriage
label values ar18c InSch

********************************************************************************
* Recode all provinces to 1993 codes

recode provmov (94=91) (82=81) (36=32) (20 21=14) (75=71) (19=16) (76=73) (65=64)

********************************************************************************
// destring pidlink
// There is slight problem that pidlink cannot be destringed because 24 observations have non-numeric pidlinks. For this purpose, the following code generates a flag that identifies these
// observations:

*generate byte non_numeric_pidlink = indexnot(pidlink, "0123456789.-")
*list pidlink if non_numeric_pidlink // if non_numeric_pidlink>0 then there is an observation that cannot be destringed.

gen double pidlink2= real(pidlink)
		format pidlink2 %12.0f
		
destring hhid, gen(hhid2) force

egen newid=group(pidlink2) // create an ID for each pidlink (first id level)
egen newhhid=group(hhid2)

sort pidlink2 wave

by pidlink2: gen survey=_n // count the survey observations for each pidlink (second id level)

// Sorted to look like CPS data
order newid newhhid pid pidlink pidlink2 survey wave
sort newhhid newid survey wave pid pidlink pidlink2 


// Flag the last wave of survey a person was recorded in:

bysort pidlink2: egen LastWave=max(survey) if pid!=. & ar01a!=0 & pidlink2!=.

gen flag_LastWave=1 if survey==LastWave

by pidlink2: egen flag_LastWave_tally=sum(flag_LastWave) if pidlink2!=. // find the missing people that flag_LastWave did not pick up (not including the 6 non-numeric pidlink people this is 170 people)

by pidlink2: egen LastWave_dead=max(survey) if flag_LastWave_tally==0

gen flag_LastWave_dead=1 if survey==LastWave_dead

egen flag_LastWave2=rsum(flag_LastWave flag_LastWave_dead), missing

drop flag_LastWave flag_LastWave_dead flag_LastWave_tally LastWave

rename flag_LastWave2 flag_LastWave

order newid newhhid pid pidlink pidlink2 survey wave flag_LastWave LastWave_dead
sort newhhid newid survey wave pid pidlink pidlink2 

********************************************************************************
// Generate Educational attainment years

// Primary education and no schooling:

gen primary=ar17 if (ar16==2 | ar16==72) & !(ar17>=96 | ar17==7) //Here, give in level of primary schooling variable total years
replace primary=0 if ar16==1 | ((ar16==2 | ar16==72) & ar17==96) | ar16==90 //For "No Schooling"; and since 96 codes as no years add for both 0 years
replace primary=6 if (ar16==2 | ar16==72) & ar17==7 //For those who have graduated, replace code 7 (graduated) with 6 (total possible years in the school)

// Junior High School

replace primary=6 if (ar16==3 | ar16==4 | ar16==73) //Backwards replace Primary Schooling with 6 years if the person is already in Junior High School
gen junior=ar17 if (ar16==3 | ar16==4 | ar16==73) & !(ar17>=96 | ar17==7)  //Here, place in level of junior high the schooling years
replace junior=0 if (ar16==3 | ar16==4 | ar16==73) & ar17==96 //For those who have not yet completed any years of schooling at this level but are in that level
replace junior=3 if (ar16==3 | ar16==4 | ar16==73) & ar17==7 //Those who graduated get the full 3 years of possible education

// Secondary Education

replace primary=6 if (ar16==5 | ar16==6 | ar16==74) //Backwards replace Primary Schooling with full years for those in high school
replace junior=3 if (ar16==5 | ar16==6 | ar16==74) //Backwards replace Junior High with full years for those in high school
gen high=ar17 if (ar16==5 | ar16==6 | ar16==74) & !(ar17>=96 | ar17==7) //Here, place in level of high school total years completed
replace high=0 if (ar16==5 | ar16==6 | ar16==74) & ar17==96 //No years of schooling at this level
replace high=3 if (ar16==5 | ar16==6 | ar16==74) & ar17==7 // Graduates of high school

// Higher Education: The purpose of this is to construct the final years of pre-tertiary schooling for those who are or have some form of tertiary education.

replace primary=6 if (ar16>=60 & ar16<=63) | (ar16>=7 & ar16<=9) | (ar16==13)
replace junior=3 if (ar16>=60 & ar16<=63) | (ar16>=7 & ar16<=9) | (ar16==13)
replace high=3 if (ar16>=60 & ar16<=63) | (ar16>=7 & ar16<=9) | (ar16==13)

// sum up the years of education

egen SchYrs=rsum(primary junior high), missing 

drop primary - high

// Classify School Levels in like groups:

gen SchLevel=.

replace SchLevel=-1 if ar16==1						// No Schooling
replace SchLevel=0 if ar16==90						// Kinder
replace SchLevel=1 if ar16==2|ar16==72				// Grade School
replace SchLevel=2 if ar16==3|ar16==4|ar16==73 	 	// Middle School
replace SchLevel=3 if ar16==5|ar16==6|ar16==74 		// High School
replace SchLevel=4 if ar16==7|ar16==8|ar16==60 		// Associates
replace SchLevel=5 if ar16==9|ar16==13|ar16==61 	// University (Bacehlor's level)
replace SchLevel=6 if ar16==62 						// University (Master's level)
replace SchLevel=7 if ar16==63 						// University (Doctoral level)

********************************************************************************

// Quick and Dirty method:
// Consider maximum educational attainment as that observed in the last wave in 
// which a person was observed.

gen MaxSchYrs=SchYrs if flag_LastWave==1
gen MaxSchLvl=SchLevel if flag_LastWave==1
replace MaxSchLvl=. if MaxSchYrs==.   // to maintain consistency between available information

********************************************************************************
//Identify Schooling

// Flag for those that are 5 years of age and younger:
// flag_NotInSch=1 if they are conceivably not in school 
// flag_NotInSch=0 if there is an inconsistency in the school level/year combination (such as being age 5 or younger and in highschool)
// flag_Kindergarten=1 if there they are currently in Kindergarten
// flag_Less5Done=1 if there are children less than or equal to 5 years old who are reported as seemingly no longer being educated

gen flag_NotInSch=1 if age<=5 & flag_LastWave==1 & !(MaxSchLvl>=0) & ar18c==6 // kids that are concievably not in school - either kinder or grade school - and who have code ar18c=6 meaning school not applicable to them
replace flag_NotInSch=0 if age<=5 & flag_LastWave==1 & MaxSchLvl>=0 & MaxSchYrs>0 // A 0 indicates that observations are inconsistent

gen flag_Kinder=1 if age<=5 & MaxSchLvl==0 & ar18c==1 // by including the 'ar18c==1' code I drop many observations that would be included if this was simply 
replace flag_Kinder=0 if age<=5 & MaxSchLvl==0 & ar18c==6 // include those who have a code 6 - this indication has an ambiguous meaning 

gen flag_Age5GradeSch=1 if age==5 & flag_LastWave==1 & MaxSchLvl==1 & !(MaxSchYrs>2) & ar18c==1
replace flag_Age5GradeSch=0 if age<5 & flag_LastWave==1 & MaxSchLvl==1 & !(MaxSchYrs>2) & ar18c==1 // Consistency checks on people who are younger than 5 and going to school above 1 school year
replace flag_Age5GradeSch=0 if age<5 & flag_LastWave==1 & MaxSchLvl==1 & MaxSchYrs>=2 & ar18c==1   // and consistency check on those who are younger than 5 and somehow have grade 2 and higher attainment

gen flag_Less5Done=1 if flag_LastWave==1 & ar18c==3 & (age<=5) // Consistency check on those who are age 5 or younger and seemingly coded as done with school


// Flag for those currently going to school

gen flag_InSch=1 if age>5 & MaxSchLvl>=0 & ar18c==1 & flag_LastWave==1
replace flag_InSch=0 if flag_InSch==1 & (MaxSchLvl==. | age==.) // These people are in "nonconventional" education coded with 0

// Flags identifying specific groups going to school

gen flag_InKinder=1 if flag_InSch==1 & MaxSchLvl==0

gen flag_InGradeSch=1 if flag_InSch==1 & (age>=6 & age<=12) & MaxSchLvl==1
replace flag_InGradeSch=0 if flag_InSch==1 & age>12 & MaxSchLvl==1 // Consistency check: all those who are older than 12 and likely should not be in this school level
gen flag_Marginal_13=1 if flag_InGradeSch==0 & age==13 // Capture those who may be marginal at the age-level cutoff

gen flag_InMidSch=1 if flag_InSch==1 & (age>=12 & age<=15) & MaxSchLvl==2
replace flag_InMidSch=0 if flag_InSch==1 & (age>15 & age<12) & MaxSchLvl==2 // Consistency check: all those who are aloder than 15 or younger than 12 and likely should not be in this school level
gen flag_Marginal_16=1 if flag_InMidSch==0 & age==16 			 // Capture those who may be marginal at the age-level cutoff

gen flag_InHiSch=1 if flag_InSch==1 & (age>=15 & age<=18) & MaxSchLvl==3
replace flag_InHiSch=0 if flag_InSch==1 & (age>18 & age<15) & MaxSchLvl==3 // Consistency check for those with ages that are inplausible for them to be in this level
gen flag_Marginal_19=1 if flag_InHiSch==0 & age==19

gen flag_InColl=1 if flag_InSch==1 & age>=18 & MaxSchLvl>3
replace flag_InColl=0 if flag_InSch==1 & age<18 & MaxSchLvl>3 // Consistency check on those who are plausibly not able to be in college given reported ages

// Optional code that recodes flag_InSch=2 for all those with inconsistencies in above groupings:

	replace flag_InSch=2 if flag_InGradeSch==0 | flag_InMidSch==0 | flag_InHiSch==0 | flag_InColl==0

// Flags for those who are done with School

gen flag_OutSch=1 if flag_LastWave==1 & (ar18c==3 | (age>=15 & (ar18c==.| ar18c==6))) & !(age<=5) // Don't include people below age 5 (who would normally not have entered the educational system except unless they are marginal age 5 cases - those below age 5 and done are included in the above flag_Less5Done
replace flag_OutSch=0 if flag_OutSch==1 & (MaxSchLvl==. | age==. | MaxSchYrs==.) 				  // A consistency check for those who have either missing information or non-conventional educational attainment

//School level adjustment for those who are in or have finished college - Give them 13 years of education

	* Find those who have done college (even if perhaps not finished)
		gen flag_OutSch_Coll=1 if flag_OutSch==1 & MaxSchLvl>3
		replace flag_OutSch_Coll=0 if flag_OutSch==1 & MaxSchLvl<=3

	* Replace Sch Yrs for those with college to 13 (13+ years)
		replace MaxSchYrs=13 if flag_OutSch_Coll==1 | flag_InColl==1

gen flag_OutSch_Code=0 if flag_OutSch==1 & ar18c==3
replace flag_OutSch_Code=1 if flag_OutSch==1 & ar18c==.
replace flag_OutSch_Code=2 if flag_OutSch==1 & ar18c==6

// Flag for those who are done with school upto and including secondary education (may still be going to school, but then they are in college)

gen flag_Secondary=1 if flag_LastWave==1 & (flag_OutSch==1| flag_InColl==1 | (flag_InHiSch==1 & ar17==7))

// Identifying the Resididual Individuals not classified

/* 
There are five flag categories that can be used to count if individuals have been identified in the survey with educational attainment:
1) flag_NotInSch - identifies those that are not in school: 1 is a valid observation, 0 is an inconsistency with regard to age and school level and/or school years
2) flag_Kinder - those who are age<=5 and attending kinder according to ar18c code: 1 is valid attending, 0 is those where ar18c is coded 6 (no necessary invalid)
3) flag_InSch - those who are in school age>5: 1 is a valid observation based on age rules, 0 is an invalid observation based on missing data, 2 is an inconsistency based on consistency checks of the subgroupings (ages inconsistent with schooling attainment)
4) flag_Age5GradeSch - those children age 5 who are in grade school (the lower marginal count on entrance)
5) flag_OutSch - those are plausibly out of school based on coding of ar18c and/or age: 1 is plausibly consistent code, 0 is a consistency check based on missing information
6) flag_Less5done - those who are age<=5 and have been coded as done with school (not that many): is a consistency check since these may have been a miscoding
*/

gen flag_IdentEduc=1 if flag_LastWave==1 & (flag_OutSch!=. | flag_InSch!=. | flag_NotInSch!=. | flag_Kinder!=. | flag_Age5GradeSch!=. | flag_Less5Done!=.)
replace flag_IdentEduc=0 if flag_LastWave==1 & flag_IdentEduc!=1 // 1=classified education (even with inconsistencies), 0=unclassifiable 

********************************************************************************

// Prepare for merging of migration information

// Family Member Relationship

// Since I care about the educational attainment of children when parents migrate I need to start identifying those people who 
// have parents and have parents in the household. The main issue is that I have to consider those who have finished school. But
// they have parents who may not be in the same household as they are.

gen Offspring=1 if ar02b==3 & flag_LastWave==1

gen Offspring_Parent=1 if Offspring==1 & (ar10<51 | ar11<51)     // this captures when either parent is in the HH
replace Offspring_Parent=0 if Offspring==1 & (ar10<51 & ar11<51) // this captures when both parents are in the HH

/* Note: the above code is constrained by the fact that when ar02b==3 it is in relation to the HH. This implies
that this code finds a weak subset of those individuals who are a biological child of the Head of Household (HH).
A robustness check should find those children whose parents are also in the household but not the Head of Household

ar02b=10 is a grandchild
ar02b=13 is a nephew/niece
ar02b=14 is a cousin
*/

gen Offspring2=1 if (ar02b==10|ar02b==13|ar02b==14) & flag_LastWave==1

gen Offspring2_Parent=1 if Offspring2==1 & (ar10<51 | ar11<51)		// If at least one parent in the house
replace Offspring2_Parent=0 if Offspring2==1 & (ar10<51 & ar11<51)	// If both parents are in the survey and in the house

// Generate a flag that identifies the available parent/child relationships that can be used when merging the migration dataset for the correlation

gen Parent_Child=1 if (Offspring_Parent==1 | Offspring2_Parent==1) & flag_Secondary==1 // At least one parent in household
replace Parent_Child=0 if (Offspring_Parent==0 | Offspring2_Parent==0) & flag_Secondary==1 // Both parents in household

********************************************************************************

// A very wrong way to use the 'mover' variable:
* Use mover to find the maximum migration event of households and last wave observation schooling

bysort pidlink2: egen MaxMig=max(mover) if mover>0 & mover<=6

by pidlink2: egen flag_MaxMig=max(MaxMig)

gen flag_MaxMig2=1 if flag_LastWave==1 & flag_MaxMig!=.
replace flag_MaxMig2=0 if flag_LastWave==1 & flag_MaxMig==.

drop flag_MaxMig
rename flag_MaxMig2 flag_MaxMig

********************************************************************************
// Person Weight Correction

bysort pidlink (wave): egen pwt_max=max(pwt)

replace pwt=pwt_max if flag_LastWave==1
replace pwt=. if flag_LastWave!=1
drop pwt_max 

********************************************************************************

save "$maindir$project/MasterTrack2.dta", replace


/* (currently held as a block)

// The below code is an attempt at finding the maximum schooling of individuals based on
// two methods: using the mode of the most observed school levels; and then using the highest school
// level observed for each individuals. The purpose of mode is to capture the most frequently coded
// level for those that may present an inconsistency in their coding across waves. The purpose of max 
// is to capture the highest level for those (usually young people) who are going to school during the survey.

// The two methods need to be reconciled as the mode method will not properly capture the proper schooling attainment
// for those who are young or actively going to school during survey observation, who may thus present repeated schooling levels
// in earlier waves; but the final (2007) wave shows an increase. The mode will not work to capture these instances but 
// the max method will. 

// The mode method

by pidlink2: egen MaxLevel=mode(SchLevel) if pid!=. & ar01a!=0 & pidlink2!=., max // This will find the most frequently surveyed school level, but if there are four unique observations it will choose the highest.

by pidlink2: egen MaxYrs=mode(SchYrs) if pid!=. & ar01a!=0, max

gen flag_MaxSch=1 if MaxLevel==SchLevel & MaxYrs==SchYrs & MaxYrs!=. & MaxLevel!=. & pidlink2!=.

by pidlink2: gen flag_MaxSchooling=_n if flag_MaxSch!=. & pidlink2!=.

by pidlink2: egen flag_MaxSchooling2=max(flag_MaxSchooling) 

gen flag_MaxSchooling3=1 if flag_MaxSchooling2==flag_MaxSchooling & flag_MaxSchooling2!=. & flag_MaxSchooling!=. & pidlink2!=.

gen MaxSchYrs_mode=SchYrs if flag_MaxSchooling3==1 
gen MaxLevel_mode=SchLevel if flag_MaxSchooling3==1

drop MaxLevel MaxYrs flag_MaxSch flag_MaxSchooling flag_MaxSchooling2

rename flag_MaxSchooling3 flag_MaxSchooling_mode

// People who were not collected with max schooling algorithm

by pidlink2: egen flag_MissingSchooling_mode=max(flag_MaxSchooling_mode) if pidlink2!=. // if the flag==. then the people where not captured by the algorithm

// This new algorithm attempts the above with the 'max' function instead of the mode (since the mode will fail to actually capture the people who have school levels
// that are weakly increasing monotonically 

by pidlink2: egen MaxLevel=max(SchLevel) if pid!=. & ar01a!=0 & pidlink2!=. // This will find the most frequently surveyed school level, but if there are four unique observations it will choose the highest.

by pidlink2: egen MaxYrs=max(SchYrs) if pid!=. & ar01a!=0

gen flag_MaxSch=1 if MaxLevel==SchLevel & MaxYrs==SchYrs & MaxYrs!=. & MaxLevel!=. & pidlink2!=.

by pidlink2: gen flag_MaxSchooling=_n if flag_MaxSch!=. & pidlink2!=.

by pidlink2: egen flag_MaxSchooling2=max(flag_MaxSchooling) 

gen flag_MaxSchooling3=1 if flag_MaxSchooling2==flag_MaxSchooling & flag_MaxSchooling2!=. & flag_MaxSchooling!=. & pidlink2!=.

gen MaxSchYrs_max=SchYrs if flag_MaxSchooling3==1 
gen MaxLevel_max=SchLevel if flag_MaxSchooling3==1

drop MaxLevel MaxYrs flag_MaxSch flag_MaxSchooling flag_MaxSchooling2

rename flag_MaxSchooling3 flag_MaxSchooling_max

// People who were not collected with max schooling algorithm

by pidlink2: egen flag_MissingSchooling_max=max(flag_MaxSchooling_max) if pidlink2!=. // if the flag==. then the people where not captured by the algorithm

// Combine the results: Collect the people who were not collected by one of the two algorithms. 

********************************************************************************

// Flag 1: Identify the individuals who have completed high school, but have not gone to college

gen flag_college=0 if flag_MaxSchYrs==1 & ((ar16>=60 & ar16<=63) | (ar16>=7 & ar16<=9))

// Flag 2: Find all those who have actually finished school 

// Adults who finished school as of Wave 4:

gen flag_adults=1 if age>18 & flag_MaxSchYrs==1

gen flag_adults_SchDone=1 if flag_adults==1 & ar18c!=1

gen flag_adults_CollDone=1 if flag_adults==1 & ar18c!=1 & flag_college==1

// Nonconventional educational levels:

by pidlink2: egen flag_nonconeduc=0 if 

*/

********************************************************************************
/* test school years from b3a_dl4 book


destring pidlink, gen(pidlink2)

sort pidlink2 dl4type

by pidlink2: egen MaxObs=max(dl4type)
by pidlink2: egen MinObs=min(dl4type)

gen flag_LastObs=1 if MaxObs==dl4type

replace flag_LastObs=0 if MinObs==dl4type & flag_LastObs!=1

gen SchStartYear= dl11a if flag_LastObs==0 | (flag_LastObs==1 & dl4type==1)
gen SchStartAge= dl11b if flag_LastObs==0 | (flag_LastObs==1 & dl4type==1)

gen SchFinYear= dl11f if flag_LastObs==1
gen SchFinAge= dl11g if flag_LastObs==1

by pidlink2: egen StartYear=max(SchStartYear)
by pidlink2: egen StartAge=max(SchStartAge)

by pidlink2: egen FinalYear=max(SchFinYear)
by pidlink2: egen FinalAge=max(SchFinAge)

replace StartYear=-1* StartYear
replace StartAge=-1*StartAge

egen SchYrs1=rsum(StartYear FinalYear) if flag_LastObs==1
egen SchYrs2=rsum(StartAge FinalAge) if flag_LastObs==1

*/
