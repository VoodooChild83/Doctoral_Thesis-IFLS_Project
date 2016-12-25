* This Do file will do the following to the single marriage dataset:
*
*	a) Update the year-start dates for the inconsistent couples via the female-reported
*	   year-start dates
*	b) Update the year-end dates, again via the females, for both the data inconsistent 
* 	   subset of the data and the larger dataset
*   c) Update the dowry information for the larger dataset via the female, and if the
*      female has missing data update via the male
*   d) Merge/Update/Correct the spousal education

********************************************************************************
// Create a couple ID to update the inconsistent dates
/*
	gen double pidlink_couple=pidlink2*1000000000 if Sex==1
		format %20.0g pidlink_couple
																		
	replace pidlink_couple=pidlink_couple+pidlink_spouse 
	
	* Assign the couple ID to the female
	
	preserve
	
		keep if Sex==1
		
		keep pidlink2 pidlink_spouse pidlink_couple
		
		rename (pidlink2 pidlink_spouse) (pidlink_spouse pidlink2)
		
		save "$maindir$tmp/Marriage History Database - couple ID.dta", replace
	
	restore
	
	merge 1:1 pidlink2 pidlink_spouse using "$maindir$tmp/Marriage History Database - couple ID.dta", update keep(1 3 4) nogen
		erase "$maindir$tmp/Marriage History Database - couple ID.dta"
		
	order pidlink_couple pidlink pidlink2 pidlink_spouse
*/

drop if pidlink_couple==.	
********************************************************************************
*	A + B) Update the year-start and year-end dates

	preserve
	
		*keep if DataConsistency==3
		
		collapseandpreserve (min) year_start (max) year_end, by(pidlink_couple) omitstatfromvarlabel
		
		save "$maindir$tmp/Marriage History Database - Update Inconsistent Dates.dta", replace
	
	restore
	
	* Merge in the female data with the original dataset to update-replace the male
	* inconsistent dates
	
		merge m:1 pidlink_couple using "$maindir$tmp/Marriage History Database - Update Inconsistent Dates.dta", update replace keep(1 3 4 5) nogen
			erase "$maindir$tmp/Marriage History Database - Update Inconsistent Dates.dta"
			
		drop Data*
		
********************************************************************************
*	C) Update Dowry information - Collapse

	preserve
	
		collapseandpreserve (mean) Dowry, by(pidlink_couple) omitstatfromvarlabel
		
		save "$maindir$tmp/Marriage History Database - Dowry data.dta", replace
	
	restore
	
	merge m:1 pidlink_couple using "$maindir$tmp/Marriage History Database - Dowry data.dta", update replace keep(1 3 4 5) nogen
				erase "$maindir$tmp/Marriage History Database - Dowry data.dta"
				
	* Realize the Dowry
	
		preserve
	
			use "$maindir$project/Inflation/Inflation.dta", clear
		
			rename year year_start
		
			save "$maindir$tmp/Marriage History Database - Inflation.dta", replace
	
		restore
	
		merge m:1 year_start using "$maindir$tmp/Marriage History Database - Inflation.dta", keep(1 3) nogen
			erase "$maindir$tmp/Marriage History Database - Inflation.dta"
			
		replace Dowry=Dowry/inflation
			drop inflation
			
		gen ln_Dowry=ln(Dowry)
		
		order pidlink-Dowry ln_Dowry
			
********************************************************************************	
*	D) Merge/Update/Correct Spousal and Self education

	preserve

		use "$maindir$project/MasterTrack2.dta", clear
			drop pidlink2
	
		drop if flag_LastWave!=1
	
		gen double pidlink_spouse= real(pidlink)
			format pidlink_spouse %12.0f
		gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
		
		recode MaxSchLvl (-1 0 = 0 "No Schooling") (1=1 "Primary") (2=2 "Obl Secondary") (3=3 "Non-Obl Secondary") (4/7 = 4 "College"), gen(SchLvl_Spouse) label(SchoolLevel)
		recode MaxSchLvl (-1 0 = 0 "No Schooling") (1=1 "Primary") (2=2 "Obl Secondary") (3=3 "Non-Obl Secondary") (4/7 = 4 "College"), gen(SchLvl) label(SchoolLevel)
	
		gen MaxSchYrs_Spouse=MaxSchYrs
	
		keep pidlink* MaxSchYrs* SchLvl*
	
		save "$maindir$tmp/Spouse Education.dta", replace

	restore

	merge 1:1 pidlink_spouse using "$maindir$tmp/Spouse Education.dta", update replace keep(1 3 4 5) keepusing(pidlink MaxSchYrs_Spouse SchLvl_Spouse) nogen
	merge 1:1 pidlink2 using "$maindir$tmp/Spouse Education.dta", update replace keep(1 3 4 5) keepusing(pidlink MaxSchYrs SchLvl) nogen
		erase "$maindir$tmp/Spouse Education.dta"

	order pidlink hhid pidlink_couple pidlink2 pidlink_spouse wave year_start year_end SchLvl MaxSchYrs SchLvl_Spouse MaxSchYrs_Spouse
	sort pidlink_couple Sex
	
	* If the above did not work, use the information from the original marriage files to update the missing information
	
	preserve
	
		keep pidlink2 pidlink_spouse MaxSch* SchLvl*
		
		rename (pidlink2 pidlink_spouse MaxSchYrs SchLvl MaxSchYrs_Spouse SchLvl_Spouse) (pidlink_spouse pidlink2 MaxSchYrs_Spouse SchLvl_Spouse MaxSchYrs SchLvl)
	
		save "$maindir$tmp/Spouse Education.dta", replace
		
	restore
	
	merge 1:1 pidlink2 pidlink_spouse using "$maindir$tmp/Spouse Education.dta", update keep(1 3 4 5) nogen
		erase "$maindir$tmp/Spouse Education.dta"

********************************************************************************
* Merge in birth years

	merge 1:1 pidlink using "$maindir$project/birthyear.dta", keep(1 3) nogen
	
	gen age=year_start-birthyr
		
********************************************************************************
* Identify the inconsistent Couples to drop

* Identify those with inconsistent dates (end ofmarriage before mearriage start) and
* those with missing marriage start dates

	gen flag_InconsisDates=1 if year_start==. | (year_start==. & year_end!=.) | (year_end<year_start)
	
* Identify those who have an age of marriage less than 10 years of age

	gen flag_InconsisAge=1 if age<10
	
	bysort pidlink_couple (Sex): egen flag_InconsisAgeMax=max(flag_InconsisAge)
		drop flag_InconsisAge
	
* Identify those who should have an year_end date and have none
	
	gen flag_NoYearEnd=1 if MaritalStat==0 & year_end==. 
	
	by pidlink_couple (Sex): egen flag_NoYearEndMax=max(flag_NoYearEnd)
		drop flag_NoYearEnd
		
* Identify those where a male has stated he has more than one wife

	gen flag_Bigamy=1 if Wives==1
	
	by pidlink_couple (Sex): egen flag_BigamyMax=max(flag_Bigamy)
		drop flag_Bigamy
		
* Consolidate and drop

	egen Drop=rsum(flag*), missing
	
	drop if Drop>=1 & Drop!=.
	 drop flag* Drop
