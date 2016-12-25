// 2012 Work Experience of those who are currently working

********************************************************************************
// 2012 work experience: current and secondary job

use "$maindir$wave_East/B3A_TK2.dta", clear

gen year=2012

* Merge in the pidlink identifier

merge 1:1 hhid12 pid12 using "$maindir$tmp/IFLS_East/pidlink.dta", keepusing(pidlink pwt) keep(1 3) nogen

********************************************************************************
********************************************************************************
// First occupation
********************************************************************************
********************************************************************************
// Rename and keep the variables associated with the primary occupation

rename (tk22a tk23a tk23a2y) (hrs_wk wks_yr tot_yrs)

replace hrs_wk=. if hrs_wk>168
replace wks_yr=. if wks_yr>52
replace tot_yrs=. if tot_yrs==98

gen year_start=year-tot_yrs

replace year_start=int(year_start) //for decimal years

	/* Update the years if the contract start year is earlier than the current time
	   working in that job (start_year --> contract renewals at current job) */
	   
	    gen dum=1 if year_start!=tk24a7y & year_start!=. & tk24a7y!=. & tk24a7y<year_start
		
		replace year_start=tk24a7y if dum==1
		
		drop dum

********************************************************************************
//Create the monthly wage
	
	egen wage_mth=rsum(tk25a1 tk26a1), missing
	
	replace wage_mth=. if wage_mth>=999999999 

********************************************************************************
//Create the yearly wage

	egen wage_yr=rsum(tk25a2 tk26a3), missing
	
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

	gen worked=1 if r_wage_yr!=. | (hrs_wk!=. & wks_yr!=. & r_wage_mth==.) | (hrs_wk!=. & wks_yr==. & r_wage_mth!=.) | (hrs_wk==. & wks_yr!=. & r_wage_mth!=.) | (hrs_wk==. & wks_yr!=. & r_wage_mth==.) | (hrs_wk!=. & wks_yr==. & r_wage_mth==.) | (hrs_wk==. & wks_yr==. & r_wage_mth!=.)
	
* Merge in Last year work salary from /hh data/B3P_TKP1.dta if there is missing wage data

preserve

	use "$maindir$wave_East/BK_AR2.dta", clear
	
	rename ar15b wage_yr
	
	keep pid12 hhid12 wage_yr
	
	save "$maindir$tmp/Salary Update.dta", replace

restore

* merge in the salary update

merge 1:1 hhid12 pid12 using "$maindir$tmp/Salary Update.dta", update keep(3 4 5) 
erase "$maindir$tmp/Salary Update.dta"

* Use the merge variable to check how many missing r_wage_month exist

gen dum_miss_wage=1 if _merge==4 & r_wage_hr==.
drop _merge

* Realize yearly wages of those who had an update
replace r_wage_yr=wage_yr/PPP if dum_miss_wage==1

* Convert to hourly wages if they have hrs/year variable filled in
replace r_wage_hr=r_wage_yr/hrs_yr if dum_miss_wage==1
replace ln_wage_hr=ln(r_wage_hr) if dum_miss_wage==1

keep pidlink year year_start hrs_* wks_yr mth_yr r_wage_* ln_* job worked pwt

gen double pidlink2= real(pidlink)
		format pidlink2 %12.0f

save "$maindir$tmp/2012 Wage Current.dta", replace
