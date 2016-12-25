use "$maindir$tmp/Wage Database1.dta", clear

drop if job==2

append using "$maindir$tmp/2012 Wage Current.dta"

rename year wave

merge m:1 pidlink wave using "$maindir$project/MasterTrack2.dta", update keepusing(provmov kabmov kecmov) keep(1 3 4 5) nogen

rename wave year

preserve

use "$maindir$project/MasterTrack2.dta", clear

keep if flag_LastWave==1

save "$maindir$tmp/Master Track pwt.dta"

restore

merge m:1 pidlink using "$maindir$tmp/Master Track pwt.dta", update keepusing(pwt) keep(1 3 4 5) nogen
erase "$maindir$tmp/Master Track pwt.dta"

rename (pwt pidlink2) (perwt serial)

keep serial year Sex Religion Urban provmov kabmov kecmov age perwt r_wage_hr 

append using "$maindir$project$ipums/Project Files/Census Wage Data.dta", force gen(IPUMS)

drop Sex-age relate-ln_wage_mth SchLvl-version ln_wage_hr

gen IPUMS_1976=1 if IPUMS==1 & year==1976

gen ln_wage_hr=ln(r_wage_hr)

* Correct Provinces

replace provmov=91 if provmov==94
replace provmov=81 if provmov==82
replace provmov=73 if provmov==76
replace provmov=32 if provmov==36

drop if provmov==. | provmov==54

collapse (median) r_wage_hr if IPUMS_1976!=1, by(provmov)

save "$maindir$tmp/Wages_Educ_Provinces_Mig.dta", replace

/*
twoway (histogram ln_wage_hr if year<=1976 & IPUMS!=1, color(green)) ///
       (histogram ln_wage_hr if year==1976 & IPUMS==1, fcolor(none) lcolor(black)) ///
	   (histogram ln_wage_hr if IPUMS!=1 & year>1976, fcolor(none) lcolor(red)) ///
	   (histogram ln_wage_hr if IPUMS==1 & year==1995, fcolor(none) lcolor(blue)), legend(order(1 "IFLS 1976" 2 "IPUMS 1976" 3 "IFLS not 1976" 4 "IPUMS 1995" ))
