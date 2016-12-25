/* This do file will create a superwide dataset that will then be used to link
   the parent's migration event with the child's schooling.*/
   
cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************

use "$maindir$project/Migration Movements/Year-Share.dta"

rename wave Wave

merge m:m pidlink stage using "$maindir$tmp/MigrationEvents-RepsurvDrop-For Mig Year Dummeis.dta", keepusing(*_Inter* *_Intra* MigYear Wave movenum) update nogen

sort pidlink stage

keep pidlink stage MigYear Wave movenum *_Inter* *_Intra* 
drop Cohort_* Tally_* *_Cohort

erase "$maindir$tmp/MigrationEvents-RepsurvDrop-For Mig Year Dummeis.dta"

* Recode all the misisng values in the flag variables

recode flag_* (.=0)

* drop the stage 0 and 12 events (keep if at age 12 there was a migration):
gen a=1
bysort pidlink (stage): egen b=sum(a)
drop if (stage<=12 & movenum==. & b>2) | (stage<12 & b==2)
drop a b

* Consolidate InterProvincial and Intra Provincial migration flags: call it interkab (the level I care about

gen byte Mig= (flag_InterProvMig==1 | flag_IntraProvMig==1 | flag_IntraKecMig==1  | flag_IntraKabMig==1)
gen byte InterKabMig= (flag_InterProvMig==1 | flag_IntraProvMig==1)
gen byte IntraKabMig= (flag_IntraKecMig==1  | flag_IntraKabMig==1 )

drop flag_*

merge m:1 pidlink using "$maindir$project/birthyear.dta"
drop if _merge==1|_merge==2
drop _merge

* Generate the dummy variables for migration events

	levelsof MigYear, local (migyr)
	
	foreach year of local migyr{
		
			gen byte Mig_`year'= (MigYear==`year' & Mig==1)
			gen byte Mig_`year'_InterKabMig= (InterKabMig==1 & MigYear==`year')
			gen byte Mig_`year'_IntraKabMig= (IntraKabMig==1 & MigYear==`year')
	}
	
* Collapse the dataset to obtain just the values for each individual
preserve
	collapse (max) Mig_*, by (pidlink)

	save "$maindir$tmp/MigrationYeardummies.dta", replace
restore

********************************************************************************
/* Generate dataset of the migration rates per year*/
/* There's a small error in the below code, as the two migration rate types should add to 
   the Mig type. It does not (Mig tends to be larger than the combination of the two types)
   This was a recode based on a deleted version of the original and the data of the original
   was correct and did not contain this error. */

bysort pidlink (stage): gen finalobs=1 if _n==_N

forvalues i=1924/2007{

	by pidlink: egen byte Mig_Year_`i'_max=max(Mig_`i') 
	by pidlink: egen byte InterKab_Year_`i'_max=max(Mig_`i'_InterKab)
	by pidlink: egen byte IntraKab_Year_`i'_max=max(Mig_`i'_IntraKab)
	
	by pidlink: replace Mig_Year_`i'_max=. if birthyr>`i'
	by pidlink: replace Mig_Year_`i'_max=. if finalobs!=.
	by pidlink: replace InterKab_Year_`i'_max=. if birthyr>`i'
	by pidlink: replace InterKab_Year_`i'_max=. if finalobs!=1
	by pidlink: replace IntraKab_Year_`i'_max=. if birthyr>`i'
	by pidlink: replace IntraKab_Year_`i'_max=. if finalobs!=1
	
	egen Rate_`i'=mean(Mig_Year_`i'_max)
	egen Rate_InterKab_`i'=mean(InterKab_Year_`i'_max)
	egen Rate_IntraKab_`i'=mean(IntraKab_Year_`i'_max)

}

gen id=_n

keep if id==1

keep  id Rate_*

reshape long Rate_@ Rate_InterKab_@ Rate_IntraKab_@, i(id) j(Year)

drop id

save "$maindir$project/MigrationRates2.dta", replace
