// 1997 Wage History Cleaning File

********************************************************************************
// 1997 History Data

use "$maindir$wave_2/b3a_tk3.dta"

preserve
********************************************************************************
********************************************************************************
// First occupation
********************************************************************************
********************************************************************************

// Rename and keep the variables associated with the primary occupation

rename (hhid97 pid97 tk28yr tk32occ tk34 tk35n tk35g tk36 tk37) (hhid1997 pid1997 year occ2 wage_mth_1 wage_mth_2 wage_mth_3 hrs_wk wks_yr)

keep pidlink year occ2 wage_mth_* hrs_wk wks_yr

********************************************************************************
// Cross-check that the three monthly wages are "exclusive"

gen wage_1_2=1 if wage_mth_1!=. & wage_mth_2!=.

	//only one observation: same amount in wage_mth_2 as wage_mth_1 => replace with missing one of them
	
	replace wage_mth_1=. if wage_1_2==1
	
gen wage_1_3=1 if wage_mth_1!=. & wage_mth_3!=. // no observations
	
gen wage_2_3=1 if wage_mth_2!=. & wage_mth_3!=. // no observations

********************************************************************************
// Create the monthly wage variable

egen wage_mth=rsum(wage_mth_*), missing

 /*Monthly wage breakdowns sum to the total month income reported, so no need to
   deal with these variables.*/

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
	drop PPP wage_*
	
	gen ln_wage_mth=ln(r_wage_mth)

* Generate a year equivalent

	gen mth_yr=(wks_yr/52)*12

*Realize the yearly income wage data

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
	
save "$maindir$tmp/1997 Wage History Occup 1.dta",replace

restore

********************************************************************************
********************************************************************************
// Second occupation
********************************************************************************
********************************************************************************

rename (hhid97 pid97 tk28yr tk42occ tk44 tk45n tk45g tk46 tk47) (hhid1997 pid1997 year occ2 wage_mth_1 wage_mth_2 wage_mth_3 hrs_wk wks_yr)

keep pidlink year occ2 wage_mth_* hrs_wk wks_yr

********************************************************************************
// Cross-check that the three monthly wages are "exclusive"

gen wage_1_2=1 if wage_mth_1!=. & wage_mth_2!=.

gen wage_1_3=1 if wage_mth_1!=. & wage_mth_3!=. // no observations
	
gen wage_2_3=1 if wage_mth_2!=. & wage_mth_3!=. // no observations

count if wage_1_2==1
count if wage_1_3==1
count if wage_2_3==1

********************************************************************************
// Create the monthly wage variable

egen wage_mth=rsum(wage_mth_*), missing

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
	drop PPP wage_*
	
	gen ln_wage_mth=ln(r_wage_mth)

* Generate a year equivalent

	gen mth_yr=(wks_yr/52)*12

*Realize the yearly income wage data

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
	
save "$maindir$tmp/1997 Wage History Occup 2.dta",replace

********************************************************************************
********************************************************************************
// Append the first dataset 
********************************************************************************
********************************************************************************

append using "$maindir$tmp/1997 Wage History Occup 1.dta"

sort pidlink job year

********************************************************************************
// Drop the observations of years 1988-1991

gen dum=1 if year>=1988 & year<1992

count if dum==1 & r_wage_hr!=.

drop if dum==1
drop dum

********************************************************************************
// Save the file

gen wave=1997

gen dataset="2"

save "$maindir$tmp/1997 Wage History.dta", replace

forvalues x=1/2{

	erase "$maindir$tmp/1997 Wage History Occup `x'.dta"
	
	}
