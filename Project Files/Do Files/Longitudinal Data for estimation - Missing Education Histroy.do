* Missing Educational History Data

* Here we will impute by assuming that children enter school at age 6
 
********************************************************************************
* Merge in the max education attainment
 
 preserve
 
	use "$maindir$project/MasterTrack2.dta", clear
	
	keep if flag_LastWave==1
	
	save "$maindir$tmp/MasterTrack.dta", replace
	
 restore

merge m:1 pidlink using "$maindir$tmp/MasterTrack.dta", update replace keepusing(MaxSchYrs) keep(1 3 4 5) nogen

* Update variables to impute start date at age 6

	replace age=year-birthyr if year-birthyr>=0
	
	bys pidlink (year): replace Grade=1 if MaxSchYrs>0 & MaxSchYrs!=. & age==6
	
	* increase the Grade level by one if schooling doesn't stop (using MaxSchYrs)
	
		by pidlink: replace Grade=Grade[_n-1]+1 if Grade[_n-1]!=. & Grade[_n-1]+1<=MaxSchYrs
		
		replace Grade=. if Grade==13

save "$maindir$tmp/Education History Missing.dta", replace
	
	
	
	

	
