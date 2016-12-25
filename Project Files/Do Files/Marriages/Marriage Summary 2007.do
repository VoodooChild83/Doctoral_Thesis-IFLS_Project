// 2007 Marriage Summary and History

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
********************************************************************************
// Current File and merge with Summary File

use "$maindir$wave_4/b3a_kw1.dta"

		* Keep only those individuals who have data per the survey instrument
	
		keep if kw01==3
		
		* Keep and clean the variables
		
		recode kw01a (1 6/8=0 "Not Married") (2/5=1 "Married") (9=.), gen(MaritalStat) label(MarrStat)
		
		recode kw01a (6 7=1 "Divorced") (1/5 8=0 "Not Divorced") (9=.), gen(Divorced) label(Divorced)
		
		recode kw05 (1=0 "Male") (3=1 "Female"), gen(Sex) label(Sex)
		
		recode kw06 (3=0 "1 Wife") (1=1 "More Than 1 Wife") (6/9=.), gen(Wives) labe(Wives)
		
		recode kw309x (96 99 = .), gen(NumMarriages)
	
		recode kw04 (1 4=1 "Parents") (3=0 "Self") (5/99 = .), gen(WhoChose) label(WhoChose)

		rename hhid07 hhid

		gen Marriage="Current"

		* Clean Dowry information

		rename kw312b Dowry
	
		order pidlink hhid
		
		* Save

		keep pidlink MaritalStat WhoChose Sex Wives NumMarriages hhid Dowry Marriage Divorced	
		
		save "$maindir$tmp/Marriage Summary 2007 - book 3.dta", replace

********************************************************************************
********************************************************************************
// Histories file

foreach book in b3a_kw3 b4_kw2 {

	use "$maindir$wave_4/`book'.dta"

	* Update the variables that in previous waves were in the summary file
	
	if "`book'"=="b4_kw2" {
	
		recode kw03a (1 6/8=0 "Not Married") (2/5=1 "Married") (9=.) if kwn==1, gen(MaritalStat) label(MarrStat)
		
		recode kw03a (6 7=1 "Divorced") (1/5 8=0 "Not Divorced") (9=.) if kwn==1, gen(Divorced) label(Divorced)
		
		recode kw04 (1 4=1 "Parents") (3=0 "Self") (5/99 = .) if kwn==1, gen(WhoChose) label(WhoChose)
		
		recode kw03 (96 99 = .) if kwn==1, gen(NumMarriages)

		rename kw12b Dowry
		
		gen Marriage="Current" if kwn==1
	
		gen byte Sex = 1
		
			label define Sex 0 "Male"  1 "Female"
			label values Sex Sex 
	
	}

********************************************************************************
********************************************************************************
// Merge in birth year

merge m:1 pidlink using "$maindir$project/birthyear.dta", keep(match master) nogen

********************************************************************************
// Clean the marriage years 

* Marriage Start Dates

	* Clean the marriage start years
	
		replace kw10yr=. if kw10yr>2008
		
	* Clean marriage start age
	
		recode kw11 (96/99=.)
		
	* Replace missing marriage start years from birthdate and age
	
		gen flag_agerep=1 if kw11!=.
		
		replace kw10yr=kw11+birthyr if flag_agerep==1
		
		drop flag_agerep
		
	* Generate age variable and flag years if younger than 8 (the minimum reported age when
	* age given and not year in original survey)
	
		gen flag_InconsisAge=1 if (kw10yr-birthyr<8 & kw10yr!=.) | (kw11+birthyr>2000 & kw11!=.) 
		
		bysort pidlink: egen flag_AgeWrong1=max(flag_InconsisAge)
		drop flag_InconsisAge
		
* Marriage End Dates
		
	* Clean the marriage end years
		
		replace kw18yr=. if kw18yr>2000
		
	* Replace missing marriage start years from birthdate and age
	
		gen flag_agerep=1 if kw19!=.
		
		replace kw18yr=kw19+birthyr if flag_agerep==1
		
		drop flag_agerep
		
	* Generate age variable and mark years as missing if younger than 8 (the minimum reported age when
	* age given and not year in original survey) or if the year of marriage end is before marriage began
		
		gen flag_InconsisAge=1 if (kw18yr-birthyr<8 & kw18yr!=.) | (kw19+birthyr>2000 & kw19!=.) | (kw18yr<kw10yr & kw18yr!=. & kw10yr!=.) | (kw10yr==.)
	
		bysort pidlink: egen flag_AgeWrong2=max(flag_InconsisAge)
		drop flag_InconsisAge
		
		egen flag_AgeWrong=rsum(flag_AgeWrong*), missing
		drop flag_AgeWrong1 flag_AgeWrong2
		
		replace flag_AgeWrong=1 if flag_AgeWrong==2
		
* Replace as missing the miarriage years if there is an inconsistency

	replace kw10yr=. if flag_AgeWrong==1
	replace kw18yr=. if flag_AgeWrong==1
	
********************************************************************************
// Clean the current Status of the marriage

	* Replace as missing if there was an age inconsitency or it is coded as 9 (missing value)
	
		replace kw11b=. if kw11b==9
		
	* Recode those who are seperated and have a marriage end date as unmarried
	
		replace kw11b=7 if kw11b==6 & kw18yr!=.
		
	* Recode those who are widowed and divorced as not married for the current state of the marriage
	
		recode kw11b (6/8 = 0 "Not Married") (2/5 = 1 "Still Married") (9=.), gen(State_of_Marr) label(State_of_Marr)
		
		if "`book'"=="b3a_kw3" {
			recode kw11b (6/7 = 1 "Divorced") (2/5 8 = 0 "Not Divorced"), gen(Divorced) label(Divorced)
		}
		
		replace Divorced=1 if kw11b>5 & kw11b<8 & kwn!=1
		replace Divorced=0 if ((kw11b>1 & kw11b<6)|kw11b==8) & kwn!=1
		
		* Replace year start if state of marriage is "Not Married" and no end year is given
		
			replace kw10yr=. if State_of_Marr==0 & kw18yr==.
			
			bysort pidlink (kw10yr): gen Clean=1 if kw10yr==.
			by pidlink: egen Cleanmax=max(Clean)
			replace kw10yr=. if Cleanmax==1
			replace kw18yr=. if Cleanmax==1
			drop Clean*	

********************************************************************************
// Recode the Schooling levels of Spouse

recode kw20 (1 = 0 "No Schooling") (2 72 = 1 "Primary") (3 4 73 = 2 "Obl Secondary") ( 5 6 74 = 3 "Non-Obl Secondary") (8 9 60/63 = 4 "College") (7 10/12 14/17 95/99 = .), gen (SchLvl_Spouse) label(SchoolLevel)

gen MaxSchYrs_Spouse=.

	replace MaxSchYrs_Spouse=0 if SchLvl_Spouse==0
	replace MaxSchYrs_Spouse=kw21 if kw21<7 & kw21!=. & SchLvl_Spouse==1
		replace MaxSchYrs_Spouse=6 if kw21==7 & SchLvl_Spouse==1
	replace MaxSchYrs_Spouse=6+kw21 if kw21<7 & kw21!=. & SchLvl_Spouse==2
		replace MaxSchYrs_Spouse=9 if kw21==7 & SchLvl_Spouse==2
	replace MaxSchYrs_Spouse=9+kw21 if kw21<7 & kw21!=. & SchLvl_Spouse==3
		replace MaxSchYrs_Spouse=12 if (kw21==7 & SchLvl_Spouse==3) | (MaxSchYrs_Spouse>13 & MaxSchYrs_Spouse!=.)
	replace MaxSchYrs_Spouse=13 if kw21==7 & SchLvl_Spouse==4
	
	* Recode those who did not finish the first year of the next level as only having reached the previous level
	
	replace SchLvl_Spouse=0 if MaxSchYrs_Spouse==0 & SchLvl_Spouse==1
	replace SchLvl_Spouse=1 if kw21==0 & SchLvl_Spouse==2
	replace SchLvl_Spouse=2 if kw21==0 & SchLvl_Spouse==3
	replace SchLvl_Spouse=3 if kw21==0 & SchLvl_Spouse==4
	
********************************************************************************
// Rename variable and drop what isn't kept

rename (kw10yr kw18yr hhid07) (year_start year_end hhid)

	* Generate the marriage number (since the kwn variable is backwards - the latest marriage is coded as marriage 1)
	
		gsort pidlink -kwn
		by pidlink: gen MarrNum=_n

********************************************************************************
// Identify the current marriage 

if "`book'"=="b3a_kw3"{

	/*bysort pidlink (year_start): gen obs=_N*/

	gen Marriage="Current" if kwn==1 /*obs==1
		replace Marriage="Current" if State_of_Marr==1 & Marriage==""
	
	by pidlink: gen Marr_Current=1 if Marriage=="Current"
	by pidlink: egen Marr_Currentmax=max(Marr_Current)
		drop Marr_Current
	replace Marriage="Current" if State_of_Marr==0 & obs==MarrNum & year_start!=. & Marr_Currentmax!=1
		drop Marr_Currentmax obs
		
	replace Marriage="" if Marriage=="Current" & year_start==. & kwn!=1 */
	
********************************************************************************
// Recode the panel respondents

	recode kw22x (1=0 "Panel") (3=1 "New"), gen(Respondent) label(Respondent)

********************************************************************************
// Merge in the Summary file

	merge m:1 pidlink Marriage using "$maindir$tmp/Marriage Summary 2007 - book 3.dta", update replace keep(1 3 4 5) nogen

	erase "$maindir$tmp/Marriage Summary 2007 - book 3.dta"

	order pidlink hhid year* MarrNum
	sort pidlink year* MarrNum

********************************************************************************
// Identify people whose current marriage status differs from the marriage state

	gen flag_InconsisMarr1=1 if MaritalStat!= State_of_Marr & Marriage=="Current"

	by pidlink: egen flag_InconsisMarrmax=max(flag_InconsisMarr1)
	drop flag_InconsisMarr1

	replace year_start=. if flag_InconsisMarrmax==1
	replace year_end=. if flag_InconsisMarrmax==1

	drop flag_InconsisMarrmax

********************************************************************************
// Identify the individuals who seem to have two current marriages but only state one wife

	by pidlink: gen flag_InconsisMarr=1 if (pidlink[_n]==pidlink[_n-1] & year_end[_n]==. & year_end[_n-1]==. & Wives[_n]==0 & Wives[_n-1]==0) | ///
										   (pidlink[_n]==pidlink[_n+1] & year_end[_n]==. & year_end[_n+1]==. & Wives[_n]==0 & Wives[_n+1]==0)

	replace year_start=. if flag_InconsisMarr==1
	replace year_end=. if flag_InconsisMarr==1

	drop flag_InconsisMarr

}

********************************************************************************
// Identify the individuals to drop

gen flag_Drop=1 if year_start==. | flag_AgeWrong==1  /* There are about 198 people who will be dropped because of inconsistencies (1.87% of the people)

														egen Person_Count1=group(pidlink flag_Drop) if flag_Drop==1  // to count number of people to drop
														egen Person_Count2=group(pidlink) 							 // to count total number of individuals
													 */
													 
if "`book'"=="b3a_kw3" drop /*Marriage*/ pid3a
if "`book'"=="b4_kw2" drop hhid07_9 

drop pid07 version* kw* birthyr module flag_AgeWrong

********************************************************************************
// Save

compress

if "`book'"=="b3a_kw3" {
		
	save "$maindir$tmp/Marriage History 2007 - `book'.dta", replace
	
}		

}

********************************************************************************
********************************************************************************
// Append the two datasets

append using "$maindir$tmp/Marriage History 2007 - b3a_kw3.dta"

sort hhid pidlink year_start

gen wave=2007

save "$maindir$tmp/Marriage History 2007.dta", replace

	erase "$maindir$tmp/Marriage History 2007 - b3a_kw3.dta"
	

		
		



