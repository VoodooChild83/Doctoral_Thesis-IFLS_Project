// 2012 Work Experience of those who no longer work (IFLS East)

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// 2007 work experience: stoppage of work and year

use "$maindir$wave_East/B3A_TK1.dta"

********************************************************************************
// Generate Year

gen year=tk07

********************************************************************************
// Generate the work status

drop if tk01==1  // Drop those who are still working

gen unpaid=1 if tk15==6

*gen stopped_1999=1 if tk06a==1

gen dum_nvrwrkd=1 if (tk05==3 | tk05==9)
gen dum=1 if (tk01!=5 & year!=.)
*gen dum2=1 if stopped_1999==1
gen dum_keep=1 if dum_nvrwrkd==1 | dum==1 /*| dum2==1 */

drop if year==. & dum_keep!=1

*drop dum2

gen stopped_wrk= 1 if tk05==1 & tk01!=1
gen retired= 1 if tk01==5
gen neverwrkd=1 if dum_nvrwrkd==1

replace retired=. if neverwrkd==1
replace stopped_wrk=. if retired==1

********************************************************************************
// Monthly Wages

gen wage_mth=tk16a

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

keep  pidlink year r_wage_mth stopped_wrk retired neverwrkd unpaid
	
order pidlink year unpaid stopped_wrk retired neverwrkd r_wage_mth 
	
gen dataset="3"

gen wave=2012

save "$maindir$tmp/2012 Wage Last Job.dta", replace
