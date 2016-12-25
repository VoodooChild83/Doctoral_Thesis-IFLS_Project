// 1993 Marriage Summary and History

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
********************************************************************************
// Summary File

foreach book in buk3 buk4 {

	use "$maindir$wave_1/`book'kw1.dta"
	
	drop hhid

	* Keep and clean the variables
	
	if "`book'"=="buk3" {

		keep if kw01==3

		recode kw02 (1 3/5=0 "Not Married") (2=1 "Married") (6/9=.), gen(MaritalStat) label(MarrStat)
		
		recode kw02 (3 4=1 "Divorced") (1 2 5=0 "Not Divorced") (6/9=.), gen(Divorced) label(Divorced)

		recode kw03 (96 99 = .), gen(NumMarriages)

		recode kw04 (1=1 "Parents/Family") (3=0 "Self") (5/9 = .), gen(WhoChose) label(WhoChose)

		recode kw05 (1=0 "Male") (3=1 "Female"), gen(Sex) label(Sex)

		recode kw06 (3=0 "1 Wife") (1=1 "More Than 1 Wife") (6/9=.), gen(Wives) label(Wives)

		rename hhid93 hhid

		keep pidlink MaritalStat WhoChose Sex Wives NumMarriages hhid Divorced

		order pidlink hhid

		gen Marriage="Current"
		
		compress

		save "$maindir$tmp/Marriage Summary 1993 - `book'.dta", replace
		
	}
	
	if "`book'"=="buk4" {

		recode kw01 (3=0 "Not Married") (1=1 "Married") (9=.), gen(MaritalStat) label(MarrStat)
		
		recode kw01 (4=1 "Divorced") (1 3=0 "Not Divorced") (6/9=.), gen(Divorced) label(Divorced)

		recode kw02 (96 99 = .), gen(NumMarriages)
		
		recode kw03 (1=1 "Parents/Family") (3=0 "Self") (5/9 = .), gen(WhoChose) label(WhoChose)
		
		gen int Sex = 1
		
			label define Sex 0 "Male"  1 "Female"
			label values Sex Sex 
		
		rename hhid93 hhid

		keep pidlink MaritalStat WhoChose Sex NumMarriages hhid Divorced

		order pidlink hhid

		gen Marriage="Current"
		
		save "$maindir$tmp/Marriage Summary 1993 - `book'.dta", replace
	
	}

********************************************************************************
********************************************************************************
// Histories file

	use "$maindir$wave_1/`book'kw2.dta"
	
	drop hhid

		* Merge in birth year

		merge m:1 pidlink using "$maindir$project/birthyear.dta", keep(match master) nogen
		
		if "`book'"=="buk4" {
		
			drop kw17
		
			rename (kw05a kw06 kw08rp kw13b kw14age kw11 kw12 kw15 kw16) (kw10yr kw11yr kw13r1 kw18yr kw19yr kw16 kw17 kw20 kw21)
		
		}

********************************************************************************
// Clean the marriage years 

	* Marriage Start Dates

		* Clean the marriage start years
	
		replace kw10yr=. if kw10yr>93
		
		replace kw10yr=1900+kw10yr
		
		* Clean marriage start age
	
		recode kw11yr (96/99=.)
		
		* Replace missing marriage start years from birthdate and age
	
		gen flag_agerep=1 if kw11yr!=.
		
		replace kw10yr=kw11yr+birthyr if flag_agerep==1
		
		drop flag_agerep
		
		* Generate age variable and flag years if younger than 7 (the minimum reported age when
		* age given and not year in original survey)
	
		gen flag_InconsisAge=1 if (kw10yr-birthyr<7 & kw10yr!=.) | (kw11yr+birthyr>1993 & kw11yr!=.) 
		
		bysort pidlink: egen flag_AgeWrong1=max(flag_InconsisAge)
		drop flag_InconsisAge
		
	* Marriage End Dates
		
		* Clean the marriage end years
		
		replace kw18yr=. if kw18yr>93
		
		replace kw18yr=1900+kw18yr
		
		* Clean the marriage end age
	
		recode kw19yr (1/2 96/99=.)
		
		* Replace missing marriage start years from birthdate and age
	
		gen flag_agerep=1 if kw19yr!=.
		
		replace kw18yr=kw19yr+birthyr if flag_agerep==1
		
		drop flag_agerep
		
		* Generate age variable and mark years as missing if younger than 9 (the minimum reported age when
		* age given and not year in original survey) or if the year of marriage end is before marriage began
		
		gen flag_InconsisAge=1 if (kw18yr-birthyr<9 & kw18yr!=.) | (kw19yr+birthyr>1993 & kw19yr!=.) | (kw18yr<kw10yr & kw18yr!=. & kw10yr!=.) | (kw10yr==.)
	
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
		
		recode kw16 (3 4 = 1 "Divorced") (1 2 5 = 0 "Not Divorced"), gen(Divorced) label(Divorced)
		
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

	gen int Respondent = 1
		
			label define Respondent 0 "Panel"  1 "New"
			label values Respondent Respondent
		
********************************************************************************
// Clean Dowry information

* Replace Dowry to missing if it is larger than 999999995

	replace kw13r1=. if kw13r1>=999999995
	
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

rename (kw10yr kw13r1 kw18yr marrnum hhid93) (year_start Dowry year_end MarrNum hhid)

sort pidlink year_start MarrNum

********************************************************************************
// Identify the current marriage

/*by pidlink: gen obs=_N*/

gen Marriage="Current" if entryord==1 /*obs==1
	replace Marriage="Current" if State_of_Marr==1 & Marriage==""
	
	by pidlink: gen Marr_Current=1 if Marriage=="Current"
	by pidlink: egen Marr_Currentmax=max(Marr_Current)
		drop Marr_Current
	replace Marriage="Current" if State_of_Marr==0 & obs==MarrNum & year_start!=. & Marr_Currentmax!=1
		drop Marr_Currentmax obs
		
	replace Marriage="" if Marriage=="Current" & year_start==.*/

********************************************************************************
// Merge in the Summary file

merge m:1 pidlink Marriage using "$maindir$tmp/Marriage Summary 1993 - `book'.dta", update replace keep(1 3 4 5) nogen

erase "$maindir$tmp/Marriage Summary 1993 - `book'.dta"

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

if "`book'"=="buk3"{

	by pidlink: gen flag_InconsisMarr=1 if (pidlink[_n]==pidlink[_n-1] & year_end[_n]==. & year_end[_n-1]==. & Wives[_n]==0 & Wives[_n-1]==0) | ///
									   (pidlink[_n]==pidlink[_n+1] & year_end[_n]==. & year_end[_n+1]==. & Wives[_n]==0 & Wives[_n+1]==0)

	replace year_start=. if flag_InconsisMarr==1
	replace year_end=. if flag_InconsisMarr==1

	drop flag_InconsisMarr
}

********************************************************************************
// Identify the individuals to drop

gen flag_Drop=1 if year_start==. | flag_AgeWrong==1  /* There are about 443 people who will be dropped because of inconsistencies (5.86% of the people)

														egen Person_Count1=group(pidlink flag_Drop) if flag_Drop==1  // to count number of people to drop
														egen Person_Count2=group(pidlink) 							 // to count total number of individuals
													 */
													 
drop case person pid pid93 commid* kw* entr* birthyr flag_AgeWrong /*Marriage*/

********************************************************************************
// Save

compress
		
save "$maindir$tmp/Marriage History 1993 - `book'.dta", replace
			
}

********************************************************************************
********************************************************************************
// Append the two datasets

append using "$maindir$tmp/Marriage History 1993 - buk3.dta"

sort pidlink year_start

gen wave=1993

save "$maindir$tmp/Marriage History 1993.dta", replace

foreach book in buk3 buk4{

	erase "$maindir$tmp/Marriage History 1993 - `book'.dta"
	
}

