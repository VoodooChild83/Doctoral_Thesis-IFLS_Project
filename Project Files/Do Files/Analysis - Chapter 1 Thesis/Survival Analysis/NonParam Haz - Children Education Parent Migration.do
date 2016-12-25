 y// The nonparametric baseline hazard with probit hazards. 

clear matrix
clear mata

set maxvar 20000
set matsize 11000

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Do the file that generates the longitudinal dataset

quietly do "$maindir$project/Do Files/Survival Analysis Dataset.do"
* The above code will take forever to run because of Linkage Correction do file.

use "$maindir$project/Longitudinal Survival dataset.dta"

********************************************************************************
// Cox Proportional Hazard Estimation: Stset the data for multiple records

stset SchoolGrade, id(pidlink) failure(GradDropOut2)

********************************************************************************
// Discrete time with Probit hazards

* Reclassify agents as "migrants for life"

foreach mig in Fa Mo FaMo{
	foreach type in Mig MigOK MigIK{
	
	bysort pidlink (year): gen `mig'`type'2=`mig'`type'
	by pidlink (year): replace `mig'`type'2=`mig'`type'2[_n-1] if `mig'`type'2[_n-1]==1 & `mig'`type'2[_n-1]!=.
	
	}
}

		gen byte FaMoMigOK3=FaMoMigOK2
		replace FaMoMigOK3=1 if FaMigOK2==1 & MoMigOK2==1
		
		gen byte FaMoMigIK3=FaMoMigIK2
		replace FaMoMigIK3=1 if FaMigIK2==1 & MoMigIK2==1
		
		/*replace FaMoMigOK3=0 if FaMigOK2==0 & MoMigOK2==0
		replace FaMoMigOK3=0 if (FaMigOK2==0 & MoMigOK2==1)
		replace FaMoMigOK3=0 if (MoMigOK2==0 & FaMigOK2==1)*/
		
		replace FaMigOK2=0 if FaMoMigOK3==1
		replace MoMigOK2=0 if FaMoMigOK3==1
		
		replace FaMigIK2=0 if FaMoMigIK3==1
		replace MoMigIK2=0 if FaMoMigIK3==1
		
		replace FaMoMigOK2=FaMoMigOK3
		replace FaMoMigIK2=FaMoMigIK3
		
		drop *OK3 *IK3
		
		
		
		
	

	* Generate the baseline hazard dummies
	forvalues i=1/12{

		gen byte year`i'= SchoolGrade==`i'
	
	}

	* Generate parents migration and schooling interactions: the baseline hazard of those who migrate
	
		
		foreach parent in FaMig MoMig FaMoMig FaMigIK MoMigIK FaMoMigIK FaMigOK MoMigOK FaMoMigOK{
			forvalues i=1/11{
				gen byte Year`i'_`parent'=year`i' * `parent'
			}
		}
		
		
	* Generate birthyr dummies for those born 1950 (exclude 1950)
	
	forvalues i=1951/1990{
		
		gen byte D_`i'= birthyr==`i'
	
	}
	
	* interact with parents education
		
		* Family share of education:
		gen FamShare=FamEduc2/13
	
	foreach parent in Father Mother FamShare{
	
	forvalues i=1951/1990{
		
		if "`parent'"=="Father"|"`parent'"=="Mother" {
		gen float D_`i'_`parent'= D_`i' * `parent'_Share
		}
		
		else gen float D_`i'_`parent'= D_`i' * `parent'
	
	}
	}
	
	foreach parent in Father Mother FamShare{
	
	forvalues i=1/11{
		
		if "`parent'"=="Father"|"`parent'"=="Mother" {
		gen byte Year_`i'_`parent'= year`i' * `parent'_Share
		}
		
		else gen byte Year_`i'_`parent'= year`i' * `parent'
	
	}
	}
	
by pidlink: gen finalobs=1 if _n==_N

foreach mig in Fa Mo FaMo{
	foreach type in Mig MigOK MigIK{
		
		by pidlink: egen byte `mig'`type'max=max(`mig'`type')
	}
}

foreach mig in FaMig MoMig FaMoMig{
	foreach type in OK IK{
	
		forvalues i=1951/1990{
		
		gen byte D_`i'_`mig'`type'= D_`i' * (`mig'`type')
		}
	}
}

/*
gen byte Grade_6=(SchoolGrade>=1 & SchoolGrade<=6)
gen byte Grade_9=(SchoolGrade>=7 & SchoolGrade<=9)
gen byte Grade_12=(SchoolGrade>=10 & SchoolGrade<=11)

foreach parent in Father Mother{
	
		forvalues i=6(3)12{
		
			gen byte Grade_`i'_`parent'Share= Grade_`i' * (`parent'_Share)
		
		}
	
	}
	
*/

foreach parent in Fa Mo FaMo{
	foreach type in Mig MigIK MigOK{
	
	by pidlink: egen TotMoves_`parent'`type'=sum(`parent'`type'), missing
	by pidlink: replace TotMoves_`parent'`type'=. if finalobs!=1
	}
}


gen flag_Moves_FaMigOKIK=1 if TotMoves_FaMigOK>0 & TotMoves_FaMigOK!=. & TotMoves_FaMigIK>0 & TotMoves_FaMigIK!=.
gen flag_Moves_MoMigOKIK=1 if TotMoves_MoMigOK>0 & TotMoves_MoMigOK!=. & TotMoves_MoMigIK>0 & TotMoves_MoMigIK!=.
gen flag_Moves_FaMoMigOKIK=1 if TotMoves_FaMoMigOK>0 & TotMoves_FaMoMigOK!=. & TotMoves_FaMoMigIK>0 & TotMoves_FaMoMigIK!=.

egen TotMoves_FaMigOKIK=rsum(TotMoves_FaMigOK TotMoves_FaMigIK) if flag_Moves_FaMigOKIK==1 & finalobs==1, missing
replace TotMoves_FaMigOKIK=0 if FaMigmax!=. & flag_Moves_FaMigOKIK!=1
replace TotMoves_FaMigOK=0 if flag_Moves_FaMigOKIK==1
replace TotMoves_FaMigIK=0 if flag_Moves_FaMigOKIK==1

egen TotMoves_MoMigOKIK=rsum(TotMoves_MoMigOK TotMoves_MoMigIK) if flag_Moves_MoMigOKIK==1 & finalobs==1, missing
replace TotMoves_MoMigOKIK=0 if MoMigmax!=. & flag_Moves_MoMigOKIK!=1
replace TotMoves_MoMigOK=0 if flag_Moves_MoMigOKIK==1
replace TotMoves_MoMigIK=0 if flag_Moves_MoMigOKIK==1

egen TotMoves_FaMoMigOKIK=rsum(TotMoves_FaMoMigOK TotMoves_FaMoMigIK) if flag_Moves_FaMoMigOKIK==1 & finalobs==1, missing
replace TotMoves_FaMoMigOKIK=0 if FaMoMigmax!=. & flag_Moves_FaMoMigOKIK!=1
replace TotMoves_FaMoMigOK=0 if flag_Moves_FaMoMigOKIK==1
replace TotMoves_FaMoMigIK=0 if flag_Moves_FaMoMigOKIK==1

drop *_Moves_*





/*

* Parental Migration lag for dynamic effect

foreach parent in Fa Mo FaMo{
	foreach mig in MigIK MigOK {
	by pidlink: gen byte `parent'`mig'lag=`parent'`mig'[_n-1]
	}
}
*/


replace FaMoMigOKmax=1 if FaMigOKmax==1 & MoMigOKmax==1
replace FaMoMigOKmax=0 if FaMigOKmax==0 & MoMigOKmax==0
replace FaMoMigOKmax=0 if (FaMigOKmax==0 & MoMigOKmax==1)
replace FaMoMigOKmax=0 if (MoMigOKmax==0 & FaMigOKmax==1)

replace FaMoMigIKmax=1 if FaMigIKmax==1 & MoMigIKmax==1
replace FaMoMigIKmax=0 if FaMigIKmax==0 & MoMigIKmax==0
replace FaMoMigIKmax=0 if (FaMigIKmax==0 & MoMigIKmax==1)
replace FaMoMigIKmax=0 if (MoMigIKmax==0 & FaMigIKmax==1)

replace FaMigOKmax=0 if FaMigOKmax==1 & MoMigOKmax==1
replace FaMigIKmax=0 if FaMigIKmax==1 & MoMigIKmax==1

replace MoMigOKmax=0 if MoMigOKmax==1 & FaMigOKmax==1
replace MoMigIKmax=0 if MoMigIKmax==1 & FaMigIKmax==1

replace FaMoMigmax=1 if FaMigmax==1 & MoMigmax==1
replace FaMoMigmax=0 if FaMigmax==0 & MoMigmax==0
replace FaMoMigmax=0 if (FaMigmax==0 & MoMigmax==1)
replace FaMoMigmax=0 if (MoMigmax==0 & FaMigmax==1)

replace FaMigmax=0 if FaMigmax==1 & MoMigmax==1

replace MoMigmax=0 if MoMigmax==1 & FaMigmax==1

quietly compress


bysort pidlink SchoolGrade (year): gen flag_GrRep=1 if _n>1
recode flag_GrRep (.=0)

order pidlink- SexUrbBirth flag_GrRep

by pidlink: egen flag_GrRepmax=max(flag_GrRep)

* Create the artificially censored dummies

	* Father's OK migration
	
	gen byte Year4_5_FaMigOK = (year4==1 & FaMigOK==1) | (year5==1 & FaMigOK==1)
	replace Year4_5_FaMigOK=. if FaMigOK==.
	
	gen byte Year6_8_FaMigOK = (year6==1 & FaMigOK==1) | (year7==1 & FaMigOK==1) | (year8==1 & FaMigOK==1)
	replace Year6_8_FaMigOK=. if FaMigOK==.

	gen byte Year9_11_FaMigOK = (year9==1 & FaMigOK==1) | (year10==1 & FaMigOK==1) | (year11==1 & FaMigOK==1)
	replace Year9_11_FaMigOK=. if FaMigOK==.
	
	* Father's IK migration
	
	gen byte Year1_2_FaMigIK = (year1==1 & FaMigIK==1) | (year2==1 & FaMigIK==1)
	replace Year1_2_FaMigIK=. if FaMigIK==.
	
	gen byte Year3_4_FaMigIK = (year3==1 & FaMigIK==1) | (year4==1 & FaMigIK==1)
	replace Year3_4_FaMigIK=. if FaMigIK==.
	
	gen byte Year5_6_FaMigIK = (year5==1 & FaMigIK==1) | (year6==1 & FaMigIK==1)
	replace Year5_6_FaMigIK=. if FaMigIK==.
	
	gen byte Year7_8_FaMigIK = (year7==1 & FaMigIK==1) | (year8==1 & FaMigIK==1) 
	replace Year7_8_FaMigIK=. if FaMigIK==.

	gen byte Year9_11_FaMigIK = (year9==1 & FaMigIK==1) | (year10==1 & FaMigIK==1) | (year11==1 & FaMigIK==1)
	replace Year9_11_FaMigIK=. if FaMigIK==.
	
	* Mother's OK migration
	
	gen byte Year1_2_MoMigOK = (year1==1 & MoMigOK==1) | (year2==1 & MoMigOK==1)
	replace Year1_2_MoMigOK=. if MoMigOK==.
	
	gen byte Year3_4_MoMigOK = (year3==1 & MoMigOK==1) | (year4==1 & MoMigOK==1) 
	replace Year3_4_MoMigOK=. if MoMigOK==.

	gen byte Year6_8_MoMigOK = (year6==1 & MoMigOK==1) | (year7==1 & MoMigOK==1) | (year8==1 & MoMigOK==1)
	replace Year6_8_MoMigOK=. if MoMigOK==.
	
	gen byte Year10_11_MoMigOK = (year10==1 & MoMigOK==1) | (year11==1 & MoMigOK==1)
	replace Year10_11_MoMigOK=. if MoMigOK==.
	
	* Mother's IK migration
	
	gen byte Year9_11_MoMigIK = (year9==1 & MoMigIK==1) | (year10==1 & MoMigIK==1) | (year11==1 & MoMigIK==1)
	replace Year9_11_MoMigIK=. if MoMigIK==.
	
	* Parent's OK migration
	
	gen byte Year1_2_FaMoMigOK = (year1==1 & FaMoMigOK==1) | (year2==1 & FaMoMigOK==1)
	replace Year1_2_FaMoMigOK=. if FaMoMigOK==.
	
	gen byte Year3_4_FaMoMigOK = (year3==1 & FaMoMigOK==1) | (year4==1 & FaMoMigOK==1) 
	replace Year3_4_FaMoMigOK=. if FaMoMigOK==.

	gen byte Year9_11_FaMoMigOK = (year9==1 & FaMoMigOK==1) | (year10==1 & FaMoMigOK==1) | (year11==1 & FaMoMigOK==1)
	replace Year9_11_FaMoMigOK=. if FaMoMigOK==.
	
	* Parent's IK migration
	
	gen byte Year1_2_FaMoMigIK = (year1==1 & FaMoMigIK==1) | (year2==1 & FaMoMigIK==1)
	replace Year1_2_FaMoMigIK=. if FaMoMigIK==.
	
	gen byte Year3_4_FaMoMigIK = (year3==1 & FaMoMigIK==1) | (year4==1 & FaMoMigIK==1) 
	replace Year3_4_FaMoMigIK=. if FaMoMigIK==.
	
	gen byte Year5_6_FaMoMigIK = (year5==1 & FaMoMigIK==1) | (year6==1 & FaMoMigIK==1) 
	replace Year5_6_FaMoMigIK=. if FaMoMigIK==.
	
	gen byte Year7_8_FaMoMigIK = (year7==1 & FaMoMigIK==1) | (year8==1 & FaMoMigIK==1) 
	replace Year7_8_FaMoMigIK=. if FaMoMigIK==.
	
	gen byte Year10_11_FaMoMigIK = (year10==1 & FaMoMigIK==1) | (year11==1 & FaMoMigIK==1)
	replace Year10_11_FaMoMigIK=. if FaMoMigIK==.

	

* Run Regressions to see effect of controls on the variabls of interest affect migration effect: margina effects are reported
	
foreach model in NonParam /*linear1 linear2*/ {
	foreach parent in Father Mother Parents {

		*foreach mig in MigIK MigOK{

			if "`parent'"=="Father"{
	
			local adult="FaMigOK"
			local adult2="FaMigIK"
			local adult3=/*"Year1_FaMigOK-Year11_FaMigOK"*/ "Year1_FaMigOK-Year3_FaMigOK Year4_5_FaMigOK Year6_8_FaMigOK Year9_11_FaMigOK"
			local adult4=/*"Year1_FaMigIK-Year11_FaMigIK"*/ "Year1_2_FaMigIK Year3_4_FaMigIK Year5_6_FaMigIK Year7_8_FaMigIK Year9_11_FaMigIK"
			
			local adult5="MoMig"
			
			local adult6="TotMoves_FaMigOK"
			local adult7="TotMoves_FaMigIK"
			local adult8="TotMoves_FaMigOKIK"
		
			local school="Father_Share"
			local BDayParFE="D_1958_Father-D_1990_Father"
		
			}
		
			if "`parent'"=="Mother"{
			
			local adult="MoMigOK"
			local adult2="MoMigIK"
			local adult3=/*"Year1_MoMigOK-Year11_MoMigOK"*/ "Year1_2_MoMigOK Year3_4_MoMigOK Year5_MoMigOK Year6_8_MoMigOK Year9_MoMigOK Year10_11_MoMigOK"
			local adult4=/*"Year1_MoMigIK-Year11_MoMigIK"*/ "Year1_MoMigIK-Year8_MoMigIK Year9_11_MoMigIK"
			
			local adult5="FaMig"
			
			local adult6="TotMoves_MoMigOK"
			local adult7="TotMoves_MoMigIK"
			local adult8="TotMoves_MoMigOKIK"
			
			local school="Mother_Share"
			local BDayParFE="D_1958_Mother-D_1990_Mother"
		
			}
		
			if "`parent'"=="Parents"{
	
			local adult="FaMoMigOK"
			local adult2="FaMoMigIK"
			local adult3=/*"Year1_FaMoMigOK-Year11_FaMoMigOK"*/ "Year1_2_FaMoMigOK Year3_4_FaMoMigOK Year5_FaMoMigOK-Year8_FaMoMigOK Year9_11_FaMoMigOK"
			local adult4=/*"Year1_FaMoMigIK-Year11_FaMoMigIK"*/ "Year1_2_FaMoMigIK Year3_4_FaMoMigIK Year5_6_FaMoMigIK Year7_8_FaMoMigIK Year9_FaMoMigIK Year10_11_FaMoMigIK"
			
			local adult6="TotMoves_FaMoMig"
			*local adult7="TotMoves_FaMoMigIK"
			*local adult8="TotMoves_FaMoMigOKIK"
			
			local school="FamShare"
			local BDayParFE="D_1958_FamShare-D_1990_FamShare"
		
			}
			
			local BDayFE="D_1958-D_1990"
			
			quietly global regressors0 "`adult3' `adult4' `adult' `adult2'"
			quietly global regressors1 "`adult3' `adult4' `adult' `adult2' UrbBirth sex BO SexBO SexUrbBirth"
			quietly global regressors2 "`adult3' `adult4' `adult' `adult2' `school'"
			quietly global regressors3 "`adult3' `adult4' `adult' `adult2' Kinder ReadInd WriteInd SchGradelag"
			quietly global regressors4 "`adult3' `adult4' `adult' `adult2' UrbBirth sex BO SexBO SexUrbBirth `school' Kinder ReadInd WriteInd SchGradelag"
			
	
			if "`model'"=="NonParam"{
			
				quietly forvalues j=4/4{
				
				if "`parent'"=="Father" | "`parent'"=="Mother" {

					qui probit GradDropOut2 year1-year11 ${regressors`j'} /*if `adult5'==0*/, nolog vce(cluster FamID) nocons
		
					estimates store `adult'HAZ`model'`j'
		
				}
				
				else {
				
					qui probit GradDropOut2 year1-year11 ${regressors`j'} /*if `adult5'==0*/, nolog vce(cluster FamID) nocons
		
					estimates store `adult'HAZ`model'`j'
				
				}
				}
				
				preserve
	
				keep *HAZ* 

				outreg2 [*] using "$maindir$project/Regressions/`model'Output:`adult'.xls", nodepvar noaster /*addstat(Pseudo R-squared, `e(r2_p)')*/ excel replace

				*save "$maindir$tmp/probithaz`parent'.dta", replace

				restore
				
				est clear
			}
				
			if "`model'"=="Cox"{
			
				quietly forvalues j=0/4 {

				qui stcox ${regressors`j'} if FaMoMarr==1, nosh nolog vce(cluster FamID)
		
				estimates store `adult'HAZ`model'`j'
		
				*margins, dydx(`adult')	

				*estimates store Margins`j'
				}
				
				preserve
	
				keep *HAZ* 

				outreg2 [*] using "$maindir$project/Regressions/`model'Output:`adult'.xls", nodepvar drop (D_*) eform ///
				title(Cox Proportional Hazard Estimation of Children's Dropout Risk) ///
				addn(Robust Standard Errors clustered at the family level.)  ///
				excel replace

				*save "$maindir$tmp/probithaz`parent'.dta", replace

				restore
				
				est clear
			}
			
			if "`model'"=="linear1"{
			
			quietly global regressors0 "`adult'max `adult2'max"
			quietly global regressors1 "`BDayFE' `adult'max `adult2'max UrbBirth sex BO SexBO SexUrbBirth"
			quietly global regressors2 "`BDayParFE' `adult'max `adult2'max `school'"
			quietly global regressors3 "`adult'max `adult2'max Kinder flag_GrRepmax ReadInd WriteInd"
			quietly global regressors4 "`BDayFE' `BDayParFE' `adult'max `adult2'max UrbBirth sex BO SexBO SexUrbBirth `school' Kinder flag_GrRepmax ReadInd WriteInd"
			
			quietly global regressors5 "`adult6' `adult7' `adult8'"
			quietly global regressors6 "`BDayFE' `adult6' `adult7' `adult8' UrbBirth sex BO SexBO SexUrbBirth"
			quietly global regressors7 "`BDayParFE' `adult6' `adult7' `adult8' `school'"
			quietly global regressors8 "`adult6' `adult7' `adult8' Kinder flag_GrRepmax ReadInd WriteInd"
			quietly global regressors9 "`BDayFE' `BDayParFE' `adult6' `adult7' `adult8' UrbBirth sex BO SexBO SexUrbBirth `school' Kinder flag_GrRepmax ReadInd WriteInd"
			
			quietly global regressors10 "i.`adult'max*i.`adult2'max"
			quietly global regressors11 "`BDayFE' i.`adult'max*i.`adult2'max UrbBirth sex BO SexBO SexUrbBirth"
			quietly global regressors12 "`BDayParFE' i.`adult'max*i.`adult2'max `school'"
			quietly global regressors13 "i.`adult'max*i.`adult2'max Kinder flag_GrRepmax ReadInd WriteInd"
			quietly global regressors14 "`BDayFE' `BDayParFE' i.`adult'max*i.`adult2'max UrbBirth sex BO SexBO SexUrbBirth `school' Kinder flag_GrRepmax ReadInd WriteInd"
			
			quietly global regressors15 "`adult'max"
			quietly global regressors16 "`BDayFE' `adult'max UrbBirth sex BO SexBO SexUrbBirth"
			quietly global regressors17 "`BDayParFE' `adult'max `school'"
			quietly global regressors18 "`adult'max Kinder flag_GrRepmax ReadInd WriteInd"
			quietly global regressors19 "`BDayFE' `BDayParFE' `adult'max UrbBirth sex BO SexBO SexUrbBirth `school' Kinder flag_GrRepmax ReadInd WriteInd"
			
			quietly global regressors20 "`adult6' "
			quietly global regressors21 "`BDayFE' `adult6'  UrbBirth sex BO SexBO SexUrbBirth"
			quietly global regressors22 "`BDayParFE' `adult6'  `school'"
			quietly global regressors23 "`adult6'  Kinder flag_GrRepmax ReadInd WriteInd"
			quietly global regressors24 "`BDayFE' `BDayParFE' `adult6' UrbBirth sex BO SexBO SexUrbBirth `school' Kinder flag_GrRepmax ReadInd WriteInd"
			
				quietly forvalues j=5/14 {
				
					if "`parent'"=="Father" | "`parent'"=="Mother" {

						qui xi: reg MaxSchYrs2 ${regressors`j'} if finalobs==1 /*& `adult5'==0*/, vce(cluster FamID)
		
						estimates store `adult'HAZ`model'`j'
		
						*margins, dydx(`adult')	

						*estimates store Margins`j'
					}
					
					else{
					
						qui xi: reg MaxSchYrs2 ${regressors`j'} if finalobs==1, vce(cluster FamID)
		
						estimates store `adult'HAZ`model'`j'
					
					}
				}
				
				preserve
	
				keep *HAZ* 

				outreg2 [*] using "$maindir$project/Regressions/`model'Output:`adult'.xls", nodepvar drop(D_*) nocons excel replace

				*save "$maindir$tmp/probithaz`parent'.dta", replace

				restore
				
				est clear
			}
			
			if "`model'"=="linear2"{
			
			quietly global regressors0 "`adult' `adult2'"
			quietly global regressors1 "`BDayFE' `adult' `adult2' UrbBirth sex BO SexBO SexUrbBirth"
			quietly global regressors2 "`BDayParFE' `adult' `adult2' `school'"
			quietly global regressors3 "`adult' `adult2' Kinder ReadInd WriteInd SchGradelag"
			quietly global regressors4 "`BDayFE' `BDayParFE' `adult' `adult2' UrbBirth sex BO SexBO SexUrbBirth `school' Kinder ReadInd WriteInd SchGradelag"

			
			
				quietly forvalues j=0/4 {

				qui reg GradDropOut2 year1-year11 ${regressors`j'}, vce(cluster FamID)
		
				estimates store `adult'HAZ`model'`j'
		
				*margins, dydx(`adult')	

				*estimates store Margins`j'
				}
				
				preserve
	
				keep *HAZ* 

				outreg2 [*] using "$maindir$project/Regressions/`model'Output:`adult'.xls", nodepvar drop(D_*) nocons excel replace

				*save "$maindir$tmp/probithaz`parent'.dta", replace

				restore
				
				est clear
			}
		}
	}


			

/*
	/*FaMigChild MoMigChild FaMoMigChild */

quietly local regressors "Year1_FaMigOK-Year11_FaMigOK Year1_FaMigIK-Year11_FaMigIK FaMigIK FaMigOK UrbBirth sex BO SexBO SexUrbBirth Father_Share Kinder ReadInd WriteInd SchGradelag"


probit GradDropOut2 year1-year11 `regressors' if MoMig==0, nocons nolog vce(cluster FamID) asis

quietly forvalues i=1/11{

	gen float year`i'_p=year`i'*_b[year`i']
	}


	gen m_FaMigOK1=1
	gen m_FaMigOK2=0
	gen m_FaMigIK=0 if FaMigIK!=.
	
quietly forvalues i=1/11{

	gen float Year`i'_m1=year`i'*m_FaMigOK1*_b[Year`i'_FaMigOK]*1
	}
	
quietly forvalues i=1/11{

	gen float Year`i'_m2=year`i'*m_FaMigOK2*_b[Year`i'_FaMigOK]*1
	}

	
	gen linpredFaMigOK1=m_FaMigOK1 * _b[FaMigOK]
	gen linpredFaMigOK2=m_FaMigOK2 * _b[FaMigOK]
	gen linpredFaMigIK=m_FaMigIK * _b[FaMigIK]
	
quietly local regressors "UrbBirth sex BO SexBO SexUrbBirth Father_Share Kinder ReadInd WriteInd SchGradelag"

quietly foreach name in `regressors' {
		
		/*if "`name'"=="UrbBirth" gen m_UrbBirth=UrbBirth
			
		if "`name'"=="SexUrbBirth" gen m_SexUrbBirth=SexUrbBirth*/
		
			egen m_`name'=mean(`name')

						
		gen linpred_`name'=m_`name' * _b[`name']
		
	}

quietly egen linpred1=rsum(linpredFaMigOK1 linpredFaMigIK linpred_*), missing
quietly egen linpred2=rsum(linpredFaMigOK2 linpredFaMigIK linpred_*), missing

quietly egen xb1=rsum(year*_p Year*_m1 linpred1), missing
quietly egen xb2=rsum(year*_p Year*_m2 linpred2), missing


gen predhazard1=normal(xb1)
gen predhazard2=normal(xb2)
replace predhazard1=. if SchoolGrade==12
replace predhazard2=. if SchoolGrade==12
replace predhazard1=. if FaMig==.
replace predhazard2=. if FaMig==.

/* Generate the predicted hazard
foreach num in 1 2 3 4{

	quietly gen predhazard`num'=normal(xb) if UrbSex==`num'
	quietly replace predhazard`num'=. if MaxSchYrs2==12
	
}*/

* Generate the average migration events per school year
foreach parent in FaMig MoMig FaMoMig{
foreach mig in OK IK{
forvalues i=0/12{

	qui bysort SchoolGrade: egen float m_`parent'`mig'_year`i'=mean(`parent'`mig') if SchoolGrade==`i'

	}
}
}

foreach parent in FaMig MoMig FaMoMig{
foreach mig in OK IK{

egen float `parent'`mig'tot=rsum(m_`parent'`mig'_*)

}
}

preserve

collapse (lastnm) *tot, by (SchoolGrade)
save "$maindir$tmp/SchGradeMigAvg.dta", replace

restore

drop *tot m_*K_year*

* Survival

by pidlink: gen survival1=1
by pidlink: gen survival2=1
by pidlink: replace survival1=survival1[_n-1]*(1-predhazard1[_n-1])^(SchoolGrade) if SchoolGrade>1
by pidlink: replace survival2=survival2[_n-1]*(1-predhazard2[_n-1])^(SchoolGrade) if SchoolGrade>1

twoway line survival1 survival2 SchoolGrade, sort title(Hazard of School DropOut) xtitle("School Years") ytitle("Predicted Hazard")  ///
		*legend(label(1 Rural Girls) label(2 Rural Boys) label(3 Urban Girls) label(4 Urban Boys))

quietly drop year*_p m_* linpred* xb predhazard* 

*/
