// Mincer Regressions of Wages

use "$maindir$tmp/Wage Database1.dta", clear

********************************************************************************
// Append the Ipums data

/*
append using "$maindir$tmp/IPUMS.dta"
	erase "$maindir$tmp/IPUMS.dta"
	
replace version="IFLS" if version==""
	
* replace military code with 200
	
		replace occ2="200" if occ2=="00"
		replace occ2="600" if occ2=="62"
*/
********************************************************************************
// Generate year fixed effects and dummies

egen year_fe=group(year) if year>1960

egen occ_fe=group(occ2)

*egen year_prov_fe=group(year provmov) if year>1960
egen year_market_fe=group(year Islandmov) if year>1960

egen market_occ_fe=group(occ2 Islandmov) if year>1960
*egen prov_occ_fe=group(occ2 provmov) if year>1960

********************************************************************************
// Add labels to the variables to add to the regressions

la var MaxSchYrs "Education"
la var age "Age"
la var age_2 "Age sq."
la var Sex "Sex"
la var Urban "Urbanization"
la var InterIslandMig "Island Migration"
la var IntraIslandMig "Within Island Migration"
la var InterIsland_ParentMig "Parent Island Migration"
la var IntraIsland_ParentMig "Parent Within Island Migration"
la var Religion "Religion"
la var Ethnicity "Ethnicity"
la var ln_wage_hr "log of hourly wage"
la var SchLvl ""

********************************************************************************
// Merge in person weights

merge m:1 pidlink using "$maindir$tmp/PersonWeights.dta", keep(1 3) keepusing(pwt) nogen

********************************************************************************
// Regress

set matsize 2000

	
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity i.year_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchYrs1
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES)  drop(i.year_fe) replace label dec(3)  nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity i.year_fe i.occ_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchYrs2
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES, Occupation FE, YES)  drop(i.year_fe i.occ_fe) label dec(3)  nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity i.year_fe i.occ_fe i.Islandmov [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchYrs3
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg- IFLS (migration premium).tex", addtext(Year FE, YES, Occupation FE, YES, Island FE, YES)  drop(i.year_fe i.occ_fe i.Islandmov) label dec(3)  nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig i.year_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchYrs4
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES)  drop(i.year_fe) label dec(3)  nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig i.year_fe i.occ_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchYrs5
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES, Occupation FE, YES)  drop(i.year_fe i.occ_fe) label dec(3) nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig i.year_fe i.occ_fe i.Islandmov [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchYrs6
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES, Occupation FE, YES, Island FE, YES)  drop(i.year_fe i.occ_fe i.Islandmov) label dec(3)nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig i.occ_fe i.year_market_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchYrs7
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Occupation FE, YES, Year*Island FE, YES)  drop(i.occ_fe i.year_market_fe) label dec(3)  nodepvar
		 
		
		
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity i.year_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchLvls1
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES)  drop(i.year_fe) label dec(3) nodepvar
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity i.year_fe i.occ_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchLvls2
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES, Occupation FE, YES)  drop(i.year_fe i.occ_fe) label dec(3) nodepvar
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity i.year_fe i.occ_fe i.Islandmov [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchLvls3
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES, Occupation FE, YES, Island FE, YES)  drop(i.year_fe i.occ_fe i.Islandmov)label dec(3) nodepvar
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig i.year_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchLvls4
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES)  drop(i.year_fe) label dec(3) nodepvar
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig i.year_fe i.occ_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchLvls5 
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES, Occupation FE, YES)  drop(i.year_fe i.occ_fe) label dec(3) nodepvar
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig i.year_fe i.occ_fe i.Islandmov [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchLvls6
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium).tex", addtext(Year FE, YES, Occupation FE, YES, Island FE, YES)  drop(i.year_fe i.occ_fe i.Islandmov) label dec(3) nodepvar
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig i.occ_fe i.year_market_fe [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'SchLvls7
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg- IFLS (migration premium).tex", addtext(Occupation FE, YES, Year*Island FE, YES)  drop(i.occ_fe i.year_market_fe) label dec(3) nodepvar
		
		
		* Children of migrants
/*		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig InterIsland_ParentMig IntraIsland_ParentMig i.year_fe if Children==1 [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'ChildSchYrs1
		outreg2 using "$$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) Children.tex", addtext(Year FE, YES)  drop(i.year_fe) replace label dec(3) nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig InterIsland_ParentMig IntraIsland_ParentMig i.year_fe i.occ_fe if Children==1 [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'ChildSchYrs2
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) Children.tex", addtext(Year FE, YES, Occupation FE, YES)  drop(i.year_fe i.occ_fe) label dec(3) nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig InterIsland_ParentMig IntraIsland_ParentMig i.year_fe i.occ_fe i.Islandmov if Children==1 [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'ChildSchYrs3
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) Children.tex", addtext(Year FE, YES, Occupation FE, YES, Island FE, YES)  drop(i.year_fe i.occ_fe i.Islandmov) label dec(3) nodepvar
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig InterIsland_ParentMig IntraIsland_ParentMig i.occ_fe i.year_market_fe if Children==1 [pw=pwt] /*if version=="`data'"*/
		*estimates store Minc`data'ChildSchYrs4
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) Children.tex", addtext(Occupation FE, YES, Year*Island FE, YES)  drop(i.occ_fe i.year_market_fe) label dec(3) nodepvar
		
		/*
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig InterIsland_ParentMig IntraIsland_ParentMig i.year_fe /*if version=="`data'"*/
		*estimates store Minc`data'ChildSchYrs5
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig InterIsland_ParentMig IntraIsland_ParentMig i.year_fe i.occ_fe /*if version=="`data'"*/
		*estimates store Minc`data'ChildSchYrs6
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig InterIsland_ParentMig IntraIsland_ParentMig i.year_fe i.occ_fe i.Islandmov /*if version=="`data'"*/
		*estimates store Minc`data'ChildSchYrs7
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterIslandMig IntraIslandMig InterIsland_ParentMig IntraIsland_ParentMig i.occ_fe i.year_market_fe /*if version=="`data'"*/
		*estimates store Minc`data'ChildSchYrs8
		*/
		
*/
		
		* Fixed Effect Regressions 
	
		xtset pidlink2
		
		/*
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.year_fe /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel1
		
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.occ_fe i.year_prov_fe /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel2 
		
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.prov_occ_fe i.year_prov_fe /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel3
		*/
		
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.year_fe  [pw=pwt] /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel4
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) FE Reg.tex", addtext(Year FE, YES)  drop(i.year_fe) replace label dec(3) nodepvar
		
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.occ_fe i.year_market_fe  [pw=pwt] /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel5
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) Fe Reg.tex", addtext(Occupation FE, YES, Year*Island FE, YES)  drop(i.year_fe i.year_market_fe) label dec(3) nodepvar
		
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.market_occ_fe i.year_market_fe  [pw=pwt] /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel6
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) Fe Reg.tex", addtext(Occupation*Island FE, YES, Year*Island FE, YES)  drop(i.market_occ_fe i.year_market_fe) label dec(3) nodepvar
		
		
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.year_fe if Children==1 [pw=pwt] /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel4
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) FE Reg Children.tex", addtext(Year FE, YES)  drop(i.year_fe ) replace label dec(3) nodepvar
		
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.occ_fe i.year_market_fe if Children==1 [pw=pwt] /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel5
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) Fe Reg Children.tex", addtext(Occupation FE, YES, Year*Island FE, YES)  drop(i.year_fe i.year_market_fe) label dec(3) nodepvar
		
		 xtreg  ln_wage_hr age age_2 Urban Skill_Level InterIslandMig IntraIslandMig i.market_occ_fe i.year_market_fe if Children==1 [pw=pwt] /*if version=="`data'"*/, fe
		*estimates store Minc`data'Panel6
		outreg2 using "$maindir$project/Regressions/TEX Files/Mincer/MincReg - IFLS (migration premium) Fe Reg Children.tex", addtext(Occupation*Island FE, YES, Year*Island FE, YES)  drop(i.market_occ_fe i.year_market_fe) label dec(3) nodepvar
		
		
		xtset, clear
	
		/*
		preserve
		
			keep *Minc*
			
			outreg2 [*] using "$maindir$project/Regressions/MincRegChild - `data'.xls", nodepvar excel replace
			
		restore
		
		est clear
		*/
	/*
	else if  "`data'"=="IPUMS" {
	
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Language if version=="`data'" & year==1995
		estimates store Minc`data'SchYrs1
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Language i.occ_fe if version=="`data'" & year==1995
		estimates store Minc`data'SchYrs2
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Language i.occ_fe i.provmov if version=="`data'" & year==1995
		estimates store Minc`data'SchYrs3
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Language  if version=="`data'" & year==1995
		estimates store Minc`data'SchLvls1
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Language i.occ_fe if version=="`data'" & year==1995
		estimates store Minc`data'SchLvls2
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Language i.occ_fe i.provmov if version=="`data'" & year==1995
		estimates store Minc`data'SchLvls3

		preserve
		
			keep *Minc*
			
			outreg2 [*] using "$maindir$project/Regressions/MincReg - `data'.xls", nodepvar excel replace
			
		restore
		
		est clear
	
	}*/


*drop if version=="IPUMS"
	drop  *_fe
	
*save "$maindir$tmp/Wage Database2.dta", replace
