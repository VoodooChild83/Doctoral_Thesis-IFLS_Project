// IPUMS Cleaning File

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************

use "$maindir$project$ipums/Raw Data/IPUMS Indonesia.dta"

keep if year==1976|year==1995

// Recode income that is missing or unknown (missing=9999998; NIU=9999999)

replace incwage=. if incwage==9999998|incwage==9999999

// Drop topcoded income (there are only 2 such observations)

gen topcode=1 if incwage==9999997
drop if topcode==1
drop topcode

// Replace the NIU with missing

replace hrsmain=. if hrsmain==998|hrsmain==999

// Replace age

replace age=. if age>97

********************************************************************************
// Occupation Codes: Harmonize codes between the two census years

gen int occ2=occ

replace occ2=. if occ2==0

	* Harmonize the 1976, 1980, 1985, 1990 census to the 1995 occupation codes
	
	gen occ3=int(occ2/10) if year==1976|year==1980|year==1985|year==1990 
	
	replace occ2=occ3 if year==1976|year==1980|year==1985|year==1990
	drop occ3
	
	* Group together related occupations that are not consistent between census
	
		* group code 29 with code 21 for 1976 (managers)
		
		replace occ2=21 if occ2==29
		*drop occ
		
		* group code 9 with group 8 for 1995 (economists lumped in with other math and stats guys)
		
		replace occ2=8 if occ2==9
		
		* group sales assistants and sales workers (1976) into the 1995 code for sales occupations
		
		replace occ2=45 if occ2==46|occ2==49
		
	* Set to missing those with unidentified/unkown/NIU
	
	gen byte dum=1 if (occ2==. & year==1976)|((occ2==.|occ2==999) & (year==1985|year==1990))|(occ2==999 & year==1995)|((occ2==9998|occ2==9999) & year==1980)
	
	replace occ2=999 if dum==1
	drop dum
	
	* Make Occupations into string variable	
	
	tostring occ2, replace
	
	replace occ2="0"+occ2 if occ2=="0"|occ2=="1"|occ2=="2"|occ2=="3"|occ2=="4"|occ2=="5"|occ2=="6"|occ2=="7"|occ2=="8"
		
********************************************************************************
// Replace Days worked with missing if coded as "Not Worked"=0, "Unkown"=8, "NIU"=9

	replace dayswrk=. if dayswrk==0|dayswrk==8|dayswrk==9
	
********************************************************************************
// Generate the average days per week worked for 1995 jobs to use in 1976 jobs

	preserve
	
		collapse dayswrk, by (occ2)
		
		save "$maindir$tmp/Mean days per week.dta"
	
	restore
	
	preserve
	
		keep if year==1976
		
		merge m:1 occ2 using "$maindir$tmp/Mean days per week.dta", update keep(1 3 4 5) nogen
		
		save "$maindir$tmp/1976 Census Data.dta"
		erase "$maindir$tmp/Mean days per week.dta"
	
	restore
	
	drop if year==1976
	
	append using  "$maindir$tmp/1976 Census Data.dta"
	
	erase  "$maindir$tmp/1976 Census Data.dta"
	
********************************************************************************
// Generate the average hours per week worked for those with missing values

preserve

	collapse hrsmain, by (occ2)
	
	save "$maindir$tmp/Mean hours per week.dta"

restore

preserve

	keep if hrsmain==. & incwage!=.
	
	merge m:1 occ2 using "$maindir$tmp/Mean hours per week.dta", update keep(1 3 4 5) nogen

	save "$maindir$tmp/1976 Census Data.dta"
	erase "$maindir$tmp/Mean hours per week.dta"

restore

	drop if hrsmain==. & incwage!=.
	
	append using "$maindir$tmp/1976 Census Data.dta"
	
	erase "$maindir$tmp/1976 Census Data.dta"

	
********************************************************************************
/* Create an indicator variable for those observations where the following are observed: 
	1) income
	2) hours worked
	3) days worked
*/

	gen byte worked=1 if incwage!=. &  hrsmain!=. 
	
********************************************************************************
// Adjust wages to 2014 IDR (Indonesian Rupiah)

* use the inflation file

merge m:1 year using "$maindir$project/Inflation/PPP.dta", keep(1 3) nogen

gen r_wage_mth=incwage/PPP
drop PPP

********************************************************************************
// Create Work Variables

gen hrs_wk=hrsmain
gen days_wk=dayswrk

gen hrs_mth=hrs_wk*(52/12)*(days_wk/7) //adjust for the number of days in a week worked

gen ln_wage_mth=ln(r_wage_mth)

gen r_wage_hr=r_wage_mth/hrs_mth
gen ln_wage_hr=ln(r_wage_hr)

********************************************************************************
/* Generate the Census Sample for those who have worked (keep only those with
   works==1) */
   
keep if worked==1

********************************************************************************
// Clean the demographic binary variable

 * Religion
 
 recode religion (5=0 "Muslim") (2 3 6/9=1 "Other"), gen(Religion) label(religion)
 
 recode educid (0 998=.) (10 21 22=0 "No Schooling") (31/39 41/44=1 "Primary") (51/55 61/65=2 "Obl Secondary") (71/75 81/86=3 "Non-Obl Secondary") (91/93 101/106 111/119 123 124=4 "Tertiary"), gen(SchLvl) label(SchoolLevel)
 
 recode sex (1=0 "Male") (2=1 "Female"), gen(Sex) label(sex)
 
 recode urban (1=0 "Rural") (2=1 "Urban"), gen(Urban) label(urbanization)
 
 recode langid (1=0 "Indonesian") (2 3 8 9=1 "Other"), gen(Language) label(language)
 
 recode lit (0 9=.) (2=0 "Literate") (1=1 "Illiterate"), gen(Literacy) label(lit)
 
 recode marst (9=.) (1 3 4=0 "Unmarried") (2=1 "Married"), gen(Marriage) label(marriage)
 
 rename  (geo1_idx geo2_idx) (provmov kabmov)
 
 rename yrschool MaxSchYrs
 
 * Replace School Years

	replace MaxSchYrs=. if MaxSchYrs>17

 
********************************************************************************
// Keep Only relavant variables

keep year serial perwt relate age birthyr Religion SchLvl Sex Urban Language Literacy Marriage provmov kabmov MaxSchYrs occ2 r_* ln_* hrs_* days_*

gen age_2=age*age

gen version="IPUMS"

save "$maindir$project$ipums/Project Files/Census Wage Data.dta",replace	

/* Go back to ipums and look to see if there is a variable for "age of first job" to 
   see if experience can be ascertained */
