/* Create a file that associates people's pidlink to the hhid and their pid. Also 
   include all the weights from the survey in this file */
   
********************************************************************************
//Pidlink Association

use "$maindir$wave_East/ptrack.dta", clear

keep pidlink hhid12 pid12 commid12 pwt

	* Bring in the location of the households and the household weight
	preserve
	
		use "$maindir$wave_East/htrack.dta", clear
		
		keep hhid12 hwt 
		
		save "$maindir$tmp/IFLS_East/htrack.dta", replace
	
	restore
	
merge m:1 hhid12 using "$maindir$tmp/IFLS_East/htrack.dta", nogen
erase "$maindir$tmp/IFLS_East/htrack.dta"

order pidlink commid12 hhid12 pid12 pwt hwt

destring pid12, replace

save "$maindir$tmp/IFLS_East/pidlink.dta", replace

