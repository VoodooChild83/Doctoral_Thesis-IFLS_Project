* The cleaning of people with mutliple marriages to obtain the dates of 
* marriage so as to include into the Dynasty information and the wage information

********************************************************************************

cd "/Users/idiosyncrasy58/" 

//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************

use "$maindir$tmp/Marriage History Database - More than 1 Marriage.dta"

append using "$maindir$tmp/Marriage History Database - Inconsistencies and Missing Spouses.dta", gen(appended)

********************************************************************************
* Collapse according to the minimum start year of the marriages
 
	collapseandpreserve (firstnm) pidlink hhid pidlink_spouse pidlink_couple appended (min) year_start year_end ///
						(lastnm) wave (firstnm) Dowry flag_Drop Sex (max) MaritalStat Divorced WhoChose ///
						State_of_Marr Wives SchLvl_Spouse MaxSchYrs_Spouse NumMarriages (min) Respondent, ///
						by(pidlink2 MarrNum) omitstatfromvarlabel

* Drop if year_start is missing and the pidlink_couple variable is empty

	drop if year_start==. & pidlink_couple==.
					
* Now find the uplicates of marriages when the couple id is the same across marriages

	duplicates tag pidlink2 pidlink_couple if pidlink_couple!=., gen(DupCouples)
	
	preserve
	
		keep if DupCouples!=. 
		
		sort pidlink_couple pidlink2
	
	restore
	
	
	
	
	
	
	
	
	reshape long year_@, i(pidlink2 MarrNum) j(Dur) string
	
	gsort pidlink2 MarrNum -Dur
