* This do file will take the file where only the one individual was observed and create 
* the missing partner based on the available observation from the individual. 

* To be used with the Marriages - Only 1 Marriage do file

********************************************************************************

preserve

	use "$maindir$tmp/Marriage History Database - one marriage and only one partner observed.dta", clear
	
	* Switch the spousal IDs
	
		rename (pidlink2 pidlink_spouse SchLvl_Spouse MaxSchYrs_Spouse) (pidlink_spouse pidlink2 SchLvl MaxSchYrs)
		
	* Replace pidlink with missing to update later
	
		replace pidlink=""
		
	* Replace Wives for females that will be switched to males when the spousal identifier switches
	
		replace Wives=. if Sex==0
	
	* Recode Sex
	
		recode Sex (0=1) (1=0)
		
	* Recode to missing those variables that have are individual to each subject
	
		replace WhoChose=.
	
		replace SpouseInHH=.
		
	* Append to the original file and save
	
	append using "$maindir$tmp/Marriage History Database - one marriage and only one partner observed.dta"

	sort hhid pidlink2
	
	save "$maindir$tmp/Marriage History Database - one marriage and only one partner observed.dta", replace

restore 

********************************************************************************
* Update database

	append using "$maindir$tmp/Marriage History Database - one marriage and only one partner observed.dta"
		erase "$maindir$tmp/Marriage History Database - one marriage and only one partner observed.dta"
		
	
* Drop the 18 couples (36 people) that are doubled
	
		bysort pidlink_spouse: gen obs1=_N
		bysort pidlink2: gen obs2=_N
	
		drop if obs1==2|obs2==2
			drop obs*
