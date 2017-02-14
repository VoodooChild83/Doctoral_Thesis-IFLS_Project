* Master Migration Data Set Builder

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
qui do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Do the migration files: 1993, 1997, 2000, 2007

foreach year in 1993 1997 2000 2007 2014{
		qui do "$maindir$project$Do/Migration/Migration `year'.do"
		}

********************************************************************************
// Do the Migration Consolidation Do file

qui do "$maindir$project$Do/Migration/Migration Consolidation.do"

********************************************************************************
// Do the Year-Share Migration dataset for descriptive stats

qui do "$maindir$project$Do/Migration/Year-Share Migrants.do"

********************************************************************************
// Do the Migration year dummies dataset for Children Parent Migration

qui do "$maindir$project$Do/Migration/Migration Year Dummies.do"
