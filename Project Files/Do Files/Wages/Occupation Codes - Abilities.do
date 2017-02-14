// Occupational Codes: Skill Index from ONET

qui do "$maindir$project$Do/Wages/onetsoc_to_isco_cws_ibs.do"

* Create the isco68 codes from isco88 codes 

isko8868 isco68, isko(isco88)

order isco68
sort isco68

* generate the 2 digit ISCO code

gen occ2 = int(isco68/100)
order occ2

* Collapse the data by the 2 digit code

collapse t_*, by(occ2) /* missing value is 3469 and its social workers; will need to find them and replace by the code*/

* Sum all the skills

egen Tot_Skills = rsum(t_*)

* Generate the median skill: this will be the cutoff between high skilled and low skilled

egen Med_Skill=median(Tot_Skills)

gen Skill_Level = (Tot_Skills>Med_Skill)

* drop uneccesary variables
drop t_* *_Skill*

* Create the 1 digit code for those with no 2 digit abilities

preserve

	replace occ2 = floor(occ2/10)
	
	collapse Skill_Level, by(occ2)
	
	replace Skill_Level = round(Skill_Level)
	
	drop if occ2==.

	tostring occ2, replace
	
	replace occ2 = occ2 + "X"
	
	* save the file of 1 digit codes
	
	save "$maindir$tmp/Digit 1 codes.dta", replace

restore

* Make occ2 a string

tostring occ2, replace

* add a 0 in front of the occupation string

foreach num in 1 2 3 4 5 6 7 8 9 {

	replace occ2 = "0"+occ2 if occ2=="`num'"

}

*append the 1 digit codes
append using "$maindir$tmp/Digit 1 codes.dta"
rm "$maindir$tmp/Digit 1 codes.dta"

preserve

	* Generate data for military occupations
	clear
	
	set obs 1
	gen occ2=`"MM"' in 1
	gen Skill_Level=0 in 1
	
	set obs 2
	replace occ2=`"M1"' in 2
	replace Skill_Level=1 in 2
	
	set obs 3
	replace occ2=`"M2"' in 3
	replace Skill_Level=1 in 3
	
	save "$maindir$tmp/Military.dta", replace

restore

append using "$maindir$tmp/Military.dta"
rm "$maindir$tmp/Military.dta"
 
* save the file
save "$maindir$tmp/Occ Codes Ability Level.dta", replace
