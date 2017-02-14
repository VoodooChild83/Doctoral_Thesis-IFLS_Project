// Migration Information 2014

********************************************************************************
//Current Residence Locations

use "$maindir$wave_5/bk_sc1.dta", clear

rename (sc03_14_14 sc02_14_14 sc01_14_14) (kec_curr kab_curr prov_curr)

keep hhid14 kec* kab* prov*

save "$maindir$tmp/res2014.dta", replace

********************************************************************************
// 2014 Birth And Age 12 Clean for both main and proxy modules:

foreach let in a {

	if "`let'"=="a" use "$maindir$wave_5/b3`let'_mg1.dta"

	* First, merge in current residence file to the birthplace and year 12 dataset
	
		merge m:1 hhid14 using "$maindir$tmp/res2014.dta", keep(1 3) nogen
		
	gen book="`let'" // book will help identify later if there are main module pidlinks in the proxy who should not be
	
	//Birth

	gen UrbRurmov0=0 if mg04==1
	replace UrbRurmov0=1 if mg04==5|mg04==3

	if "`let'"=="a"{
	
		* Kec
		gen kecmov0=mg01b if mg01bx==1 				 // Code is given and not the same as current residence
	
			replace kecmov0=kec_curr if mg01bx==3	 // Current location is the same as the birthplace
			replace kecmov0=. if mg01bx==.|mg01bx>=4 // missing values 
	
			* Name Change
			replace kecmov0=mg03bb if mg03bbx==1
			replace kecmov0=. if kecmov0>=900     	 // These are not valid kec codes according to the BPA

		* Kab
		gen kabmov0=mg01c if mg01cx==1
	
			replace kabmov0=kab_curr if mg01cx==3 
			replace kabmov0=. if mg01cx==.|mg01cx>=4 // missing values
	
			* Name Change
			replace kabmov0=mg03bc if mg03bcx==1
			replace kabmov0=. if kabmov0>90			 // 90 is the maximum kab code available in BPS
		}
	
	else {
	
		* Kec
		gen kecmov0=mg01b 			 				 // Code is given and not the same as current residence
	
			* Name Change
			replace kecmov0=mg03bb if mg03bbx==1
			replace kecmov0=. if kecmov0>=900     	 // These are not valid kec codes according to the BPA

		* Kab
		gen kabmov0=mg01c
	
			* Name Change
			replace kabmov0=mg03bc if mg03bcx==1
			replace kabmov0=. if kabmov0>90			 // 90 is the maximum kab code available in BPS
		}
	
	* Prov
	gen provmov0=mg01d if mg01dx==1
	
		replace provmov0=prov_curr if mg01dx==3
		replace provmov0=. if mg01dx==.|mg01dx>=4

		* Name Change
		replace provmov0=mg03bd if mg03bdx==1
		replace provmov0=. if provmov0>94		// 94 is the maximum BPS codes for provinces in BPS
	

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
		replace kecmov12=. if kecmov12>=900        				  // These are not valid kec codes according to the BPA

	* Kab	
	gen kabmov12=mg05c if mg05cx==1 & mg04a==3  

		replace kabmov12=kabmov0 if mg04a==1 
		replace kabmov12=kab_curr if mg05cx==3 & mg04a==3
		replace kabmov12=. if (mg05cx==. |  mg05cx>=8) & mg04a==3
	
		* Name Change
		replace kabmov12=mg07c if mg07cx==1 & !(mg07c>=98) & mg04a==3
		replace kabmov12=. if kabmov12>90			 			 // 90 is the maximum kab code available in BPS
	
	* Prov
	gen provmov12=mg05d if mg05dx==1 & mg04a==3 

		replace provmov12=provmov0 if mg04a==1 
		replace provmov12=prov_curr if mg05dx==3 & mg04a==3
		replace provmov12=. if (mg05dx==. |  mg05dx>=8) & mg04a==3
	
		* Name Change
		replace provmov12=mg07d if mg07dx==1 & !(mg07d>=98) & mg04a==3
		replace provmov12=. if provmov12>94		       			// 94 is the maximum BPS codes for provinces in BPS
	
	if "`let'"=="a"{
	
		rename mg18a panel14
		label define panel 1 "Panel, preprinted" 2 "Panel, not preprinted" 3 "New"
		label values panel14 panel

		* Reshape Long
			keep hhid14 pid14 pidlink kec* kab* prov* panel14 UrbRur* book
			drop *_curr

			reshape long kecmov@ kabmov@ provmov@ UrbRurmov@, i(pidlink) j(stage)
		}
	
	if "`let'"=="a" save "$maindir$tmp/b3`let'_mg1_2014.dta", replace
}

erase "$maindir$tmp/res2014.dta"

********************************************************************************
// Append the Proxy and Main datasets: Birth-Age12 data

	* Find if there are repeated pidlinks across the datasets using book
		bysort pidlink (stage book): gen obs=_n
		
		by pidlink: drop if book=="a" & _N>2 // keep the main module migration event: only 1 case is repeated
		
		drop obs book
		
recode panel14 .=0 
label define panel 0 "0. Proxy Insert", add

save "$maindir$tmp/b3a_mg1_2014.dta", replace

********************************************************************************
// Clean the Main and Proxy Migration Event Datasets

// Main 2014 Migration DataSet

use "$maindir$wave_5/b3a_mg2.dta"

keep hhid14 pid14 pidlink movenum mg21bx-mg21b mg24yr mg25 mg26 mg35 mg36
gen book="a"


* Flag last observation
    
	bysort pidlink (movenum): gen flag_FinalObs=1 if movenum==_N
	
* Create the Movement Variables

gen UrbRurmov=0 if mg26==1
replace UrbRurmov=1 if mg26==5|mg26==3
drop mg26

	* Kec
	gen kecmov=mg21b
	/*
		* Replace if there has been a name change
		replace kecmov=mg23b if mg22==1 & mg23bx==1 & !(mg23b>900)
		replace kecmov=. if kecmov>900					// No BPS Kec codes that go beyond 900
		gen flag_kecchange=1 if mg22==1 & mg23bx==1 & !(mg23b>900)
	*/	
	* Kab
	gen kabmov=mg21c
	/*
		* Replace if there has been a name change
		replace kabmov=mg23c if mg22==1 & mg23cx==1 & !(mg23c>90)
		replace kabmov=. if kabmov>90					// No BPS Kap codes that go beyond 90
		gen flag_kabchange=1 if mg22==1 & mg23cx==1 & !(mg23c>90)
	*/	
	* Prov
	gen provmov=mg21d
	/*
		* Replace if there has been a name change
		replace provmov=mg23d if mg22==1 & mg23dx==1 & !(mg23d>94)
		replace provmov=. if provmov>94					// No BPS Prov Codes go beyond 94 (which are current highest)
		gen flag_provchange=1 if mg22==1 & mg23dx==1 & !(mg23d>94)
	*/
drop mg21bx-mg21b

save "$maindir$tmp/b3a_mg2_2014.dta", replace

********************************************************************************
// Append the Proxy and Main datasets: After 12 years old migration

* Check if there are repeat pidlinks after append

	gen a=1
	bysort pidlink book: egen b=sum(a)
	gen dup=1 if flag_FinalObs==1 & movenum!=b //No duplicate observations
	
	drop a b dup book

save "$maindir$tmp/b3a_mg2_2014.dta", replace

********************************************************************************
// Merge birthday information to get full years for all people
	
	  use "$maindir$project/birthyear.dta"

			preserve
				collapse (mean) birthyr, by (pidlink)
	
				save "$maindir$tmp/birthyear.dta", replace
			restore
		
	  foreach mig in 1 2{
			use "$maindir$tmp/b3a_mg`mig'_2014.dta"

	   		merge m:1 pidlink using "$maindir$tmp/birthyear.dta", keep(1 3) nogen
	   		
	   		save "$maindir$tmp/b3a_mg`mig'_2014.dta", replace
	   		}
	   
	  erase "$maindir$tmp/birthyear.dta"

********************************************************************************
// Update 2014 Migration Event Years:

gen MigYear=mg24yr

	* Update migration year using birth year and migration age
	
	gen MigAge=mg25
	
	gen flag_MigAge=1 if (birthyr+MigAge>2015) & MigYear==. & MigAge!=. // migration event is beyond the latest wave year: 2014/2015
	replace flag_MigAge=0 if MigYear==. & flag_MigAge!=1 & MigAge==.
	
	replace MigYear=birthyr+MigAge if flag_MigAge==. & MigYear==.
	
	drop flag_MigAge MigAge mg24yr mg25 birthyr

order pidlink pid* hhid* movenum flag_FinalObs
sort pidlink movenum

save "$maindir$tmp/b3a_mg2_2014.dta", replace

********************************************************************************
// Merge in the Panel information from the Birth-Age12 dataset

use "$maindir$tmp/b3a_mg1_2014.dta"

preserve
	drop if stage==12
	keep pidlink panel14
	save "$maindir$tmp/panelinfo2014.dta", replace
restore

use "$maindir$tmp/b3a_mg2_2014.dta"

merge m:1 pidlink using "$maindir$tmp/panelinfo2014.dta", keep(1 3) nogen
drop flag_FinalObs

save "$maindir$tmp/b3a_mg2_2014.dta", replace

erase "$maindir$tmp/panelinfo2014.dta"
