// 1997 Marriage Summary and History

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
********************************************************************************
// Current File and merge with Summary File

foreach book in 3/b3a_kw2 4/b4_kw1 {

	use "$maindir$wave_2/hh97b`book'.dta"
		
	if "`book'"=="3/b3a_kw2"{

		merge 1:1 pidlink using "$maindir$wave_2/hh97b3/b3a_kw1.dta", keep(match master) nogen

		* Keep and clean the variables

		recode kw05 (1=0 "Male") (3=1 "Female"), gen(Sex) label(Sex)

		recode kw06 (3=0 "1 Wife") (1=1 "More Than 1 Wife") (6/9=.), gen(Wives) labe(Wives)
		
	}
	
	else {
	
		gen byte Sex = 1
		
		label define Sex 0 "Male"  1 "Female"
		label values Sex Sex 
	
	}
	
		* Keep and clean the common variables

		recode kw02 (1 3/5=0 "Not Married") (2=1 "Married") (9=.), gen(MaritalStat) label(MarrStat)
		
		recode kw02 (3 4=1 "Divorced") (1 2 5=0 "Not Divorced") (6/9=.), gen(Divorced) label(Divorced)

		recode kw03 (96 99 = .), gen(NumMarriages)

		recode kw04 (1 4=1 "Parents/Family") (3=0 "Self") (5/9 = .), gen(WhoChose) label(WhoChose)

		rename hhid97 hhid

		gen Marriage="Current"

		* Clean Dowry information

		replace kw12b=. if kw12bx!=1

		rename kw12b Dowry
		
		order pidlink hhid

		if "`book'"=="3/b3a_kw2"{

			keep pidlink MaritalStat WhoChose Sex Wives NumMarriages hhid Dowry Marriage Divorced
			
			save "$maindir$tmp/Marriage Summary 1997 - book3.dta", replace
			
		}
		
		if "`book'"=="4/b4_kw1" {
		
			keep pidlink MaritalStat WhoChose Sex NumMarriages Dowry Marriage Divorced hhid
			
			save "$maindir$tmp/Marriage Summary 1997 - book4.dta", replace
		
		}
		
		
		
	}

********************************************************************************
********************************************************************************
// Histories file

foreach book in 3/b3a_kw3 4/b4_kw2{

use "$maindir$wave_2/hh97b`book'.dta"

********************************************************************************
********************************************************************************
// Merge in birth year

merge m:1 pidlink using "$maindir$project/birthyear.dta", keep(match master) nogen

********************************************************************************
// Clean the marriage years 

* Marriage Start Dates

	* Clean the marriage start years
	
		replace kw10yr=. if kw10yr>1998
		
	* Clean marriage start age
	
		recode kw11 (96/99=.)
		
	* Replace missing marriage start years from birthdate and age
	
		gen flag_agerep=1 if kw11!=.
		
		replace kw10yr=kw11+birthyr if flag_agerep==1
		
		drop flag_agerep
		
	* Generate age variable and flag years if younger than 8 (the minimum reported age when
	* age given and not year in original survey)
	
		gen flag_InconsisAge=1 if (kw10yr-birthyr<8 & kw10yr!=.) | (kw11+birthyr>1998 & kw11!=.) 
		
		bysort pidlink: egen flag_AgeWrong1=max(flag_InconsisAge)
		drop flag_InconsisAge
		
* Marriage End Dates
		
	* Clean the marriage end years
		
		replace kw18yr=. if kw18yr>1998
		
	* Replace missing marriage start years from birthdate and age
	
		gen flag_agerep=1 if kw19!=.
		
		replace kw18yr=kw19+birthyr if flag_agerep==1
		
		drop flag_agerep
		
	* Generate age variable and mark years as missing if younger than 8 (the minimum reported age when
	* age given and not year in original survey) or if the year of marriage end is before marriage began
		
		gen flag_InconsisAge=1 if (kw18yr-birthyr<8 & kw18yr!=.) | (kw19+birthyr>1998 & kw19!=.) | (kw18yr<kw10yr & kw18yr!=. & kw10yr!=.) | (kw10yr==.)
	
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
	
		replace kw16=. if kw16==9
		
	* Recode those who are seperated and have a marriage end date as unmarried
	
		replace kw16=4 if kw16==3 & kw18yr!=.
		
	* Recode those who are widowed and divorced as not married for the current state of the marriage
	
		recode kw16 (3 4 5 = 0 "Not Married") (2 = 1 "Still Married"), gen(State_of_Marr) label(State_of_Marr)
		
		recode kw16 (3 4 = 1 "Divorced") (2 5 = 0 "Not Divorced"), gen(Divorced) label(Divorced)
		
		* Replace year start if state of marriage is "Not Married" and no end year is given
		
			replace kw10yr=. if State_of_Marr==0 & kw18yr==.
			
			bysort pidlink (kw10yr): gen Clean=1 if kw10yr==.
			by pidlink: egen Cleanmax=max(Clean)
			replace kw10yr=. if Cleanmax==1
			replace kw18yr=. if Cleanmax==1
			drop Clean*
	
	* Spouse Lives in HH?
	
		recode kw17 (1=0 "Yes") (3=1 "No"), gen(SpouseInHH) label(SpouseInHH)

********************************************************************************
// Recode the panel respondents

	recode kw22x (1=0 "Panel") (3=1 "New"), gen(Respondent) label(Respondent)
	
********************************************************************************
// Recode the Schooling levels of Spouse

recode kw20 (1 = 0 "No Schooling") (2 = 1 "Primary") (3 4 = 2 "Obl Secondary") ( 5 6 = 3 "Non-Obl Secondary") (7/9 = 4 "College") (10/99 = .), gen (SchLvl_Spouse) label(SchoolLevel)

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

rename (kw10yr kw18yr hhid97) (year_start year_end hhid)

	* Generate the marriage number (since the kwn variable is backwards - the latest marriage is coded as marriage 1)

		gsort pidlink -kwn
		by pidlink: gen MarrNum=_n

********************************************************************************
// Identify the current marriage

/*by pidlink: gen obs=_N*/

gen Marriage="Current" if kwn==1 /*obs==1
	replace Marriage="Current" if State_of_Marr==1 & Marriage==""
	
	by pidlink: gen Marr_Current=1 if Marriage=="Current"
	by pidlink: egen Marr_Currentmax=max(Marr_Current)
		drop Marr_Current
	replace Marriage="Current" if State_of_Marr==0 & obs==MarrNum & year_start!=. & Marr_Currentmax!=1
		drop Marr_Currentmax obs
		
	replace Marriage="" if Marriage=="Current" & year_start==. & kwn!=1 */

********************************************************************************
// Merge in the Summary file

if "`book'"=="3/b3a_kw3"{	

	merge m:1 pidlink Marriage using "$maindir$tmp/Marriage Summary 1997 - book3.dta", update replace keep(1 3 4 5) nogen

	erase "$maindir$tmp/Marriage Summary 1997 - book3.dta"
	
} 

if "`book'"=="4/b4_kw2" {

	merge m:1 pidlink Marriage using "$maindir$tmp/Marriage Summary 1997 - book4.dta", update replace keep(1 3 4 5) nogen

	erase "$maindir$tmp/Marriage Summary 1997 - book4.dta"

}

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

if "`book'"=="3/b3a_kw3" {

	by pidlink: gen flag_InconsisMarr=1 if (pidlink[_n]==pidlink[_n-1] & year_end[_n]==. & year_end[_n-1]==. & Wives[_n]==0 & Wives[_n-1]==0) | ///
									   (pidlink[_n]==pidlink[_n+1] & year_end[_n]==. & year_end[_n+1]==. & Wives[_n]==0 & Wives[_n+1]==0)

	replace year_start=. if flag_InconsisMarr==1
	replace year_end=. if flag_InconsisMarr==1

	drop flag_InconsisMarr

}

********************************************************************************
// Identify the individuals to drop

gen flag_Drop=1 if year_start==. | flag_AgeWrong==1  /* There are about 372 people who will be dropped because of inconsistencies (4.37% of the people)

														egen Person_Count1=group(pidlink flag_Drop) if flag_Drop==1  // to count number of people to drop
														egen Person_Count2=group(pidlink) 							 // to count total number of individuals
													 */
 
drop pid97 version* kw* birthyr flag_AgeWrong /*Marriage*/

********************************************************************************
// Save

compress

if "`book'"=="3/b3a_kw3" {
		
	save "$maindir$tmp/Marriage History 1997 - book3.dta", replace
	
}

}

********************************************************************************
********************************************************************************
// Append the two datasets

append using "$maindir$tmp/Marriage History 1997 - book3.dta"

sort pidlink year_start

gen wave=1997

save "$maindir$tmp/Marriage History 1997.dta", replace

	erase "$maindir$tmp/Marriage History 1997 - book3.dta"
	


		
		




		
		



