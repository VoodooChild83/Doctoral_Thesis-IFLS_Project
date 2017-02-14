// Migration Information 1993

********************************************************************************
// 1993 Birth And Age 12 Clean:

use "$maindir$wave_1/buk3mg1.dta"

gen UrbRurmov0=0 if mg04==1
replace UrbRurmov0=1 if mg04==5|mg04==3

//Birth

* Kec
gen kecname0=mg01b1
gen kecmov0=mg01b2

	replace kecmov0=. if mg01b2>=5000 & mg01b2<=10000
	
	* Name Change
	replace kecmov0=mg03b3 if mg03b1==3 & !(mg03b3>=5000 & mg03b3<=10000)
	replace kecname0=mg03b2 if mg03b1==3 

* Kab
gen kabname0=mg01c1	
gen kabmov0=mg01c2

	replace kabmov0=. if mg01c2>=500 & mg01c2<=1000
	
	* Name Change
	replace kabmov0=mg03c3 if mg03c1==3 & !(mg03c3>=500 & mg03c3<=1000)
	replace kabname0=mg03c2 if mg03c1==3
	
* Prov
gen provname0=mg01d1
gen provmov0=mg01d2

	* Name Change
	replace provmov0=mg03d3 if mg03d1==3
	replace provname0=mg03d2
	

// Age 12

gen UrbRurmov12=0 if mg08==1
replace UrbRurmov12=1 if mg08==5|mg08==3

* Kec
gen kecname12=mg05b1
gen kecmov12=mg05b2 
	replace kecmov12=. if mg05b2>=5000 & mg05b2<=10000
	
	* Name Change
	replace kecmov12=mg07b3 if mg07b1==3 & !(mg07b3>=5000 & mg07b3<=10000)
	replace kecname12=mg07b2 if mg07b1==3

* Kab	
gen kabname12=mg05c1
gen kabmov12=mg05c2
	replace kabmov12=. if mg05c2>=500 & mg05c2<=1000
	
	* Name Change
	replace kabmov12=mg07c3 if mg07c1==3 & !(mg07c3>=500 & mg07c3<=1000)
	replace kabname12=mg07c2 if mg07c1==3
	
* Prov
gen provname12=mg05d1
gen provmov12=mg05d2

	* Name Change
	replace provmov12=mg07d3 if mg07d1==3
	replace provname12=mg07d2 if mg07d1==3

keep hhid93 pid93 pidlink kec* kab* prov*

reshape long kecmov@ kecname@ kabmov@ kabname@ provmov@ provname@ UrbRurmov@, i(pidlink) j(stage)

save "$maindir$tmp/b3a_mg1_1993.dta", replace

********************************************************************************
// 1993 Wave Migration Clean:

use "$maindir$wave_1/buk3mg2.dta"

keep hhid93 pid93 pidlink movenum mg21b1-mg22 mg23b1-mg23d3 mg24yr mg25 mg26 mg35 mg36

* Define the movement variables

gen kecmov=mg21b2
gen kecname=mg21b1

gen kabmov=mg21c2
gen kabname=mg21c1

gen provmov=mg21d2
gen provname=mg21d1

gen UrbRurmov=0 if mg26==1
replace UrbRurmov=1 if mg26==5|mg26==3
drop mg26

* Clean the geolocation information with the updates:

	//Kec

	/*LOCATION CODES IN THE 5000 SERIES INDICATE THAT THE NAME OF THE GIVEN GEOGRAPHIC UNIT IS NOT CONSISTENT WITH THE OTHER GEOGRAPHIC
	UNITS GIVEN FOR THE LOCATION. FOR EXAMPLE, THE KECAMATAN NAME GIVEN IS NOT AMONG THE KECAMATANS THAT EXIST WITHIN THE KABUPATEN AND PROVINCE
	NAMES GIVEN.*/

	replace kecmov=. if mg21b2>=5000 & mg21b2<=10000
	
	* New Kec name
	
	replace kecmov=mg23b3 if mg23b1==3 & !(mg23b3>=5000 & mg23b3<=10000)
	replace kecname=mg23b2 if mg23b1==3
	*gen flag_kecchange=1 if mg23b1==3 & !(mg23b3>=5000 & mg23b3<=10000)
	
	//Kab
	
	replace kabmov=. if mg21c2>=500 & mg21c2<=1000
	
	* New Kab name
	
	replace kabmov=mg23c3 if mg23c1==3 & !(mg23c3>=500 & mg23c3<=1000)
	replace kabname=mg23c2 if mg23c1==3
	*gen flag_kabchange=1 if mg23c1==3 & !(mg23c3>=500 & mg23c3<=1000)
	
	//Prov
	
	replace provmov=. if mg21d2>500
	
	* New Prov name
	
	replace provmov=mg23d3 if mg23d1==3 & !(mg21d2>500)
	replace provname=mg23d2 if mg23d1==3
	*gen flag_provchange=1 if mg23d1==3 & !(mg21d2>500)
	

drop mg21b1-mg23d3 
	
save "$maindir$tmp/b3a_mg2_1993.dta", replace
	
********************************************************************************
// Update Missing locations using the location .dta files for both 

* First method: Merge all the geographical datasets together and update the codes

	* First, create the 1993 location database to update values:
	
		* Update name of BENKULU
		use "$maindir$wave_1/prov.dta"
		replace nama = "BENGKULU" in 7
		save "$maindir$tmp/prov1993.dta", replace

		use "$maindir$wave_1/kec.dta"

		drop kode

		rename nama kecname
	
		* Merge province names
			merge m:1 prov using "$maindir$tmp/prov1993.dta", keepusing(nama) nogen

			rename nama provname
			erase "$maindir$tmp/prov1993.dta"
	
		* Merge kab names
			merge m:1 prov kab using "$maindir$wave_1/kab.dta", keepusing(nama) nogen

			rename nama kabname
	
		* Identify and drop the repeats: these will not be updated
			egen id=concat(provname kabname kecname)
			bysort id: gen dup = cond(_N==1,0,_n)
	
			drop if dup>0
			drop dup id
	
			rename (prov kab kec) (provmov kabmov kecmov)
	
			save "$maindir$tmp/geo_1993.dta", replace
	
	* Now update and replace the missing and/or wrong values
	
		foreach mig in 1 2{
			
			use "$maindir$tmp/b3a_mg`mig'_1993.dta"
	
			merge m:1 provname kabname kecname using "$maindir$tmp/geo_1993.dta", update replace
			drop if _merge==2
		    drop _merge
			
			drop *name
			
			save "$maindir$tmp/b3a_mg`mig'_1993.dta", replace
			}	
			
		erase "$maindir$tmp/geo_1993.dta"
			
********************************************************************************
// Merge birthday information to get full years for all people
	
	  use "$maindir$project/birthyear.dta"

			preserve
				collapse (mean) birthyr, by (pidlink)
	
				save "$maindir$tmp/birthyear.dta", replace
			restore
		
	  foreach mig in 1 2{
			use "$maindir$tmp/b3a_mg`mig'_1993.dta"

	   		merge m:1 pidlink using "$maindir$tmp/birthyear.dta"
	   		drop if _merge==2
	   		drop _merge
	   		
	   		save "$maindir$tmp/b3a_mg`mig'_1993.dta", replace
	   		}
	   
	  erase "$maindir$tmp/birthyear.dta"
	   
********************************************************************************
// Update 1993 Migration Event Years:
	
	//Replace mg24yr>=96 with missing value
	
	gen MigYear=mg24yr
	replace MigYear=. if mg24yr>=96
	replace MigYear=1900+MigYear
	
	//Update migration year using birth year and migration age
	
	gen MigAge=mg25
	
	gen flag_MigAge=1 if  MigAge>=96 & MigAge!=. & MigYear==. 									 // Flag possible problems: code 1: age>=96 may be missing codes
	 	replace flag_MigAge=0 if (birthyr+MigAge>1994) & MigYear==. & flag_MigAge!=1 & MigAge!=. // 						code 0: inconsistant, migration year is greater than observed wave
		replace flag_MigAge=2 if MigYear==. & flag_MigAge!=1 & MigAge==.                         //						    code 2: all information missing
	
	replace MigYear=birthyr+MigAge if (birthyr+MigAge<=1994) & MigYear==.  //The logical test 'birthyr+MigAge<=1994' is indicating 
																		   //whether at the birth year + migration age does 
																		   //not violate the year 1993, when we observe the person
    drop MigAge mg24yr mg25 flag_MigAge birthyr
    
order pidlink pid* hhid* movenum 
sort pidlink movenum

save "$maindir$tmp/b3a_mg2_1993.dta", replace

********************************************************************************
// Start cycling through migration events to get the kind of moves. 
/*
gen MigStart=MigYear if movenum==1
gen MigEnd=MigYear if flag_FinalObs==1

foreach var in MigStart MigEnd{
		by pidlink: egen `var'1=max(`var')
		drop `var'
		rename `var'1 `var'
		replace `var'=. if flag_FinalObs!=1
		}

gen flag_kecmig=.
gen flag_kabmig=.
gen flag_provmig=.  		// interprovincial migration also includes possible international migration since these are not distinguished

gen flag_villmigsame=.		// a village migration within the same kec
gen flag_kecmigsame=.		// intraregency migration (a subregency change within the same heirarchy of regency and province)
gen flag_kabmigsame=.		// intraprovincial migration (a subregency and regency change within the hierarchy of province)

gen flag_UrbRurmig=.		// did migrations take place between rural and urban

quietly levelsof movenum, local(levels)

* First, find the inter-geographical migration events

quietly foreach var in kec kab prov UrbRur{

		foreach l of local levels{
				by pidlink: replace flag_`var'mig=1 if movenum==`l' & `var'mov[_n-1]!=`var'mov[_n] 
				}
		}

* Second, find the intra-geographical migration events (that is, events that occur intraregency (implies same province) and/or intraprovincially)

quietly foreach var in kec kab vill{
		
			if "`var'"=="kec" egen id=concat(provmov kabmov)
			if "`var'"=="kab" egen id=concat(provmov)
			if "`var'"=="vill" egen id=concat(provmov kabmov kecmov)
		
			if "`var'"=="kec"|"`var'"=="kab"{
				foreach l of local levels{
						by pidlink: replace flag_`var'migsame=1 if movenum==`l' & `var'mov[_n-1]!=`var'mov[_n] & id[_n-1]==id[_n] 
				}
			drop id
			}
			if "`var'"=="vill"{
				foreach l of local levels{
						by pidlink: replace flag_`var'migsame=1 if movenum==`l' & id[_n-1]==id[_n] 
				}
			drop id
			}
				
		}
			
rename (*provmig *kecmigsame *kabmigsame) (*InterProvMig *IntraRegMig *IntraProvMig)

save "$maindir$tmp/1993migration.dta", replace

********************************************************************************
// Count the types of migration events that occur

quietly foreach var in vill InterProvMig IntraRegMig IntraProvMig UrbRur{
		by pidlink: egen Tally_`var'=count(flag_`var')
		replace Tally_`var'=. if flag_FinalObs!=1
		recode Tally_`var' 0=.
		}
		
* Check that the migration number of events has been properly aggregated

	egen TotalMov=rsum(Tally_vill Tally_InterProvMig Tally_IntraRegMig Tally_IntraProvMig)
	gen flag_InconsisMov=1 if TotalMov!=movenum & flag_FinalObs==1

	tab flag_InconsisMov if flag_FinalObs==1, missing
	
	//Migration events have been properly aggregated into groups

drop flag_kecmig-flag_UrbRurmig TotalMov flag_InconsisMov

save "$maindir$tmp/1993migration.dta", replace

********************************************************************************
// Migration Members
/*
gen Spouse=.
gen Father=.
gen Mother=.
gen Brother=.
gen Sister=.
gen ParentsLaw=.
gen Children=.
gen OtherFam=.
gen NonFam=.

local kin "Spouse Father Mother Brother Sister ParentsLaw Children OtherFam NonFam"

foreach k of local kin{
		
		replace `k'=1 if 

}
*/
*drop if flag_FinalObs!=1

********************************************************************************
// Reduce dataset for final merge

keep pidlink pid93 hhid93 movenum flag_FinalObs MigStart- Tally_UrbRur

drop if flag_FinalObs!=1
rename *FinalObs *Mig

save "$maindir$tmp/1993migration.dta", replace

********************************************************************************
*/
/* The below code is the second method for updating location codes based on the provided
location codes in the 1993 wave */

* Second Method: Update and Replace each geographical code seperately
/*
	foreach geo in prov kab kec{
	
			use "$maindir$wave_1/`geo'.dta"
			
			drop kode
			
			rename nama `geo'name
			rename prov provmov
							
			if "`geo'"=="kab" {
				rename kab kabmov
				
				// There are instances where some location names have same identifier combos: drop
				// them and don't update
				
				egen id=concat(`geo'name provmov)
				
				bysort id: gen dup = cond(_N==1,0,_n)
				
				drop if dup>0
				
				drop id dup
				
				}
		
			if "`geo'"=="kec" {
				rename kec kecmov
				rename kab kabmov
				
				// There are instances of when some location names have same identifier combos: drop
				// them and don't update
				
				egen id=concat(`geo'name provmov kabmov)
				
				bysort id: gen dup = cond(_N==1,0,_n)
				
				drop if dup>0
				
				drop id dup
				
				}
			
			save "$maindir$tmp/`geo'_1993.dta", replace
			
			foreach mig in 1 2{
			
				use "$maindir$tmp/b3a_mg`mig'_1993.dta"
			
				if "`geo'"=="prov" {
					merge m:1 `geo'name using "$maindir$tmp/`geo'_1993.dta", gen(`geo'_merge) update replace
					drop if `geo'_merge==2
					}
				
				if "`geo'"=="kab" {
					merge m:1 provmov `geo'name using "$maindir$tmp/`geo'_1993.dta", gen(`geo'_merge) update replace
					drop if `geo'_merge==2
					}
				
				if "`geo'"=="kec" {
					merge m:1 provmov kabmov `geo'name using "$maindir$tmp/`geo'_1993.dta", gen(`geo'_merge) update replace
					drop if `geo'_merge==2
					}
				
				drop `geo'_merge
			
				save "$maindir$tmp/b3a_mg`mig'_1993.dta", replace
			}	
			
			erase "$maindir$tmp/`geo'_1993.dta"
	}
*/
