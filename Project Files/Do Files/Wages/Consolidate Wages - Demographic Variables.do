// Generate the Database of observables for the wage imputations

********************************************************************************
// Use the Year-Share database

use "$maindir$project/Migration Movements/Year-Share.dta"

********************************************************************************
// Create the Migration database for wages

* Append the Birth-Age12geo data

append using "$maindir$tmp/Birth-Age12geo.dta", keep(Urb* provmov pidlink stage MigYear)
sort pidlink stage

	* Merge in the RepSurvDrop.dta
	/*
		preserve
		
			use  "$maindir$tmp/MigrationEvents-RepsurvDrop.dta", clear
			
			bys pidlink stage (movenum): gen movenum_stage=_n
			
			save "$maindir$tmp/MigrationEvents-RepsurvDrop.dta", replace
			
		restore
	*/	
	
*merge 1:1 pidlink stage movenum_stage using "$maindir$tmp/MigrationEvents-RepsurvDrop.dta",update keepusing(provmov UrbRurmov) keep(1 3 4 5) nogen
		
/* Note: 6/2/2017: removed this portion change the above to better merge (not use 'merge m:m')
		keep pidlink MigYear
		
		merge m:m pidlink MigYear using "$maindir$tmp/MigrationEvents-RepsurvDrop.dta", keepusing(UrbRurmov kecmov kabmov provmov) update
	
		sort pidlink MigYear
*/	
	/* Generate a mover variable
	
		by pidlink: egen moved=max(TotalMoves)
		gen byte Mover=(moved!=0)
		drop moved*/
	
	* Drop unnecessary variable
	
		rename (MigYear stage) (year age)

		*keep pidlink age year Sex Marriage MaxSchYrs MaxSchLvl UrbBirth *mov /*Mover*/

	* Fill in the missing years (merge in the birth year)
		* already in the file (Note: 6/2/2017)
		*merge m:1 pidlink using "$maindir$project/birthyear.dta", keep(1 3) nogen
	
* Drop Duplicates

  * Drop duplicates by pidlink year
  
	duplicates drop pidlink year if year!=., force
	
* Create the Provincial Migration variable

gen ProvMig=1 if InterIslandMig==1 | IntraIslandMig==1
gen Prov_FamilyMig=1 if InterIsland_FamilyMig==1 | IntraIsland_FamilyMig==1

********************************************************************************
// Genrate the demographic variable database

preserve

	* Generate the dataset for nonchanging variables (max sch year and levels, religion, ethnicity)

		use "$maindir$project/MasterTrack2.dta", clear
	
		sort pidlink wave
	
		keep if flag_LastWave==1
	
		keep pidlink sex MaxSchYrs MaxSchLvl ar15 ar15d ar13 birthyr
		
		* Replace sex

			recode sex (1=0 "Male") (3=1 "Female"), gen(Sex) label (male)
			
		* Replace Married
			
			recode ar13 (1 3/5 8 9 = 0 "Unmarried") (2=1 "Married"), gen (Marriage) label(marriage)
		
		* Create New School Level
			
			recode MaxSchLvl (-1 = 0 "No Schooling") (1=1 "Primary") (2=2 "Obl Secondary") ( 3=3 "Non-Obl Secondary") (4/7=4 "College"), gen (SchLvl) label(SchoolLevel)
		
		* Create dummies for the religious and ethnic groups
	
			recode ar15 (1=0 "Islam") (2/7 95 98 99=1 "Other"), gen(Religion) label(Religion)

			recode ar15d (1 2=0 "Javanese/Sundanese") (3/23 25/28 95 99=1 "Other"), gen(Ethnicity) label(Ethnicity)
			
			drop ar15 ar15d ar13 sex MaxSchLvl
		
		save "$maindir$tmp/Demos.dta", replace
		
	* Generate the dataset for household locations
	
		use "$maindir$project/MasterTrack2.dta", clear
	
		sort pidlink wave
		
		drop if hhid=="" | provmov==.
		
		keep pidlink wave provmov sc05
		
		rename (sc05 wave) (UrbRurmov year)
		
		replace UrbRurmov=0 if UrbRurmov==2
		
		save "$maindir$tmp/Demos-location.dta", replace
	
restore
/*
* Merge in the demo and location

	merge m:1 pidlink using "$maindir$tmp/Demos.dta", update replace keep(1 3 4 5) nogen

	merge m:m pidlink year using "$maindir$tmp/Demos-location.dta", update keep(1 3 4 5) nogen
	
	erase "$maindir$tmp/Demos.dta"
	erase "$maindir$tmp/Demos-location.dta"
*/

********************************************************************************
// Merge in the information of parental migration and identify Children in the dataset

preserve

	use "$maindir$tmp/Childrens Education - Longitudinal Data.dta", clear
	
	collapse (firstnm) *max, by(pidlink)
	
	rename (InterIslandmax IntraIslandmax Provmax) (InterIsland_ParentMig IntraIsland_ParentMig Prov_ParentMig)
	
	save "$maindir$tmp/Parental Migration.dta", replace
	
	/*
	use "$maindir$project/Longitudinal Survival dataset.dta", clear
	
	collapse (max) FaMigOK MoMigOK FaMoMigOK, by (pidlink)

	save "$maindir$tmp/Parental Migration.dta", replace
	*/
restore

	merge m:1 pidlink using "$maindir$tmp/Parental Migration.dta", keep(1 3)
	
	recode _merge (1=0 "Not Children") (3=1 "Children"), gen(Children) label(children)
		drop _merge
		
	erase "$maindir$tmp/Parental Migration.dta"	

********************************************************************************
// Make the data longitudinal

* Use the wave as the final observation year

	* Replace wave if it is not the last observed wave
	
		bys pidlink (age): replace wave=. if _n!=_N
	
	preserve
	
		* Rename Wave to year_Wave to resahpe long
		
		keep pidlink wave birthyr
	
		rename wave year
		
		gen age=year-birthyr
		
		keep if year!=.
		
		save "$maindir$tmp/Final Wave.dta", replace
		
	restore
	
* Append the final wave as the final year observed

append using "$maindir$tmp/Final Wave.dta", gen(_append)
erase "$maindir$tmp/Final Wave.dta"

sort pidlink year

* Drop the induced duplicates (there are people who may have had migration events the year of the wave)
duplicates tag pidlink year, gen(dup)

drop if _append==1 & dup==1
drop _append dup
		
* Drop if years are missing
duplicates tag pidlink year, gen(dup)
drop if dup==1
drop dup

* fix the year that is missing for the age=12 person who has a birthyr but missing the age=12 year
bys pidlink (age): replace year=age+year[_n-1] if age==12 & year==. & year[_n-1]!=.

drop wave movenum* Mig

compress
	
* Tsset the data

	gen double pidlink2= real(pidlink)
		format pidlink2 %12.0f

	tsset pidlink2 year
	
* Fill in with years

	tsfill
	
	*drop age
	
* Carry forward all the observations

	replace birthyr=year if age==0 & birthyr==.

	by pidlink2: carryforward pidlink provmov Urb* birth* *_ParentMig Children, replace
	
	gsort pidlink2 -year
	by pidlink2: carryforward UrbBirth Urb12, replace
	
	sort pidlink year
	
	replace age=year-birthyr
	
* Clear tsset

	tsset, clear
	drop pidlink2 
	
compress

save "$maindir$tmp/Wages - Demography.dta", replace

	

