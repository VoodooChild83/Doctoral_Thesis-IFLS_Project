// Longitudinal Wage Database Generator

********************************************************************************
// Do the year cleaning file

qui do "$maindir$project$Do/Wages/Consolidate Wages - Repeated Year Clean.do"

preserve
	clear
	qui do "$maindir$project$Do/Wages/Consolidate Wages - Demographic Variables.do"
restore

preserve
	clear
	qui do "$maindir$project$Do/Wages/Occupation Codes - Abilities.do"
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
		
	* Merge in the data
	
		merge 1:1 pidlink year using "$maindir$tmp/Wages - Demography.dta", keep(1 3) nogen
		
		merge m:1 pidlink using "$maindir$tmp/Demos.dta", update replace keep(1 3 4 5) nogen

		joinby pidlink year using "$maindir$tmp/Demos-location.dta", update unm(m)
		drop _merge
		/*
		merge m:1 pidlink using "$maindir$tmp/Parental Migration.dta", keep(1 3)
	
			recode _merge (1=0 "Not Children") (3=1 "Children"), gen(Children) label(children)
			drop _merge
		*/
		* Carry forward the merged information
		
			bysort pidlink2 (year): carryforward *mov Urb* birth* job, replace
	
		* Carry backward to merged variables for years that were not in the demography file
		
			gsort pidlink2 -year
			
			by pidlink2: carryforward occ2 provmov Islandmov Urb* birth*, replace
	
			sort pidlink year
			
	* Generate age
	
		replace age=year-birthyr
	
		gen age_2=age*age
	
		* drop if age is less than 10 years old
		
			drop if age<10
	
	* Generate Migration dummies: Inter-Provincial Moves
	
		*by pidlink: gen InterProvMig=1 if pidlink[_n]==pidlink[_n-1] & provmov[_n]!=provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=.
	
		recode Inter* (.=0) 
		recode Intra* (.=0)
		recode Prov* (.=0)
		
	* Generate Migration dummies: Intra-Provincial Moves
	
		*by pidlink: gen IntraProvMig=1 if pidlink[_n]==pidlink[_n-1] & provmov[_n]==provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=. & kabmov[_n]!=kabmov[_n-1] &  kabmov[_n]!=. & kabmov[_n-1]!=.
		
		*replace IntraProvMig=0 if IntraProvMig==.
		
		
	save "$maindir$tmp/Wage Database - Job1.dta", replace
			

restore

	keep if job==2
	
	** destring pidlink
	
		gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
	
	* tsset the data
	
		tsset pidlink2 year
		
	* fill in the years
	
		tsfill
		
	* Remove double years where job==.
		
	* Carry forward pidlink
	
		by pidlink2: carryforward pidlink occ2, replace
		
	* Merge in the data
	
		merge 1:1 pidlink year using "$maindir$tmp/Wages - Demography.dta", keep(1 3) nogen
		
		merge m:1 pidlink using "$maindir$tmp/Demos.dta", update replace keep(1 3 4 5) nogen

		joinby pidlink year using "$maindir$tmp/Demos-location.dta", update unm(m)
		drop _merge
		/*
		merge m:1 pidlink using "$maindir$tmp/Parental Migration.dta", keep(1 3)
	
			recode _merge (1=0 "Not Children") (3=1 "Children"), gen(Children) label(children)
			drop _merge
		
		erase "$maindir$tmp/Parental Migration.dta" */
		erase "$maindir$tmp/Wages - Demography.dta"
		erase "$maindir$tmp/Demos.dta"
		erase "$maindir$tmp/Demos-location.dta"
		
		
		* Carry forward the merged information
		
			bysort pidlink2 (year): carryforward *mov Urb* birth* job, replace
	
		* Carry backward to merged variables for years that were not in the demography file
		
			gsort pidlink2 -year
			
			by pidlink2: carryforward occ2 provmov Islandmov Urb* birth*, replace
	
			sort pidlink year
			
	* Generate age
	
		replace age=year-birthyr
	
		gen age_2=age*age
	
		* drop if age is less than 10 years old
		
			drop if age<10
	
	* Generate Migration dummies: Inter-Provincial Moves
	
		*by pidlink: gen InterProvMig=1 if pidlink[_n]==pidlink[_n-1] & provmov[_n]!=provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=.
	
		recode Inter* (.=0) 
		recode Intra* (.=0)
		recode Prov* (.=0)
		
	* Generate Migration dummies: Intra-Provincial Moves
	
		*bys pidlink2 (year): gen IntraProvMig=(pidlink[_n]==pidlink[_n-1] & provmov[_n]==provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=. & kabmov[_n]!=kabmov[_n-1] &  kabmov[_n]!=. & kabmov[_n-1]!=.)
		
		*replace IntraProvMig=. if (kabmov==. & provmov!=.) | (kabmov!=. & provmov==.) | (kabmov==. & provmov==.)
		
********************************************************************************
// Append First Occupation

append using "$maindir$tmp/Wage Database - Job1.dta"
	erase "$maindir$tmp/Wage Database - Job1.dta"

sort pidlink year job

rename UrbRurmov Urban

********************************************************************************
// Identify Children from Parental link information
/*
preserve

	use "$maindir$tmp/Parent Child Link - Master.dta", clear
	
	* Drop if parental codes are missing
		drop if pidlink_father==. | pidlink_mother==.
	
	* Drop duplicates
		duplicates drop pidlink, force
		
	* Generate a Child code
	
	gen Child=1
	
	keep pidlink Child

	save "$maindir$tmp/Children.dta", replace

restore
*/
*merge m:1 pidlink using "$maindir$tmp/Children.dta", keep(1 3) nogen
*rm "$maindir$tmp/Children.dta"

/*
merge m:1 pidlink using "$maindir$tmp/Identified Children.dta", keep(1 3) keepusing(pidlink_father pidlink_mother) gen(Child)

gen Child_1 = 1 if (Children==1 & Child==1) | (Children==1 & Child!=1) | (Children!=1 & Child==1)
drop Child Children
rename Child_1 Children
*/
********************************************************************************
// Create Forever Migrant Indicators **THIS NEEDS TO BE FIXED SO THAT IT IS PROPERLY TIME VARYING

* FOR EXAMPLE: A PERSON WHO HAS MOVED INTER-PROVINCIALLY SHOULD THEN HAVE A "FOREVER PROVINCIAL MIGRANT DUMMY"
* 			   THE SAME FOR SOMEONE WHO HAS AN INTRAPROVINCIAL MIGRATION EVENT. HOWEVER, THE MOMENT A
* 			   PERSON WHO WAS A PROVINCIAL MIGRANT ENGAGES IN AN INTRAPROVINCIAL MIGRATION (OR VICE VERSA)
*			   THIS PERSON BECOMES, FOREVER MORE, A "BOTH MOVER" AND SHOULD THEN BE CATAGORIZED AS SUCH.
*			   ALTERNATIVELY: PEOPLE WHO ARE BOTH MOVERS COULD BE SWITCHING BETWEEN THE TWO STATES, AND ARE NOT REALLY
*			   "BOTH MOVERS" JUST SWITCHING, AND SO THE DUMMY VARIABLE IS CAPTURING THE POST-MIGRATION WAGE PREMIUMS
/*
* Generate a "forever mover"
	
		gen Mover = InterProvMig
		gen Mover2 = IntraProvMig
		
		bys pidlink (year job): replace Mover=1 if pidlink[_n]==pidlink[_n-1] & Mover[_n-1]==1
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
*/
********************************************************************************
// Merge in the last work information

preserve
	clear
	qui do "$maindir$project$Do/Wages/Consolodate Wages - Last Wage.do"
restore

merge m:1 pidlink using "$maindir$tmp/Wages - Last Worked.dta", keep(1 3) nogen

erase "$maindir$tmp/Wages - Last Worked.dta"

sort pidlink year job 

replace year_stopped=. if year_stopped==9998|year_stopped==9999

* Fill in the wage of the year stopped work

preserve

	keep pidlink year_stopped occ2_stopped-r_wage_mth_stopped job
	
	rename *_stopped *
	
	collapse (max) r_wage_hr r_wage_mth (firstnm) occ2 *_wk *_yr, by(pidlink year job)
	
	save "$maindir$tmp/Last Job.dta", replace

restore

merge 1:1 pidlink year job using "$maindir$tmp/Last Job.dta", update keep(1 3 4 5) nogen
rm "$maindir$tmp/Last Job.dta"

drop *_stopped stopped_*

* update the wages of people based on the average hrs/wk and wks/yr that their occupation has

preserve

	keep job occ2 hrs_wk wks_yr
	
	collapse (median) hrs_wk wks_yr, by(occ2 job)
	
	drop if occ2==""

	save "$maindir$tmp/Time in Occ.dta", replace

restore

merge m:1 occ2 job using "$maindir$tmp/Time in Occ.dta", update keep(1 3 4 5) nogen

replace r_wage_hr=r_wage_mth/4.333*1/hrs_wk if r_wage_hr==. & r_wage_mth!=.
replace r_wage_hr=r_wage_yr*1/wks_yr*1/hrs_wk if r_wage_hr==. & r_wage_mth==. & r_wage_yr!=.

erase "$maindir$tmp/Time in Occ.dta"

replace ln_wage_hr=ln(r_wage_hr) if ln_wage_hr==. & r_wage_hr!=.

********************************************************************************
* Replace negative wages with their positive wage

	foreach time in hr mth yr {
		replace r_wage_`time'=-1*r_wage_`time' if r_wage_`time'<0 & r_wage_`time'!=0
		replace ln_wage_`time'=ln(r_wage_`time') if ln_wage_`time'==. & r_wage_`time'!=.
	}
	
********************************************************************************
* Never worked

*If we observe a wage, they worked
replace neverwrkd=0 if ln_wage_hr!=.

* identify all of the people and get rid of them
bys pidlink (year job): egen Wkd=min(neverwrkd)
replace neverwrkd=Wkd

drop if Wkd==1
drop Wkd neverwrkd
	
********************************************************************************
* Abilities

* Recode occupation 00

replace occ2="0X" if occ2=="00"

merge m:1 occ2 using "$maindir$tmp/Occ Codes Ability Level.dta", keep(1 3) nogen

sort pidlink year job

replace Skill_Level=0 if occ2=="51"|occ2=="48"|occ2=="49"|occ2=="69"
replace Skill_Level=1 if occ2=="70"|occ2=="22"|occ2=="23"|occ2=="24"|occ2=="26"|occ2=="27"|occ2=="28"|occ2=="29"

* Skill Level Other way

gen Skill_Level_School = MaxSchYrs>=9

********************************************************************************
* Find those born on or after 1980

bys pidlink (year job): gen Young=1 if FirstJob==1 & birthyr>=1980 & birthyr!=. &job==1
bys pidlink (year job): gen Test2=1 if _n==1 & birthyr>=1980 & birthyr!=. &job==1 &r_wage_hr!=. & Young!=1
bys pidlink (year job): gen Test3=1 if _n==1 & birthyr>=1980 & birthyr!=. &job==1 & unpaid==1 & Young!=1
by pidlink: egen Test2_Max=max(Test2)
by pidlink: egen Test3_Max=max(Test3)
replace Young=1 if (Test2_Max==1 & Test2==1) | (Test3_Max==1 & Test3==1)
drop Test2* Test3*

preserve

	keep if Young==1 & Children==1
	
	collapse (firstnm) year-Young, by(pidlink)

	replace unpaid=. if r_wage_hr!=.
	
	save "$maindir$tmp/First Wages of Children.dta", replace
	
restore

********************************************************************************
* Island Groups

* Create Island Designations

	replace Islandmov=1 if (provmov>=11 & provmov<=19) & Islandmov==.
			
			replace Islandmov= 2 if (provmov>=31 & provmov<=35) & Islandmov==.
			replace Islandmov= 3 if (provmov>=51 & provmov<=53) & Islandmov==.
			replace Islandmov= 4 if (provmov>=61 & provmov<=64) & Islandmov==.
			replace Islandmov= 5 if (provmov>=71 & provmov<=74) & Islandmov==.
			replace Islandmov= 6 if provmov==81 & Islandmov==.
			replace Islandmov= 7 if provmov==91 & Islandmov==.

********************************************************************************
* Find those who are adults but not the Children of other people

preserve

	keep if Young!=1 & Children!=1
	
	keep if FirstJob==1
	
	collapse (firstnm) year-Skill_Level, by(pidlink)

	replace unpaid=. if r_wage_hr!=.
	
	save "$maindir$tmp/First Wages of Adults.dta", replace

restore

