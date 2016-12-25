// Education Start-Stop: Adults

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************

//Merge Education Graduation/Left Information from b3_dl1 and d3_dl4 and proxy books

// There are some repeated pidlinks: they occur in both the interview and the proxy book when appending the data.
// If this is the case, take the interview data and drop the proxy


// 1993 Wave

* Grab Literacy Information

	use "$maindir$wave_1/buk3dl1.dta"

	* Speak Indonesian
	
	gen SpeakInd1993= 1 if dl01==1
	replace SpeakInd1993=0 if dl01==3
	replace SpeakInd1993=. if dl01>3
	
	* Read Indonesian
	
	gen ReadInd1993= 1 if dl02==1
	replace ReadInd1993=0 if dl02==3
	replace ReadInd1993=. if dl02>3
	
	* Write Indonesian
	
	gen WriteInd1993= 1 if dl03==1
	replace WriteInd1993=0 if dl03==3
	replace WriteInd1993=. if dl03>3
	
	keep pidlink pid93 hhid93 *Ind*
	
	rename (pid93 hhid93) (pid1993 hhid1993)
	
	save "$maindir$tmp/b3a_dl1_1993.dta", replace
	

use "$maindir$wave_1/buk3dl3.dta"

keep pidlink dl27a dl28a

gen YearExitSch1993=1900+dl27a
replace YearExitSch1993=. if YearExitSch1993>=1996

rename dl28a AgeExitSch1993

drop dl27a

save "$maindir$tmp/b3a_dl3_1993.dta", replace

//Grade Repeats & Kindergarten
		
			use "$maindir$wave_1/buk3dl2.dta"
			
			* Kindergarten attendance
		
				gen Kinder= (dl10==11)
				bysort pidlink (dl08): egen Kinder1993=max(Kinder)
				drop Kinder
				
			* Administration
			
				gen Admin= 1 if dl11==1|dl11==2
				replace Admin=0 if dl11>2
				replace Admin=. if dl11>6
				
				bysort pidlink: egen Admin1993=max(Admin)
				drop Admin
				
			* Grade repeats
		
			destring pidlink, gen(pidlink2) force
			
			preserve
				
				rename (dl08 dl14a dl14b dl14c dl14d dl14e dl14f faccode) (Level GrRep1_ GrRep2_ GrRep3_ GrRep4_ GrRep5_ GrRep6_ SchID_)
				
				keep pidlink GrRep* Level /*SchID_*/
				
				recode GrRep* (.=0)
				
				drop if Level==4
				
				reshape wide GrRep1_ GrRep2_ GrRep3_ GrRep4_ GrRep5_ GrRep6_ /*SchID_*/, i(pidlink) j(Level)
				
				forvalues i=1/6{
					forvalues j=1/3{
						rename GrRep`i'_`j' GrRep`i'_`j'1993
					}
				}
				
				drop GrRep4_2* GrRep4_3* GrRep5_2* GrRep5_3* GrRep6_2* GrRep6_3*
				
				save "$maindir$tmp/1993_GradeRep.dta", replace
			
			restore
				
				/*egen RepeatGr=rsum(dl14a dl14b dl14c dl14d dl14e dl14f)
				bysort pidlink2 (dl08): egen RepeatGr2=total(RepeatGr), missing
				by pidlink2: egen GrRep1993=max(RepeatGr2)
				replace GrRep1993=. if GrRep1993==0
				drop RepeatGr RepeatGr2*/
			
			bysort pidlink2 (dl08): gen flag=1 if dl08==_N
			
			keep if flag==1
			
			keep pidlink Kinder1993 Admin1993
			
			merge 1:1 pidlink using "$maindir$tmp/1993_GradeRep.dta", nogen
			
			save "$maindir$tmp/b3a_dl2_1993.dta", replace
			erase "$maindir$tmp/1993_GradeRep.dta"
			
		//Merge in Grade Repeats	
			
			use "$maindir$tmp/b3a_dl1_1993.dta"
			
			foreach num in 2 3{
			
				merge 1:1 pidlink using "$maindir$tmp/b3a_dl`num'_1993.dta"
				drop if _merge==2
				drop _merge
			
			}
			
			save "$maindir$tmp/b3a_dl1_1993.dta", replace
			erase "$maindir$tmp/b3a_dl2_1993.dta"
			erase "$maindir$tmp/b3a_dl3_1993.dta"
			

// 1997 wave

foreach let in a p {

		use "$maindir$wave_2/hh97b3/b3`let'_dl1.dta"
		
		keep pidlink pid97 hhid97 dl01a dl02 dl03 dl07byr dl07c
		
		gen book1997="`let'"
		
		* Literacy Variables
		
		* Speak Indonesian
	
		gen SpeakInd1997=regexm(dl01a, "^A")
		replace SpeakInd1997=. if dl01a==""
		drop dl01a
	
		* Speak More than one language
		
		* Read Indonesian
	
		gen ReadInd1997= 1 if dl02==1
		replace ReadInd1997=0 if dl02==3
		replace ReadInd1997=. if dl02>3
		drop dl02
	
		* Write Indonesian
	
		gen WriteInd1997= 1 if dl03==1
		replace WriteInd1997=0 if dl03==3
		replace WriteInd1997=. if dl03>3
		drop dl03
	
		rename (pid97 hhid97 dl07byr dl07c) (pid1997 hhid1997 YearExitSch1997 AgeExitSch1997)
		
		save "$maindir$tmp/b3`let'_dl1_1997.dta", replace
		
		if "`let'"=="a"{
		
		//Grade Repeats Kindergarten and Administration
		
			use "$maindir$wave_2/hh97b3/b3`let'_dl2.dta"
			
			* Kindergarten attendance
		
				gen Kinder= (dl10==11)
				bysort pidlink: egen Kinder1997=max(Kinder)
				drop Kinder
				
			* Administration
			
				gen Admin= 1 if dl11==1|dl11==2
				replace Admin=0 if dl11>2
				replace Admin=. if dl11>6
				
				bysort pidlink: egen Admin1997=max(Admin)
				drop Admin
		
			destring pidlink, gen(pidlink2) force
			
			preserve
				
				rename (dl2type dl14a dl14b dl14c dl14d dl14e dl14f) (Level GrRep1_ GrRep2_ GrRep3_ GrRep4_ GrRep5_ GrRep6_)
				
				keep pidlink GrRep* Level /*SchID_*/
				
				recode GrRep* (.=0)
				
				drop if Level==4
				drop if Level==.
				
				reshape wide GrRep1_ GrRep2_ GrRep3_ GrRep4_ GrRep5_ GrRep6_ /*SchID_*/, i(pidlink) j(Level)
				
				forvalues i=1/6{
					forvalues j=1/3{
						rename GrRep`i'_`j' GrRep`i'_`j'1997
					}
				}
				
				drop GrRep4_2* GrRep4_3* GrRep5_2* GrRep5_3* GrRep6_2* GrRep6_3*
				
				save "$maindir$tmp/1997_GradeRep.dta", replace
			
			restore
			
			/*egen RepeatGr=rsum(dl14a dl14b dl14c dl14d dl14e dl14f)
			bysort pidlink2 (dl2type): egen RepeatGr2=total(RepeatGr), missing
			by pidlink2: egen GrRep1997=max(RepeatGr2)
			replace GrRep1997=. if GrRep1997==0
			drop RepeatGr RepeatGr2*/
			
			bysort pidlink2: gen flag=1 if dl2type==_N
			
			keep if flag==1
			
			keep pidlink Admin1997 Kinder1997
			
			merge 1:1 pidlink using "$maindir$tmp/1997_GradeRep.dta", nogen
			
			save "$maindir$tmp/b3`let'_dl2_1997.dta", replace
			erase "$maindir$tmp/1997_GradeRep.dta"
			
		//Merge in Grade Repeats	
			
			use "$maindir$tmp/b3`let'_dl1_1997.dta"
			
			merge 1:1 pidlink using "$maindir$tmp/b3`let'_dl2_1997.dta"
			drop if _merge==2
			drop _merge
			
			save "$maindir$tmp/b3`let'_dl1_1997.dta", replace
			erase "$maindir$tmp/b3`let'_dl2_1997.dta"
			}

		if "`let'"=="p"{
			
			use "$maindir$tmp/b3a_dl1_1997.dta"

			append using "$maindir$tmp/b3p_dl1_1997.dta"

			save "$maindir$tmp/b3a_dl1_1997.dta", replace

			erase "$maindir$tmp/b3p_dl1_1997.dta"
			}
	    }

// 2000 wave

foreach let in a p {

		use "$maindir$wave_3/b3`let'_dl1.dta"
		
		if "`let'"=="a" keep pidlink pid00 hhid00 dl01a dl02 dl03 dl06 dl07byr dl07c dl05a  //variable dl05a not in the proxy book
		else keep pidlink pid00 hhid00 dl01a dl02 dl03 dl06 dl07byr dl07c
			
		gen book2000="`let'"

		rename (pid00 hhid dl07byr dl07c) (pid2000 hhid2000 YearExitSch2000 AgeExitSch2000)
		
		if "`let'"=="a" rename dl05a AgeStartSch2000
		
		* Literacy Variables
		
		* Speak Indonesian
	
		gen SpeakInd2000=regexm(dl01a, "A+")
		replace SpeakInd2000=. if dl01a==""
		drop dl01a
	
		* Speak More than one language
		
		* Read Indonesian
	
		gen ReadInd2000= 1 if dl02==1
		replace ReadInd2000=0 if dl02==3
		replace ReadInd2000=. if dl02>3
		drop dl02
	
		* Write Indonesian
	
		gen WriteInd2000= 1 if dl03==1
		replace WriteInd2000=0 if dl03==3
		replace WriteInd200=. if dl03>3
		drop dl03
		
		* Kindergarten attendance
		
				gen Kinder= (dl06==90)
				bysort pidlink: egen Kinder2000=max(Kinder)
				drop Kinder dl06

		save "$maindir$tmp/b3`let'_dl1_2000.dta", replace
		
		if "`let'"=="a"{
		//Grade Repeats + Administration
		
			use "$maindir$wave_3/b3`let'_dl2.dta"
				
			* Administration
			
				gen Admin= 1 if dl11==1|dl11==2
				replace Admin=0 if (dl11>2 & dl11<7)|dl11==8
				replace Admin=. if dl11>8|dl11==7
				
				bysort pidlink: egen Admin2000=max(Admin)
				drop Admin
		
			destring pidlink, gen(pidlink2) force
			
			preserve
				
				rename (dl2type dl14a dl14b dl14c dl14d dl14e dl14f) (Level GrRep1_ GrRep2_ GrRep3_ GrRep4_ GrRep5_ GrRep6_)
				
				keep pidlink GrRep* Level /*SchID_*/
				
				recode GrRep* (.=0)
				
				drop if Level==4
				drop if Level==.
				
				reshape wide GrRep1_ GrRep2_ GrRep3_ GrRep4_ GrRep5_ GrRep6_ /*SchID_*/, i(pidlink) j(Level)
				
				forvalues i=1/6{
					forvalues j=1/3{
						rename GrRep`i'_`j' GrRep`i'_`j'2000
					}
				}
				
				drop GrRep4_2* GrRep4_3* GrRep5_2* GrRep5_3* GrRep6_2* GrRep6_3*
				
				save "$maindir$tmp/2000_GradeRep.dta", replace
			
			restore
			
			/*egen RepeatGr=rsum(dl14a dl14b dl14c dl14d dl14e dl14f)
			bysort pidlink2 (dl2type): egen RepeatGr2=total(RepeatGr), missing
			by pidlink2: egen GrRep2000=max(RepeatGr2)
			replace GrRep2000=. if GrRep2000==0
			drop RepeatGr RepeatGr2*/
			
			bysort pidlink2: gen flag=1 if dl2type==_N
			
			keep if flag==1
			
			keep pidlink Admin2000
			
			merge 1:1 pidlink using "$maindir$tmp/2000_GradeRep.dta", nogen
			
			save "$maindir$tmp/b3`let'_dl2_2000.dta", replace
			erase "$maindir$tmp/2000_GradeRep.dta"
			
		//Merge in Grade Repeats	
			
			use "$maindir$tmp/b3`let'_dl1_2000.dta"
			
			merge 1:1 pidlink using "$maindir$tmp/b3`let'_dl2_2000.dta"
			drop if _merge==2
			drop _merge
			
			save "$maindir$tmp/b3`let'_dl1_2000.dta", replace
			erase "$maindir$tmp/b3`let'_dl2_2000.dta"
			}
			
		if "`let'"=="p"{
		   
		   use "$maindir$tmp/b3a_dl1_2000.dta"

		   append using "$maindir$tmp/b3p_dl1_2000.dta"

		   save "$maindir$tmp/b3a_dl1_2000.dta", replace

	       erase "$maindir$tmp/b3p_dl1_2000.dta"
	       }
	    }

********************************************************************************
//2007 wave:
* This wave had two books from which to draw the education start and end dates: modules
* dl1 and dl4. I use these two modules to check for consistency across the dates for individuals
* In total there seem to be only 25 instances out of 30k people that have inconsistent start dates.

*** Note for future cleaning: to get a better imputation of the end dates keep variables on the years 
*** of grade repitions. Add these as penalty dates for future modeling. For first pass data mining this 
*** doesn't matter.

// book dl1

foreach let in 3a p {

		use "$maindir$wave_4/b`let'_dl1.dta"

		keep pidlink pid07 hhid07 dl01a dl02 dl03 dl05b dl07byr dl05a
		gen book2007="`let'"

		rename (pid07 hhid07 dl07byr dl05a) (pid2007 hhid2007 YearExitSch20071 AgeEntSch2007)
		
		* Literacy Variables
		
		* Speak Indonesian
	
		gen SpeakInd2007=regexm(dl01a, "A+")
		replace SpeakInd2007=. if dl01a==""
		drop dl01a
	
		* Speak More than one language
		
		* Read Indonesian
	
		gen ReadInd2007= 1 if dl02==1
		replace ReadInd2007=0 if dl02==3
		replace ReadInd2007=. if dl02>3
		drop dl02
	
		* Write Indonesian
	
		gen WriteInd2007= 1 if dl03==1
		replace WriteInd2007=0 if dl03==3
		replace WriteInd2007=. if dl03>3
		drop dl03
		
		* Kindergarten attendance
		
				gen Kinder= (dl05b==1)
				replace Kinder=. if dl05b>3
				bysort pidlink: egen Kinder2007=max(Kinder)
				drop Kinder dl05b
		
		save "$maindir$tmp/b`let'_dl1_2007.dta", replace
		
		if "`let'"=="p"{
		
			use "$maindir$tmp/b3a_dl1_2007.dta"

			append using "$maindir$tmp/bp_dl1_2007.dta"

			save "$maindir$tmp/b3a_dl1_2007.dta", replace

			erase "$maindir$tmp/bp_dl1_2007.dta"
			}
	    }
		
// book dl2

use "$maindir$wave_4/b3a_dl2.dta"
keep pidlink dl11

gen book2007="3a"

	* Administration
			
	gen Admin= 1 if dl11==1|dl11==2
	replace Admin=0 if (dl11>2 & dl11<9)
	replace Admin=. if dl11>8
				
	bysort pidlink: egen Admin2007=max(Admin)
	drop Admin dl11
	
by pidlink: drop if _n!=_N
	
save "$maindir$tmp/b3a_dl2_2007.dta", replace

use "$maindir$tmp/b3a_dl1_2007.dta"

merge m:1 pidlink using "$maindir$tmp/b3a_dl2_2007.dta", update
drop if _merge==2
drop _merge

save "$maindir$tmp/b3a_dl1_2007.dta", replace
erase "$maindir$tmp/b3a_dl2_2007.dta"

	    
// book dl4

foreach let in 3a p {

		use "$maindir$wave_4/b`let'_dl4.dta"

		keep pidlink pid07 hhid07 dl11a dl11b dl11f dl11g dl4type dl14a1 dl14b2 dl14c3 dl14d4 dl14e5 dl14f6
		
		if "`let'"=="3a" gen book2007="a" 
		else gen book2007="p" 
		
		//clean up the data: capture the beginning and end school ages or years up to 
		//level 3 code (high shcool) - don't include the college years to prevent imputing
		//finish dates later on
		
		destring pidlink, gen(pidlink2) force

		bysort pidlink2 (dl4type): egen LowLvl=min(dl4type)
		by pidlink2: egen HiLvl=max(dl4type)
		
		*gen flag_LastObs=1 if HiLvl==dl4type
		
		by pidlink2: gen flag_LastObs=1 if (dl4type==_N & dl4type<=3) | (dl4type==_N-1 & dl4type==3) //Captures highschool as the highest level
		
		*by pidlink2: gen HiLvl3=dl4type if flag_LastObs==1
		
		// Repeat Grades: those people failed
		
			preserve
				
				rename (dl4type dl14a1 dl14b2 dl14c3 dl14d4 dl14e5 dl14f6) (Level GrRep1_ GrRep2_ GrRep3_ GrRep4_ GrRep5_ GrRep6_)
				
				keep pidlink GrRep* Level /*SchID_*/
				
				recode GrRep* (.=0)
				
				drop if Level==4
				drop if Level==.
				
				reshape wide GrRep1_ GrRep2_ GrRep3_ GrRep4_ GrRep5_ GrRep6_ /*SchID_*/, i(pidlink) j(Level)
				
				forvalues i=1/6{
					forvalues j=1/3{
						rename GrRep`i'_`j' GrRep`i'_`j'2007
					}
				}
				
				drop GrRep4_2* GrRep4_3* GrRep5_2* GrRep5_3* GrRep6_2* GrRep6_3*
				
				save "$maindir$tmp/2007_GradeRep.dta", replace
			
			restore
			
			/*egen RepeatGr=rsum(dl14a1 dl14b2 dl14c3 dl14d4 dl14e5 dl14f6)
			by pidlink2: egen RepeatGr2=total(RepeatGr), missing
			by pidlink2: egen GrRep=max(RepeatGr2)
			replace GrRep=. if GrRep==0
			drop RepeatGr RepeatGr2*/
		
		replace flag_LastObs=0 if LowLvl==dl4type & flag_LastObs!=1

		gen SchStartYear= dl11a if flag_LastObs==0 | (flag_LastObs==1 & dl4type==1)
		gen SchStartAge= dl11b if flag_LastObs==0 | (flag_LastObs==1 & dl4type==1)

		gen SchFinYear= dl11f if flag_LastObs==1
		gen SchFinAge= dl11g if flag_LastObs==1

		by pidlink2: egen StartYear=max(SchStartYear)
		by pidlink2: egen StartAge=max(SchStartAge)

		by pidlink2: egen FinalYear=max(SchFinYear)
		by pidlink2: egen FinalAge=max(SchFinAge)
		
		keep if flag_LastObs==1

		keep pidlink pid07 hhid07 LowLvl HiLvl StartYear StartAge FinalYear FinalAge book2007

		rename pid07 pid2007
		rename hhid07 hhid2007
		rename LowLvl LowLvl2007
		rename HiLvl  HiLvl2007
		rename StartYear YearEntSch20071
		rename StartAge AgeEntSch20072
		rename FinalYear YearExitSch20072
		rename FinalAge AgeExitSch2007
		
		merge 1:1 pidlink using "$maindir$tmp/2007_GradeRep.dta", nogen
		
		save "$maindir$tmp/b`let'_dl4_2007.dta", replace
		erase "$maindir$tmp/2007_GradeRep.dta"
		
		if "`let'"=="p"{
		
			use "$maindir$tmp/b3a_dl4_2007.dta"

			append using "$maindir$tmp/bp_dl4_2007.dta"
			
			destring pidlink, gen(pidlink2) force
		
			sort pidlink2 book2007
		
			by pidlink2: gen obs=_n
		
			drop if obs==2 & book2007=="p"

			drop pidlink2 obs book2007

			save "$maindir$tmp/b3a_dl4_2007.dta", replace

			erase "$maindir$tmp/bp_dl4_2007.dta"
			}
		
	    }

	    
// Drop the repeated measures of pidlinks after wave 1993

foreach year in 1997 2000 2007{

		use "$maindir$tmp/b3a_dl1_`year'.dta"
		
		destring pidlink, gen(pidlink2) force
		
		sort pidlink2 book`year' //book`year'_2
		
		by pidlink2: gen obs=_n
		
		drop if obs==2 & book`year'=="p"

		drop pidlink2 obs book`year'
		
		save "$maindir$tmp/b3a_dl1_`year'.dta", replace
		
		}

// 2007: Merge the dl1 and dl4 datasets and consolidate the start and end dates of school entrance

use "$maindir$tmp/b3a_dl1_2007.dta"

merge 1:1 pidlink using "$maindir$tmp/b3a_dl4_2007.dta", gen(dl_merge) //Use dl_merge to identify those observations that merged to then correct for the fact that
																	   //I am only considering high school level education as the finish point (since this may affect
																	   //consistency when collapse is performed for those who have a college finish date in dl1 dataset)
replace AgeEntSch2007=. if AgeEntSch2007>90
replace AgeEntSch20072=. if AgeEntSch20072>90
replace AgeExitSch2007=. if AgeExitSch2007>90
replace YearExitSch20071=. if YearExitSch20071>9000
replace YearEntSch20071=. if YearEntSch20071>9000
replace YearExitSch20072=. if YearExitSch20072>9000

save "$maindir$tmp/b3a_dl1_2007.dta", replace
erase "$maindir$tmp/b3a_dl4_2007.dta"

********************************************************************************
//Birth year used to update the years of entrance and exit based on the entrance and
//exit ages when respondents didn't list a year

// Merge birthyear into the datasets

use "$maindir$project/birthyear.dta"

foreach year in 1993 1997 2000 2007{
		
		use "$maindir$tmp/b3a_dl1_`year'.dta"
		
		merge 1:1 pidlink using "$maindir$project/birthyear.dta"
		drop if _merge==2
		drop _merge
		
		rename birthyr birthyr`year'
		
		save "$maindir$tmp/b3a_dl1_`year'.dta", replace
		}
		
// Use birthyear to update variables

	use "$maindir$tmp/b3a_dl1_2007.dta"

	* Year Enter School

	replace YearEntSch20071=birthyr2007+AgeEntSch2007 if YearEntSch20071==.	//dl1 book
	gen YearEntSch20072=birthyr2007+AgeEntSch20072							//dl4 book
	
	replace YearEntSch20071=. if YearEntSch20071<=birthyr2007

	* Year Exit School

	replace YearExitSch20071=birthyr2007+AgeExitSch2007 if YearExitSch20071==.	//dl1 book
	
	// Replace Inconsistencies
		replace YearExitSch20071=. if YearExitSch20071>2007
		replace YearEntSch20071=. if YearExitSch20071<YearEntSch20071
		replace YearExitSch20071=. if YearExitSch20071<=birthyr2007
	
		replace YearExitSch20072=. if YearExitSch20072>2007
		replace YearEntSch20072=. if YearExitSch20072<YearEntSch20072
		replace YearExitSch20072=. if YearExitSch20072<=birthyr2007
	
	drop AgeEntSch* AgeExitSch*

	order pidlink hhid2007 pid2007 LowLvl2007 HiLvl2007 birthyr2007 YearEntSch* YearExitSch*

	save "$maindir$tmp/b3a_dl1_2007.dta", replace

// Remove the observations on Exit Years for dl1 survey before consistency collapse for those who finished college (since I take as highest level high school and don't
// want that collapse tries to reconcile large year gaps for those who have completed college and have a date in dl1 book for those who matched in merge)

replace YearExitSch20071=. if dl_merge==3 & HiLvl2007==4
drop dl_merge

// Clean up the data with consistency check on year entrances and exits between surveys

preserve
	reshape long YearEntSch2007@ YearExitSch2007@, i(pidlink) j(survey)

	collapse (mean) birthyr2007 YearEntSch2007 YearExitSch2007, by(pidlink)
	
	// Round the years for those that have inconsistencies
	tostring YearEntSch2007, gen(YearEntSch20072)
	tostring YearExitSch2007, gen(YearExitSch20072)
	gen byte yearent=indexnot(YearEntSch20072, "0123456789")
	gen byte yearexit=indexnot(YearExitSch20072, "0123456789")
	
	replace YearEntSch2007=round(YearEntSch2007) //if yearent==5
	replace YearExitSch2007=round(YearExitSch2007) //if yearexit==5
	
	drop YearEntSch20072 YearExitSch20072 year*
		
	save "$maindir$tmp/EducStartStop_2007.dta", replace
restore

merge 1:1 pidlink using "$maindir$tmp/EducStartStop_2007.dta", keepusing(YearEntSch2007 YearExitSch2007) nogen

drop YearEntSch20071-YearExitSch20072

// Impute missing year start dates: assume people start at age 6 for those missing

/* Do not impute this
tab LowLvl2007 if YearEntSch2007==.  // How many observations can be replaced by imputing start age=6 for primary school entrance

	* Impute the year of entrance for those with Entrance Level==1
	
	replace YearEntSch2007=birthyr2007+6 if LowLvl2007==1 & YearEntSch2007==.
*/

drop LowLvl2007 HiLvl2007

save "$maindir$tmp/b3a_dl1_2007.dta", replace
erase "$maindir$tmp/EducStartStop_2007.dta"

********************************************************************************

// Repeat the above procedure for the remaining data sets before a consolidation 
// of all sets to then merge with the Master Tracker file.


foreach year in 2000 1997 1993{

		use "$maindir$tmp/b3a_dl1_`year'.dta"

		order pidlink hhid`year' pid`year' 
		
		if `year'==2000{
			gen YearEntSch`year'=birthyr`year'+AgeStartSch`year'
			
			replace YearExitSch`year'=birthyr`year'+AgeExitSch`year' if YearExitSch`year'==.
			
			//Replace Inconsistencies 
			replace YearExitSch`year'=. if YearExitSch`year'>`year'
			replace YearExitSch`year'=. if YearExitSch`year'<=birthyr`year'
			
			replace YearEntSch`year'=. if YearEntSch`year'>YearExitSch`year'
			replace YearEntSch`year'=. if YearEntSch`year'<=birthyr`year'
			
			drop AgeStartSch`year' AgeExitSch`year'
			}
		
		else {
			replace YearExitSch`year'=birthyr`year'+AgeExitSch`year' if YearExitSch`year'==.
			
			replace YearExitSch`year'=. if YearExitSch`year'>`year'   //Invalid exit years
			replace YearExitSch`year'=. if YearExitSch`year'<=birthyr`year'
			
			drop AgeExitSch`year'
			}
		
		save "$maindir$tmp/b3a_dl1_`year'.dta", replace		
		}
		
// Merge all the datasets to get a wide database of all the years and to then 
// take care of inconsistencies:

use "$maindir$tmp/b3a_dl1_2007.dta"

foreach year in 2000 1997 1993{

		merge 1:1 pidlink using "$maindir$tmp/b3a_dl1_`year'.dta", nogen
		}		

// Reshape data long to collapse into entrance and exit year

reshape long hhid@ pid@ birthyr@ YearEntSch@ YearExitSch@ GrRep1_1@ GrRep2_1@ ///
GrRep3_1@ GrRep4_1@ GrRep5_1@ GrRep6_1@ GrRep1_2@ GrRep2_2@ GrRep3_2@ GrRep1_3@ ///
GrRep2_3@ GrRep3_3@ SpeakInd@ WriteInd@ ReadInd@ Admin@ Kinder@, i(pidlink) j(wave)

* Collapse by taking the last nonmissing observation (to be consistent with how educational
* attainment is captured in Master Track file):

collapse (mean) YearEntSch YearExitSch (max) GrRep* *Ind Admin Kinder, by(pidlink)

replace  YearEntSch=ceil(YearEntSch)
replace YearExitSch=ceil(YearExitSch)

rename (GrRep1_1 GrRep2_1 GrRep3_1 GrRep4_1 GrRep5_1 GrRep6_1 GrRep1_2 GrRep2_2 GrRep3_2 GrRep1_3 GrRep2_3 GrRep3_3) ///
	   (Grade1 Grade2 Grade3 Grade4 Grade5 Grade6 Grade7 Grade8 Grade9 Grade10 Grade11 Grade12)

save "$maindir$project/EducStartStop.dta", replace

foreach year in 1993 1997 2000 2007{

	erase "$maindir$tmp/b3a_dl1_`year'.dta"
	}
