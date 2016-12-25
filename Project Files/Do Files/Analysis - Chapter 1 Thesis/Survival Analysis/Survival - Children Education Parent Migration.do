/// This do files is simply to stset the data for a Weibull type analysis


clear matrix
clear mata

set maxvar 20000
set matsize 11000

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Quietly do the file that builds the dataset

quietly do "$maindir$project/Do Files/Survival Analysis Dataset.do"
* The above code will take forever to run because of Linkage Correction do file.

use "$maindir$project/Survival dataset.dta"

********************************************************************************
//Set the data for duration

* Up to Graduation

stset SchoolGrade, failure(GradDropOut2)

	* Create a grouping variable: Sex and Birth Urbinization

	egen UrbSex=group(UrbBirth sex)
	
	* Create a second migration gourping
	
	egen mig2=group(FaMig MoMig FaMoMig)
	
	* Create the mig grouping for those whose parent's don't and do migrate
	gen mig3=1 if mig2==1	//don't migrate
	replace mig3=2 if mig2==4  // do migrate
	
	gen mig4=1 if mig2==1
	replace mig4=2 if mig2==2	//Father migrate
	
	gen mig5=1 if mig2==1
	replace mig5=2 if mig2==3  //Mother migrate
	
	
	
	egen mig2OK=group(FaMigOK MoMigOK FaMoMigOK)
	
	* Create the mig grouping for those whose parent's don't and do migrate
	gen mig3OK=1 if mig2OK==1	//don't migrate
	replace mig3OK=2 if mig2OK==4  // do migrate
	
	gen mig4OK=1 if mig2OK==1
	replace mig4OK=2 if mig2OK==2	//Father migrate
	
	gen mig5OK=1 if mig2OK==1
	replace mig5OK=2 if mig2OK==3  //Mother migrate
	
	
	* Create some graphs for the different hazard
	
		* Urbanization and sex differentiation
		
		sts graph,hazard by(UrbSex) ci ciopts(fi(inten0) lp(dash)) ///
		title(Survival of School Attendance) xtitle("School Years") ytitle("K-M Hazard") ///
		legend(order(9 10 11 12) label(9 Rural Girls) label(10 Rural Boys) label(11 Urban Girls) label(12 Urban Boys))
	
		graph export "$maindir$project/Graphs/UrbSexHaz.png", replace
		
		
foreach urb in Rural Urban{
		foreach gend in Boys Girls{
	
			if "`urb'"=="Rural" {
				if "`gend'"=="Girls" {
					local code=1
					local scale="ylabel(0.3(0.1)1)"
					}
				else {
					local code=2
					local scale="ylabel(0.3(0.1)1)"
					}
				}
			if "`urb'"=="Urban"{
				if "`gend'"=="Girls"{
					local code=3
					local scale="ylabel(0.6(0.1)1)"
					}
				else {
					local code=4
					local scale="ylabel(0.6(0.1)1)"
					}
				}
				
			foreach seq in /* All*/ /*Father*/ /*Mother*/ Parents {
			
				/*if "`seq'"=="All" {
					local label="legend(order(9 10 11 12) label(9 Parents Don't Mig) label(10 Father Mig) label(11 Mother Mig) label(12 Parents Mig))"
					local tac=2
					}*/
				/*if "`seq'"=="Father" {
					local label="legend(order(5 6) label(5 Parents Don't Mig) label(6 Father Mig))"
					local tac=4
					}*/
				/*if "`seq'"=="Mother" {
					local label="legend(order(5 6) label(5 Parents Don't Mig) label(6 Mother Mig))"
					local tac=5
					}*/
				else {
					local label="legend(order(5 6) label(5 Parents Don't Mig) label(6 Parents Mig))"
					local tac=3
					}
				
					sts graph if UrbSex==1,survival by(mig4) ci ciopts(fi(inten0) lp(dash)) ///
					title(Survival of `urb' `gend' School Attendance) xtitle("School Years") ytitle("K-M Hazard") legend(order(5 6) label(5 Parents Don't Mig) label(6 Parents Mig)) xlabel(0(1)12)
					
					graph export "$maindir$project/Graphs/`urb'`gend'`seq'Mig.png", replace
			}	
	
		}
}

stset, clear

save "$maindir$project/Survival-Parent Child Migration.dta", replace


