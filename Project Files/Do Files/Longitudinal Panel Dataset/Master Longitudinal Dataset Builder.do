***************** MASTER LONGITUDINAL DATASET GENERATOR ************************

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Build the Dynasties, Generations, and Families 

	* 1) Do the Dynasty Builder file to place people in their appropriate dynasties
	
		qui do "$maindir$project$Do/Longitudinal Panel DataSet/Dynasty Builder.do"
		
	* 2) Assign the generations to each person WITHIN the already built dynasties
	
		qui do "$maindir$project$Do/Longitudinal Panel DataSet/Generation Builder.do"
			
		* TEMP (Remove later)
		
		save "$maindir$tmp/Dynasty Build.dta", replace

********************************************************************************
// Education Data Set

	qui do "$maindir$project$Do/Education/Childrens Education - Longitudinal Dataset for Master Data.do"
	
********************************************************************************
// MIGRATION DATA SET 

	qui do "$maindir$project$Do/Longitudinal Panel DataSet/Migration Longitudinal Builder.do"
	
