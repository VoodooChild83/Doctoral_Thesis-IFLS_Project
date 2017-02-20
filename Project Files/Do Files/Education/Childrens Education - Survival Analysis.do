* Estimation of the Survival Functions

********************************************************************************
// Create the Survival Analysis variables

	* Generate parents migration and schooling interactions: the baseline hazard of those who migrate

		replace Prov_Mover=Prov_FamilyMig if Prov_FamilyMig==1 & Prov_Mover==0
		*replace Prov_FamilyMig=Prov_Mover if Prov_Mover==1 & Prov_FamilyMig==0
		
	* Generate a variable for if the child begins school after age 7
	
		bys pidlink (year Grade): gen Late_Starter= 1 if age>7 & _n==1
		by pidlink: egen Late_Startmax=max(Late_Starter)
			drop Late_Starter
			rename Late_Startmax Late_Starter
			by pidlink: replace Late_Starter=0 if Late_Starter==.

	sort pidlink Grade year

	* Drop Out
	
		bysort pidlink (year): gen byte GradDropOut=(MaxSchYrs_2<12 & _n==_N)

	* Generate the baseline hazard dummies
	
		forvalues i=1/12{
	
			gen byte year`i'= Grade==`i'
		
		}
		
	* Generate parents migration and schooling interactions: the baseline hazard of those who migrate
	
		forvalues i=1/11{
			gen byte year`i'_Prov_Mover = year`i' * Prov_FamilyMig
		}
		
		* Create the year10_11 variable since year11 is censored
			gen year10_11 = (year10==1 | year11==1)
				
			gen year1_3_Prov_Mover= (year1==1 & Prov_FamilyMig==1) |(year2==1 & Prov_FamilyMig==1)|(year3==1 & Prov_FamilyMig==1) 
			gen year7_8_Prov_Mover= (year7==1 & Prov_FamilyMig==1) |(year8==1 & Prov_FamilyMig==1)
			gen year10_11_Prov_Mover= (year10==1 & Prov_FamilyMig==1) | (year11==1 & Prov_FamilyMig==1)
			
			drop year10 year11 year12 year1_Prov_Mover year2_Prov_Mover year3_Prov_Mover year7_Prov_Mover year8_Prov_Mover year10_Prov_Mover year11_Prov_Mover

	* Generate birthyr dummies for those born 1950 (exclude 1950)

		forvalues i=1970/1999{
			
			gen byte D_`i'= birthyr==`i'
		
		}
		
********************************************************************************
* Label Variables

la var GradDropOut "School Exit"
la var Prov_Mover "Family Province Mig"
la var Admin "Admin of School: 1=Private"
la var SpeakInd "Speaks Indonesian"
la var ReadInd "Reads Indonesian"
la var WriteInd "Writes Indonesian"
la var Worked "Worked in School"
la var d_GrRep "Repeated Grade"
la var UrbBirth "Urbanization of Birth"
la var Urbanization "Urbanization"
la var sex "Sex"
la var Religion "Religion: 1=Other"
la var ParentalSchAvg "Parent's Education"
la var Late_Starter "Age Sch. Start > 7"

********************************************************************************
// Merge in person weights

merge m:1 pidlink using "$maindir$tmp/PersonWeights.dta", keep(1 3) keepusing(pwt) nogen

********************************************************************************
* Regressions
/*

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis.tex", addtext(Baseline Hazard, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover) replace label dec(3) noas nodepvar

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover Urbanization UrbBirth sex Religion if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis.tex", addtext(Baseline Hazard, YES, Individual Control, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover Religion Urbanization UrbBirth sex) label dec(3) noas nodepvar

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover ParentalSchAvg if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis.tex", addtext(Baseline Hazard, YES, Parental Control, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover ParentalSchAvg) label dec(3) noas nodepvar

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover SpeakInd ReadInd WriteInd Worked Admin Late_Starter d_GrRep if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis.tex", addtext(Baseline Hazard, YES, Schooling Controls, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover SpeakInd ReadInd WriteInd Worked Admin Late_Starter d_GrRep) label dec(3) noas nodepvar

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover Urbanization UrbBirth sex Religion ParentalSchAvg SpeakInd ReadInd WriteInd Worked Admin Late_Starter d_GrRep if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis.tex", addtext(Baseline Hazard, YES, Individual Control, YES,Parental Control, YES, Schooling Controls, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover Urbanization UrbBirth sex ParentalSchAvg SpeakInd ReadInd WriteInd Worked Admin Late_Starter d_GrRep) label dec(3) noas nodepvar



* With asterisks
qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Ast.tex", addtext(Baseline Hazard, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover) replace label dec(3) nodepvar

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover Urbanization UrbBirth sex Religion if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Ast.tex", addtext(Baseline Hazard, YES, Individual Control, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover) label dec(3) nodepvar

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover ParentalSchAvg if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Ast.tex", addtext(Baseline Hazard, YES, Parental Control, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover) label dec(3) nodepvar

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover SpeakInd ReadInd WriteInd Worked Admin Late_Starter d_GrRep if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Ast.tex", addtext(Baseline Hazard, YES, Schooling Controls, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover) label dec(3) nodepvar

qui probit GradDropOut Prov_Mover  year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover Urbanization UrbBirth sex Religion ParentalSchAvg SpeakInd ReadInd WriteInd Worked Admin Late_Starter d_GrRep if birthyr>1970 [pw=pwt], vce(cluster Dynasty) nolog nocons
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Ast.tex", addtext(Baseline Hazard, YES, Individual Control, YES,Parental Control, YES, Schooling Controls, YES) drop(year1-year9 year10_11 year1_3_Prov_Mover year4_Prov_Mover-year6_Prov_Mover year7_8_Prov_Mover year9_Prov_Mover year10_11_Prov_Mover) label dec(3) nodepvar

*/

* Cox Models


stset Grade [pw=pwt], failure (GradDropOut)

qui stcox Prov_Mover Urbanization UrbBirth sex Religion if birthyr>1970,  vce(cluster Dynasty) nolog
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Cox.tex", addtext(Cohort Controls, YES) replace label dec(3) nodepvar

qui stcox ParentalSchAvg if birthyr>1970,  vce(cluster Dynasty) st(mov_stat) nolog 
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Cox.tex", addtext(Cohort Controls, YES) label dec(3) nodepvar

qui stcox SpeakInd ReadInd WriteInd Worked Admin Late_Starter if birthyr>1970,  vce(cluster Dynasty) st(mov_stat) nolog
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Cox.tex", addtext(Cohort Controls, YES)  label dec(3) nodepvar

qui stcox  Urbanization UrbBirth sex Religion ParentalSchAvg SpeakInd ReadInd WriteInd Worked Admin Late_Starter d_GrRep if birthyr>1970,  vce(cluster Dynasty) nolog
outreg2 using "$maindir$project/Regressions/TEX Files/Survival/Survival Analysis - Cox.tex", addtext(Cohort Controls, YES) label dec(3) nodepvar

stcox Prov_Mover Urbanization UrbBirth sex Religion SpeakInd ReadInd WriteInd Worked Admin Late_Starter if birthyr>1970, vce(cluster ProvCode) nolog basesurv(S0)

label var S0 "Parent's Don't Migrate"
gen S1=S0^exp(_b[Prov_Mover]) 
label var S1 "Parent's Migrate"
sort _t
twoway (line S0 _t) (line S1 _t), ytitle(Survival) xtitle(Grade) title(Survival of Students in the School System)  xlabel(1 (1) 12)
          
graph export "$maindir$project/Descriptive Stats/Cox Survival.jpg", replace

stset,clear

drop year1-year10_11_Prov_Mover D_* S0 S1

