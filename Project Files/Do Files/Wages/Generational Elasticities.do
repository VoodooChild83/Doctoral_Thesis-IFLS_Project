* Estimation of Intergenerational mobility (in skill and wage of first job)

use "$maindir$tmp/Wage Database1.dta", clear

* Keep only the first jobs

bys pidlink (year job): keep if ( FirstJob==1 | (_n==1 & r_wage_hr!=.) ) /// & job==1

* Collapse the data to keep only one observation per person

collapse (mean) r_wage_hr age year hrs_wk wks_yr (max) Skill_Level IntraIsland_ParentMig InterIsland_ParentMig Prov_ParentMig UrbBirth Urb12 (firstnm) MaxSchYrs Sex Religion Ethnicity birthyr occ2, by (pidlink)

replace year=int(year)

* regenerate the log income

gen ln_wage_hr=ln(r_wage_hr)

* Find the father and the mother

preserve

	use "$maindir$tmp/Parent Child Link - Master.dta", clear
	
	keep if pidlink_father!=.|pidlink_mother!=.
	
	duplicates drop pidlink, force
	
	save "$maindir$tmp/Chilren to merge.dta", replace
	
restore

* Merge in the parental identifiers

merge 1:1 pidlink using "$maindir$tmp/Chilren to merge.dta", keepusing(pidlink_father pidlink_mother) keep(1 3) nogen
erase "$maindir$tmp/Chilren to merge.dta"

* Get the parent's first income and merge into the dataset

foreach parent in father mother {

	preserve
	
		keep if pidlink_`parent'!=.
		
		duplicates drop pidlink_`parent', force
		
		gen ln_wage_`parent'=ln_wage_hr
		
		gen Skill_Level_`parent'=Skill_Level
		
		gen MaxSchYrs_`parent'=MaxSchYrs
		
		gen UrbBirth_`parent' = UrbBirth
		
		gen Urb12_`parent' = Urb12
		
		gen Religion_`parent' = Religion
		
		gen Ethnicity_`parent' = Ethnicity
		
		gen year_`parent'=year
		
		gen birthyr_`parent'=birthyr
		
		gen age_`parent'=age
		
		gen hrs_wk_`parent'=hrs_wk
		
		gen wks_yr_`parent'=wks_yr
		
		save "$maindir$tmp/`parent' to merge.dta", replace
	
	restore
	
	preserve
	
		use "$maindir$tmp/EducStartStop.dta",clear
		
		gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
		
		gen long pidlink_`parent'= pidlink2
		
		gen SpeakInd_`parent'=SpeakInd
		gen ReadInd_`parent'=ReadInd
		gen WriteInd_`parent'=WriteInd
		
		save "$maindir$tmp/Parent Literacy.dta", replace
	
	restore

	merge m:1 pidlink_`parent' using "$maindir$tmp/`parent' to merge.dta", keepusing(*_`parent') keep(1 3) nogen
	merge m:1 pidlink_`parent' using "$maindir$tmp/Parent Literacy.dta", keepusing(*_`parent') keep(1 3) nogen
	erase "$maindir$tmp/`parent' to merge.dta"
	erase "$maindir$tmp/Parent Literacy.dta"
}

* Merge in the Dynasty to control in cluster

preserve
	
	use "$maindir$tmp/Dynasty Build.dta", clear
	
	duplicates drop pidlink, force
	
	save "$maindir$tmp/Dynasty to merge.dta", replace

restore

merge 1:1 pidlink using "$maindir$tmp/Dynasty to merge.dta", keepusing(Dynasty Family) keep(1 3) nogen
erase "$maindir$tmp/Dynasty to merge.dta"

* Merge in person weights

preserve

	use "$maindir$project/MasterTrack2.dta", clear
	
	keep if flag_LastWave==1
	
	keep pidlink pwt
	
	gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
	
	gen long pwt_father= pidlink2
	gen long pwt_mother=pidlink2
	
	save "$maindir$tmp/PersonWeights.dta", replace

restore

merge m:1 pidlink using "$maindir$tmp/PersonWeights.dta", keep(1 3) keepusing(pwt) nogen

* Poverty measure

gen r_wage_mth=r_wage_hr*hrs_wk*(52/12)
gen wage_mth_father=exp(ln_wage_father)*hrs_wk_father*(52/12)
gen wage_mth_mother=exp(ln_wage_mother)*hrs_wk_mother*(52/12)

gen Poverty=r_wage_mth<=79 &r_wage_mth!=.
	replace Poverty=. if r_wage_mth==.
gen Poverty_father=wage_mth_father<=79 & wage_mth_father!=.
	replace Poverty_father=. if wage_mth_father==.
gen Poverty_mother=wage_mth_mother<=79 & wage_mth_mother!=.
	replace Poverty_mother=. if wage_mth_mother==.

* Find all the children who were born on or after 1980 - Only analyse these people

gen flag_Birth_1980_99=1 if birthyr>=1980 & birthyr!=.

********************************************************************************
// Add labels to the variables to add to the regressions

la var MaxSchYrs "Education (Years)"
la var MaxSchYrs_father "Father's Education"
la var MaxSchYrs_mother "Mother's Education"
la var Sex "Sex"
la var InterIsland_ParentMig "Parent Island Migration"
la var IntraIsland_ParentMig "Parent Within Island Migration"
la var Religion "Religion"
la var Religion_father "Father's Religion"
la var Religion_mother "Mother's Religion"
la var Ethnicity_father "Father's Ethnicity"
la var Ethnicity_mother "Mother's Ethnicity"
la var Ethnicity "Ethnicity"
la var ln_wage_hr "ln (hourly wage)"
la var Skill_Level "Skill Level"
la var Skill_Level_father "Skill Level - Father"
la var Skill_Level_mother "Skill Level - Mother"
la var ln_wage_father "Father's Wage (First Job)"
la var ln_wage_mother "Mother's Wage (First Job)"
la var UrbBirth "Urbanization - Birth"
la var UrbBirth_father "Urbanization - Birth (Father)"
la var UrbBirth_mother "Urbanization - Birth (Mother)"
la var Urb12_father "Urbanization - Age 12 (Father)"
la var Urb12_mother "Urbanization - Age 12 (Mother)"
la var SpeakInd_father "Speaks Ind - Father"
la var SpeakInd_mother "Speaks Ind - Mother"
la var ReadInd_father "Read Ind - Father"
la var ReadInd_mother "Read Ind - Mother"
la var WriteInd_father "Write Ind - Father"
la var WriteInd_mother "Write Ind - Mother"


* Gen the birthyr-start year fe
/*
egen Birth_Start_fe=group(birthyr year) if flag_Birth_1980_99==1

*egen Birth_Start_father_fe=group(birthyr_father year_father) if flag_Birth_1980_99==1
*egen Birth_Start_mother_fe=group(birthyr_mother year_mother) if flag_Birth_1980_99==1

********************************************************************************
// Run the Regressions (Uncomment to rerun the regression -  So as to preserve the Tex Files)

* Father's Wages

qui areg ln_wage_hr ln_wage_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Father IEE.tex", addtext(Cohort*Start Year FE, YES) replace label dec(3) noas nodepvar

qui areg ln_wage_hr ln_wage_father MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Father IEE.tex", addtext(Cohort*Start Year FE, YES)  label dec(3) noas nodepvar

qui areg ln_wage_hr ln_wage_father Religion_father Ethnicity_father UrbBirth_father Urb12_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Father IEE.tex", addtext(Cohort*Start Year FE, YES) label dec(3) noas nodepvar

qui areg ln_wage_hr ln_wage_father MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father Religion_father Ethnicity_father UrbBirth_father Urb12_father InterIsland_ParentMig IntraIsland_ParentMig if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Father IEE.tex", addtext(Cohort*Start Year FE, YES)  label dec(3) noas nodepvar

* Father's Skill Level

qui areg Skill_Level Skill_Level_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Father IEE.tex", addtext(Cohort*Start Year FE, YES) label dec(3) noas nodepvar

qui areg Skill_Level Skill_Level_father MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Father IEE.tex", addtext(Cohort*Start Year FE, YES)  label dec(3) noas nodepvar

qui areg Skill_Level Skill_Level_father Religion_father Ethnicity_father UrbBirth_father Urb12_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Father IEE.tex", addtext(Cohort*Start Year FE, YES) label dec(3) noas nodepvar


qui areg Skill_Level Skill_Level_father MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father Religion_father Ethnicity_father UrbBirth_father Urb12_father InterIsland_ParentMig IntraIsland_ParentMig if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Father IEE.tex", addtext(Cohort*Start Year FE, YES)  label dec(3) noas nodepvar




* Mother's Wages

qui areg ln_wage_hr ln_wage_mother if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Mother IEE.tex", addtext(Cohort*Start Year FE, YES) replace label dec(3) noas nodepvar

qui areg ln_wage_hr ln_wage_mother MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Mother IEE.tex", addtext(Cohort*Start Year FE, YES)  label dec(3) noas nodepvar

qui areg ln_wage_hr ln_wage_mother Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Mother IEE.tex", addtext(Cohort*Start Year FE, YES) label dec(3) noas nodepvar

qui areg ln_wage_hr ln_wage_mother MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother InterIsland_ParentMig IntraIsland_ParentMig  if flag_Birth_1980_99==1, vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Mother IEE.tex", addtext(Cohort*Start Year FE, YES)  label dec(3) noas nodepvar

* Mother's Skill Level

qui areg Skill_Level Skill_Level_mother if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Mother IEE.tex", addtext(Cohort*Start Year FE, YES)  label dec(3) noas nodepvar

qui areg Skill_Level Skill_Level_mother MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Mother IEE.tex", addtext(Cohort*Start Year FE, YES) label dec(3) noas nodepvar

qui areg Skill_Level Skill_Level_mother Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Mother IEE.tex", addtext(Cohort*Start Year FE, YES) label dec(3) noas nodepvar

qui areg Skill_Level Skill_Level_mother MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother InterIsland_ParentMig IntraIsland_ParentMig if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Mother IEE.tex", addtext(Cohort*Start Year FE, YES) label dec(3) noas nodepvar



/*
* Parent's Wages

qui areg ln_wage_hr ln_wage_mother ln_wage_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Parents IEE.tex", addtext(Cohort*Start Year FE, YES) replace label dec(3) noas nodepvar

qui areg ln_wage_hr  ln_wage_mother ln_wage_father MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Parents IEE.tex", addtext(Parent's Education Control, YES,Cohort*Start Year FE, YES) drop(MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father)  label dec(3) noas nodepvar

qui areg ln_wage_hr ln_wage_mother ln_wage_father Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother Religion_father Ethnicity_father UrbBirth_father Urb12_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Parents IEE.tex", addtext(Parent's Birth and Characteristic Control, YES,Cohort*Start Year FE, YES) drop(Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother Religion_father Ethnicity_father UrbBirth_father Urb12_father) label dec(3) noas nodepvar

qui areg ln_wage_hr ln_wage_mother ln_wage_father MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother Religion_father Ethnicity_father UrbBirth_father Urb12_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Parents IEE.tex", addtext(Parent's Education Control, YES,Parent's Birth and Characteristic Control, YES, Cohort*Start Year FE, YES) drop(MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother Religion_father Ethnicity_father UrbBirth_father Urb12_father)  label dec(3) noas nodepvar


* Parent's Skill Level

qui areg Skill_Level Skill_Level_father Skill_Level_mother if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Parents IEE.tex", addtext(Cohort*Start Year FE, YES) label dec(3) noas nodepvar

qui areg Skill_Level Skill_Level_father Skill_Level_mother  MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Parents IEE.tex", addtext(Parent's Education Control, YES,Cohort*Start Year FE, YES) drop(MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father)  label dec(3) noas nodepvar

qui areg Skill_Level Skill_Level_father Skill_Level_mother  Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother Religion_father Ethnicity_father UrbBirth_father Urb12_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Parents IEE.tex", addtext(Parent's Birth and Characteristic Control, YES,Cohort*Start Year FE, YES) drop(Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother Religion_father Ethnicity_father UrbBirth_father Urb12_father) label dec(3) noas nodepvar

qui areg Skill_Level Skill_Level_father Skill_Level_mother MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother Religion_father Ethnicity_father UrbBirth_father Urb12_father if flag_Birth_1980_99==1 [pw=pwt], vce(cluster Dynasty) absorb(Birth_Start_fe)
outreg2 using "$maindir$project/Regressions/TEX Files/IEE/Parents IEE.tex", addtext(Parent's Education Control, YES,Parent's Birth and Characteristic Control, YES, Cohort*Start Year FE, YES) drop(MaxSchYrs_mother SpeakInd_mother ReadInd_mother WriteInd_mother MaxSchYrs_father SpeakInd_father ReadInd_father WriteInd_father Religion_mother Ethnicity_mother UrbBirth_mother Urb12_mother Religion_father Ethnicity_father UrbBirth_father Urb12_father)  label dec(3) noas nodepvar

