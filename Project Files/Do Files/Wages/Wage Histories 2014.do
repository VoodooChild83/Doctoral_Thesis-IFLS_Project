// 2014 Wage History Cleaning File

********************************************************************************
// 2014 History Data

use "$maindir$wave_5/b3a_tk3.dta"

// Rename and keep the variables associated with the primary occupation

rename (tk28year occ2014) (year occ2)

// Cleanup the occupation string variable: remove the initial 0

	*replace occ2=substr( occ2, 2,.) if  occ2!="999"
	
gen worked=1 if tk28==1
gen unpaid=1 if tk33==6
	
gen job=1

gen wave=2014

gen dataset="2"

keep pidlink year occ2 unpaid worked job wave dataset

save "$maindir$tmp/2014 Wage History.dta", replace
	
	