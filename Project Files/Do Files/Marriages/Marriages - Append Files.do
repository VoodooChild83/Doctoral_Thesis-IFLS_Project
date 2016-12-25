* This file will append all the marriage files to create the longitudinal histories

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Do the do files for each year

foreach year in 1993 1997 2000 2007{

quietly do "$maindir$project$Do/Marriages/Marriage Summary `year'.do"

}



	* Append the histories	

		foreach year in 2000 1997 1993 {

			append using "$maindir$tmp/Marriage History `year'.dta"
	
			}
			
order pidlink hhid wave MarrNum year*

*bysort pidlink wave (MarrNum): gen flag_CurrMarr=(MarrNum==_N)

********************************************************************************
// Erase the Data

	foreach year in 2007 2000 1997 1993 {

			erase "$maindir$tmp/Marriage History `year'.dta"
	
			}
	

