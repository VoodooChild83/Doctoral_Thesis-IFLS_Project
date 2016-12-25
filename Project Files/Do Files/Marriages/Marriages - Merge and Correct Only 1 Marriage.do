* This Do File will merge into the 1 Marriage file and correct the following:

*		a) Merge into the file an identifier variable from the Multiple Marriage Do file to identify
*		   those couples where at least one of the partners have had a multiple marriage (not observed in the 
*		   first pass clean
*		b) Identify spousal partners who are in different households because of the collapse (use the females) and
*		   update the information to keep everyone in the same house for date cleaning
*		c) For those individuals with i) a spousal partner and ii) a missing start_year, but whose spouse has
*		   the marriage start year, update through a merge
* 		d) Do the same as above with the end of a marriage
*		e) Use the _merge identifier for both a) and b) to get a generate a flag for the consistency of dates and to identify
* 		   the marriage pairs in a household

********************************************************************************

	preserve
	
		keep pidlink_spouse pidlink2 year_start 
		
		rename (pidlink_spouse pidlink2) (pidlink2 pidlink_spouse)
		
		save "$maindir$tmp/Marriage History Missing Year_Start Update.dta", replace
	
	restore
	
	preserve
	
		keep pidlink_spouse pidlink2 year_end 
		
		rename (pidlink_spouse pidlink2) (pidlink2 pidlink_spouse)
		
		save "$maindir$tmp/Marriage History Missing Year_End Update.dta", replace
	
	restore
	
	preserve
	
		keep if Sex==1
		
		keep pidlink_spouse pidlink2 hhid
		
		rename (pidlink_spouse pidlink2) (pidlink2 pidlink_spouse)
		
		save "$maindir$tmp/Marriage History Missing HHID Update.dta", replace
	
	restore
	
	* Identify those individuals who, using Multiple Marriage Do File, have multiple marriages.
	
		merge 1:1 pidlink2 pidlink_spouse using "$maindir$tmp/Marriage History Database - multiply married people.dta", keep(1 3) nogen
			erase "$maindir$tmp/Marriage History Database - multiply married people.dta"
			
			* Drop thoese identified from the dataset
			
				drop if flag_Identify==1
				drop flag_Identify
	
	* Update hhid so that spouses are all in the same HH
	
		merge 1:1 pidlink2 pidlink_spouse using "$maindir$tmp/Marriage History Missing HHID Update.dta", update replace keep(1 3 4 5) nogen
			erase "$maindir$tmp/Marriage History Missing HHID Update.dta"
		
	* Then update year_end
	
		merge 1:1 pidlink2 pidlink_spouse using "$maindir$tmp/Marriage History Missing Year_End Update.dta",update keep(1 3 4 5) nogen
			erase "$maindir$tmp/Marriage History Missing Year_End Update.dta"
		
	* Now update the year_start
   
		merge 1:1 pidlink2 pidlink_spouse using "$maindir$tmp/Marriage History Missing Year_Start Update.dta",update keep(1 3 4 5)
			erase "$maindir$tmp/Marriage History Missing Year_Start Update.dta"
	
	* Use the merge variable from year_start to identify those people that have inconsistent dates, and those where only one spouse is present in the database
	
		recode _merge (1 = 1 "One Spouse") (3 4 = 2 "Two Spouses - Consistent Dates") (5 = 3 "Two Spouses - Inconsistent Dates"), gen(DataConsistency) label(SpouseDataConsistency)
			drop _merge
	
	* Keep those individuals where only one of the partners is surveyed (that is, spouse is no surveyed) in a seperate file
	
		preserve
	
			keep if DataConsistency==1
		
			save "$maindir$tmp/Marriage History Database - one marriage and only one partner observed.dta", replace
	
		restore
	
		keep if DataConsistency!=1
		
		* Check that we have even numbered people in each household
			
			bysort hhid Sex: gen obs2=_N 
			
			tab obs2
			tab Sex		// There are 4 females more than there are males: we will try to correct this
			
				drop obs2	
	
		* Find the 4 females and sequester and try to update Sex with MasterTrack file
	
			preserve
	
				keep if Sex==1
		
				keep pidlink2 pidlink_spouse
		
				rename (pidlink2 pidlink_spouse) (pidlink_spouse pidlink2)
		
				gen flag_spouse=1
		
				save "$maindir$tmp/Marriage History Database - females married to eachother.dta", replace

			restore
	
			merge 1:1 pidlink2 pidlink_spouse using "$maindir$tmp/Marriage History Database - females married to eachother.dta", nogen
				erase "$maindir$tmp/Marriage History Database - females married to eachother.dta"
	
			* It turns out that there are two couples that seem to be comprised of same sex partnerships. An attempt at correcting possibly
			* incorrect sex lead to these two couples needing to be dropped
		
			drop if Sex==1 & flag_spouse==1
				drop flag_spouse
