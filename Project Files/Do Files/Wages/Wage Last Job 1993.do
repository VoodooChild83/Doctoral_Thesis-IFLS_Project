// 1993 Work Experience of those who no longer work

********************************************************************************
// 1993 work experience: stoppage of work and year

use "$maindir$wave_1/buk3tk1.dta"

********************************************************************************
// Rename relavant variables

rename (occ12) (occ2)

********************************************************************************
// Test that those who are working don't have data input into this file => that
// this file is seemingly exclusive to those who have ended their working life

count if tk01==1 & tk13!=.
count if tk01==1 & tk14!=.
count if tk01==1 & tk16rp!=.
count if tk01==1 & tk17r1!=.

forvalues x=1/6{
	count if tk01==1 & tk16r`x'!=.
	}
	
drop if tk01==1  // Drop those who are still working

********************************************************************************
// Generate Year

gen year=1900+tk07

replace year=. if year>1993

* Test if the tk07 (years) that are missing have associated wage values

	count if year==. & ( tk13!=.| tk14!=.| tk16rp!=. |tk17r1!=.)
    
	forvalues x=1/6{
		count if year==. & tk16r`x'!=.
		}
********************************************************************************
// Generate Work Status

gen stopped_1987=1 if tk06==1

gen unpaid=1 if tk15==6
	
gen dum_nvrwrkd=1 if tk05==3
gen dum=1 if (tk01!=5 & year!=.)
gen dum2=1 if stopped_1987==1
gen dum_keep=1 if dum_nvrwrkd==1 | dum==1 |dum2==1

drop if year==. & dum_keep!=1

drop dum2

gen stopped_wrk= 1 if tk05==1 & tk01!=1
gen retired= 1 if tk01==5
gen neverwrkd=1 if dum_nvrwrkd==1

replace retired=. if neverwrkd==1
replace stopped_wrk=. if retired==1

********************************************************************************
// Clean hours worked and weeks worked

gen hrs_wk=tk13
gen wks_yr=tk14

replace wks_yr=. if wks_yr>52

replace hrs_wk=. if wks_yr==.

********************************************************************************
// Clean the wages

* replace salary to missing if valued above 99996
	
	forvalues x=1/6 {
	
		replace tk16r`x'=. if tk16r`x'>=99996
	
	}
	
	replace tk16rp_=. if tk16rp_>=99996
	replace tk17r1=. if tk17r1>=99996
	
* Generate the monthly wages: these should be mutually exclusive
	
	egen wage_mth_1=rsum(tk16r1-tk16r6), missing
	
	gen wage_mth_2=tk16rp_
	
	gen wage_mth_3=tk17r1
	
	* Generate dummies for values of wages 
	
		forvalues x=1/3{
		
			gen dum`x'=(wage_mth_`x'!=.)
		}
		
		gen dum_ex1=dum1*dum2
		gen dum_ex2=dum1*dum3
		gen dum_ex3=dum2*dum3
		
		count if dum_ex1==1
		count if dum_ex2==1
		count if dum_ex3==1

		drop dum*
		
	* generate the monthly wage variable
	
		egen wage_mth=rsum(wage_mth_*), missing
		drop wage_mth_*
	
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

********************************************************************************
// Create income and time variables

* Generate a year equivalent

	gen mth_yr=(wks_yr/52)*12

* Realize the yearly income wage data

	gen r_wage_yr=r_wage_mth*mth_yr
	
	gen ln_wage_yr=ln(r_wage_yr)

* Generate total hours worked per year

	gen hrs_yr=hrs_wk*wks_yr
	
* Generate the hourly wage 

	gen r_wage_hr=r_wage_yr/hrs_yr
	
	gen ln_wage_hr=ln(r_wage_hr)
	
********************************************************************************
// Keep the desired variables

keep  pidlink occ2 year hrs_wk wks_yr mth_yr r_wage_hr r_wage_mth r_wage_yr ln_wage_yr ln_wage_hr stopped_wrk retired neverwrkd stopped_1987 unpaid
	
order pidlink year occ2 stopped_1987 stopped_wrk unpaid retired neverwrkd hrs_wk wks_yr mth_yr r_wage_hr r_wage_mth r_wage_yr ln_wage_hr ln_wage_yr
	
gen dataset="3"

gen wave=1993

save "$maindir$tmp/1993 Wage Last Job.dta", replace








