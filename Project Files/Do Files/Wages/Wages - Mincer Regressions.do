// Mincer Regressions of Wages

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Pick one of the two:

qui do "$maindir$project$Do/Wages/Wages - Imputation.do"

*use "$maindir$tmp/Wage Database2.dta"

********************************************************************************
// Append the Ipums data

append using "$maindir$tmp/IPUMS.dta"
	erase "$maindir$tmp/IPUMS.dta"
	
replace version="IFLS" if version==""
	
* replace military code with 200
	
		replace occ2="200" if occ2=="00"
		replace occ2="600" if occ2=="62"

********************************************************************************
// Generate year fixed effects and dummies

egen year_fe=group(year) if year>1960

egen occ_fe=group(occ2)

egen year_prov_fe=group(year provmov) if year>1960
egen year_market_fe=group(year Market) if year>1960

egen market_occ_fe=group(occ2 Market) if year>1960
egen prov_occ_fe=group(year provmov) if year>1960

********************************************************************************
// Regress

set matsize 2000

foreach data in IFLS IPUMS {

	if "`data'"=="IFLS"{
	
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity i.year_fe if version=="`data'"
		estimates store Minc`data'SchYrs1
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity i.year_fe i.occ_fe if version=="`data'"
		estimates store Minc`data'SchYrs2
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity i.year_fe i.occ_fe i.provmov if version=="`data'"
		estimates store Minc`data'SchYrs3
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig i.year_fe if version=="`data'"
		estimates store Minc`data'SchYrs4
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig i.year_fe i.occ_fe if version=="`data'"
		estimates store Minc`data'SchYrs5
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig i.year_fe i.occ_fe i.provmov if version=="`data'"
		estimates store Minc`data'SchYrs6
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig i.occ_fe i.year_prov_fe if version=="`data'"
		estimates store Minc`data'SchYrs7
		
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity i.year_fe if version=="`data'"
		estimates store Minc`data'SchLvls1
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity i.year_fe i.occ_fe if version=="`data'"
		estimates store Minc`data'SchLvls2
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity i.year_fe i.occ_fe i.provmov if version=="`data'"
		estimates store Minc`data'SchLvls3
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig i.year_fe if version=="`data'"
		estimates store Minc`data'SchLvls4
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig i.year_fe i.occ_fe if version=="`data'"
		estimates store Minc`data'SchLvls5 
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig i.year_fe i.occ_fe i.provmov if version=="`data'"
		estimates store Minc`data'SchLvls6
		
		qui reg ln_wage_hr i.SchLvl age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig i.occ_fe i.year_prov_fe if version=="`data'"
		estimates store Minc`data'SchLvls7
		
		
		* Children of migrants
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig InterProvMig_parent IntraProvMig_parent i.year_fe /*if version=="`data'"*/
		estimates store Minc`data'ChildSchYrs1
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig InterProvMig_parent IntraProvMig_parent i.year_fe i.occ_fe /*if version=="`data'"*/
		estimates store Minc`data'ChildSchYrs2
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig InterProvMig_parent IntraProvMig_parent i.year_fe i.occ_fe i.provmov /*if version=="`data'"*/
		estimates store Minc`data'ChildSchYrs3
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterProvMig IntraProvMig InterProvMig_parent IntraProvMig_parent i.occ_fe i.year_prov_fe /*if version=="`data'"*/
		estimates store Minc`data'ChildSchYrs4
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterMarketMig IntraMarketMig InterMarketMig_parent IntraMarketMig_parent i.year_fe /*if version=="`data'"*/
		estimates store Minc`data'ChildSchYrs5
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterMarketMig IntraMarketMig InterMarketMig_parent IntraMarketMig_parent i.year_fe i.occ_fe /*if version=="`data'"*/
		estimates store Minc`data'ChildSchYrs6
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterMarketMig IntraMarketMig InterMarketMig_parent IntraMarketMig_parent i.year_fe i.occ_fe i.Market /*if version=="`data'"*/
		estimates store Minc`data'ChildSchYrs7
		
		qui reg ln_wage_hr MaxSchYrs age age_2 Sex Urban Religion Ethnicity InterMarketMig IntraMarketMig InterMarketMig_parent IntraMarketMig_parent i.occ_fe i.year_market_fe /*if version=="`data'"*/
		estimates store Minc`data'ChildSchYrs8
		
		
		* Fixed Effect Regressions 
	
		xtset pidlink2
		
		 xtreg  ln_wage_hr age age_2 Urban InterProvMig IntraProvMig i.year_fe if version=="`data'", fe
		estimates store Minc`data'Panel1
		
		 xtreg  ln_wage_hr age age_2 Urban InterProvMig IntraProvMig i.occ_fe i.year_prov_fe if version=="`data'", fe
		estimates store Minc`data'Panel2 
		
		 xtreg  ln_wage_hr age age_2 Urban InterProvMig IntraProvMig i.prov_occ_fe i.year_prov_fe if version=="`data'", fe
		estimates store Minc`data'Panel3
	
		 xtreg  ln_wage_hr age age_2 Urban InterMarketMig IntraMarketMig i.year_fe if version=="`data'", fe
		estimates store Minc`data'Panel4
		
		 xtreg  ln_wage_hr age age_2 Urban InterMarketMig IntraMarketMig i.occ_fe i.year_market_fe if version=="`data'", fe
		estimates store Minc`data'Panel5
		
		 xtreg  ln_wage_hr age age_2 Urban InterMarketMig IntraMarketMig i.market_occ_fe i.year_market_fe if version=="`data'", fe
		estimates store Minc`data'Panel6
		
		xtset, clear
	

		preserve
		
			keep *Minc*
			
			outreg2 [*] using "$maindir$project/Regressions/MincRegChild - `data'.xls", nodepvar excel replace
			
		restore
		
		est clear
		
	}

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
	
	}
}

drop if version=="IPUMS"
	drop Occupation-flag_0wage serial-version *_fe
	
save "$maindir$tmp/Wage Database2.dta", replace
