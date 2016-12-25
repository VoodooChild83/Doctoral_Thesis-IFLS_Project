********************* 							 *******************************

*  Migration Longitudianal Data - Export for Python and SQLite to visualize	   *

********************************************************************************

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
*Do the migration builder file to generate the data

qui do "$maindir$project$Do/Longitudinal Panel DataSet/Migration Longitudinal Builder.do"

export delimited pidlink age kecmov kabmov provmov using "$maindir$project/Python Vis of Mig Data/migration_data.csv", delimiter(";") replace




