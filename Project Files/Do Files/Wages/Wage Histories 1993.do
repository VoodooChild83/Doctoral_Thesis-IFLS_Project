// 1993 Wage History Cleaning File

********************************************************************************
// 1993 History Data

use "$maindir$wave_1/buk3tk3.dta"

preserve
********************************************************************************
********************************************************************************
// First occupation
********************************************************************************
********************************************************************************

// Rename and keep the variables associated with the primary occupation

replace year=1900+year

rename (hhid pid93 occ32 tk33 tk34) (hhid1993 pid1993 occ2 hrs_wk wks_yr)

********************************************************************************
//Create the monthly wage

	* mark as missing those values that are greater than 99996 (assumed to be the missing categories)
	
	forvalues x=1/7 {
		replace tk36r`x'=. if tk36r`x'>=99996
		}
	replace tk37r1=. if tk37r1>=99996
	
	* generate the monthly wage

	egen wage_mth=rsum(tk36r* tk37r1), missing

	replace wage_mth=wage_mth*1000
	
********************************************************************************
//Keep only necessary data

keep pidlink occ2 hrs_wk wks_yr wage_mth year

********************************************************************************
// Merge inflation data

merge m:1 year using "$maindir$project/Inflation/PPP.dta", keep(1 3) nogen

sort pidlink year

********************************************************************************
// Clean the hrs/week variable and generate the necessary yearly variables

replace hrs_wk=. if hrs_wk>168
replace wks_yr=. if wks_yr>52

* Realize monthly wages

	gen r_wage_mth=wage_mth/PPP
	drop PPP wage_mth
	
	gen ln_wage_mth=ln(r_wage_mth)

* Generate a year equivalent

	gen mth_yr=(wks_yr/52)*12

* Realize the yearly income wage data

	gen r_wage_yr=r_wage_mth*mth_yr
	
	gen ln_wage_yr=ln(r_wage_yr)

* Generate total hours worked per year

	gen hrs_yr=hrs_wk*wks_yr
	
* Generate total hours worked per month

	gen hrs_mth=hrs_wk*wks_yr*1/12
	
* Generate the hourly wage 

	gen r_wage_hr=r_wage_yr/hrs_yr
	
	gen ln_wage_hr=ln(r_wage_hr)
	
* Generate occupation number

	gen int job=1
	
* Generate if worked

	gen worked=1 if r_wage_yr!=. | (hrs_wk!=. & wks_yr!=. & r_wage_mth==. & occ2!="") | (hrs_wk!=. & wks_yr==. & r_wage_mth!=. & occ2!="") | (hrs_wk==. & wks_yr!=. & r_wage_mth!=. & occ2!="") | (hrs_wk==. & wks_yr!=. & r_wage_mth==. & occ2!="") | (hrs_wk!=. & wks_yr==. & r_wage_mth==. & occ2!="") | (hrs_wk==. & wks_yr==. & r_wage_mth!=. & occ2!="")
	
save "$maindir$tmp/1993 Wage History Occup 1.dta",replace

restore

********************************************************************************
********************************************************************************
// Second occupation
********************************************************************************
********************************************************************************

replace year=1900+year

rename (hhid pid93 occ42 tk43 tk44 tk46r1) (hhid1993 pid1993 occ2 hrs_wk wks_yr wage_mth)

keep pidlink occ2 hrs_wk wks_yr wage_mth year

********************************************************************************
// Merge inflation data - PPP to create the INT$ instead of keeping things in Rupiah

merge m:1 year using "$maindir$project/Inflation/PPP.dta", keep(1 3) nogen

sort pidlink year

********************************************************************************
// Clean the hrs/week variable and generate the necessary yearly wage variables

replace hrs_wk=. if hrs_wk>168
replace wks_yr=. if wks_yr>52

* Realize monthly wages

	gen r_wage_mth=wage_mth/PPP
	drop PPP wage_mth

	gen ln_wage_mth=ln(r_wage_mth)
	
* Generate a year equivalent

	gen mth_yr=(wks_yr/52)*12

* Realize the yearly income wage data

	gen r_wage_yr=r_wage_mth*mth_yr
	
	gen ln_wage_yr=ln(r_wage_yr)

* Generate total hours worked per year

	gen hrs_yr=hrs_wk*wks_yr
	
* Generate total hours worked per month

	gen hrs_mth=hrs_wk*wks_yr*1/12
	
* Generate the hourly wage 

	gen r_wage_hr=r_wage_yr/hrs_yr
	
	gen ln_wage_hr=ln(r_wage_hr)
	
* Generate job number

	gen int job=2
	
* Generate if worked

	gen worked=1 if r_wage_yr!=. | (hrs_wk!=. & wks_yr!=. & r_wage_mth==. & occ2!="") | (hrs_wk!=. & wks_yr==. & r_wage_mth!=. & occ2!="") | (hrs_wk==. & wks_yr!=. & r_wage_mth!=. & occ2!="") | (hrs_wk==. & wks_yr!=. & r_wage_mth==. & occ2!="") | (hrs_wk!=. & wks_yr==. & r_wage_mth==. & occ2!="") | (hrs_wk==. & wks_yr==. & r_wage_mth!=. & occ2!="")	
	
	keep if worked==1
	
save "$maindir$tmp/1993 Wage History Occup 2.dta",replace

********************************************************************************
********************************************************************************
// Append the first dataset 
********************************************************************************
********************************************************************************

append using "$maindir$tmp/1993 Wage History Occup 1.dta"

sort pidlink job year

********************************************************************************
// Save the file

gen wave=1993

gen dataset="2"

save "$maindir$tmp/1993 Wage History.dta", replace

forvalues x=1/2{

	erase "$maindir$tmp/1993 Wage History Occup `x'.dta"
	}


