* There are obviously some single-parent households where the children have no parent IDs and the parent obviously has no 
* couple ID. To obtain an "ID" for these single-parent households I will simply use their pidlinks. To identify single
* parents I collapse the children to obtain a dataset that I can then re-merge into this one that will identify parents. 
* Then I will use the _merge variable with the code that corresponds to a "match" to then replace pidlink_couple with the
* person's own pidlink - that is, they become their own "couple."
		
		* Replace pidlink_parent = the pidlink of the identifiable parent IF only one of the two parents are observed
		
			gen flag_ChildSingleParent=1 if pidlink_parent==. & (pidlink_father!=.|pidlink_mother!=.) & pidlink_father!=pidlink_mother // flag all those who have only one observed parent
		
			foreach par in mother father{
			
				replace pidlink_parent=pidlink_`par' if pidlink_parent==. & flag_ChildSingleParent==1
			
			}
			
		* Keep all the children of single parents and then create a flag variable 
		
			preserve
		
				keep if flag_ChildSingleParent==1
				
				* Check that there are consistencies within the pidlink_parent variable
						
					bysort pidlink: egen double pidlink_parentMean=mean(pidlink_parent)
						
						assert pidlink_parent==pidlink_parentMean, null
						
							// The above assert command SHOULD NOT BREAK WITH AN INCONSISTENCY --> 
							// no inconsistencies. 
				
					keep pidlink pidlink_parent wave
				
				* Keep only one observation per parent and wave
				
					duplicates drop pidlink_parent, force
					
				* rename pidlink_parent to pidlink2 to identify the parent in the dataset
				
					rename pidlink_parent pidlink2
					
				* generate the parental identifier
				 
					gen flag_SingleParent=1
				
				save "$maindir$tmp/Single Parents.dta", replace
		
			restore
			
		* Merge into the dataset the single parent identifier flag variable
		
			merge m:1 pidlink2 using "$maindir$tmp/Single Parents.dta", keep(1 3) keepusing(flag_SingleParent) nogen
				erase "$maindir$tmp/Single Parents.dta"
		
		* Replace the pidlink_couple of the identified single person as themselves and if 
		* the person doesn't already have an entry in pidlink_couple (if they do have an entry
		* in pidlink_couple, replace flag_SingleParent to missing as these are not really 
		* a single parent, just that the child's other parent is missing in the entry) -
		* accomplish this with a new flag variable.
		
			gen flag_NotSingleParent=1 if flag_SingleParent==1 & pidlink_couple!=.
			
			* Correct the flag for those parents with multiple observations and a NOT SINGLE PARENT flag
			
				duplicates tag pidlink2 flag_NotSingleParent, gen (DupNSP)
				
				bys pidlink2: egen byte DupNSPMax=max(DupNSP)
				
				replace flag_SingleParent=. if flag_NotSingleParent==. & DupNSPMax>0
					drop DupNSP*
			
			* To account for those children who have only one reported parent but
			* whose reported parent is identified as being in a couple (flagged as not
			* a single parent), I will have to duplicate this parent to create them 
			* as a single parent (they may have been in a relationship with someone 
			* I did not observe and their observed child's missing parent was from this union). 
			
			preserve
			
				keep if flag_NotSingleParent==1
				
				* Drop the multiple observations of this individual
				
					duplicates drop pidlink2, force
					
					drop flag_NotSingleParent
					
				* Replace pidlink_couple to missing for these identified single parents
				
					replace pidlink_couple=. 
					replace pidlink_spouse=. 
					
				save "$maindir$tmp/Not Single Parents.dta", replace
		
			restore
			
			append using "$maindir$tmp/Not Single Parents.dta", gen(appended)
				erase "$maindir$tmp/Not Single Parents.dta"
				
				* Tag duplicates for careful replace
				
					duplicates tag pidlink2 pidlink_couple if pidlink_couple==. & flag_SingleParent==1, gen (DupSingleParents)
			
			* Replace the flag for Single Parents to missing for those who are identifed as
			* NOT single parents
			
				replace flag_SingleParent=. if flag_NotSingleParent==1
				
			* Assign the single parents their own pidlink2 id as their couple ID for ease of
			* parental identification
		
				replace pidlink_couple=pidlink2 if flag_SingleParent==1 & pidlink_couple==. & ((appended==0 & DupSingleParents==0)|(appended==1))
				replace flag_SingleParent=. if flag_SingleParent==1 & pidlink_couple==.
					drop flag_Not* appended DupSingle*
