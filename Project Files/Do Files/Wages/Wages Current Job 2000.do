// 2000 Work Experience of those who are currently working

********************************************************************************
// 2000 work experience: current and secondary job

use "$maindir$wave_3/b3a_tk2.dta"

gen year=2000

preserve

********************************************************************************
********************************************************************************
// First occupation
********************************************************************************
********************************************************************************
// Rename and keep the variables associated with the primary occupation

rename (tk20ab tk22a tk23a tk23a2) (occ2 hrs_wk wks_yr tot_yrs)

gen year_start=year-tot_yrs

replace year_start=int(year_start) //for decimal years

replace hrs_wk=. if hrs_wk>168
replace wks_yr=. if wks_yr>52

********************************************************************************
//Create the monthly wage
	
	egen wage_mth=rsum(tk25a1 tk26amn tk26amg), missing

********************************************************************************
//Create the yearly wage

	egen wage_yr=rsum(tk25a2 tk26ayn tk26ayg), missing
	
********************************************************************************
// Reconcile the wage/month and the wage/year

	* Identify cases where wage/month=0 and wage/year!=0
 
		gen flag_wage_incon=1 if wage_mth==0 & wage_yr!=0 & wage_yr!=.
	
		* Identify if the above have non-missing wks_yr
		
		gen flag_wks_yr=1 if flag_wage_incon==1 & wks_yr!=.
		
	* Identify the cases where wage/month is missing but wage/year is not
	
		gen flag_miss_wage_mth=1 if wage_mth==. & wage_yr!=.
		
	* Generate the month equivalent
	
		gen mth_yr=(wks_yr/52)*12
	
	* Replace the wage/month if wage/month=0 or wage/month=. but wage/year is not
	
		replace wage_mth=wage_yr/mth_yr if (flag_wks_yr==1|flag_miss_wage_mth==1)
 
	/* Replace the wage/year by upscaling the wage/month according to the year equivalent
	   for those observations that were not already adjusted. */
	
		replace wage_yr=(wage_mth*mth_yr) if flag_wks_yr==.
		
	drop flag_*
	
********************************************************************************
// Merge inflation data

merge m:1 year using "$maindir$project/Inflation/PPP.dta", keep(1 3) nogen

sort pidlink year

********************************************************************************
// Realize wages and generate the different timed wages

* Realize wages

	gen r_wage_mth=wage_mth/PPP
	gen ln_wage_mth=ln(r_wage_mth)
	
	gen r_wage_yr=wage_yr/PPP
	gen ln_wage_yr=ln(r_wage_yr)
	
	drop wage_mth wage_yr PPP
	
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
	
keep pidlink year year_start occ2 hrs_* wks_yr mth_yr r_wage_* ln_* job worked
	
save "$maindir$tmp/2000 Wage Current Occup 1.dta",replace

restore

********************************************************************************
********************************************************************************
// Second occupation
********************************************************************************
********************************************************************************
// Rename and keep the variables associated with the primary occupation

rename (tk20bb tk22b tk23b tk23b2) (occ2 hrs_wk wks_yr tot_yrs)

gen year_start=year-tot_yrs

replace year_start=int(year_start) //for decimal years

replace hrs_wk=. if hrs_wk>168
replace wks_yr=. if wks_yr>52

********************************************************************************
//Create the monthly wage
	
	egen wage_mth=rsum(tk25b1 tk26bmn tk26bmg), missing

********************************************************************************
//Create the yearly wage

	egen wage_yr=rsum(tk25b2 tk26byn tk26byg), missing
	
********************************************************************************
// Reconcile the wage/month and the wage/year

	* Identify cases where wage/month=0 and wage/year!=0
 
		gen flag_wage_incon=1 if wage_mth==0 & wage_yr!=0 & wage_yr!=.
	
		* Identify if the above have non-missing wks_yr
		
		gen flag_wks_yr=1 if flag_wage_incon==1 & wks_yr!=.
		
	* Identify the cases where wage/month is missing but wage/year is not
	
		gen flag_miss_wage_mth=1 if wage_mth==. & wage_yr!=.
		
	* Generate the month equivalent
	
		gen mth_yr=(wks_yr/52)*12
	
	* Replace the wage/month if wage/month=0 or wage/month=. but wage/year is not
	
		replace wage_mth=wage_yr/mth_yr if (flag_wks_yr==1|flag_miss_wage_mth==1)
 
	* Replace the wage/year by upscaling the wage/month according to the year equivalent
	* for those observations that were not already adjusted. 
	
		replace wage_yr=(wage_mth*mth_yr) if flag_wks_yr==.
		
	drop flag_*
	
********************************************************************************
// Merge inflation data

merge m:1 year using "$maindir$project/Inflation/PPP.dta", keep(1 3) nogen

sort pidlink year

********************************************************************************
// Realize wages and generate the different timed wages

* Realize wages

	gen r_wage_mth=wage_mth/PPP
	gen ln_wage_mth=ln(r_wage_mth)
	
	gen r_wage_yr=wage_yr/PPP
	gen ln_wage_yr=ln(r_wage_yr)
	
	drop wage_mth wage_yr PPP
	
* Generate total hours worked per year

	gen hrs_yr=hrs_wk*wks_yr
	
* Generate total hours worked per month

	gen hrs_mth=hrs_wk*wks_yr*1/12
	
* Generate the hourly wage 

	gen r_wage_hr=r_wage_yr/hrs_yr
	
	gen ln_wage_hr=ln(r_wage_hr)
	
* Generate occupation number

	gen int job=2
	
* Generate if worked

	gen worked=1 if r_wage_yr!=. | (hrs_wk!=. & wks_yr!=. & r_wage_mth==. & occ2!="") | (hrs_wk!=. & wks_yr==. & r_wage_mth!=. & occ2!="") | (hrs_wk==. & wks_yr!=. & r_wage_mth!=. & occ2!="") | (hrs_wk==. & wks_yr!=. & r_wage_mth==. & occ2!="") | (hrs_wk!=. & wks_yr==. & r_wage_mth==. & occ2!="") | (hrs_wk==. & wks_yr==. & r_wage_mth!=. & occ2!="")
	
	keep if worked==1
	
keep pidlink year occ2 hrs_* wks_yr mth_yr r_wage_* ln_* job worked year_start
	
save "$maindir$tmp/2000 Wage Current Occup 2.dta",replace

********************************************************************************
********************************************************************************
// Append the first dataset 
********************************************************************************
********************************************************************************

append using "$maindir$tmp/2000 Wage Current Occup 1.dta"

sort pidlink job year

********************************************************************************

gen wave=2000

gen dataset="4"

save "$maindir$tmp/2000 Wage Current.dta", replace

forvalues x=1/2{

	erase "$maindir$tmp/2000 Wage Current Occup `x'.dta"
	}

	
