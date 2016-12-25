* Find the inconsistencies & missing partner info: the spouses who are seemingly 
* simultaneously married to different individuals (especially females married to more than one male)
* based on having only one marriage and yet married 

* This file is in association to the "Marriages - Only 1 Marriage" do file, and as such it 
* is not a stand-alone file. 

********************************************************************************

* Find those individuals who are/were married to someone (the pidlink_spouse) who was married multiple times - observe multiple partners
 
		bysort pidlink_spouse: gen obs=_N if pidlink_spouse!=.
		
	* Find those who have no information on their spouses
	
		bysort pidlink: gen obs2=_N if pidlink_spouse==.
		
	* Sequester these multiply married partners and individuals with unidentified partners
	
		preserve
	
			keep if obs2==1|(obs>1 & obs!=.)
		
			gen flag_InconsisPartners=1 if obs!=.
				drop obs2 obs
		
			save "$maindir$tmp/Marriage History Database - Inconsistencies and Missing Spouses.dta", replace
		
			* Now keep only those where Inconsistant Spousal Partners equal 1, and keep only one observation to identify these people in the 
			* dataset with these spousal partners.
		
			keep if flag_InconsisPartners==1
		
			keep pidlink_spouse flag_InconsisPartners
		
			rename pidlink_spouse pidlink2
		
			bysort pidlink2: gen obs=_n
		
			keep if obs==1
			drop obs
		
			save "$maindir$tmp/Marriage History Database - Spousal Partner Inconsistencies.dta", replace

		restore
		
	* Once sequestered, remove them from the file
	
		drop if obs2==1|(obs>1 & obs!=.)
		drop obs2 obs
	
	* Identify in pidlink2 the spouses who appear in multiple partnerships (who are multiple times seen in pidlink_spouse)
	
		merge 1:1 pidlink2 using "$maindir$tmp/Marriage History Database - Spousal Partner Inconsistencies.dta", keep(1 3) nogen
			erase "$maindir$tmp/Marriage History Database - Spousal Partner Inconsistencies.dta"
	
	* Include these identfied inconsistencies into the Inconsistencies and Missing Spouses dataset
	
	preserve
	
		keep if flag_InconsisPartners==1
	
		append using "$maindir$tmp/Marriage History Database - Inconsistencies and Missing Spouses.dta"
		
		save "$maindir$tmp/Marriage History Database - Inconsistencies and Missing Spouses.dta", replace
	
	restore
	
	drop if flag_InconsisPartners==1
	drop flag_*
