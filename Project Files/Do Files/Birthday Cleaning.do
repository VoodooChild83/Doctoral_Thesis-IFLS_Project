//Birthday and Age Cleaning file

********************************************************************************
// Prepare the data for a dataset of birthdays

//Start with 1993 hh roster

use "$maindir$wave_1/bukkar2.dta", clear

keep ar08yr ar09yr pidlink pid93 hhid93

gen wave=1993

rename (ar08yr ar09yr pid93 hhid93) (birthyr age pid hhid)

replace birthyr=. if birthyr>=95 | birthyr==0
replace birthyr=1900+birthyr if birthyr!=.

save "$maindir$tmp/bk_ar1_1993.dta", replace

//The 1997 hh roster

use "$maindir$wave_2/hh97bk/bk_ar1.dta"

keep ar08yr age_97 pidlink pid hhid

gen wave=1997

rename (ar08yr age_97) (birthyr age)

replace birthyr=. if birthyr>1998 | birthyr==0
replace age=. if age>900

save "$maindir$tmp/bk_ar1_1997.dta", replace

//2000 hh roster

use "$maindir$wave_3/bk_ar1.dta"

keep ar08yr ar09 pidlink pid00 hhid00

gen wave=2000

rename (ar08yr ar09 pid00 hhid00) (birthyr age pid hhid)

replace birthyr=. if birthyr>2000

replace age=. if age>900
replace age=0 if age<1
replace age=floor(age) if age>1 & age<2

save "$maindir$tmp/bk_ar1_2000.dta", replace

//2007 hh roster

use "$maindir$wave_4/bk_ar1.dta"

keep ar08yr ar09 pidlink pid07 hhid07

gen wave=2007

rename (ar08yr ar09 pid07 hhid07) (birthyr age pid hhid)

replace birthyr=. if birthyr>2008

replace age=. if age>900

save "$maindir$tmp/bk_ar1_2007.dta", replace

//2012 IFLS East dataset

use "$maindir$wave_East/BK_AR1.dta"

* merge in pidlink

merge 1:1 pid12 hhid12 using "$maindir$tmp/IFLS_East/pidlink.dta", keepusing(pidlink) keep(1 3) nogen

keep ar08yr ar09 pidlink pid12 hhid12

gen wave=2012

rename (ar08yr ar09 pid12 hhid12) (birthyr age pid hhid)

replace birthyr=. if birthyr>2012

replace age=. if age>900

save "$maindir$tmp/bk_ar1_2012.dta", replace


********************************************************************************

// Append the datasets to get the birthday years

foreach year in 2007 2000 1997 1993{
		
		append using "$maindir$tmp/bk_ar1_`year'.dta"
		
		save "$maindir$project/birthyear.dta", replace

}

********************************************************************************
// Clean the Datasets to get one database of birthyearsh

// Try methods to clean data: 
// 1) impute missing information first and then take modes
// 2) take modes first and then impute missing values by filling in with mode values
// 3) take the last non-missing observation of either age or birthyear for each respondent
// 4) Collapse the mean of birth years, using ages to fill in when they are non existent

	gen BirthYr=birthyr
	gen Age=age
	
	/*
	// 1) Impute the birth years for those with missing birth years by taking the current age and subtracting from the wave year

		bysort pidlink (wave): gen BirthImp=1 if birthyr==.
		replace birthyr=wave-age if BirthImp==1

		*There are some observations that have missing ages and birth years even though they were observed in previous waves: fill them in
	
			gen BirthImp2=1 if birthyr==. & age==.
	
			by pidlink: replace birthyr=birthyr[_n-1] if birthyr[_n-1]!=. & birthyr==.
	
			gen AgeImp=1 if age==.
	
			by pidlink: replace age=wave-birthyr if AgeImp==1

		*Take the mode of birth years and ages for each subset: birh year by pidlink; age by pidlink and wave
	
			by pidlink: egen birthyr1=mode(birthyr)
				
			by pidlink wave: egen age1=mode(age)
				
		* For missing birth years (those that don't have a mode), take the last observation
			
			by pidlink: gen obs=_n if BirthYr!=.
			by pidlink: egen flag_lastobs=max(obs)
		
			replace birthyr1=BirthYr if flag_lastobs==obs & birthyr1==.
			
			drop *obs 
			
			by pidlink: egen birthyr2=max(birthyr1)
			
			drop birthyr1
			rename birthyr2 birthyr1
			
		
	// 2) Take modes of birth years first
		
		by pidlink: egen BirthYr1=mode(BirthYr)
		by pidlink wave: egen Age1=mode(Age)
		
		* For missing birth years (those that don't have a mode), take the last observed birth year
			
			bysort pidlink (wave): gen obs=_n if BirthYr!=.
			bysort pidlink (wave): egen flag_lastobs=max(obs)
			
			replace BirthYr1=BirthYr if flag_lastobs==obs & BirthYr1==.
			
			drop *obs
			
			by pidlink: egen BirthYr2=max(BirthYr1)
			drop BirthYr1
			rename BirthYr2 BirthYr1
		
		* Impute the missing birth years from the remaining observations based on the provided ages for those that have only one observation
			
			by pidlink: replace BirthYr1=wave-Age if _N==1 & BirthYr1==.
			
		* Impute the remaining birth years by taking the last observed Age for each agent with multiple observations and no original birth year provided
		
			bysort pidlink (wave): gen obs=_n if Age!=. & BirthYr1==. & BirthYr1[_n+1]==.
			by pidlink: egen flag_lastobs=max(obs)
			
			by pidlink: replace BirthYr1=wave-Age if obs==flag_lastobs & BirthYr1==.
			
			drop *obs

			by pidlink: egen BirthYr2=max(BirthYr1)
			drop BirthYr1
			rename BirthYr2 BirthYr1
			
		* Since above last procedure would give same results if done with method 1, replace these birth years into Method 1
			
			gen flag=1 if birthyr1==. & BirthYr1!=.
			
			replace birthyr1=BirthYr1 if flag==1
		
			drop flag

	// 3) Last non-missing birth year or age for each respondent
	
		  by pidlink: gen obs1=_n if BirthYr!=.
		  by pidlink: egen flag_obs1=max(obs1)
		  
		  by pidlink: gen obs2=_n if Age!=.
		  by pidlink: egen flag_obs2=max(obs2)
	
		  * Nonmissing birthyear
		  	
		  	by pidlink: gen BirthYr2=BirthYr if BirthYr!=. & obs1==flag_obs1
		  
		  * Nonmissing ages
		  
		  	by pidlink: gen Age2=Age if Age!=. & obs2==flag_obs2 & BirthYr2==.
		  	
		  	drop *obs*
		  
		  * Impute: Use wave to generate the birth year if it's missing and age provided
		  
		  	by pidlink: replace BirthYr2=wave-Age2 if BirthYr2==. & Age2!=.
		  	
		  * Spread out the birth years
		  
		  	by pidlink: egen BirthYr3=max(BirthYr2)
		  	drop BirthYr2
		  	rename BirthYr3 BirthYr2
		  	
		  	replace Age2=Age if Age2==.
	*/	  	  	
		  	
	// 4) Collapse according to the mean
	
		  gen BirthYr3=BirthYr
		  replace BirthYr3=wave-Age
		  
		  preserve
		  
		  	collapse (mean) BirthYr3, by (pidlink)
		  	
		  	replace BirthYr3=round(BirthYr3)
		  	
		  	save "$maindir$tmp/meanbirthday.dta", replace
		  	
		  restore
		  
		  merge m:1 pidlink using "$maindir$tmp/meanbirthday.dta", update replace nogen
		  
		  erase "$maindir$tmp/meanbirthday.dta"
					
	// Check consistency of results
		/*
		gen Consis1=(abs((birthyr1+Age)-wave))^2
		quietly sum Consis1
		gen Error1=sqrt(r(sum))
				
		gen Consis2=(abs((BirthYr1+Age)-wave))^2
		quietly sum Consis2
		gen Error2=sqrt(r(sum))	
		
		gen Consis3=(abs((BirthYr2+Age)-wave))^2
		quietly sum Consis3
		gen Error3=sqrt(r(sum))
		*/
		gen Consis4=(abs((BirthYr3+Age)-wave))^2
		quietly sum Consis4
		gen Error4=sqrt(r(sum))
		
*******************************************************************************
	
// The fourth method leads to the smallest error in imputation: Keep it and delete the rest
	
* Collapse the dataset to get individual birth years according to first method

collapse (mean) BirthYr3 , by (pidlink)

rename (BirthYr3) (birthyr)

sort pidlink 

save "$maindir$project/birthyear.dta", replace

foreach year in 1993 1997 2000 2007 2012{
		erase "$maindir$tmp/bk_ar1_`year'.dta"
		}
