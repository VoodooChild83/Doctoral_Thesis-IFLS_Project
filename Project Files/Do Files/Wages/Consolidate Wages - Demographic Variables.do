// Generate the Database of observables for the wage imputations

********************************************************************************
// Use the Year-Share database

use "$maindir$project/Migration Movements/Year-Share.dta"

********************************************************************************
// Create the Migration database for wages

	replace MigYear=wave if MigYear==.
	
	* Replace sex

			recode sex (1=0 "Male") (3=1 "Female"), gen(Sex) label (mafe)
			
			drop sex
			
	* Replace Married
			
			recode Marriage (1 3/5 8 9 = 0 "Unmarried") (2=1 "Married"), gen (marriage) label(marriage)
			
			drop Marriage
			rename marriage Marriage
			
	* Merge in the RepSurvDrop.dta

		merge m:m pidlink MigYear using "$maindir$tmp/MigrationEvents-RepsurvDrop.dta", keepusing(UrbRurmov kecmov kabmov provmov) update
	
		sort pidlink MigYear
	
	/* Generate a mover variable
	
		by pidlink: egen moved=max(TotalMoves)
		gen byte Mover=(moved!=0)
		drop moved*/
	
	* Drop unnecessary variable
	
		rename (MigYear stage) (year age)

		keep pidlink age year Sex Marriage MaxSchYrs MaxSchLvl UrbBirth *mov /*Mover*/

	* Fill in the missing years (merge in the birth year)

		merge m:1 pidlink using "$maindir$project/birthyear.dta", keep(1 3) nogen
	
* Drop Duplicates

  * Directly drop duplicates
  
	duplicates drop
  
  * Drop duplicates by pidlink year
  
	duplicates drop pidlink year, force
	
********************************************************************************
// Genrate the demographic variable database

preserve

	* Generate the dataset for nonchanging variables (max sch year and levels, religion, ethnicity)

		use "$maindir$project/MasterTrack2.dta", clear
	
		sort pidlink wave
	
		keep if flag_LastWave==1
	
		keep pidlink sex MaxSchYrs MaxSchLvl ar15 ar15d
	
		rename (ar15 ar15d) (religion ethnicity)
		
		* Create dummies for the religious and ethnic groups
	
			recode religion (1=0 "Islam") (2/7 95 98 99=1 "Other"), gen(Religion) label(Religion)

			recode ethnicity (1 2=0 "Javanese/Sundanese") (3/23 25/28 95 99=1 "Other"), gen(Ethnicity) label(Ethnicity)
			
			drop religion ethnicity
	
		* Replace sex

			recode sex (1=0 "Male") (3=1 "Female"), gen(Sex) label (mafe)
			
			drop sex
		
		save "$maindir$tmp/Demos.dta", replace
		
	* Generate the dataset for household locations
	
		use "$maindir$project/MasterTrack2.dta", clear
	
		sort pidlink wave
		
		drop if hhid=="" | provmov==.
		
		keep pidlink wave *mov sc05
		
		rename (sc05 wave) (UrbRurmov year)
		
		replace UrbRurmov=0 if UrbRurmov==2
		
		save "$maindir$tmp/Demos-location.dta", replace
	
restore

* Merge in the demo and location

	merge m:1 pidlink using "$maindir$tmp/Demos.dta", update replace keep(1 3 4 5) nogen

	merge m:m pidlink year using "$maindir$tmp/Demos-location.dta", update keep(1 3 4 5) nogen
	
	erase "$maindir$tmp/Demos.dta"
	erase "$maindir$tmp/Demos-location.dta"
	
* Replace as missing provincial codes that are not correct

	replace provmov=. if provmov<11 | (provmov>21&provmov<31) | (provmov>36&provmov<51) | ///
					(provmov>53&provmov<61) | (provmov>64&provmov<71) | (provmov>76&provmov<81) | /// 
					(provmov>82&provmov<91) | (provmov>91&provmov<94) | provmov>94
					
* Create New School Level
			
	recode MaxSchLvl (-1 = 0 "No Schooling") (1=1 "Primary") (2=2 "Obl Secondary") ( 3=3 "Non-Obl Secondary") (4/7=4 "College"), gen (SchLvl) label(SchoolLevel)
	
********************************************************************************
// Merge in the information of parental migration and identify Children in the dataset

preserve

	use "$maindir$project/Longitudinal Survival dataset.dta", clear
	
	collapse (max) FaMigOK MoMigOK FaMoMigOK, by (pidlink)

	save "$maindir$tmp/Parental Migration.dta", replace

restore

	merge m:1 pidlink using "$maindir$tmp/Parental Migration.dta"
	drop if _merge==2
	
	recode _merge (1=0 "Not Children") (3=1 "Children"), gen(Children) label(children)
		drop _merge
		
	erase "$maindir$tmp/Parental Migration.dta"
	
********************************************************************************
// Make the data longitudinal

gen double pidlink2= real(pidlink)
	format pidlink2 %12.0f
	
* Tsset the data

	tsset pidlink2 year
	
* Fill in with years

	tsfill
	
	drop age
	
* Carry forward all the observations

	by pidlink2: carryforward pidlink *mov Sex MaxSchYrs *SchLvl Urb* /*Mover*/ birth* Rel* Eth* *OK Children, replace
	
	sort pidlink year
	
* Clear tsset

	tsset, clear
	drop pidlink2
	
compress

save "$maindir$tmp/Wages - Demography.dta", replace

	

