/* This file collects all the EBTANAS scores of survey participants */

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

**************** ADULT TEST SCORES *********************************************
// Cycle through all the files to create a panel data set

forval i=2/5{

	local surv = "wave_" + "`i'"
	
	if `i'==2 use "$maindir$`surv'/hh97b3/b3a_dl3.dta", clear
	
	else use "$maindir$`surv'/b3a_dl3.dta", clear
	
	keep (pidlink dl3type dl16cyr dl16db dl16dd dl16e dl16g)
	
	rename (dl3type dl16cyr dl16db dl16dd dl16e dl16g) ///
	       (Sch_Lvl test_year ind_score math_score tot_score hrs_day_sch)
		   
	gen wave=`i'
		   
	if `i'!=5 save "$maindir$tmp/Test Score Wave `i'.dta", replace
	
	if `i'==5{
	
		append using "$maindir$tmp/Test Score Wave 2.dta"
		append using "$maindir$tmp/Test Score Wave 3.dta"
		append using "$maindir$tmp/Test Score Wave 4.dta"
		
		rm "$maindir$tmp/Test Score Wave 2.dta"
		rm "$maindir$tmp/Test Score Wave 3.dta"
		rm "$maindir$tmp/Test Score Wave 4.dta"
		
	}

}

* Sort and order the data

order pidlink Sch_Lvl wave
sort pidlink Sch_Lvl wave

* Drop if Sch_Lvl is missing
drop if Sch_Lvl==.
drop if Sch_Lvl==4

* Collapse the data by pidlink Sch_Lvl on first non-missing

collapseandpreserve (firstnm) test_year ind_score math_score tot_score hrs_day_sch, by(pidlink Sch_Lvl) omitstatfromvarlabel

* Identify the dataset

gen Dataset = "Adult"

save "$maindir$tmp/Test Scores.dta", replace

**************** CHILDREN TEST SCORES ******************************************

forval i=2/5{

	local surv = "wave_" + "`i'"

	if `i'==2 | `i'==3 {

		if `i'==2 use "$maindir$`surv'/hh97b5/b5_dla1.dta", clear
		
		else use "$maindir$`surv'/b5_dla1.dta", clear
		
		keep (pidlink dla08 dla22yr dla23b dla23e dla24)
		
		rename (dla08 dla22yr dla23b dla23e dla24 ) ///
			   (Sch_Lvl test_year ind_score math_score tot_score)
	
	}
	
	else {
	
		use "$maindir$`surv'/b5_dla2.dta", clear
		
		if `i'==4 { 
			
			*destring the school type variable
			gen dlatype_2 =real(dlatype)
			drop dlatype
			rename dlatype_2 dlatype
		}
		
		keep(pidlink dlatype dla76cyr dla76db dla76dd dla76e)
		
		rename (dlatype dla76cyr dla76db dla76dd dla76e) ///
		       (Sch_Lvl test_year ind_score math_score tot_score)
	
	}
	
	gen wave=`i'
	
	if `i'!=5 save "$maindir$tmp/Test Score Wave `i'.dta", replace
	
	if `i'==5{
	
		append using "$maindir$tmp/Test Score Wave 2.dta"
		append using "$maindir$tmp/Test Score Wave 3.dta"
		append using "$maindir$tmp/Test Score Wave 4.dta"
		
		rm "$maindir$tmp/Test Score Wave 2.dta"
		rm "$maindir$tmp/Test Score Wave 3.dta"
		rm "$maindir$tmp/Test Score Wave 4.dta"
		
	}

}

* Drop if Sch_Lvl is missing
drop if Sch_Lvl==.
drop if Sch_Lvl==4

* Sort the data
order pidlink Sch_Lvl wave
sort pidlink Sch_Lvl wave

* Collapse the data by pidlink Sch_Lvl on first non-missing
collapseandpreserve (firstnm) test_year ind_score math_score tot_score, by(pidlink Sch_Lvl) omitstatfromvarlabel

*identify the dataset
gen Dataset = "Children"

****** APPEND THE ADULT DATASET ********

append using "$maindir$tmp/Test Scores.dta"

sort pidlink Sch_Lvl
