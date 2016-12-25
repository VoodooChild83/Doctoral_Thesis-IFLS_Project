* This files will build the generations within a Dynasty

* Care must be observed, as a general pattern for creating the generation should 
* be identifieable, but single parents as the progenitor of a Dynasty inverts one
* method for identifying them. 
*	- For G=1:
*	   It is relatively easy to identify generation 1 (in general) in this case.
*	   The first generation of a dynasty, the progenerators, are those who have 
* 	   the smaller of the pidlink_couple (for multigenerational families). AND 
*      their pidlink_couple should equal the family variable. So either running 
* 	   the 'min' routine or simply identifying that they have the same family id
*      as the pidlink_couple is sufficient.
*	- For G>1:
*	   We may need to try other methods (it becomes difficult for count, sum, group
*      methods because grandchildren+ will be difficult to account for and may 
*      generate more generations than there actually are.

**************** GENERATE GENERATION 1 WITHIN A DYNASTY	************************

* Within a dynasty, generate the first generation

	bys Dynasty (Family pidlink_couple pidlink_parent pidlink): gen Generation=1 if Family==pidlink_couple
		order Dynasty Generation
			sort Dynasty Generation pidlink_couple pidlink2
			
********************* GENERATE G>1 WITHIN A DYNASTY ****************************

* To generate the subsequent generations create a loop that inverts the name of 
* of pidlink_couple and pidlink_parent and thus both spouses who do not originate 
* from the household and children can be updated. Assume 4 generation (so iterate
* 3 times - great grandchildren are likely not having children).

	forvalues i=1/3{
		
			* First do the children in a generation
	
				preserve
				
				* Keep only the Generation from the loop and necessary variable
				
					keep if Generation==`i' & pidlink_couple!=.
			
					keep pidlink_couple Generation
					
				* Increment the loop local variable to assign the new generation
			
					local j=`i'+1
			
					replace Generation=`j'
					
				* Invert the parental and couple id, and drop the duplicates
			
					rename (pidlink_couple) (pidlink_parent)
				
					duplicates drop pidlink_parent, force
				
				save "$maindir$tmp/Generation Child Updater.dta", replace
	
				restore
			
			* Merge into the dataset the Child generation updater
			
				merge m:1 pidlink_parent using "$maindir$tmp/Generation Child Updater.dta", update replace keep(1 3 4 5) nogen
				
			* Update the spouses.....but only up to G=3, since G=4 has not been married and as such they have nothing in their
			* pidlink_couple variable
			
			if `j'<4 {
			
				* Now do the same to assign the non-dynasty member partner the generation of their spouse
			
					preserve
						
						/*if `j'==2*/ keep if Generation==`j' & pidlink_couple!=.
					
						*if `j'==3 keep if (Generation==`j'| Generation==`i') & pidlink_couple!=.
					
						keep pidlink_couple Generation
					
						* Keep only one observation (in case there are IFLS partners from the same generation already has a Generation Identifier
					
							collapse (min) Generation, by(pidlink_couple)
					
					save "$maindir$tmp/Generation Spouse Updater.dta", replace
			
					restore
				
				* Merge into the dataset the Spouse's generation updater
			
					merge m:1 pidlink_couple using "$maindir$tmp/Generation Spouse Updater.dta", update replace keep(1 3 4 5) nogen
			}
		
	}
	
		erase "$maindir$tmp/Generation Child Updater.dta"
	
	* Test that all couples are in the same generation:
		
		bys pidlink_couple: gen flag_GenInconsis=1 if pidlink_couple[_n]==pidlink_couple[_n+1] & Generation[_n]!=Generation[_n+1] & pidlink_couple!=.
		
		// The above code should result in all missing values (all couples are in the same generation - no displacement)
		
		drop flag_GenInconsis
		
* Correct the inconsistencies due to the merge of spouses with higher generations updating their partner in the dynasty they stay in (13 inconsistencies)

	 bys pidlink2 (pidlink_couple): gen FLAG=1 if pidlink2[_n]==pidlink2[_n+1] & Generation[_n]!=Generation[_n+1] & Dynasty[_n]==Dynasty[_n+1]
	 bys pidlink2 (pidlink_couple): replace FLAG=1 if pidlink2[_n]==pidlink2[_n-1] & Generation[_n]!=Generation[_n-1] & Dynasty[_n]==Dynasty[_n-1]
	 
	 preserve
	 
		keep if FLAG==1
		
		collapse (min) Generation (firstnm) pidlink_couple, by (pidlink2)
		
		save "$maindir$tmp/Generation Spouse Updater.dta", replace
	 
	 restore
	 
	 merge m:1 pidlink_couple using "$maindir$tmp/Generation Spouse Updater.dta", update replace keep(1 3 4 5) nogen
		erase "$maindir$tmp/Generation Spouse Updater.dta"
			drop FLAG
		
	sort Dynasty Generation Family pidlink2
