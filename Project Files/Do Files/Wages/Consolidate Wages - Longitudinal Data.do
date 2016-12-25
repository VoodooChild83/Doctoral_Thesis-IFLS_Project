// Longitudinal Wage Database Generator

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Do the year cleaning file

qui do "$maindir$project$Do/Wages/Consolidate Wages - Repeated Year Clean.do"

preserve
	qui do "$maindir$project$Do/Wages/Consolidate Wages - Demographic Variables.do"
restore

********************************************************************************
// Make the dataset a panel to utilize time series operations

* first work with the first job 

preserve
	
	keep if job==1
	
	* destring pidlink
	
		gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
	
	* tsset the data
	
		tsset pidlink2 year
		
	* fill in the years
	
		tsfill
		
	* Remove double years where job==.
		
	* Carry forward pidlink
	
		by pidlink2: carryforward pidlink occ2, replace
		
	* Merge in the province and kap data
	
		merge 1:1 pidlink year using "$maindir$tmp/Wages - Demography.dta", keep(1 3) nogen
		
		* Carry forward the merged information
		
			bysort pidlink2 (year): carryforward *mov Sex Marriage Max* *SchLvl Urb* /*Mover*/ birth* Rel* Eth* job Children *OK, replace
	
		* Carry backward to merged variables for years that were not in the demography file
		
			gsort pidlink2 -year
			
			by pidlink2: carryforward occ2 *mov Sex Marriage Max* *SchLvl Urb* /*Mover*/ birth* Rel* Eth* Children *OK, replace
	
			sort pidlink year
			
	* Generate age
	
		gen int age=year-birthyr
	
		gen age_2=age*age
	
		* drop if age is less than 10 years old
		
		drop if age<10
		
	* Generate Migration dummies: Inter-Provincial Moves
	
		by pidlink: gen InterProvMig=1 if pidlink[_n]==pidlink[_n-1] & provmov[_n]!=provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=.
	
		replace InterProvMig=0 if InterProvMig==.
		
	* Generate Migration dummies: Intra-Provincial Moves
	
		by pidlink: gen IntraProvMig=1 if pidlink[_n]==pidlink[_n-1] & provmov[_n]==provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=. & kabmov[_n]!=kabmov[_n-1] &  kabmov[_n]!=. & kabmov[_n-1]!=.
		
		replace IntraProvMig=0 if IntraProvMig==.
		
		
	save "$maindir$tmp/Wage Database - Job1.dta", replace
			

restore

	keep if job==2
	
	* destring pidlink
	
		gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
	
	* tsset the data
	
		tsset pidlink2 year
		
	* fill in the years
	
		tsfill
		
	* Carry forward pidlink
	
		by pidlink2: carryforward pidlink occ2, replace
		
	* Merge in the province and kap data
	
		merge 1:1 pidlink year using "$maindir$tmp/Wages - Demography.dta", keep(1 3) nogen

		erase "$maindir$tmp/Wages - Demography.dta"
		
		* Carry forward the merged information
		
			bysort pidlink2 (year): carryforward *mov Sex Max* *SchLvl Urb* /*Mover*/ birth* Rel* Eth* job *OK Children, replace
	
		* Carry backward to merged variables for years that were not in the demography file
		
			gsort pidlink2 -year
			
			by pidlink2: carryforward *mov Sex Marriage Max* *SchLvl Urb* /*Mover*/ birth* Rel* Eth* *OK Children, replace
	
			sort pidlink year
			
	* Generate age
	
	gen int age=year-birthyr
	
	gen age_2=age*age
	
		* drop if age is less than 10 years old
		
		drop if age<10
		
	* Generate Migration dummies: Inter-Provincial Moves
	
		bys pidlink2 (year): gen InterProvMig=(pidlink[_n]==pidlink[_n-1] & provmov[_n]!=provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=.)
	
		replace InterProvMig=. if provmov==.
		
	* Generate Migration dummies: Intra-Provincial Moves
	
		bys pidlink2 (year): gen IntraProvMig=(pidlink[_n]==pidlink[_n-1] & provmov[_n]==provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=. & kabmov[_n]!=kabmov[_n-1] &  kabmov[_n]!=. & kabmov[_n-1]!=.)
		
		replace IntraProvMig=. if (kabmov==. & provmov!=.) | (kabmov!=. & provmov==.) | (kabmov==. & provmov==.)
		
********************************************************************************
// Append First Occupation

append using "$maindir$tmp/Wage Database - Job1.dta"
	erase "$maindir$tmp/Wage Database - Job1.dta"

sort pidlink year job

rename UrbRurmov Urban

********************************************************************************
// Create Forever Migrant Indicators **THIS NEEDS TO BE FIXED SO THAT IT IS PROPERLY TIME VARYING

* FOR EXAMPLE: A PERSON WHO HAS MOVED INTER-PROVINCIALLY SHOULD THEN HAVE A "FOREVER PROVINCIAL MIGRANT DUMMY"
* 			   THE SAME FOR SOMEONE WHO HAS AN INTRAPROVINCIAL MIGRATION EVENT. HOWEVER, THE MOMENT A
* 			   PERSON WHO WAS A PROVINCIAL MIGRANT ENGAGES IN AN INTRAPROVINCIAL MIGRATION (OR VICE VERSA)
*			   THIS PERSON BECOMES, FOREVER MORE, A "BOTH MOVER" AND SHOULD THEN BE CATAGORIZED AS SUCH.
*			   ALTERNATIVELY: PEOPLE WHO ARE BOTH MOVERS COULD BE SWITCHING BETWEEN THE TWO STATES, AND ARE NOT REALLY
*			   "BOTH MOVERS" JUST SWITCHING, AND SO THE DUMMY VARIABLE IS CAPTURING THE POST-MIGRATION WAGE PREMIUMS

* Generate a "forever mover"
	
		gen Mover = InterProvMig
		gen Mover2 = IntraProvMig
		
		by pidlink: replace Mover=1 if pidlink[_n]==pidlink[_n-1] & Mover[_n-1]==1
		by pidlink: replace Mover2=1 if pidlink[_n]==pidlink[_n-1] & Mover2[_n-1]==1
		
		/* Problem with this is that it confuses both types of movers, since people may have 
		   both types of migrations */
		   
	* Create mutually exclusive "forever" migration groups 
	
		by pidlink: egen Movermax=max(Mover)
		by pidlink: egen Mover2max=max(Mover2)
		
		by pidlink: gen MoverTest=Movermax*Mover2max
		
		* Create the mutually exclusive forever mover
		
		gen ProvMover=(Mover==1 & MoverTest==0)
		gen IntraProvMover=(Mover2==1 & MoverTest==0)
		
	
		* For those with both types of migrations
		
		egen BothMover1=rsum(Movermax Mover2max)
		egen BothMover2=rsum(Mover Mover2)
		
		gen BothMover=BothMover2 if BothMover1==2
		replace BothMover=1 if BothMover==2
		replace BothMover=0 if BothMover==.
		
		/*
		replace ProvMover=. if IntraProvMover==1 | BothMover==1
		replace IntraProvMover=. if ProvMover==1 | BothMover==1
		replace BothMover=. if IntraProvMover==1 | ProvMov==1
		*/
		
		drop Mover* BothMover1 BothMover2
		
		*statsby MeanWages=r(mean), by (ProvMover IntraProvMover BothMover) saving("$maindir$project/MeanWagesMovers.dta", replace):  summarize r_wage_hr if job==1

********************************************************************************
// Merge in the last work information

preserve
	qui do "$maindir$project$Do/Wages/Consolodate Wages - Last Wage.do"
restore

merge m:1 pidlink using "$maindir$tmp/Wages - Last Worked.dta", keep(1 3) nogen

erase "$maindir$tmp/Wages - Last Worked.dta"

sort pidlink year

********************************************************************************
* Replace negative wages with their positive wage

	foreach time in hr mth yr {
		replace r_wage_`time'=-1*r_wage_`time' if r_wage_`time'<0 & r_wage_`time'!=0
		replace ln_wage_`time'=ln(r_wage_`time') if ln_wage_`time'==. & r_wage_`time'!=.
	}
	
********************************************************************************
