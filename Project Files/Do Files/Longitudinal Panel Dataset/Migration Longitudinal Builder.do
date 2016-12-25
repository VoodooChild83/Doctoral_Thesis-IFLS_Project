********************* 							 *******************************

*					 Migration Longitudianal Data 							   *

********************************************************************************
// Quietly do the Year-Share do file to obtain the panel of movements

qui do "$maindir$project/Do Files/Year-Share Migrants.do"

	keep pidlink hhid* movenum stage wave MigYear mg35 mg36 *mov Urb*
	
	* 1) Merge in the household location in the wave years
	
		* Keep only those observations that have no MigYear observations (this 
		* generates a 1-to-1 for merging since these are the waves)
	
		preserve
		
			keep if MigYear==.
	
			merge 1:1 pidlink wave using "$maindir$project/MasterTrack2.dta", update keep(1 3 4 5) keepusing(*mov) nogen
			
			save "$maindir$tmp/Wave Locations.dta", replace
			
		restore
		
		drop if MigYear==.
		
		append using "$maindir$tmp/Wave Locations.dta"
			erase "$maindir$tmp/Wave Locations.dta"
		
		sort pidlink stage
		
	* 2) Append the birth year-age 12 geo locations and clean the duplicates (as 
	* 	 there are those 
	
		append using "$maindir$tmp/Birth-Age12geo.dta", gen(flag_append)
			sort pidlink stage wave
			
		* Drop the duplicates
		
			duplicates tag pidlink stage, gen(Double)
		
			drop if flag_append==1 & Double==1
				drop Double flag_append
				
	* 3) Find the people who have no age 0 data (later I will specifically look to
	*    update only the location of children across time based on parental movements)
	*    and include into MigYear the birthyear - checking that consistency is maintained
	
		preserve
			
			collapseandpreserve (firstnm) stage MigYear wave, by(pidlink) omitstatfromvarlabel
			
			keep if stage!=0
			
			* merge in the birthyear
			
				merge 1:1 pidlink using "$maindir$project/birthyear.dta", keep(1 3) nogen
			
			* Create the birth-year check variable
			
				gen birthyr_check=wave-stage
				
				gen check=birthyr_check-birthyr
				
					// check if there are inconsistencies 
					
					tab check
					
				drop *check
				
			* Replace the MigYear with birth year and then and the age of the person
			
				replace stage=0
				replace MigYear=birthyr
					drop birthyr wave
			
			* save for append
			
				save "$maindir$tmp/Age 0.dta", replace
		
		restore
		
		* append the year of birth to the dataset (later mother's location in that year
		* will update the location for those who are children)
		
		append using "$maindir$tmp/Age 0.dta"
			erase "$maindir$tmp/Age 0.dta"
			
		sort pidlink stage MigYear wave
		
		* Replace in missing MigYear the wave year (as this is the corresponding missing
		* year) and rename MigYear and Stage as Year and Age so that we have proper
		* longitudinal observations
		
		replace MigYear=wave if MigYear==.
			drop wave
			
		rename (stage MigYear) (age year)
				
	* 4) Generate the Dummy variables to identify who moved with the mover 
	
	   /* Use strpos to check if the corresponding household member moved
	      A = Spouse
		  B = Father 
		  C = Mother
		  D = Brother
		  E = Sister
		  F = In-Laws
		  G = Children
		  I = Non Family Member
		  V = Other Family Member	*/
		  
		  * Use reverse and substr to create the new variables from the list in the
		  * for loop
		  
		foreach fam in ASpouse GChildren BFather CMother DBrother ESister {
		
			local code=substr("`fam'",1,1)
			local person=substr("`fam'",2,.)
			
			gen `person'_Mig=strpos(mg36,"`code'") if mg36!=""
			
			recode `person'_Mig (0=.) (1/9=1)
	
		}
		
		drop mg36
		
	* 5) Merge in the couple and spouse pidlink id from the marriage dataset ---------------> Re work this and update to the couple id method remastered
	
		gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
	
		preserve
		
			use "$maindir$tmp/Marriage History Database - Couples only 1 Marriage.dta", clear
			
			keep pidlink pidlink_couple pidlink_spouse
			
			save "$maindir$tmp/Couple Pidlinks.dta", replace
		
		restore
		
		* merge in the pidlinks
		
		merge m:1 pidlink using "$maindir$tmp/Couple Pidlinks.dta", keep (1 3) nogen
			erase "$maindir$tmp/Couple Pidlinks.dta"
		
		order pidlink pidlink2 pidlink_spouse pidlink_couple
		
	* 6) Clean the provincial codes 
	
		* Replace as missing provincial codes that are not correct

		replace provmov=. if provmov<11 | (provmov>21&provmov<31) | (provmov>36&provmov<51) | ///
					(provmov>53&provmov<61) | (provmov>64&provmov<71) | (provmov>76&provmov<81) | /// 
					(provmov>82&provmov<91) | (provmov>91&provmov<94) | provmov>94

