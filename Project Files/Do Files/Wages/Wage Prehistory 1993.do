// 1993 Wage History Cleaning File - First Job and subsequent

********************************************************************************
// Raw data

use "$maindir$wave_1/buk3tk5.dta"

********************************************************************************
// Generate Years

* Merge in the birthyear data

merge m:1 pidlink using "$maindir$project/birthyear.dta", keep (1 3) nogen

* First Job: Year reported

	gen year=tk47
	gen age=tk48
	
	* replace with missing codes indicating unkown values
		replace year=. if tk47==tk48
		replace age=. if tk47==tk48
	
	* replace age if it is the same or greater than 96
	
		replace age=. if tk47>=96 & tk48>=96
		replace age=. if age>93
		
	* replace year if it is greater than 93
	
		replace year=. if year>93
		
	* Add 1900 to the year
	
		replace year=1900+year
		
	* Generate year for those with only age based on birth year
	
		replace year=birthyr+age if year==.
		
		drop age birthyr
		
	* Generate the 1983 and 1973 jobs
	
		replace year=1983 if jobrec==2 & year==.
		replace year=1973 if jobrec==3 & year==.
		replace year=. if year>1993
		
	* Flag inconsitencies where first job age is after the observed 1973 or 1983
	* (due to birth year inconsistency)
		
		gen FirstJob=1 if jobrec==1
		
		bysort pidlink (year): gen year_unorder=(FirstJob[1]!=1 & year!=.)
		
		by pidlink: gen obs=_n
		
		by pidlink: gen flag_FirstJobInconsis=1 if  year_unorder[1]==1 & obs==1
		
		drop year_unorder obs
	
	sort pidlink year
	
********************************************************************************
// Clean weeks worked and income

	* replace to missing those wks worked that are greater than 52

		replace tk54=. if tk54>52
		replace tk53=. if tk54==. & tk53>97
		
********************************************************************************
// Clean wages and create the monthly wage
		
	* replace salary to missing if valued above 99996
	
	forvalues x=2/7 {
	
		replace tk56r`x'=. if tk56r`x'>=99996
	
	}
	
	replace tk56r1_=. if tk56r1_>=99996
	replace tk57r1=. if tk57r1>=99996
	
// Generate the monthly wages: these should be mutually exclusive

	egen wage_mth_1=rsum(tk56r2-tk56r7), missing
	
	gen wage_mth_2=tk56r1_
	
	gen wage_mth_3=tk57r1
	
	gen wage_mth_4=tk59r1 if tk55==6 & wage_mth_1==. & wage_mth_2==. & wage_mth_3==.
	
	* Generate dummies for values of wages 
	
		forvalues x=1/4{
		
			gen dum`x'=(wage_mth_`x'!=.)
		}
		
		gen dum_ex1=dum1*dum2
		gen dum_ex2=dum1*dum3
		gen dum_ex3=dum1*dum4
		gen dum_ex4=dum2*dum3
		gen dum_ex5=dum2*dum4
		gen dum_ex6=dum3*dum4
	
	* count the values where wages are not mutually exclusive

		count if dum_ex1==1
		count if dum_ex2==1
		count if dum_ex3==1
		count if dum_ex4==1
		count if dum_ex5==1
		count if dum_ex6==1
		
		drop dum*
	
	* generate the monthly wage variable
	
	egen wage_mth=rsum(wage_mth_*), missing
	drop wage_mth_*
	
	*replace wage_mth=. if wage_mth==0
	
	* increase the wages by 1000 (as the current wages are in units of thousands)
	
	replace wage_mth=wage_mth*1000
	
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

gen wks_yr=tk54
gen hrs_wk=tk53

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

	gen worked=(tk55<=6)
	
	replace worked=1 if wks_yr!=. // Correct for those people who say they don't know if they worked but have work information

********************************************************************************
// Keep only the necessary variables

rename (hhid93 pid93 occ52) (hhid1993 pid1993 occ2)

keep pidlink occ2 year flag_FirstJobInconsis hrs_* *_yr *_hr *_mth  worked FirstJob

order pidlink year occ2 flag_* worked hrs_* wks_yr mth_yr r_wage_hr r_wage_mth r_wage_yr ln_wage_hr ln_wage_mth ln_wage_yr FirstJob

********************************************************************************
// Fill in missing occupation codes

gen occ3=occ2

by pidlink: gen dum1=1 if occ3==""
by pidlink: egen dum2=max(dum1)

* Go forwards

bysort pidlink (year): replace occ3=occ3[_n-1] if occ3[_n]=="" & occ3[_n-1]!=""

gen dum3=1 if occ3==""

* Go backwards

bysort pidlink (year): replace occ3=occ3[_n+1] if occ3[_n]=="" & occ3[_n+1]!=""
bysort pidlink (year): replace occ3=occ3[_n+1] if occ3[_n]=="" & occ3[_n+1]!=""

replace occ2=occ3
drop occ3 dum*

********************************************************************************
// Replace the weeks/hr and wks/yr from previous observations

/* ????? - perhaps wait until i have family variables: I may impute these based on
   marriage, sex, number of children, etc. */
   
********************************************************************************
// Save the file

gen dataset="1"

gen wave=1993

save "$maindir$tmp/1993 Wage PreHistory.dta", replace


