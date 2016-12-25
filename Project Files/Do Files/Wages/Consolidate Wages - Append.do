 // Append the Current Wages, Wage Histories, and the Prehistory datasets for cleaning

********************************************************************************
// Do the do files for each type of data

foreach year in 1993 1997 2000 2007{

quietly do "$maindir$project$Do/Wages/Wages Current Job `year'.do"
quietly do "$maindir$project$Do/Wages/Wage Histories `year'.do"
quietly do "$maindir$project$Do/Wages/Wage Prehistory `year'.do"

}

********************************************************************************
// Append the Last Wage Datasets 

use "$maindir$tmp/1993 Wage History.dta"

	* Append the histories	

		foreach year in 1997 2000 2007 {

			append using "$maindir$tmp/`year' Wage History.dta"
	
			}
	
	* Append the wage prehistory and current jobs
	
		foreach year in 1993 1997 2000 2007 {

			append using "$maindir$tmp/`year' Wage Prehistory.dta"
			append using "$maindir$tmp/`year' Wage Current.dta"
	
			}
			
	* Erase the parent files
	
		
		foreach year in 1993 1997 2000 2007 {
		
			erase "$maindir$tmp/`year' Wage History.dta"
			erase "$maindir$tmp/`year' Wage Prehistory.dta"
			erase "$maindir$tmp/`year' Wage Current.dta"
	
			}
	
		sort pidlink year wave
		
		compress
		
		
	
	


	
