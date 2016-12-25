/* This do file generates the dataset to use for creating the descriptive statistics
   of migration events. */

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Do the Migration Consolidation Do file

quietly do "$maindir$project/Do Files/Migration Consolidation.do"

********************************************************************************
// Merge information from master tracker file

use "$maindir$tmp/MigrationEvents-RepsurvDrop.dta"

rename Wave wave

merge m:m pidlink wave using "$maindir$project/MasterTrack2.dta", keepusing (ar01a sex ar13 MaxSchYrs MaxSchLvl flag_OutSch)
			
*drop if _merge==2
drop _merge

rename (ar13 ar01a) (Marriage Alive_Dead)

sort pidlink stage

*save "$maindir$project/Migration Movements/Year-Share.dta", replace

********************************************************************************
// Merge HHID to guage if person is in sample during particular waves
preserve

use "$maindir$project/MasterTrack2.dta", clear

keep pidlink wave hhid pid

sort pidlink wave

reshape wide hhid pid, i(pidlink) j(wave)

rename (*1993 *1997 *2000 *2007) (*93 *97 *00 *07)

save "$maindir$tmp/hhid.dta", replace

restore

*use "$maindir$project/Migration Movements/Year-Share.dta"

merge m:1 pidlink using "$maindir$tmp/hhid.dta", update
drop _merge

erase "$maindir$tmp/hhid.dta"
********************************************************************************
// Merge the birthyear info to incorporate all people

merge m:1 pidlink using "$maindir$project/birthyear.dta"

drop if _merge==2
drop _merge

********************************************************************************
// Clean

	* Assign Birth Urbanization
	
	bysort pidlink: gen UrbBirth1=UrbRurmov if stage==0
	bysort pidlink: egen UrbBirth=max(UrbBirth1)
	drop UrbBirth1 UrbRurmov
	
	* Retain only the age 0 and age 12 locations
	
	drop if stage>0 & stage<12 & movenum==.
	
	* No birthyear info is missing
	
	drop if birthyr==.
	
	* replace stage as the age for missing values
	
	replace stage=wave-birthyr if stage==.
	drop birthyr
	
	* Replace movenum with 1 for averaging
	
	replace movenum=1 if movenum!=.
	replace movenum=0 if movenum==. & stage!=0 & stage!=12 & stage!=. 
	replace movenum=. if stage<15 & movenum==1
	
	* Find last observation of movers that coincides with their total moves
				
	bysort pidlink: egen flag=max(TotalMoves)
	by pidlink: egen flag1=max(MaxSchYrs)
	by pidlink: egen flag2=max(flag_OutSch)
	by pidlink: egen flag3=max(MaxSchLvl)
					
	replace TotalMoves=flag if TotalMoves==.
	replace MaxSchYrs=flag1 if MaxSchYrs==.
	replace flag_OutSch=flag2 if flag_OutSch==.
	replace MaxSchLvl=flag3 if MaxSchLvl==.
	
	drop flag flag1 flag2 flag3
	
	* Drop if dead
				
	drop if Alive_Dead==0
	drop Alive_Dead
	
	* Drop if person has a missing PID in a wave year but has a year in that wave
	
	gen flag_Redundant=1 if (pid93==. & wave==1993) | (pid97==. & wave==1997) | (pid00==. & wave==2000) | (pid07==. & wave==2007)
	drop if flag_Redundant==1
	drop flag_Redundant
	
	* Drop Children from the sample (and any age<=12 migration event - keep the age 12 location information)
				
	by pidlink: gen flag3=1 if stage<15 & stage!=0 & stage!=12 | (stage<15 & wave!=.)
					
	drop if flag3==1  
	drop flag3
	
		* Drop the repeats of age=0 
		by pidlink: gen obs=_n if stage<=12
		tab obs	// any observation beyond 2 is a repeat of one fo the age 0 and/or 12 locations
		by pidlink: egen obs2=max(obs)
		
		gen flag=1 if stage==0 & obs2==3 & mg36!="" 				 //(rule has that mg36!="" since any the age0
		by pidlink: replace flag=2 if stage==0 & obs2==3 & obs==1 & flag[_n+1]!=1
		
		drop if flag!=.
		
		drop obs obs2 flag
	
	* Drop those that are still in school
				
	drop if flag_OutSch==.
	
	* Create the share of migrants (those adults who report having at least 1 event)
	
	bysort pidlink wave (stage): gen obs=_n if wave!=. & stage>=15
	
	bysort pidlink wave (movenum TotalMoves): gen mover=1 if movenum==1 & obs==_N // find the last observation of a persons list of migration events for each wave
	bysort pidlink wave (movenum TotalMoves): replace mover=0 if movenum==0 & obs==_N //replace with 0 those in each wave that have not migrated
	
	drop obs
	
	sort pidlink stage
	
********************************************************************************
// Assign Cohorts to those who don't have migration events
	
gen Cohort="15-24" if stage>=15 & stage<=24 
replace Cohort="25-34" if stage>=25 & stage<=34 
replace Cohort="35-44" if stage>=35 & stage<=44 
replace Cohort="45-54" if stage>=45 & stage<=54 
replace Cohort="55-64" if stage>=55 & stage<=64 
replace Cohort="65+" if stage>64 

********************************************************************************
// Generate the Mean Migration Numbers per Migrant according to Cohorts
/*
* First, find the last Cohort observation per person
	bysort pidlink Cohort (stage): gen obs=_n 
	replace obs=. if Cohort==""
	by pidlink Cohort (stage): gen flag_finalobsCohort=1 if obs==_N
	drop obs
	
* Second, find the total moves per person within a cohort
	bysort pidlink Cohort (stage): egen TotalMovesCohort=sum(movenum), missing
	replace TotalMovesCohort=. if  flag_finalobsCohort==.
	
* Third, for each person identify if they are a migrant within a cohort
	bysort pidlink Cohort (stage): egen moverCohort=max(movenum)
	replace moverCohort=. if flag_finalobsCohort==.

preserve
	
	collapse (lastnm) sex UrbBirth MaxSchYrs wave moverCohort TotalMovesCohort flag_InterIntraProv_Cohort flag_InterProv_Cohort flag_IslandHopperCohort, by (pidlink Cohort)
	
	statsby MeanMoves=r(mean) SDMovs=r(sd) SizeMoves=r(N), by (Cohort MaxSchYrs) subsets saving("$maindir$project/Migration Movements/CohortSchYrs.dta", replace):  summarize TotalMovesCohort if moverCohort==1
	statsby MeanMoves=r(mean) SDMovs=r(sd) SizeMoves=r(N), by (Cohort) subsets saving("$maindir$project/Migration Movements/Cohort.dta", replace):  summarize TotalMovesCohort if moverCohort==1
	statsby MeanMoves=r(mean) SDMovs=r(sd) SizeMoves=r(N), by (UrbBirth MaxSchYrs) subsets saving("$maindir$project/Migration Movements/UrbBirth.dta", replace):  summarize TotalMovesCohort if moverCohort==1
	statsby MeanMoves=r(mean) SDMovs=r(sd) SizeMoves=r(N), by (UrbBirth Cohort) subsets saving("$maindir$project/Migration Movements/UrbBirthCohort.dta", replace):  summarize TotalMovesCohort if moverCohort==1
	statsby MeanMoves=r(mean) SDMovs=r(sd) SizeMoves=r(N), by (UrbBirth Cohort) subsets saving("$maindir$project/Migration Movements/UrbBirthCohort-InterIntraProv.dta", replace):  summarize TotalMovesCohort if flag_InterIntraProv_Cohort==1
	statsby MeanMoves=r(mean) SDMovs=r(sd) SizeMoves=r(N), by (UrbBirth Cohort) subsets saving("$maindir$project/Migration Movements/UrbBirthCohort-InterProv.dta", replace):  summarize TotalMovesCohort if flag_InterProv_Cohort==1
	statsby MeanMoves=r(mean) SDMovs=r(sd) SizeMoves=r(N), by (UrbBirth Cohort) subsets saving("$maindir$project/Migration Movements/UrbBirthCohort-IslandHop.dta", replace):  summarize TotalMovesCohort if flag_IslandHopperCohort==1
	statsby MeanMoves=r(mean) SDMovs=r(sd) SizeMoves=r(N), by (sex UrbBirth MaxSchYrs) subsets saving("$maindir$project/Migration Movements/sex.dta", replace):  summarize TotalMovesCohort if moverCohort==1
	
restore


save "$maindir$project/Migration Movements/Year-Share.dta", replace

********************************************************************************						
					
