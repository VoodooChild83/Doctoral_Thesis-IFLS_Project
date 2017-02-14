/* This file simply finds the total number of people that have completed the cognitive tests */

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// 2007 Wave Cognitive Tests

	* Adults
	use "$maindir$wave_4/b3b_co2.dta"
	
		* Append the second test
		append using "$maindir$wave_4/b3b_co3.dta", gen(_append)
	
		* Find repeated pidlinks
		bysort pidlink: gen obs=_n
	
		tab obs
		
			* drop the observation per pidlink with total lowest number
			drop if obs==2
		
			drop _append obs
	
		* Generate test identifier completed
	
		gen CogTest=1 
	
		keep pidlink CogTest
		save  "$maindir$tmp/CognitiveTest.dta", replace
	
	* 2007 Children/Young Adults
	
		use "$maindir$wave_4/bek_ek1.dta"
		
		* Append the second test (adults)
		append using "$maindir$wave_4/bek_ek2", gen(_append)
		
		* Find repeated pidlinks
		bysort pidlink: gen obs=_n
		
		tab obs
		
			* Drop the observation identifier that has the lowest count
			drop if obs==2
			
			drop _append obs
			
	* 2000 Children/Young Adults
	
		* Append the 2000 cognitive tests
		append using "$maindir$wave_3/bek.dta", gen(_append)
		
		* Keep only those who completed the test (even if only partially)
		gen flag=1 if (ekc3==1 | ekc3==2) | (result==1|result==2)
		
		drop if flag!=1
		drop flag
		
		* Find repetitive pidlinks
		bysort pidlink: gen obs=_n
		
		tab obs
		
			* Drop the repeated pidlink with lowest observations
			drop if obs==2
			drop obs _append
			
		gen CogTest=1
		
		keep pidlink CogTest
		
********************************************************************************
// Merge all the cognitive test participation records

append using "$maindir$tmp/CognitiveTest.dta", gen(_append)

	/* If append==0 the person took the younger person cognitive test, if
	   append==1 then the person took the adult test. */
	   
	 bysort pidlink: gen obs=_n
	 
	 * Identify the people who took both tests
	 by pidlink: gen CogTestKidsAdult=1 if _append[1]!=_append[2] & CogTest[1]==CogTest[2]
	 by pidlink: replace CogTestKidsAdult=0 if CogTestKidsAdult==.
	 
	 * Drop the repeated pidlinks
	 drop if obs==2
	 drop obs _append
	 
	 save "$maindir$tmp/CognitiveTest.dta",replace	
	
