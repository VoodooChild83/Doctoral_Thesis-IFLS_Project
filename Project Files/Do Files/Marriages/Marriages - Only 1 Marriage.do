* MASTER MARRIAGE FILE FOR ONLY ONCE EVER MARRIED COUPLES (BOTH PARTNERS ONLY MARRIED ONCE)

* This file will merge the pidlink of the spouse into the data sets and create the longintudinal marriage history
* of those PAIRS who have only had 1 marriage in their lifetime (when pairs are identifiable - if the spouse of an
* individual is not identifiable, because they were not surveyed, then the given information of the one individual
* is kept). 

* In my comments I regard an "individual" as the unit of observation - using the pidilnk identifier
* I use "spouse" or "partner" interchangebly to refer to the marriage partner of the"individual"

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Link Husband and Wife identifiers

*qui do "$maindir$project$Do/Marriages/Marriages - Link Husband Wife.do"
	* The above code takes close to 48 hours to run - a saved file has the links *

********************************************************************************
// Generate the Marriage database

qui do "$maindir$project$Do/Marriages/Marriages - Append Files.do"

********************************************************************************
// Merge in the spouses of the individuals

	gen double pidlink2= real(pidlink)
		format pidlink2 %12.0f
		
	sort pidlink2 wave MarrNum
		
	merge m:1 pidlink2 wave using "$maindir$tmp/Husband Wife Link.dta",keep(1 3) nogen keepusing(pidlink_spouse)
	merge m:1 pidlink2 pidlink_spouse using "$maindir$tmp/Husband Wife ID Link.dta", keep(1 3) nogen keepusing(pidlink_couple)
	
	* Drop the spouse pidlink if not the current marriage
	
		replace pidlink_spouse=. if Marriage==""
		replace pidlink_couple=. if Marriage==""
	
		drop Marriage
	
		order pidlink hhid pidlink2 pidlink_spouse pidlink_couple wave 
	
********************************************************************************
// Find those who have only ever been married once
	
 * 1) Consider only those that have ever had one marriage (if spouse has had more than one, obtain their information from the sole remaingin spouse)
 
	bysort pidlink (wave MarrNum): egen MaxMarrNum=max(MarrNum)
	
	egen People_1Marr=group(pidlink MaxMarrNum) if MaxMarrNum==1 //There are 24071 people who have only been married once ~83% of the sample
	
 * 2) Keep and regard for later those who have had more than one marriage, as well as creating a file of the spousal partners for individuals with multiple marriages
 
	preserve
 
		qui do "$maindir$project$Do/Marriages/Marriages - Multiple Marriages.do"
	
	restore
	
 * 3) Keep only those with one marriage reported across the waves
	
	drop if People_1Marr==.
		drop MaxMarrNum People_1Marr
	
 * 4) Collapse using the collapse and preserve function (obtained from the internet) to preserve labels
	
	qui collapseandpreserve (lastnm) hhid wave pidlink2 pidlink_spouse pidlink_couple year_start year_end Dowry MarrNum MaritalStat Divorced WhoChose Sex State_of_Marr SchLvl_Spouse MaxSchYrs_Spouse Wives SpouseInHH, by(pidlink) omitstatfromvarlabel
	
 * 5) Find the inconsistencies & missing partner info: different individuals who are seemingly simultaneously married to the same spouse (especially females married to more than one male)
 
	qui do "$maindir$project$Do/Marriages/Marriages - Single Marriage Multiple Partners.do"
	
 * 6) Merge in identifying information to clean up those with only one marriage AND identify those whose spouse is not in the survey
 
	qui do "$maindir$project$Do/Marriages/Marriages - Merge and Correct Only 1 Marriage.do"
	
 * 7) Create the second partner in the databse for those where only one partner was observed in the single marriage
 
	qui do "$maindir$project$Do/Marriages/Marriages - Recreate missing spouse.do"
	
 * 8) Update widowed individuals

	qui do "$maindir$project$Do/Marriages/Marriages - Correct missing year end dates widowed and divorced.do"
	
 * 9) Correct the inconsistent dates for flag_DataConsistency=3 and update other information
 
	qui do "$maindir$project$Do/Marriages/Marriages - Correct 1 Marriage Do File.do"
	
 save "$maindir$tmp/Marriage History Database - Couples only 1 Marriage.dta", replace
