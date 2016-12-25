* This do file will update the widowed couples enddates by incorporating the
* "exit year" information from the Master Track information (under variable
* a18eyr - the year the individual exited the household - cross-referenced with
* the status of the person's death categorization via variable ar01a). 
*
* This file will also try to grab the divorced partners who have missing year_end information

********************************************************************************
// Generate the death (or exit year, to see how many people I actually grab)

preserve

	use "$maindir$project/MasterTrack2.dta", clear
	
	collapseandpreserve (lastnm) ar01a ar18eyr, by(pidlink) omitstatfromvarlabel
	
	* Recall that in the dataset the living spouse is pidlink2 and the "dead"
	* or "divorced" spouse is pidlink_spouse. So we will generate the dataset of when the spouse
	* "exited" the household and merge against this spouse in the sub dataset where the 
	* individual (pidilnk2 person) has declared they are either not married 
	* anymore or divorced and the year is missing. 
	
	gen double pidlink_spouse= real(pidlink)
		format pidlink_spouse %12.0f
		drop pidlink
		drop if pidlink_spouse==.
	
	save "$maindir$tmp/HH exit years.dta", replace
	
	* Keep only the dates for those who are dead
	
		keep if ar01a==0
	
		rename ar18eyr year_end
		
		drop ar01a
		
		save "$maindir$tmp/HH death exit years.dta", replace
		
	* Create a seperate file for those who are identified as anything other than dead
		
		use "$maindir$tmp/HH exit years.dta", clear
	
		drop if ar01a==0
		
		rename ar18eyr year_end
		
		drop ar01a
		
		save "$maindir$tmp/HH exit years.dta", replace

restore

// Generate the subfiles of widowed and divorced and update the year_end dates

	* Work first with those who are widowed and year_end is missing

	preserve

		keep if MaritalStat==0 & year_end==. & Divorced==0
		
		* Merge from death dates
		
		merge 1:1 pidlink_spouse using "$maindir$tmp/HH death exit years.dta", update keep(1 3 4)
			erase "$maindir$tmp/HH death exit years.dta"
			
			* Create the flag variable identifying this merge
		
			recode _merge (4 = 1 "Widow Updated") (1 3= 0 "Widow Not Updated"), gen(flag_WidowFile1Update) label(WidowDeathUpdate)
				drop _merge
				
		* Merge from the more general "Not in Household"
			
		merge 1:1 pidlink_spouse using "$maindir$tmp/HH exit years.dta", update keep(1 3 4)
		
		recode _merge (4 = 1 "Widow Updated") (1 3 = 0 "Widow Not Updated"), gen(flag_WidowFile2Update) label(WidowNHHUpdate)
				drop _merge
				
		save "$maindir$tmp/Marriage History Database - Widowers.dta", replace
		
	restore
	
	* Now work on those who are divorced and have no end dates
	
	preserve
	
		keep if MaritalStat==0 & year_end==. & Divorced==1
		
		merge 1:1 pidlink_spouse using "$maindir$tmp/HH exit years.dta", update keep(1 3 4)
			erase "$maindir$tmp/HH exit years.dta"
		
		recode _merge (4 = 1 "Divorce Updated") (1 3 = 0 "Divorce Not Updated"), gen(flag_DivorceUpdate) label(DivorceUpdate)
				drop _merge
				
		* Append the widowed persons to this dataset for a quick merge with the original dataset
		
		append using "$maindir$tmp/Marriage History Database - Widowers.dta"
			erase "$maindir$tmp/Marriage History Database - Widowers.dta"
			
			drop flag_*
			
		save "$maindir$tmp/Marriage History Database - Widowers and Divorced.dta", replace
	
	restore
	
// Update the database
	
	drop if MaritalStat==0 & year_end==.
	
	append using "$maindir$tmp/Marriage History Database - Widowers and Divorced.dta", gen(WidowDivorceApp)
		
	* Update now the year_end dates for the partner spouse as in the other dataset: Since the individual (pidlink2)
	* has been updated, use the Widowers and Divorced data file to merge in the missing year for the dead/divorced spouse
	
	preserve
	
		use "$maindir$tmp/Marriage History Database - Widowers and Divorced.dta", clear
		
		rename (pidlink2 pidlink_spouse) (pidlink_spouse pidlink2)
		
		save "$maindir$tmp/Marriage History Database - Widowers and Divorced.dta", replace
	
	restore
	
	merge 1:1 pidlink_spouse pidlink2 using "$maindir$tmp/Marriage History Database - Widowers and Divorced.dta", update keep(1 3 4 5) keepusing(year_end) nogen
		erase "$maindir$tmp/Marriage History Database - Widowers and Divorced.dta"
		
	drop WidowDivorceApp
	
