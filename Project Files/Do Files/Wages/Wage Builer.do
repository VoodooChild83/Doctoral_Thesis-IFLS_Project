* Build the Wage Database

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************

* Build the wage panel data set and the Child Wages data set of their first jobs

	qui do "$maindir$project$Do/Wages/Consolidate Wages - Longitudinal Data.do"

	save "$maindir$tmp/Wage Database1.dta", replace

* Impute wage data

	qui do "$maindir$project$Do/Wages/Wages - Imputation.do"
	
	save "$maindir$tmp/Wage Database2.dta", replace

* Run the Mincer regressions file

	qui do "$maindir$project$Do/Wages/Wages - Mincer Regressions.do"
	
* Run the Generaltional Elasticities file for analysis

	qui do "$maindir$project$Do/Wages/Generational Elasticities.do"
