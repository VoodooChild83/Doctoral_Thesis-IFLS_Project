**** CREATE THE DATABASE OF PARENTAL CODES TO GENERATE CONSISTENT DYNASTIES ****

* Use the fact that IFLS children will have at least one parent identified to find
*	a) Those IFLS offspring who are/have been married and whose spouse is not an IFLS child
*	b) Those whose spouse IS an IFLS child and so we need to know which person is in the
*	   household and those where people don't live in the same household: those in the same
*	   household need to have a clarification of who is the principal in the dynasty
*			1) Those who are not in the same household may need to either be dropped, or there
*			   will need to ba clarification of why the couple is not in the same household:
*			   The "collapse" command keeps the last hhid and couple-id. So need to know if these
*			   couples divorced/seperated.

	keep if pidlink_couple!=. & (pidlink_father!=.|pidlink_mother!=.) /*& Incest!=1*/ /*& flag_SingleParent!=1*/

	* Find duplicates (there may be intermarriage between survey participants from different household
	* that are also surveyed - they need to be correctly placed in the appropriate dynasty, that is we will
	* take as given the dynasty where they are located in the HHIDs)
	
		duplicates tag pidlink_couple, gen(DupCouples)
	
		* Now find those Duplicate couples that are in the same household....this way the person who has the same 
		* parent_pidlink and Family ID is the "principle" and the spouse is the one who has moved into the person's
		* household
	
			duplicates tag hhid if DupCouples==1, gen(CoupleInSameHH)
			
				* 45  Couples where both partners are IFLS children are not in the same household
				* 374 Couples where both partners are IFLS children are in the same household
					tab sex CoupleInSameHH
					
	* To place the partner of the spouse that is in the same household but who has parent identifiers into the same family
	* we will need to take the minimum of the identifiers (as it is supposed that the minimum is the parental 

		bys pidlink_couple (pidlink_parent): egen double FamilyIDMin=min(Family) if CoupleInSameHH==1
		
		* Drop the partner from the duplicate couples once the Family Identifier has been updated
		
			gen flag_DropDupCouple=1 if pidlink_parent!=FamilyIDMin & DupCouples==1
			
			drop if flag_DropDupCouple==1
				drop flag_DropDupCouple CoupleInSameHH FamilyIDMin DupCouples
				
	* Create the databases to merged-in Family and Dynasty information as needed
	
		* Keep the variables that will be necessary to update people
		
			keep Dynasty Family pidlink_couple pidlink_parent
			
				duplicates drop pidlink_couple, force
			
			save "$maindir$tmp/Spousal Partner Family ID Updater.dta", replace
			
		* Rename Variables to update the Dynasty information
			
			rename (pidlink_couple pidlink_parent) (pidlink_parent pidlink_couple)
			
			* drop duplicates
			
				duplicates drop pidlink_parent, force
			
			save "$maindir$tmp/Dynasty Updater.dta", replace
			
