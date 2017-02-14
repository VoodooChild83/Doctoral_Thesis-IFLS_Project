// Migration Information 1997

********************************************************************************
//Current Residence Locations
use "$maindir$wave_2/hh97bk/bk_sc.dta", clear

rename (sc03 sc02 sc01) (kec_curr kab_curr prov_curr)

keep hhid97 kec* kab* prov*

save "$maindir$tmp/res1997.dta", replace

********************************************************************************
// 1997 Birth And Age 12 Clean for both main and proxy modules:

foreach let in a p{

	if "`let'"=="a" use "$maindir$wave_2/b3`let'_mg1.dta"
	else use "$maindir$wave_2/b3`let'_mg.dta"

	* First, merge in current residence file to the birthplace and year 12 dataset
	
		merge m:1 hhid97 using "$maindir$tmp/res1997.dta"
		drop if _merge==2
		drop _merge
		
	gen book="`let'" // book will help identify later if there are main module pidlinks in the proxy who should not be
	
	//Birth

	gen UrbRurmov0=0 if mg04==1
	replace UrbRurmov0=1 if mg04==5|mg04==3

	* Kec
	gen kecmov0=mg01b

		replace kecmov0=. if mg01bx==.|mg01bx>=4 // missing values 
	
		* Name Change
		replace kecmov0=mg03b if mg03bx==1

	* Kab
	gen kabmov0=mg01c

		replace kabmov0=. if mg01cx==.|mg01cx>=4 // missing values
	
		* Name Change
		replace kabmov0=mg03c if mg03cx==1
	
	* Prov
	gen provmov0=mg01d

		replace provmov0=. if mg01dx==.|mg01dx>=4

		* Name Change
		replace provmov0=mg03d if mg03dx==1
	

	// Age 12

	gen UrbRurmov12=0 if mg08==1
	replace UrbRurmov12=1 if mg08==5|mg08==3

	* Kec
	gen kecmov12=mg05b if mg05bx==1 & mg04a==3

		replace kecmov12=kecmov0 if mg04a==1
		replace kecmov12=kec_curr if mg05bx==3 & mg04a==3
		replace kecmov12=. if (mg05bx==. |  mg05bx>=8) & mg04a==3 // missing values
	
		* Name Change
		replace kecmov12=mg07b if mg07bx==1 & !(mg07b>=998) & mg04a==3

	* Kab	
	gen kabmov12=mg05c if mg05cx==1 & mg04a==3  

		replace kabmov12=kabmov0 if mg04a==1 
		replace kabmov12=kab_curr if mg05cx==3 & mg04a==3
		replace kabmov12=. if (mg05cx==. |  mg05cx>=8) & mg04a==3
	
		* Name Change
		replace kabmov12=mg07c if mg07cx==1 & !(mg07c>=98) & mg04a==3
	
	* Prov
	gen provmov12=mg05d if mg05dx==1 & mg04a==3 

		replace provmov12=provmov0 if mg04a==1 
		replace provmov12=prov_curr if mg05dx==3 & mg04a==3
		replace provmov12=. if (mg05dx==. |  mg05dx>=8) & mg04a==3
	
		* Name Change
		replace provmov12=mg07d if mg07dx==1 & !(mg07d>=98) & mg04a==3
	
	if "`let'"=="a"{
	
		rename mg00x panel97

		* Reshape Long
			keep hhid97 pid97 pidlink kec* kab* prov* panel97 UrbRur* book
			drop *_curr

			reshape long kecmov@ kabmov@ provmov@ UrbRurmov@, i(pidlink) j(stage)
		}
		
	else {
		* Reshape Long
			keep hhid97 pid97 pidlink kec* kab* prov* UrbRur* book
			drop *_curr

			reshape long kecmov@ kabmov@ provmov@ UrbRurmov@, i(pidlink) j(stage)
		}	

	if "`let'"=="a" save "$maindir$tmp/b3`let'_mg1_1997.dta", replace
	else save "$maindir$tmp/b3`let'_mg1_1997.dta", replace
}

erase "$maindir$tmp/res1997.dta"

********************************************************************************
// Append the Proxy and Main datasets: Birth-Age12 data

use "$maindir$tmp/b3a_mg1_1997.dta"

append using "$maindir$tmp/b3p_mg1_1997.dta"

erase "$maindir$tmp/b3p_mg1_1997.dta"

	* Find if there are repeated pidlinks across the datasets using book
		destring pidlink, gen(pidlink2) force
		bysort pidlink2 (stage book): gen obs=_n
		
		by pidlink2: drop if book=="p" & _N>2 // keep the main module migration event: only 1 case is repeated
		
		drop pidlink2 obs book
		
recode panel97 .=0 
label define panew 0 "0. Proxy Insert", add

save "$maindir$tmp/b3a_mg1_1997.dta", replace

********************************************************************************	
// Clean the migration after 12 years old data sets: Proxy and Main

// Main 1997 Migration DataSet

use "$maindir$wave_2/b3a_mg2.dta"

keep hhid97 pid97 pidlink movenum mg21bx-mg23d mg24yr mg25 mg26 mg35 mg36
gen book="a"

* Flag last observation
    
	bysort pidlink (movenum): gen flag_FinalObs=1 if movenum==_N
	
* Create the Movement Variables

gen UrbRurmov=0 if mg26==1
replace UrbRurmov=1 if mg26==5|mg26==3
drop mg26

	* Kec
	gen kecmov=mg21b
	
		* Replace if there has been a name change
		replace kecmov=mg23b if mg22==1 & mg23bx==1
		gen flag_kecchange=1 if mg22==1 & mg23bx==1
		
	* Kab
	gen kabmov=mg21c

		* Replace if there has been a name change
		replace kabmov=mg23c if mg22==1 & mg23cx==1
		gen flag_kabchange=1 if mg22==1 & mg23cx==1
	
	* Prov
	gen provmov=mg21d
	
		* Replace if there has been a name change
		replace provmov=mg23d if mg22==1 & mg23dx==1
		gen flag_provchange=1 if mg22==1 & mg23dx==1

drop mg21bx-mg23d

save "$maindir$tmp/b3a_mg2_1997.dta", replace

// Proxy 1997 Migration Dataset

use "$maindir$wave_2/b3p_mg.dta"

drop if mg11!=3 //Since this is a proxy book, the person was not at home to answer it. 
				//If mg11==1 then the person has not always lived there then there has
				//been a migration event and I catlogue it

keep pid97 hhid97 pidlink mg12yr-mg14d

rename (mg12yr mg13) (mg24yr mg25)  // Rename variables to match those in main dataset
gen movenum=1
gen flag_FinalObs=1
gen book="p"

	* Kec
	gen kecmov=mg14b
	
	* Kab
	gen kabmov=mg14c
	
	* Prov
	gen provmov=mg14d
	
drop mg14bx-mg14d

drop if provmov==. & kecmov==. & kabmov==.

save "$maindir$tmp/b3p_mg2_1997.dta", replace

********************************************************************************
// Append the Proxy and Main datasets: After 12 years old migration

use "$maindir$tmp/b3a_mg2_1997.dta"

append using "$maindir$tmp/b3p_mg2_1997.dta"

erase "$maindir$tmp/b3p_mg2_1997.dta"

* Check if there are repeat pidlinks after append

	gen a=1
	bysort pidlink book: egen b=sum(a)
	gen dup=1 if flag_FinalObs==1 & movenum!=b //No duplicate observations
	
	drop a b dup book

save "$maindir$tmp/b3a_mg2_1997.dta", replace
		
********************************************************************************
// Merge birthday information to get full years for all people
	
	  use "$maindir$project/birthyear.dta"

			preserve
				collapse (mean) birthyr, by (pidlink)
	
				save "$maindir$tmp/birthyear.dta", replace
			restore
		
	  foreach mig in 1 2{
			use "$maindir$tmp/b3a_mg`mig'_1997.dta"

	   		merge m:1 pidlink using "$maindir$tmp/birthyear.dta"
	   		drop if _merge==2
	   		drop _merge
	   		
	   		save "$maindir$tmp/b3a_mg`mig'_1997.dta", replace
	   		}
	   
	  erase "$maindir$tmp/birthyear.dta"
	  
********************************************************************************
// Update 1997 Migration Event Years:

gen MigYear=mg24yr

	* Update migration year using birth year and migration age
	
	gen MigAge=mg25
	
	gen flag_MigAge=1 if (birthyr+MigAge>1998) & MigYear==. & MigAge!=. // migration event is beyond the latest wave year: 1998
	replace flag_MigAge=0 if MigYear==. & flag_MigAge!=1 & MigAge==.
	
	replace MigYear=birthyr+MigAge if flag_MigAge==. & MigYear==.
	
	drop flag_MigAge MigAge mg24yr mg25 birthyr

order pidlink pid* hhid* movenum flag_FinalObs
sort pidlink movenum

save "$maindir$tmp/b3a_mg2_1997.dta", replace

********************************************************************************
// Merge in the Panel information from the Birth-Age12 dataset

use "$maindir$tmp/b3a_mg1_1997.dta"

preserve
	drop if stage==12
	keep pidlink panel97
	save "$maindir$tmp/panelinfo1997.dta"
restore

use "$maindir$tmp/b3a_mg2_1997.dta"

merge m:1 pidlink using "$maindir$tmp/panelinfo1997.dta"
drop if _merge==2
drop _merge flag_FinalObs

save "$maindir$tmp/b3a_mg2_1997.dta", replace

erase "$maindir$tmp/panelinfo1997.dta"
