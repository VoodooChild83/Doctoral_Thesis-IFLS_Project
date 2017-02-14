/* This do file will create a superwide dataset that will then be used to link
   the parent's migration event with the child's schooling.*/

********************************************************************************

use "$maindir$project/Migration Movements/Year-Share.dta", clear

*rename wave Wave
/*
preserve

	use "$maindir$tmp/MigrationEvents-RepsurvDrop-For Mig Year Dummeis.dta", clear
	
	keep pidlink stage *_Inter* *_Intra* MigYear Wave movenum
	
	save "$maindir$tmp/MigrationEvents Update.dta", replace

restore

joinby pidlink stage using  "$maindir$tmp/MigrationEvents Update.dta", update unm(m)
drop _merge
erase  "$maindir$tmp/MigrationEvents Update.dta"
*/

sort pidlink stage

keep pidlink stage MigYear wave movenum* *_Inter* *_Intra* *Family* Urb* *UrbRurmig Islandmov provmov
drop Cohort_* Tally_* 

* Recode all the misisng values in the flag variables

recode flag_Inter* (.=0)
recode flag_Family* (.=0)

* drop the stage 0 and 12 events (keep if at age 12 there was a migration):
gen a=1
bysort pidlink (stage): egen b=sum(a)
drop if (stage<=12 & movenum==. & b>2) | (stage<12 & b==2)
drop a b

* Consolidate InterProvincial and InterIsland migration flags: call it InterIsland (the level I care about

gen byte Mig= (flag_InterProvMig==1 | flag_InterIslandMig==1) //flag_IntraProvMig==1 | flag_IntraKecMig==1  | flag_IntraKabMig==1)
gen byte InterIslandMig= flag_InterIslandMig
gen byte IntraIslandMig= (flag_InterProvMig==1  & flag_InterIslandMig!=1 )
/*
gen byte InterKabMig= (flag_InterProvMig==1 | flag_IntraProvMig==1)
gen byte IntraKabMig= (flag_IntraKecMig==1  | flag_IntraKabMig==1 )
*/

* Seperate family Migrations by their types (interisland and intraisland)
gen byte InterIsland_FamilyMig = (flag_Family_IslandMov==1 & InterIslandMig==1)
gen byte IntraIsland_FamilyMig = (flag_Family_ProvMov==1 & IntraIslandMig==1)
drop flag_Inter* flag_Family*

merge m:1 pidlink using "$maindir$project/birthyear.dta", keep (1 3) nogen

* Find the multiple observations
duplicates tag pidlink stage, gen (dup)

levelsof dup, local(levels)

foreach l of local levels{

	if `l'>0{
		preserve

			* First preserve the movement with the family migration
			keep if dup==`l'
	
			egen SUM=rsum(InterIslandMig-IntraIsland_FamilyMig)
			bys pidlink stage (movenum_stage): egen SUM_MAX=max(SUM)
	
			keep if SUM_MAX==SUM
			drop SUM*
	
			* Now keep the First maximal observation
			by pidlink stage: egen ObsMax=max(movenum_stage)
	
			by pidlink stage: keep if ObsMax==movenum_stage
			drop *Max
	
			save "$maindir$tmp/Duplicates_`l'.dta", replace
	
		restore
	}
}

drop if dup>0

* Append the cleaned duplicates

forvalues i=1/4{

	append using "$maindir$tmp/Duplicates_`i'.dta"
	erase "$maindir$tmp/Duplicates_`i'.dta"
}

drop dup

* Generate the dummy variables for migration events

	levelsof MigYear, local (migyr)
	
	foreach year of local migyr{
		
			gen byte Mig_`year'= (MigYear==`year' & Mig==1)
			gen byte Mig_`year'_InterIslandMig= (InterIslandMig==1 & MigYear==`year')
			gen byte Mig_`year'_IntraIslandMig= (IntraIslandMig==1 & MigYear==`year')
			
			gen byte Mig_`year'_InterIsland_FamilyMig= (InterIsland_FamilyMig==1 & MigYear==`year')
			gen byte Mig_`year'_IntraIsland_FamilyMig= (IntraIsland_FamilyMig==1 & MigYear==`year')
			
			/*
			gen byte Mig_`year'_InterKabMig= (InterKabMig==1 & MigYear==`year')
			gen byte Mig_`year'_IntraKabMig= (IntraKabMig==1 & MigYear==`year')
			*/
	}
	
* Collapse the dataset to obtain just the values for each individual
preserve
	collapse (max) Mig_*, by (pidlink)

	save "$maindir$tmp/MigrationYeardummies.dta", replace
restore

drop Mig_*

save "$maindir$project/Migration Movements/Year-Share.dta", replace

********************************************************************************
/* Generate dataset of the migration rates per year*/
/* There's a small error in the below code, as the two migration rate types should add to 
   the Mig type. It does not (Mig tends to be larger than the combination of the two types)
   This was a recode based on a deleted version of the original and the data of the original
   was correct and did not contain this error. */
/*
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
*/
