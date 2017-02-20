* Children's Education Longitudinal Sample Builder (Does not correct for grade repeats)

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************

* Identify Children to Analyze

	qui do "$maindir$tmp/Education/Childrens Education - Identify Children.do"
	
* Create the Education Dates panel data set

	qui do "$maindir$project$Do/Education/EducationDates.do"
	
* Create the Panel Dataset (Does not account for grade repeats)

	qui do "$maindir$project$Do/Education/Childrens Education - Longitudinal Dataset.do"
	
* Conduct the Survival Anlaysis

	qui do "$maindir$project$Do/Education/Childrens Education - Survival Analysis.do"	
	
* Conduct the descriptive analysis

	
		
* Save file

save "$maindir$tmp/Childrens Education - Longitudinal Data.dta", replace
		
