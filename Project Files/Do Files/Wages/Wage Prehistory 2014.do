// 2014 Wage History Cleaning File - First Job & Last Paying Job

********************************************************************************
// Raw data

use "$maindir$wave_5/b3a_tk4.dta"

********************************************************************************
// Cleanup the occupation string variable: remove the initial 0

	*replace occ2014=substr( occ2014, 2,.) if  occ2014!="999" // code 999 is the unknown code
	
********************************************************************************
// Generate Years

* Merge in the birthyear data

merge m:1 pidlink using "$maindir$project/birthyear.dta", keep(1 3) nogen

* First Job: Year reported

	gen year=tk47yr
	gen age=tk48
		
	* Generate year for those with only age based on birth year
	
		replace year=birthyr+age if year==.
		
		drop age birthyr
		
********************************************************************************
// Clean weeks worked and income

	* replace to missing those wks worked that are greater than 52 and hours

		replace tk54=. if tk54>52
		replace tk53=. if tk53>168
		
********************************************************************************
// Generate the monthly wages: these should be mutually exclusive

	gen wage_mth=tk56 
	
********************************************************************************
// Merge inflation data

merge m:1 year using "$maindir$project/Inflation/PPP.dta", keep(1 3) nogen

sort pidlink year

********************************************************************************
// Realize the monthly wages

gen r_wage_mth=wage_mth/PPP
drop PPP wage_mth

gen ln_wage_mth=ln(r_wage_mth)

********************************************************************************
// Generate the necessary time variables

rename (tk53 tk54) (hrs_wk wks_yr)

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
	
********************************************************************************
// Did person work?

* Worked variable

	gen worked=1 if year!=.
	
	gen FirstJob=1 if year!=.

********************************************************************************
// Keep only the necessary variables

rename (occ2014) (occ2)

gen unpaid=1 if tk55==6

keep pidlink occ2 year hrs_* *_yr *_hr *_mth  worked FirstJob unpaid

order pidlink year unpaid occ2 worked hrs_* wks_yr mth_yr r_wage_hr r_wage_mth r_wage_yr ln_wage_hr ln_wage_mth ln_wage_yr FirstJob

********************************************************************************
// Save the file

gen wave=2014

gen dataset="1"

save "$maindir$tmp/2014 Wage PreHistory.dta", replace
	
		
