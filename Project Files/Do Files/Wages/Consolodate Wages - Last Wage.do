// Consolidate the last wage files

********************************************************************************
// Do the Last Wage files

foreach year in 1993 1997 2000 2007{

quietly do "$maindir$project$Do/Wages/Wage Last Job `year'.do"

}

********************************************************************************
// Append the Last Wage Datasets 

use "$maindir$tmp/1993 Wage Last Job.dta"

foreach year in 1997 2000 2007 {

	append using "$maindir$tmp/`year' Wage Last Job.dta"
	
	}
	
foreach year in 1993 1997 2000 2007{

erase "$maindir$tmp/`year' Wage Last Job.dta"

}
	
sort pidlink year wave

order pidlink year *_1987 *_1992 *_1995 *_1999 stopped_wrk retired neverwrkd

********************************************************************************
// Find repetitions across waves

bysort pidlink (wave): gen obs=_N

by pidlink: egen sum_nvrwrkd=total(neverwrkd)

********************************************************************************
// Collapse all information

collapse (firstnm) year (lastnm) stopped_* retired - mth_yr (mean) r_wage_hr r_wage_mth, by (pidlink)

********************************************************************************
// Final Clean

	* Remove Never worked indicator if there are values in the year_stopped variables
	
		foreach year in 1987 1992 1995 1999 {
			
					replace neverwrkd=. if (stopped_`year'==1|stopped_wrk==1|retired==1) & neverwrkd==1
					
					}
		
	
	* Create the collapsable "stopped work after year _____" variable
		
				foreach year in 1987 1992 1995 1999 {
			
					replace stopped_`year'=`year' if stopped_`year'==1
					
					}
					
rename (year occ2 hrs_wk wks_yr mth_yr r_wage_hr r_wage_mth) (year_stopped occ2_stopped hrs_wk_stopped wks_yr_stopped mth_yr_stopped r_wage_hr_stopped r_wage_mth_stopped)

********************************************************************************
// Save File

save "$maindir$tmp/Wages - Last Worked.dta", replace

/*
********************************************************************************
// Remove those who have never worked and keep them in a seperate file

preserve

drop if repeatobs!=sum_nvrwrkd

drop sum_* *obs

 * Collapse the never worked repeated observations into one observation: these people have never worked

	collapse (lastnm) year-wave, by(pidlink)

save "$maindir$tmp/Wage Last Job Consolidate - Never Worked.dta", replace

restore

drop if repeatobs==sum_nvrwrkd

********************************************************************************
// Remove those with only one observation and keep them in a seperate file

preserve

keep if repeatobs==1

drop sum_* *obs

save "$maindir$tmp/Wage Last Job Consolidate - One Observation.dta", replace

restore

drop if repeatobs==1

********************************************************************************
// Work on those with 2 repeated observations

preserve

keep if repeatobs==2

drop *obs sum_*

 * Those with the same year observed twice in a row
 
	bysort pidlink (wave): gen rptyr=1 if year[_n-1]==year[_n] & year[_n-1]!=. & year[_n]!=.

	by pidlink: egen rptyr_pers=max(rptyr)
	
		* Work now with only this subset of data
	
		keep if rptyr_pers==1
		
		by pidlink: gen wave_1993=1 if wave==1993
		
		by pidlink: replace wave_1993=1 if wave[1]>1993 // Don't drop those with no 1993 wave observation: rationale is 
														// if 1993 wave is observed keep it - replace the wage if 
														// non-observed in 1993 but observed in other waves
		
		* replace the wage with the next observation if the previous observation is missing
		
		by pidlink: gen dum=1 if wave_1993==1 & r_wage_mth[_n]==. & r_wage_mth[_n+1]!=.
		by pidlink: replace r_wage_mth=r_wage_mth[_n+1] if dum==1
		
		* If a retirement is observed in a future wave then replace it in the previous waves
		
		by pidlink: replace retire=retire[_n+1] if retire[_n]==. & retire[_n+1]==1 & stopped_wrk[_n]==1
		
		replace stopped_wrk=. if retire==1
		
		* First drop if the 'wave_1993' variable doesn't equal to 1
		
		drop if wave_1993!=1 // Keep the 1993 and drop any repeated observations after 1993 for those with a 1993 observation
		
		collapse (firstnm) year (lastnm) stopped_* retired - r_wage_hr (mean) r_wage_mth (lastnm) r_wage_yr - wave, by (pidlink)
		
		* update any economic variable that may have been filled due to a missing wage now observed
		
		replace r_wage_yr=r_wage_mth*(wks_yr/52)*12 if r_wage_yr==.
		replace ln_wage_yr=ln(r_wage_yr) if ln_wage_yr==.
		replace r_wage_hr=r_wage_yr/(hrs_wk*wks_yr) if r_wage_hr==.
		replace ln_wage_hr=ln(r_wage_hr) if ln_wage_hr==.
		
		* append with those who had one observations (the previous section)
		
		append using "$maindir$tmp/Wage Last Job Consolidate - One Observation.dta", gen(Obs_2_same_year)
		
		* save to restore
		
		save "$maindir$tmp/Wage Last Job Consolidate - One Observation.dta", replace
		
restore

preserve

	keep if repeatobs==2

	drop repeatobs sum_*

	* Now drop those with the same year observed twice in a row (already worked on and appended to the singly observed)
 
		bysort pidlink (wave): gen rptyr=1 if year[_n-1]==year[_n] & year[_n-1]!=. & year[_n]!=.

		by pidlink: egen rptyr_pers=max(rptyr)
	
		drop if rptyr_pers==1
		drop rptyr*
		
	* Work on those with no years in their observations
	
		bysort pidlink (wave): gen noyrs=1 if year[_n]==year[_n+1] & year[_n]==. & year[_n+1]==. & pidlink[_n+1]==pidlink[_n]
		
		by pidlink: egen noyrs_pers=max(noyrs)
	
		* Work now with only this subset of data
		
			keep if noyrs_pers==1
			drop noyrs*
			
/*		* Count if the person is consistently retired
		
			by pidlink: egen retiredcount=total(retired)
		
		* Keep only the final retired observation
		
			by pidlink: gen dum_drop=1 if obs[_n+1]==retiredcount[_n+1] & obs[_n]!=retiredcount[_n] & pidlink[_n+1]==pidlink[_n]
			
			* Drop the first observation of those who have retired
			
				*drop if dum_drop==1
				*drop dum_*
		
		* Identify those who "never worked" and later had an observed stop date
		
			by pidlink: gen initial_nvrwrkd2=1 if neverwrkd[_n]==1 & neverwrkd[_n+1]==.
		
			* Drop those who have a never worked and then worked
			
				*drop if initial_nvrwrkd==1
				*drop initial_*
				
		* Identify those who twice have stopped working
		
			by pidlink: egen stop_wrk_count=total(stopped_wrk)
			
*/
		
		* Create the collapsable "stopped work after year _____" variable
		
				foreach year in 1987 1992 1995 1999 {
			
					replace stopped_`year'=`year' if stopped_`year'==1
					
					}
					
		* continue this code later
		
		
		
		
	
		
