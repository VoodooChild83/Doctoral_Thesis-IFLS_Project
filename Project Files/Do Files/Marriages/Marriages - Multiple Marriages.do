* This file will take those with multiple marriages and consolidate the associated partner
* (and drop those that have missing values for their partners).

* This file is in association with the "Marriage - Only 1 Marriage" do file to help identify those individuals who
* may have had only one spouse so far in lifetime, but whose partner may have had previous spouses.

* Not correcting or helping to identify these individuals would make it look like the spouse who reported the sole marriage
* so far in the lifetime did not have the partner spouse in the survey. 

********************************************************************************

	keep if People_1Marr==.
		
		*drop if flag_Drop==1
		
		drop People* MaxMarr*
	
		save "$maindir$tmp/Marriage History Database - More than 1 Marriage.dta", replace
		
		* Now collapse by marriage numbers to obtain the spouses to help identify the partners in other datasets (use the firstnm)
		
			collapseandpreserve (firstnm) pidlink2 pidlink_spouse pidlink_couple, by(pidlink MarrNum) omitstatfromvarlabel
			
		* Identify those spousal partners who are listed as spousal partners in more than 1 marriage number: keep only the last observation
		
			by pidlink: gen flag_RepSpouse=1 if pidlink[_n]==pidlink[_n+1] & MarrNum[_n]!=MarrNum[_n+1] & pidlink_spouse[_n]==pidlink_spouse[_n+1] & pidlink_spouse!=.
			
		* Identify those where the collapse generated gaps between marriage years and the spousal partners are the same
			
				* check
					tab MarrNum if flag_RepSpouse==1
		
				by pidlink: egen double pidlink_spouseMax=max(pidlink_spouse) 
				by pidlink: egen double pidlink_spouseMin=min(pidlink_spouse)
				by pidlink: egen double flag_RepSpouseMax=max(flag_RepSpouse)
				
				gen flag_RepSpouseConsis1=1 if pidlink_spouseMax==pidlink_spouseMin & flag_RepSpouseMax==1
				gen flag_RepSpouseConsis2=1 if pidlink_spouseMax==pidlink_spouseMin & flag_RepSpouseMax!=1 & pidlink_spouseMax!=. 
				
			* Keep those individuals with more than one marriage who have different observed spouses in each marriage in seperate file for later merge to identify 
			* (that is, the spouse may have had one marriage and the individual surveyed may have had several so it may look like the surveyed spouse is the only
			* one in the One Marriage file who is present and surveyed - we will remove these people since their existence is complicated). 
			
				preserve
			
					keep if flag_RepSpouseConsis1==. & flag_RepSpouseConsis2==. & pidlink_spouse!=.
					
					collapseandpreserve (firstnm) pidlink2 pidlink_couple, by(pidlink pidlink_spouse) omitstatfromvarlabel
	
					drop pidlink
				
					* Save for append later
				
						save "$maindir$tmp/Marriage History Database - individuals with more than 1 identified spouse.dta", replace
				
				restore	
				
			* Drop those from above that were sequestered in the diferent file to identify in the 1 Marriage file, work on remaining cases
			
				drop if (flag_RepSpouseConsis1==. & flag_RepSpouseConsis2==. & (pidlink_spouse!=. | pidlink_spouse==.)) | pidlink_spouse==.
			
			* Now drop the observations that are not the last one
			
				bysort pidlink flag_RepSpouseConsis1: gen obs1=_n if flag_RepSpouseConsis1==1
				bysort pidlink flag_RepSpouseConsis2: gen obs2=_n if flag_RepSpouseConsis2==1
			
				bysort pidlink: gen flag_drop=1 if (flag_RepSpouseConsis1==1 & obs1!=_N) | (flag_RepSpouseConsis2==1 & obs2!=_N)
			
				drop if flag_drop==1
					drop flag_* obs* *Max *Min MarrNum pidlink
					
			* Keep in a seperate file those individuals whose spouses have multiple marriages
			
				bysort pidlink_spouse: gen obs=_N
				
				preserve
				
					keep if obs>1
						drop obs
	
						gen file=2
						
						save "$maindir$tmp/Marriage History Database - spouses with more than 1 identified individuals.dta", replace
				
				restore
	
			* Now identify those who have had multiple marriages and the spouse has had seemingly one marriage - individual with multiple marriage only reports the spouse of last marriage
				
				drop if obs>1
					drop obs
	
				gen file=3
				
			* Append the previous two files to create the master file of identifiable couples where one or both partners have had more than one marriage
			
				append using "$maindir$tmp/Marriage History Database - individuals with more than 1 identified spouse.dta"
					erase "$maindir$tmp/Marriage History Database - individuals with more than 1 identified spouse.dta"
				append using "$maindir$tmp/Marriage History Database - spouses with more than 1 identified individuals.dta"
					erase "$maindir$tmp/Marriage History Database - spouses with more than 1 identified individuals.dta"
					
					* Test to see if there are duplicates on the pidlink2 pidlink_spouse combination (there should not be any as the three files treated each part seperately)
					
						duplicates report pidlink2 pidlink_spouse
						
						// There should be no repeats of the combination above
						
				gen flag_Identify=1
					drop file
					
				save "$maindir$tmp/Marriage History Database - multiply married people.dta", replace
				
				* Switch the order of spouses - and append - to identify all combinations of spouses in the 1 marriage dataset (drop duplicates if necessary)
				
					rename (pidlink2 pidlink_spouse) (pidlink_spouse pidlink2)
					
					append using "$maindir$tmp/Marriage History Database - multiply married people.dta"
				
					duplicates drop
				
					save "$maindir$tmp/Marriage History Database - multiply married people.dta", replace
