// 1997 Work Experience of those who no longer work

********************************************************************************
// 1997 work experience: stoppage of work and year

use "$maindir$wave_2/b3a_tk1.dta"

********************************************************************************
// Generate Year

gen year=tk07

********************************************************************************
// Generate the work status

drop if tk01==1  // Drop those who are still working

gen unpaid=1 if tk15==6

gen stopped_1987=1 if tk06a==1
gen stopped_1992=1 if tk06b==1

gen dum_nvrwrkd=1 if tk05==3
gen dum=1 if (tk01!=5 & year!=.)
gen dum2=1 if stopped_1987==1 | stopped_1992==1
gen dum_keep=1 if dum_nvrwrkd==1 | dum==1 | dum2==1

drop if year==. & dum_keep!=1

drop dum2

gen stopped_wrk= 1 if tk05==1 & tk01!=1
gen retired= 1 if tk01==5
gen neverwrkd=1 if dum_nvrwrkd==1

replace retired=. if neverwrkd==1
replace stopped_wrk=. if retired==1

********************************************************************************
// Monthly Wages

gen wage_mth=tk16

********************************************************************************
// Merge inflation data

merge m:1 year using "$maindir$project/Inflation/PPP.dta", keep(1 3) nogen

sort pidlink year

********************************************************************************
// Realize the monthly wages

gen r_wage_mth=wage_mth/PPP
drop PPP wage_mth

********************************************************************************
// Keep the desired variables

keep  pidlink year r_wage_mth stopped_wrk retired neverwrkd stopped_1987 stopped_1992 unpaid
	
order pidlink year unpaid stopped_1987 stopped_1992 stopped_wrk retired neverwrkd r_wage_mth 
	
gen dataset="3"

gen wave=1997

save "$maindir$tmp/1997 Wage Last Job.dta", replace






