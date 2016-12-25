// 1993 Work Experience of those who are currently working

********************************************************************************
// 1993 work experience: current and secondary job

use "$maindir$wave_1/buk3tk2.dta"

gen year=1993

preserve

********************************************************************************
********************************************************************************
// First occupation
********************************************************************************
********************************************************************************
// Rename and keep the variables associated with the primary occupation

rename (occ20a tk22a tk23a) (occ2 hrs_wk wks_yr)

********************************************************************************
//Create the monthly wage

	* mark as missing those values that are greater than 99996 (assumed to be the missing categories)
	
	forvalues x=1/7 {
		replace tk25r`x'm_=. if tk25r`x'm_>=99996
		}
	replace tk26r1m_=. if tk26r1m_>=99996
	
	* generate the monthly wage

	egen wage_mth=rsum(tk25r1m_ tk25r2m_ tk25r3m_ tk25r4m_ tk25r5m_ tk25r6m_ tk25r7m_  tk26r1m_), missing
	
********************************************************************************
//Create the yearly wage

	* mark as missing those values that are greater than 999996 (assumed to be the missing categories)
	
	forvalues x=1/7 {
		replace tk25r`x'y_=. if tk25r`x'y_>=999996
		}
	replace tk26r1y_=. if tk26r1y_>=999996
	
	* generate the monthly wage

	egen wage_yr=rsum(tk25r1y_ tk25r2y_ tk25r3y_ tk25r4y_ tk25r5y_ tk25r6y_ tk25r7y_  tk26r1y_), missing
	
********************************************************************************
// Clean the wks/year variable

replace wks_yr=. if wks_yr>52	

replace hrs_wk=. if (wks_yr==. & hrs_wk>7) | hrs_wk>168
	
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
		
	* Increase the amount by 1000 rupiahs
	
		replace wage_mth=wage_mth*1000
		replace wage_yr=wage_yr*1000
		
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
	
	
keep pidlink year occ2 hrs_* wks_yr mth_yr r_wage_* ln_* job worked
	
save "$maindir$tmp/1993 Wage Current Occup 1.dta",replace

restore

********************************************************************************
********************************************************************************
// Second occupation
********************************************************************************
********************************************************************************

// Rename and keep the variables associated with the primary occupation

rename (hhid pid93 occ20b tk22b tk23b) (hhid1993 pid1993 occ2 hrs_wk wks_yr)

********************************************************************************
//Create the monthly wage

	* mark as missing those values that are greater than 99996 (assumed to be the missing categories)
	
	forvalues x=1/7 {
		replace t25br`x'm_=. if t25br`x'm_>=99996
		}
	replace t26br1m_=. if t26br1m_>=99996
	
	* generate the monthly wage

	egen wage_mth=rsum(t25br1m_ t25br2m_ t25br3m_ t25br4m_ t25br5m_ t25br6m_ t25br7m_  t26br1m_), missing
	
********************************************************************************
//Create the yearly wage

	* mark as missing those values that are greater than 999996 (assumed to be the missing categories)
	
	forvalues x=1/7 {
		replace t25br`x'y_=. if t25br`x'y_>=999996
		}
	replace t26br1y_=. if t26br1y_>=999996
	
	* generate the monthly wage

	egen wage_yr=rsum(t25br1y_ t25br2y_ t25br3y_ t25br4y_ t25br5y_ t25br6y_ t25br7y_  t26br1y_), missing
	
********************************************************************************
// Clean the wks/year variable

replace wks_yr=. if wks_yr>52	

replace hrs_wk=. if (wks_yr==. & hrs_wk>7) | hrs_wk>168
	
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
		
	* Increase the amount by 1000 rupiahs
	
		replace wage_mth=wage_mth*1000
		replace wage_yr=wage_yr*1000
		
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
	
keep pidlink year occ2 hrs_* wks_yr mth_yr r_wage_* ln_* job worked
	
save "$maindir$tmp/1993 Wage Current Occup 2.dta",replace

********************************************************************************
********************************************************************************
// Append the first dataset 
********************************************************************************
********************************************************************************

append using "$maindir$tmp/1993 Wage Current Occup 1.dta"

sort pidlink job year

********************************************************************************

gen wave=1993

gen dataset="4"

save "$maindir$tmp/1993 Wage Current.dta", replace

forvalues x=1/2{

	erase "$maindir$tmp/1993 Wage Current Occup `x'.dta"
	}

	





