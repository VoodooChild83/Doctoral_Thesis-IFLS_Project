* This File will identify the children:

* First observed child born to the parents
* Child will be born between 1980 and 1999

********************************************************************************
* Identify the Children

use "$maindir$tmp/Dynasty Build.dta", clear

* Find all the first born children who were born between 1980 and 1999

	* First, merge in birthdays
	
	merge m:1 pidlink using "$maindir$project/birthyear.dta", keep(1 3) nogen
	
	* Now find the children
	
	order Dynasty pidlink birthyr
	
	bys Dynasty Family Generation (birthyr): gen FirstBorn_1980_99=1 if birthyr>=1980 & birthyr<=1999 & _n==1 & pidlink_father!=. & pidlink_mother!=.

	* Remove repeated children identifications
	
	bys pidlink: egen Count=total(FirstBorn_1980_99),missing
	by pidlink: replace Count=. if _n!=_N
	
	keep if Count!=.
	
	keep pidlink pidlink2 *_father *_mother birthyr
	
********************************************************************************
* Drop duplicates

sort pidlink_father pidlink_mother birthyr
duplicates drop pidlink_father pidlink_mother, force

sort pidlink_mother birthyr
duplicates drop pidlink_mother, force

sort pidlink_father birthyr
duplicates drop pidlink_father, force

save "$maindir$tmp/Identified Children.dta", replace

preserve

	use "$maindir$project/MasterTrack2.dta", clear
	
	keep if flag_LastWave==1
	
	save "$maindir$tmp/MasterTrack.dta", replace
	
restore

merge 1:1 pidlink using "$maindir$tmp/MasterTrack.dta", keepusing(provmov) keep(1 3)
