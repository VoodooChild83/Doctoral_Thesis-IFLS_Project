use "$maindir$project/MasterTrack2.dta", clear

keep if flag_LastWave==1 & (flag_OutSch==1 | flag_NotInSch==1)

rename (wave sex ar15 MaxSchLvl sc05 pwt) (year Sex Religion SchLvl Urban perwt)

keep pidlink2 year Sex Religion SchLvl Urban MaxSchYrs provmov kabmov kecmov birthyr age perwt

preserve

use "$maindir$tmp/Wage Database1.dta", clear

drop if job==2

collapse (mean) r_wage_hr, by(pidlink2 year)

save "$maindir$tmp/Wage Database Cleaner.dta", replace

by pidlink2:gen flag_LastObs=1 if _n==_N
by pidlink2: gen flag_missing_lastwage=1 if flag_LastObs==1 & r_wage_hr==.
by pidlink2: egen fla_missing_max=max(flag_missing_lastwage)

drop flag_LastObs flag_missing_lastwage

keep if fla_missing_max==1

collapse (lastnm) year r_wage_hr, by(pidlink)

replace year=1993 if year==1992
replace year=1997 if year==1996
replace year=2000 if year==1999
replace year=2007 if year==2006|year==2008

save "$maindir$tmp/Wage Database Cleaner 2.dta", replace

use "$maindir$tmp/Wage Database Cleaner.dta", clear

merge 1:1 pidlink2 year using "$maindir$tmp/Wage Database Cleaner 2.dta", update keep(1 3 4) nogen
erase "$maindir$tmp/Wage Database Cleaner 2.dta"

save "$maindir$tmp/Wage Database Cleaner.dta", replace

restore

merge 1:1 pidlink2 year using "$maindir$tmp/Wage Database Cleaner.dta", keep(1 3) nogen
erase "$maindir$tmp/Wage Database Cleaner.dta"

merge 1:1 pidlink2 year using "$maindir$tmp/2012 Wage Current.dta",update keepusing(r_wage_hr) keep(1 3 4 5) nogen

rename pidlink2 serial

append using "$maindir$project$ipums/Project Files/Census Wage Data.dta", force gen(IPUMS)

drop relate-ln_wage_mth Language-version ln_wage_hr

gen IPUMS_1976=1 if IPUMS==1 & year==1976

* Correct Kab Codes from the IPUMS file

gen provmov_2=provmov*100 if IPUMS==1 & IPUMS_1976!=1
gen kabmov_2=kabmov-provmov_2 if IPUMS==1 & IPUMS_1976!=1

replace kabmov=kabmov_2 if IPUMS==1 & IPUMS_1976!=1

drop *_2
drop if IPUMS_1976==1

gen ln_wage_hr=ln(r_wage_hr)

* Correct school years

replace MaxSchYrs=13 if MaxSchYrs>12 & MaxSchYrs!=.

preserve
* Correct Provinces

replace provmov=91 if provmov==94
replace provmov=81 if provmov==82
replace provmov=73 if provmov==76
replace provmov=32 if provmov==36

drop if provmov==54 // No Timur East - another country

* Collapse the data

collapse (mean) MaxSchYrs (median) ln_wage_hr [aw=perwt], by(provmov)
gen r_wage_hr=exp(ln_wage_hr)

save "$maindir$tmp/Wages_Educ_Provinces.dta", replace
restore

preserve
collapse (mean) MaxSchYrs (median) ln_wage_hr [aw=perwt], by(provmov kabmov)
gen r_wage_hr=exp(ln_wage_hr)

save "$maindir$tmp/Wages_Educ_Kabupatens.dta", replace
restore
