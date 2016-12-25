// Clean the Double Years Consolidated Wages

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Do the Consolidated Wage do file to create the raw data set

qui do "$maindir$project/Do Files/Consolidate Wages.do"

********************************************************************************
// Drop observations that have no years - would not be able to identify 

replace year=. if year>2008

drop if year==.

********************************************************************************
// Fill in first job identifier

bysort pidlink year (job wave): egen first_job=max(FirstJob)
replace FirstJob=first_job
drop first_job

********************************************************************************
// Identify those observations with repeated years (overlap from different waves)

	bysort pidlink year (job wave): gen byte flag_repyrs=1 if (year[_n]==year[_n+1] & pidlink[_n]==pidlink[_n+1] & (job[_n]==job[_n+1] | ((job[_n+1]==. & job[_n]==1)|(job[_n]==. & job[_n+1]==1)))) | ///
														      (year[_n-1]==year[_n] & pidlink[_n]==pidlink[_n-1] & (job[_n]==job[_n-1] | ((job[_n-1]==. & job[_n]==1)|(job[_n]==. & job[_n-1]==1))))
													  
	* Check the flag (how many counts of repeated years are there?):
	
		by pidlink year: egen Sum=count(flag_repyrs)
		
		replace Sum=. if Sum==0 | flag_repyrs==. // Remove the 0s and those where job==.
		
		tab Sum
		
		/* 
		   				Sum |      Freq.     Percent        Cum.		Drop Count
				------------+------------------------------------------------------
						  2 |    182,476       92.79       92.79		91,238 
						  3 |      5,556        2.83       95.62		 3,704
						  4 |      8,616        4.38      100.00		 4,306+1=4307
				------------+------------------------------------------------------
					  Total |    196,648      100.00					99,249 
					  
		   If Sum==3 then there are instances where job==. for the same year; 
		   if Sum==4 there are instances where we observe duplicate years for the first and second occupation and only 
		   three instances where Sum==4 and the job vairable has a missing variable (all for the same person)
		*/
		   
		* Code to check Sum==4 is of form of two repeated years (for two occupations)
		   
		/*	  count if Sum==4 & (job==1|job==2) & job!=. //Should be the same count as in the tabulate
			  
			gen byte dum=1 if Sum==4 & (job==1|job==2) & job!=.
			drop dum  
		*/
		
********************************************************************************		   
/* Identify the repeated observation to drop: (currently 6,170 need to be identified)
   1) keep either the current wage observation (dataset==4) if repeated year occurs between two waves;
   2) or keep the observation with the wage observation */

   * Flag the observation when both years have a missing wage observation but one has a months worked and the other doesn't
   
	by pidlink: gen byte flag_repyrs_nowks=1 if (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n-1]!=.) | ///
												(year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n+1]!=.) | ///
												(year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & flag_repyrs[_n]==1 & worked[_n]!=. & worked[_n+1]!=.) | ///
												(year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & flag_repyrs[_n]==1 & worked[_n]!=. & worked[_n-1]!=.) | ///
												(year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]==. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & job[_n-1]!=. & job[_n]==. & occ2[_n-1]!="") | ///
												(year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]==. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & job[_n-1]==. & job[_n]==.) 
   
   * Flag the observation that is missing a wage
   
	by pidlink: gen byte flag_repyrs_nowage=1 if (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n-1]!=.) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n+1]!=.)
   
   * Flag the second observation for repeated years when wages are not missing
  
	by pidlink: gen byte flag_repyrs_secobs=1 if (year[_n]==year[_n-1] & r_wage_mth[_n]!=. & r_wage_mth[_n-1]!=. & r_wage_mth[_n-1]>0 & r_wage_mth[_n]>0 & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]!=. & r_wage_mth[_n-1]!=. & r_wage_mth[_n-1]==0 & r_wage_mth[_n]==0 & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1) | ///
																																																									///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]!=. & r_wage_mth[_n]==0 & r_wage_mth[_n-1]!=. & r_wage_mth[_n-1]>0 & pidlink[_n]==pidlink[_n-1] & !(wave[_n]>wave[_n-1] | wave[_n]==wave[_n-1]) & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]!=. & r_wage_mth[_n]==0 & r_wage_mth[_n+1]!=. & r_wage_mth[_n+1]>0 & pidlink[_n]==pidlink[_n+1] & !(wave[_n]<wave[_n+1] | wave[_n]==wave[_n+1]) & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]!=. & r_wage_mth[_n]==0 & r_wage_mth[_n-1]!=. & r_wage_mth[_n-1]>0 & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]!=. & r_wage_mth[_n]==0 & r_wage_mth[_n+1]!=. & r_wage_mth[_n+1]>0 & pidlink[_n]==pidlink[_n+1] & wave[_n]==wave[_n+1] & flag_repyrs[_n]==1) | ///
																																																									    ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]!=. & r_wage_mth[_n]==0 & r_wage_mth[_n-1]!=. & r_wage_mth[_n-1]>0 & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]!=. & r_wage_mth[_n]==0 & r_wage_mth[_n+1]!=. & r_wage_mth[_n+1]>0 & pidlink[_n]==pidlink[_n+1] & wave[_n]<wave[_n+1] & flag_repyrs[_n]==1) | ///
																																																									   ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]!=. & r_wage_mth[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & !(wave[_n]>wave[_n-1]) & flag_repyrs[_n]==1 & worked[_n]==1 & worked[_n-1]==1 & job[_n]==. & job[_n-1]!=.) | ///
											     (year[_n]==year[_n-1] & r_wage_mth[_n]!=. & r_wage_mth[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & worked[_n]==1 & worked[_n-1]==1) | ///
																																															///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1) | /// 
												 (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & wave[_n]<wave[_n+1] & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & !(wave[_n]<wave[_n-1]) & flag_repyrs[_n]==1 & job[_n]!=. & job[_n-1]==. & Sum[_n]==2 & Sum[_n-1]==2) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & !(wave[_n]<wave[_n+1]) & flag_repyrs[_n]==1 & job[_n]!=. & job[_n+1]==. & Sum[_n]==2 & Sum[_n+1]==2) | ///
																																																						   ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]!=. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1) | ///
																																																							  ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & wave[_n]==wave[_n+1] & flag_repyrs[_n]==1) | ///		
																																														     ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & wave[_n]==wave[_n+1] & flag_repyrs[_n]==1) | ///
																																																							   ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]!=. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1 & job[_n-1]!=. & job[_n]==.) | ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]!=. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & job[_n-1]!=. & job[_n]==.) | ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]!=. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & job[_n-1]==. & job[_n]==.) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]!=. & mth_yr[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & wave[_n]==wave[_n+1] & flag_repyrs[_n]==1 & job[_n+1]!=. & job[_n]==.) | ///
																																																														   ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1 & job[_n-1]!=. & job[_n]!=.) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & wave[_n]<wave[_n+1] & flag_repyrs[_n]==1 & job[_n+1]!=. & job[_n]!=.) | ///
												 (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]!=. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & job[_n-1]!=. & job[_n]!=.) | ///
												 (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]!=. & pidlink[_n]==pidlink[_n+1] & wave[_n]==wave[_n+1] & flag_repyrs[_n]==1 & job[_n+1]!=. & job[_n]!=.)											 
	
	* Flag second observation for those with no work
	
	by pidlink: gen byte flag_repyrs_secobs_nowrk=1 if ((year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]==. & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n-1]!=.) | ///
													   (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]==. & pidlink[_n]==pidlink[_n+1] & wave[_n]<wave[_n+1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n+1]!=.) | ///
													   (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]==. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n-1]!=.) | ///
													   (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]==. & pidlink[_n]==pidlink[_n+1] & wave[_n]==wave[_n+1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n+1]!=.) | ///
																																																																	   ///
													   (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]==. & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n-1]==. & occ2[_n]=="" & occ2[_n-1]!="") | ///
													   (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]==. & pidlink[_n]==pidlink[_n+1] & wave[_n]<wave[_n+1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n+1]==. & occ2[_n]=="" & occ2[_n+1]!="") | ///
													   (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]==. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n-1]==. & occ2[_n]=="" & occ2[_n-1]!="") | ///
													   (year[_n]==year[_n+1] & r_wage_mth[_n]==. & r_wage_mth[_n+1]==. & mth_yr[_n]==. & mth_yr[_n+1]==. & pidlink[_n]==pidlink[_n+1] & wave[_n]==wave[_n+1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n+1]==. & occ2[_n]=="" & occ2[_n+1]!="")) | ///
																																																																									    ///
													   (year[_n]= =year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]==. & pidlink[_n]==pidlink[_n-1] & wave[_n]>wave[_n-1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n-1]==. & occ2[_n]=="" & occ2[_n-1]=="" ) | ///																																																												
													   (year[_n]==year[_n-1] & r_wage_mth[_n]==. & r_wage_mth[_n-1]==. & mth_yr[_n]==. & mth_yr[_n-1]==. & pidlink[_n]==pidlink[_n-1] & wave[_n]==wave[_n-1] & flag_repyrs[_n]==1 & worked[_n]==. & worked[_n-1]==. & occ2[_n]=="" & occ2[_n-1]=="")
													   
********************************************************************************  
// Check that I have captured all the possible drops: 2 observed years 
	
	* For those with two observations (Sum=2) finish the cleaning process
	
			gen dum2=1 if Sum==2 & (flag_repyrs_nowks==1| flag_repyrs_nowage==1| flag_repyrs_secobs==1| flag_repyrs_secobs_nowrk==1)
			
			by pidlink year (job wave): egen dum2_miss=count(dum2)
			replace dum2_miss=. if Sum!=2
			replace dum2=. if dum2_miss==2 & ( mth_yr!=. | (r_wage_mth!=. & r_wage_mth!=0))
			drop dum2_miss
			
			by pidlink year (job wave): egen dum2_miss=count(dum2)
			replace dum2_miss=. if Sum!=2
			replace dum2=. if dum2_miss==2 & occ2!="" & mth_yr==. & r_wage_mth==.
			drop dum2_miss
			
			by pidlink year (job wave): egen dum2_miss=count(dum2)
			replace dum2_miss=. if Sum!=2
			bysort pidlink year (job wave) dum2_miss: replace dum2=1 if _n==1 & dum2_miss==0 
			drop dum2_miss
			
			rename dum2 drop_obs_2
			
********************************************************************************  
// Check that I have captured all the possible drops: 4 observed years 
			
	* For those with 4 observations (Sum=4) finish the cleaning process
			
			gen dum4=1 if Sum==4 & (flag_repyrs_nowks==1| flag_repyrs_nowage==1| flag_repyrs_secobs==1| flag_repyrs_secobs_nowrk==1)
	
			bysort pidlink year job (wave): egen dum4_miss=count(dum4)
			replace dum4_miss=. if Sum!=4
			
			bysort pidlink year job dum4_miss: replace dum4=. if _n==1 & dum4_miss==2
			drop dum4_miss
			
			rename dum4 drop_obs_4
			
********************************************************************************  
// Check that I have captured all the possible drops: 3 observed years 
		
	* For those with three observations (Sum=3)
			
			gen dum3=1 if Sum==3 & (flag_repyrs_nowks==1| flag_repyrs_nowage==1| flag_repyrs_secobs==1| flag_repyrs_secobs_nowrk==1)
			
			bysort pidlink year (job wave): egen dum3_miss=count(dum3)
			replace dum3_miss=. if Sum!=3
			
			* Collapse all the observations where 2 observations have not been identfied for a drop
			
			preserve
			
				keep if (dum3_miss==1 & Sum==3) | (dum3_miss==3 & Sum==3)
			
				collapse (max) hrs_wk wks_yr r_wage_mth (firstnm) occ2 job worked year_start FirstJob flag_repyrs Sum wave, by(pidlink year)
			
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
				  
				save "$maindir$tmp/Wage Database - 3 obs collapse.dta", replace
				  
			restore
		
			drop if (dum3_miss==1 & Sum==3) | (dum3_miss==3 & Sum==3)
			
			append using "$maindir$tmp/Wage Database - 3 obs collapse.dta", gen(append_3_obs)
			
			sort pidlink year job wave
			
			erase "$maindir$tmp/Wage Database - 3 obs collapse.dta"
			
			drop dum3_miss append_*
			
			rename dum3 drop_obs_3
			
********************************************************************************
// Drop the repeated years (for each occupation)

egen drop_obs=rsum(drop_*),missing

drop drop_obs_* flag_* Sum

drop if drop_obs==1

replace job=1 if job==. & worked!=. & occ2!=""

drop drop_*
 
********************************************************************************
// Any Remaining years, collapse

bysort pidlink year (job wave): gen byte flag_repyrs=1 if (year[_n]==year[_n+1] & pidlink[_n]==pidlink[_n+1] & (job[_n]==job[_n+1] | ((job[_n+1]==. & job[_n]==1)|(job[_n]==. & job[_n+1]==1)))) | ///
														  (year[_n-1]==year[_n] & pidlink[_n]==pidlink[_n-1] & (job[_n]==job[_n-1] | ((job[_n-1]==. & job[_n]==1)|(job[_n]==. & job[_n-1]==1))))
											
preserve

	keep if flag_repyrs==1
			
	collapse (max) hrs_wk wks_yr r_wage_mth (firstnm) occ2 job worked year_start FirstJob flag_repyrs wave, by(pidlink year)
	
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

* Remove last repeat observation
/*
	bysort pidlink year: gen rep=1 if (year[_n]==year[_n-1]&pidlink[_n]==pidlink[_n-1])|(year[_n]==year[_n+1]&pidlink[_n]==pidlink[_n+1]) 

	by pidlink year: gen obs=_n
	by pidlink year: replace rep=. if rep==1 & obs==1
	
	drop if rep==1
	
	drop obs rep
*/			
********************************************************************************

compress

save "$maindir$tmp/Wage Database.dta", replace

			
			

			
			
