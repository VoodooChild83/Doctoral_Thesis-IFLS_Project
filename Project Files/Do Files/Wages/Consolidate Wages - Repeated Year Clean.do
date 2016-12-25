// Clean the Double Years Consolidated Wages

********************************************************************************
// Do the Consolidated Wage do file to create the raw data set

qui do "$maindir$project$Do/Wages/Consolidate Wages - Append.do"

********************************************************************************
// Drop observations that have no years - would not be able to identify 

replace year=. if year>2008

drop if year==.

********************************************************************************
// Fill in first job identifier

bysort pidlink year (job wave): egen first_job=max(FirstJob)
	replace FirstJob=first_job
		drop first_job

replace job=1 if job==.

********************************************************************************
// Identify those observations with repeated years (overlap from different waves)

	bysort pidlink year job (wave): gen byte flag_repyrs=1 if (year[_n]==year[_n+1] & pidlink[_n]==pidlink[_n+1]) | ///
														      (year[_n-1]==year[_n] & pidlink[_n]==pidlink[_n-1])
													  
********************************************************************************
// Clean the replicated years

		preserve
			
				keep if flag_repyrs==1
			
				collapse (max) hrs_wk wks_yr r_wage_mth (firstnm) occ2 worked year_start  FirstJob wave flag_repyrs, by(pidlink year job)
	
				* Regenerate the income variables 
			
					* Generate the month equivalent
	
					gen mth_yr=(wks_yr/52)*12
				  
					* Generate yarly wages
				  
					gen r_wage_yr=r_wage_mth*mth_yr
				  
					gen ln_wage_yr=ln(r_wage_yr)
				  
					* Generate total hours worked per year

					gen hrs_yr=hrs_wk*wks_yr
	
					* Generate the hourly wage 

					gen r_wage_hr=r_wage_yr/hrs_yr
	
					gen ln_wage_hr=ln(r_wage_hr)
				  
					save "$maindir$tmp/Wage Database - last year clean.dta", replace
				  
		restore	
	
		drop if flag_repyrs==1

		append using "$maindir$tmp/Wage Database - last year clean.dta"

		sort pidlink job year
			
		erase "$maindir$tmp/Wage Database - last year clean.dta"

		drop flag_repyrs	
			
********************************************************************************
// Clean the occupation codes: Harmonize with IPUMS occ codes and collapse codes
// that have few observations into neighboring code

* Remove students

drop if occ2=="SS"

* Recode occupations to place those occupations with small observed individuals into the occupation of closest neighbor with larger obs

replace occ2="0X" if occ2=="00"
replace occ2="08" if occ2=="0X"|occ2=="09"
replace occ2="21" if occ2=="24"
replace occ2="26" if occ2=="27"
replace occ2="45" if occ2=="48"|occ2=="49"|occ2=="4X"
replace occ2="89" if occ2=="8X"
replace occ2="95" if occ2=="96"
replace occ2="99" if occ2=="9X"|occ2=="999"
replace occ2="100" if occ2=="X2"|occ2=="XX"
replace occ2="79" if occ2=="7X"
replace occ2="75" if occ2=="76"
replace occ2="64" if occ2=="69"
replace occ2="51" if occ2=="52"|occ2=="50"
replace occ2="29" if occ2=="2X"
replace occ2="05" if occ2=="04"
replace occ2="35" if occ2=="34"
replace occ2="28" if occ2=="29"
replace occ2="86" if occ2=="87"
replace occ2="90" if occ2=="91"
replace occ2="01" if occ2=="02"
replace occ2="00" if occ2=="MM"|occ2=="M1"|occ2=="M2"
replace occ2="39" if occ2=="3X"


********************************************************************************
// Save

compress

order pidlink year occ2 hrs_wk hrs_mth hrs_yr wks_yr mth_yr r_wage_hr ln_wage_hr r_wage_mth ln_wage_mth r_wage_yr ln_wage_yr

drop wave dataset

*save "$maindir$tmp/Wage Database.dta", replace

			
			

			
			
