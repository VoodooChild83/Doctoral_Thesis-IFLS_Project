********************* 							 *******************************

*					 Migration Longitudianal Data 							   *

********************************************************************************
// Quietly do the Year-Share do file to obtain the panel of movements

use "$maindir$project/Migration Movements/Year-Share.dta", clear

	rename (MigYear provmov flag_UrbRurmig) (year ProvCode Urbanization)
	
		drop UrbBirth Urb12
		
********************************************************************************	
* 1) Merge in the household location in the wave years
	
		* Keep only those observations that have no MigYear observations (this 
		* generates a 1-to-1 for merging since these are the waves)
	
		preserve
		
			use "$maindir$project/MasterTrack2.dta", clear
			
			keep pidlink sc05 provmov wave birthyr
			
			rename (wave provmov) (year ProvCode)
			
			recode sc05 (2=0 "Rural")(1=1 "Urban"), l(Urbanization) gen(Urbanization)
				drop sc05
			
			* Drop IFLS-EAST
			drop if year==2012
			* Drop missing locations (houshold not observed that wave
			drop if ProvCode==.
		
			save "$maindir$tmp/Wave Locations.dta", replace
			
		restore
		
		append using "$maindir$tmp/Wave Locations.dta"
			erase "$maindir$tmp/Wave Locations.dta"
		
		sort pidlink year
		
		* update age
		
		rename stage age
		
		* drop those who have negative birthyears
		
		drop if year-birthyr<0 & year!=. & birthyr!=.
		
		* drop all children
		
		replace age = year-birthyr
********************************************************************************
* 2) Append the birth year-age 12 geo locations and clean the duplicates (as 
* 	 there are those 
	
		preserve
		
			use "$maindir$tmp/Birth-Age12geo.dta", clear
			
			rename (stage MigYear provmov UrbRurmov) (age year ProvCode Urbanization)
			
			keep pidlink age year ProvCode Urbanization
			
			save "$maindir$tmp/Birth-12 Loc.dta", replace
		
		restore
	
		append using "$maindir$tmp/Birth-12 Loc.dta"
			erase "$maindir$tmp/Birth-12 Loc.dta"
			
			sort pidlink year
		
		*Continue from here: need to drop duplicates related to Wave years and then need to add birthyear and drop the duplicates according to those who already have an age=0 info.
		* Drop the duplicates
		
			collapse (firstnm) birthyr age mg36 (max) movenum* ProvCode Islandmov Family_Move Inter* Intra* Mig Urbanization, by (pidlink year)
			
			drop if year==. | age==.

********************************************************************************
* 3) Find the people who have no age 0 data (later I will specifically look to
*    update only the location of children across time based on parental movements)
*    and include into MigYear the birthyear - checking that consistency is maintained
	
		preserve
			
			collapseandpreserve (firstnm) age year birthyr, by(pidlink) omitstatfromvarlabel
			
			keep if age!=0
			
			* merge in the birthyear
			
				merge 1:1 pidlink using "$maindir$project/birthyear.dta",update replace keep(1 3 4 5) nogen
				
				drop if birthyr==.
			
			* Replace the MigYear with birth year and then and the age of the person
			
				replace age=0
				replace year=birthyr
			
			* save for append
			
				save "$maindir$tmp/Age 0.dta", replace
		
		restore
		
		* append the year of birth to the dataset (later mother's location in that year
		* will update the location for those who are children)
		
		append using "$maindir$tmp/Age 0.dta"
			erase "$maindir$tmp/Age 0.dta"
			
		sort pidlink age

********************************************************************************
* 4) Generate the Dummy variables to identify who moved with the mover 
	
		* Generate the type of family member moves
		
		gen byte Spousal_Only_Move = regexm(mg36,"^A")
		gen byte Children_Only_Move = regexm(mg36,"G")
			replace Spousal_Only_Move = 0 if Family_Move==1
			replace Children_Only_Move = 0 if Family_Move==1
			
		gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
		
		drop mg36
		
********************************************************************************
* 5) Merge in the parental identifier information
	
		preserve
		
			use "$maindir$tmp/Parent Child Link - Master.dta", clear
			
			collapseandpreserve (firstnm) pidlink_father pidlink_mother, by(pidlink) omitstatfromvarlabel
			
			keep if pidlink_mother!=. | pidlink_father!=.
			
			save "$maindir$tmp/Parent Info Merge.dta", replace
		
		restore
		
		merge m:1 pidlink using "$maindir$tmp/Parent Info Merge.dta", keep(1 3) nogen

********************************************************************************
* 6) Expand the data to prepare for merging of parental info to update location histories of children
	
		preserve
		
			keep pidlink* year age birthyr
	
			* Create the last year observed
		
				bys pidlink (year): egen FinalYear=max(year)
		
			* generate the difference between final year and current year
	
				by pidlink: gen Diff=year[_N]-year[1]
		
				bys pidlink (year) : gen last = _n == _N
		
			* Expand
	
				qui sum Diff
				local DiffMax=`r(max)'
			
				expand `DiffMax' if last
				drop Diff last
		
			* Replace all of the copies of the migration and provincial codes (expand makes copies of the last observation)
				gsort pidlink age
		
			*Replace the first of the last variables that has 1 with 0 to identify the original data
			
				by pidlink: replace year=. if _n!=1
				
				by pidlink: replace year=year[_n-1]+1 if year==. & year[_n-1]!=.
				
				by pidlink: drop if year>FinalYear
					drop FinalYear
					
			* Replace birthyr at commencement and make sure that birthyr is completely filled
				
				replace birthyr=year if age==0 & birthyr==.
				
				by pidlink: replace birthyr=birthyr[_n-1] if birthyr==. & birthyr[_n-1]!=.
				
				replace age=year-birthyr
				
				drop birthyr
				
			save "$maindir$tmp/Longitudinal Expansion of Persons in years and age.dta", replace
				
		restore
		
		save "$maindir$tmp/Longitudinal Migration Data.dta", replace
		
		use "$maindir$tmp/Longitudinal Expansion of Persons in years and age.dta", clear
		
		merge 1:1 pidlink year using "$maindir$tmp/Longitudinal Migration Data.dta", keep(1 3) nogen
			drop birthyr
			erase "$maindir$tmp/Longitudinal Migration Data.dta"

********************************************************************************
* 7) Need to Identify when identified children (as they have parental identifiers) become adult to prevent putting parent's information in their adult portion of life
	
		* We will first remove all those who are still in school -> we don't care bout them
		
		preserve
		
			use "$maindir$project/MasterTrack2.dta", clear
			
			keep if flag_LastWave==1
			
			save "$maindir$tmp/MasterTrack.dta", replace
		
		restore
		
		merge m:1 pidlink using "$maindir$tmp/MasterTrack.dta", keepusing(flag_*) keep(1 3) nogen
		drop flag_LastWave flag_ImpAge flag_InKinder-flag_MaxMig
		
		drop if flag_NotInSch!=.| flag_Kinder!=.| flag_Age5GradeSch!=.| flag_Less5Done!=.| flag_InSch!=.
			drop flag_*
			
		* Educational longitudinal history data
		
		preserve
		
			use "$maindir$tmp/Longitudinal Data Set - Education.dta", clear
			sort pidlink year
			
			collapseandpreserve (lastnm) year Grade age birthyr, by(pidlink) omitstatfromvarlabel
			
			* update the year (add 1) for school exit year - the year in the data is school entrance year
			
			replace year = year+1
			replace age = age+1
			
			gen Adult = 1 if age>=15
			
			drop Grade
			
			save "$maindir$tmp/Education Based Age of Adulthood.dta", replace
			
			* Parent-Child linkage data from before to keep all possible children
		
			use "$maindir$tmp/Parent Info Merge.dta", clear
			
			* merge in the schooling information
			
				merge 1:1 pidlink using "$maindir$tmp/MasterTrack.dta", keepusing(birthyr flag_OutSch MaxSchYrs) keep(1 3) nogen
				
				keep if flag_OutSch!=.
					drop flag*
					
			* merge in the Adult information from the previous educational longitudinal history to see who is not known, keeping only those who are not in the educ history
			
				merge 1:1 pidlink using "$maindir$tmp/Education Based Age of Adulthood.dta", keepusing(pidlink) keep(1) nogen
				
			* replace the Schooling years that are 13 with 12
			
				replace MaxSchYrs=12 if MaxSchYrs==13
				
			* Age and Year of school entrance
			
				gen year = birthyr+6+MaxSchYrs if MaxSchYrs!=.
				gen age = year-birthyr
				gen Adult = 1 if age>=15
				
					drop *_father *_mother MaxSchYrs
		
			* append to the previous dataset of identified Adult Children who are adults
			
				append using "$maindir$tmp/Education Based Age of Adulthood.dta"
				
				sort pidlink 
				
			* For those who have not finished school in an Adult state, generate the year at which they are 15 years old
			
				gen year_15 = birthyr+15 if Adult==.
				
				replace year=year_15 if year_15!=.
				
				replace Adult=1 if year-birthyr>=15 & Adult==.
				
				drop birthyr age year_*
				
			save "$maindir$tmp/Education Based Age of Adulthood.dta", replace
		
		restore
		
		merge 1:1 pidlink year using "$maindir$tmp/Education Based Age of Adulthood.dta", keep(1 3) nogen
			erase "$maindir$tmp/Education Based Age of Adulthood.dta"
		
		order pidlink year age Adult
		
		* update the state of adulthood for all identified individuals
			by pidlink (year): replace Adult=Adult[_n-1] if Adult[_n-1]==1 & Adult[_n]==.
			
		* for those who are not identified, but have parental identifiers, locate them
			
			by pidlink: gen flag=1 if _n==_N & Adult!=1 & (pidlink_father!=.|pidlink_mother!=.)
				
			tab age if flag==1
				
			* locate those who are less than 15 years old to drop them from the sample
				
				bys pidlink (year): egen flagMax=max(flag)
				by pidlink: egen ageMax=max(age) if flagMax==1
				
				drop if ageMax<15 & ageMax!=.
					drop ageMax
						
				* for those identified children with no Adult states (flagMax==1) seperate them and construct it
				
					preserve
					
						keep if flagMax==1
						
						merge m:1 pidlink using "$maindir$tmp/MasterTrack.dta", keepusing(MaxSchYrs birthyr) keep(1 3) nogen
				
						* drop duplicates (keep only one observation)
						
							duplicates drop pidlink, force
						
							keep pidlink birthyr MaxSchYrs
						
						* Create the adult age if the Child has schooling years and a non-misisng flag
						
							gen year = birthyr+6+MaxSchYrs if MaxSchYrs!=.
							
						* For those who don't have schooling information, use the survey definition of an adult
						
							replace year = birthyr+15 if year==.
							
						* Create the Adult identifier
						
							gen Adult=1 if year-birthyr>14 & year!=.
							
						* Create the age 15 year for those who have a missing Adult identifier but not a missing year (due to finishing school before being an adult)
						
							gen year_15 = birthyr+15 if Adult==.
							replace year=year_15 if year_15!=.
							replace Adult=1 if year_15!=.
							
						keep pidlink year Adult
						
						save "$maindir$tmp/Education Based Age of Adulthood.dta", replace
					
					restore
			
			* Merge in the updates
				merge 1:1 pidlink year using "$maindir$tmp/Education Based Age of Adulthood.dta",update keep(1 3 4 5) nogen
					erase "$maindir$tmp/Education Based Age of Adulthood.dta"
					
			* update the state of adulthood for all identified individuals
				by pidlink (year): replace Adult=Adult[_n-1] if Adult[_n-1]==1 & Adult[_n]==.
				
			* Drop those children who can not be identified
			
				by pidlink: gen Drop=1 if Adult!=1 & _n==_N & flagMax==1
				
				by pidlink: egen DropMax=max(Drop) 
				
				drop if DropMax==1
					drop Drop* flag*

********************************************************************************
* 8) Seperate the Adult Children from the Adults to consolidate spousal movements (sub data process - married couples merge)

 * Identify all children to drop
 
	by pidlink: egen Children = max(Adult)
	
	preserve
	
		keep if Children ==1
		
		save "$maindir$tmp/Longitudinal Migration Data - Children.dta", replace
	
	restore
	
	drop if Children==1
		drop Children
		
	* Prepare the married couples dataset (multiple and single married)
	
	preserve
	
		use "$maindir$tmp/Marriage History Database - More than 1 Marriage.dta", clear
		
		sort pidlink MarrNum year_start
		
		collapseandpreserve (firstnm) pidlink_spouse year_start year_end, by(pidlink MarrNum) omitstatfromvarlabel
		
		reshape long year@, i(pidlink MarrNum) j(Event) s
		
		gsort pidlink MarrNum -Event
		
		* drop those with no years
		
			by pidlink: gen Miss_year=1 if year==.
			
			drop if Miss_year==1
				drop Miss_year
			
		* Identify the marrige number with missing spousal information both in the starting and ending phase (if link present in one case we can just fill in the other)
		
			gen byte flag=1 if Event=="_start" & pidlink_spouse==. 
				replace flag=1 if Event=="_end" & pidlink_spouse==.
				
			by pidlink: egen byte Tot_Spouse=count(flag) if flag!=.
			
			* drop all those who have missing spouses
			
				drop if Tot_Spouse!=.
					drop Tot_Spouse flag
					
		* find duplicate couples by pidlink year
		
			duplicates tag pidlink year, gen(dup)
			
			by pidlink MarrNum: gen byte flag=1 if dup>0 & _n==_N
			
			keep if dup==0 | (dup>0 & flag==1)
				drop flag
				
			* find those who have multiple marriages with the same spouse identified in the multiple marraiges
				
				by pidlink: gen byte flag=1 if MarrNum[_n]!=MarrNum[_n-1] & pidlink[_n]==pidlink[_n-1] & pidlink_spouse[_n]==pidlink_spouse[_n-1] & dup>0
				
				*update variable to keep the last "_end" year for those who were married for only one year (keep the last spouse)
				by pidlink: replace flag=1 if MarrNum[_n]!=MarrNum[_n-1] & Event[_n]==Event[_n-1] & pidlink[_n]==pidlink[_n-1] & pidlink_spouse[_n]!=pidlink_spouse[_n-1] & year[_n]==year[_n-1] & dup>0
				
				* createa anew variable that catalogues if the same spouse is repeated
				keep if dup==0 | (dup>0 & flag==1)
				drop flag dup
				
				duplicates tag pidlink year, gen(dup_2)
			
				by pidlink: replace dup_2=. if _n!=_N & dup_2>0
				
				keep if dup_2!=.
				drop dup_2
				
			* Flag End date
			
			gen byte flag_end=1 if Event=="_end"
			gen byte flag_start=1 if Event=="_start"
			
			keep pidlink pidlink_spouse year flag_end flag_start
				
		save "$maindir$tmp/Multiple Married Couples.dta", replace
		
		* Repeat for those married only once
		
			use "$maindir/$tmp/Marriage History Database - Couples only 1 Marriage.dta", clear
		
			keep pidlink pidlink_spouse year_*
		
			reshape long year@, i(pidlink) j(Event) s
				gsort pidlink -Event
				
			drop if year==.
	
			gen byte flag_end=1 if Event=="_end"
			gen byte flag_start=1 if Event=="_start"
			
			keep pidlink pidlink_spouse year flag_end flag_start
			
			* make sure we drop duplicates
			
				duplicates tag pidlink year, gen(dup_2)
				
				drop if dup_2>0 & flag_end!=1
					drop dup_2
			
		* append with the multiple marriages
		
		append using "$maindir$tmp/Multiple Married Couples.dta"
			erase "$maindir$tmp/Multiple Married Couples.dta"
			
		sort pidlink year
		
		duplicates drop pidlink year, force
			
		save "$maindir$tmp/Married Couples.dta", replace
		
	restore
	
		* merge in the spousal information
		merge 1:1 pidlink year using "$maindir$tmp/Married Couples.dta", keep(1 3) nogen
		
	
		* fill in the spousal information according to the condition that flag_end stops the fill in
		by pidlink: replace pidlink_spouse=pidlink_spouse[_n-1] if pidlink_spouse[_n-1]!=. & flag_end[_n-1]!=1 & flag_end[_n]==.
			drop flag_end

		* merge in spousal information for the children dataset
		
		preserve
		
			use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
			
			merge 1:1 pidlink year using "$maindir$tmp/Married Couples.dta", keep(1 3) nogen
				erase "$maindir$tmp/Married Couples.dta"
				
			* fill in the spousal information according to the condition that flag_end stops the fill in
			by pidlink: replace pidlink_spouse=pidlink_spouse[_n-1] if pidlink_spouse[_n-1]!=. & flag_end[_n-1]!=1 & flag_end[_n]==.
				drop flag_end
				
			order pidlink*
			
			save "$maindir$tmp/Longitudinal Migration Data - Children.dta", replace
		
		restore
	
	order pidlink*
					
********************************************************************************	
* 9) Update the location of spouses 

	* Update partner location at the start of marriage dates
	
	preserve
	
		* Reappend the children's dataset
		append using "$maindir$tmp/Longitudinal Migration Data - Children.dta"
	
		* Update the Island information
	
			replace Islandmov=1 if (ProvCode>=11 & ProvCode<=19)
			
			replace Islandmov= 2 if (ProvCode>=31 & ProvCode<=35)
			replace Islandmov= 3 if (ProvCode>=51 & ProvCode<=53)
			replace Islandmov= 4 if (ProvCode>=61 & ProvCode<=64)
			replace Islandmov= 5 if (ProvCode>=71 & ProvCode<=74)
			replace Islandmov= 6 if ProvCode==81 
			replace Islandmov= 7 if ProvCode==91
			
		* Update all the Location info
			sort pidlink year
	
			foreach Var of varlist ProvCode Islandmov Urbanization{
	
				by pidlink: replace `Var'=`Var'[_n-1] if pidlink[_n]==pidlink[_n-1] & `Var'[_n]==. & `Var'[_n-1]!=.
		
			}
			
		keep pidlink pidlink2 year ProvCode Islandmov Urbanization flag_start
		
		keep if flag_start==1
		
		save "$maindir$tmp/Marriage Start Location.dta", replace
		
	restore
	
	* Spousal info from Children dataset
	preserve
	
		use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
		
		* merge in the information of the location at marriage start
		
			merge 1:1 pidlink year using "$maindir$tmp/Marriage Start Location.dta", update keepusing(ProvCode Islandmov Urbanization) keep(1 3 4 5) nogen
		
		keep if pidlink_spouse!=.
	
		drop pidlink_spouse
		
		rename pidlink2 pidlink_spouse
		
		foreach Var of varlist ProvCode Islandmov Urbanization InterIsland_FamilyMig IntraIsland_FamilyMig Spousal_Only_Move flag_start {
		
			rename `Var' `Var'_spouse
		}
		
		keep year *spouse
		
		save "$maindir$tmp/Children Spouse Info.dta", replace
			
	restore
	
	*Spousal info from Adult dataset
	preserve
	
		* merge in the information of the location at marriage start
		
			merge 1:1 pidlink year using "$maindir$tmp/Marriage Start Location.dta", update keepusing(ProvCode Islandmov Urbanization) keep(1 3 4 5) nogen
				erase "$maindir$tmp/Marriage Start Location.dta"
	
		keep if pidlink_spouse!=.
	
		drop pidlink_spouse
		
		rename pidlink2 pidlink_spouse
		
		foreach Var of varlist ProvCode Islandmov Urbanization InterIsland_FamilyMig IntraIsland_FamilyMig Spousal_Only_Move flag_start {
		
			rename `Var' `Var'_spouse
		}
		
		keep year *spouse
	
		append using "$maindir$tmp/Children Spouse Info.dta"
			erase "$maindir$tmp/Children Spouse Info.dta"
		
		save "$maindir$tmp/Adult Spouse Info.dta", replace
		
	restore
	
	* Reappend the children's dataset
	append using "$maindir$tmp/Longitudinal Migration Data - Children.dta"
	
	* Merge in the spousal information
	merge m:1 pidlink_spouse year using "$maindir$tmp/Adult Spouse Info.dta", keep(1 3) nogen
		erase "$maindir$tmp/Adult Spouse Info.dta"
	
	* Update the Prov Code, Urbanization, Island Code if the Spouse has moved and the person doesn't have information
	
	foreach Var of varlist ProvCode Islandmov Urbanization{
	
		replace `Var' = `Var'_spouse if (Spousal_Only_Move==.|Spousal_Only_Move==0) & Spousal_Only_Move_spouse==1 & `Var'==.
		replace `Var' = `Var'_spouse if (InterIsland_FamilyMig==.|InterIsland_FamilyMig==0) & InterIsland_FamilyMig_spouse==1 & `Var'==.
		replace `Var' = `Var'_spouse if (IntraIsland_FamilyMig==.|IntraIsland_FamilyMig==0) & IntraIsland_FamilyMig_spouse==1 & `Var'==.
		replace `Var' = `Var'_spouse if flag_start==1 & `Var'==.
	
	}
	
	drop Spousal_Only_Move ProvCode_spouse-flag_start_spouse movenum* Mig flag_start
	
	compress
	
********************************************************************************
* 10) Update non-Children data set with parental locations locations

	preserve
	
		keep if Children==1
		
		save "$maindir$tmp/Longitudinal Migration Data - Children.dta", replace

	restore
	
	drop if Children==1
		drop Children 

	* Update the Island information
	
	replace Islandmov=1 if (ProvCode>=11 & ProvCode<=19)
			
			replace Islandmov= 2 if (ProvCode>=31 & ProvCode<=35)
			replace Islandmov= 3 if (ProvCode>=51 & ProvCode<=53)
			replace Islandmov= 4 if (ProvCode>=61 & ProvCode<=64)
			replace Islandmov= 5 if (ProvCode>=71 & ProvCode<=74)
			replace Islandmov= 6 if ProvCode==81 
			replace Islandmov= 7 if ProvCode==91
			
	* Update all the Location info
	sort pidlink year
	
	foreach Var of varlist ProvCode Islandmov Urbanization{
	
		by pidlink: replace `Var'=`Var'[_n-1] if pidlink[_n]==pidlink[_n-1] & `Var'[_n]==. & `Var'[_n-1]!=.
		
	}
	
	compress
	
	* Update migration dummies
	by pidlink: replace InterIslandMig = (pidlink[_n]==pidlink[_n-1] & Islandmov[_n]!=Islandmov[_n-1] & Islandmov[_n-1]!=.)
		replace InterIslandMig=. if ProvCode==. & Islandmov==.
	by pidlink: replace IntraIslandMig = (pidlink[_n]==pidlink[_n-1] & Islandmov[_n]==Islandmov[_n-1] & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n-1]!=. & Islandmov[_n-1]!=.)
		replace IntraIslandMig=. if ProvCode==. & Islandmov==.
	replace InterIsland_FamilyMig = (Family_Move==1 & InterIslandMig==1)
		replace InterIsland_FamilyMig = . if ProvCode==. & Islandmov==.
	replace IntraIsland_FamilyMig = (Family_Move==1 & IntraIslandMig==1)
		replace IntraIsland_FamilyMig = . if ProvCode==. & Islandmov==.
		
		
********************************************************************************	
* 11) Children's Dataset Parental Locations
		
	* Adult Data set
	
	foreach Parent in father mother{
		
		preserve
			
			drop pidlink_father pidlink_mother
			
			drop if pidlink2==.
			
			rename pidlink2 pidlink_`Parent'
		
			foreach Var of varlist ProvCode Islandmov Urbanization Family_Move InterIslandMig InterIsland_FamilyMig IntraIslandMig IntraIsland_FamilyMig Children_Only_Move{
		
				rename `Var' `Var'_`Parent'
			}
		
			keep year *_`Parent'
		
			save "$maindir$tmp/`Parent'.dta", replace
	
		restore

	}
	
* First Round: Update parental location for those Child-Adults whose parents are in the Adult dataset
	
	preserve
	
		use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
		
		* Keep only the data for childhood
		keep if Adult==.
		
		sort pidlink year
		
		foreach Parent in father mother{
		
			merge m:1 pidlink_`Parent' year using "$maindir$tmp/`Parent'.dta", keepusing(*_`Parent') keep(1 3) gen(merge_`Parent')
				erase "$maindir$tmp/`Parent'.dta"
		
		}
		
		* Max of the merge variable (in case there are variable merges wthin a pidlink)
		bys pidlink (year): egen MergeMax_mother=max(merge_mother)
		by pidlink: egen MergeMax_father=max(merge_father)
		
		replace merge_mother=MergeMax_mother
		replace merge_father=MergeMax_father
			drop MergeMax_*
			
		save "$maindir$tmp/Temp Round 1.dta", replace
		
		keep if (merge_mother==1 & merge_father==1)
		drop ProvCode_father-Children_Only_Move_father ProvCode_mother-Children_Only_Move_mother
		
		save "$maindir$tmp/Children of Children.dta", replace
		
		use "$maindir$tmp/Temp Round 1.dta", clear
			
		keep if (merge_mother==3|merge_father==3)

		* Adjust the location information to account for parental locations
	
		foreach Var of varlist ProvCode Islandmov Urbanization{
		
			display("`Var'")
		
			display("Age 0")
				replace `Var' = `Var'_mother if age==0 & `Var'==. & Children_Only_Move_mother!=1 & Family_Move_mother!=1 & InterIslandMig_mother!=1 & IntraIslandMig_mother!=1 & `Var'_mother!=.
				replace `Var' = `Var'_father if age==0 & `Var'==. & Children_Only_Move_father!=1 & Family_Move_father!=1 & InterIslandMig_father!=1 & IntraIslandMig_father!=1 & `Var'_father!=.
			
				display("if one of parents move with the children")
				replace `Var' = `Var'_mother if age==0 & `Var'==. & Children_Only_Move_mother==1 & `Var'_mother!=.
				replace `Var' = `Var'_father if age==0 & `Var'==. & Children_Only_Move_father==1 & `Var'_father!=.
				
				display("if there is a family move")
				replace `Var' = `Var'_mother if age==0 & `Var'==. & Family_Move_mother==1 & `Var'_mother!=.
				replace `Var' = `Var'_father if age==0 & `Var'==. & Family_Move_father==1 & `Var'_father!=.	
				
			display("Family Migration")
				replace `Var' = `Var'_mother if ((InterIsland_FamilyMig_mother==1 & InterIsland_FamilyMig_father==.) | (IntraIsland_FamilyMig_mother==1 & IntraIsland_FamilyMig_father==.)) & `Var'==. & `Var'_mother!=.
				replace `Var' = `Var'_father if ((InterIsland_FamilyMig_father==1 & InterIsland_FamilyMig_mother==.) | (IntraIsland_FamilyMig_father==1 & IntraIsland_FamilyMig_mother==.)) & `Var'==. & `Var'_father!=.
			
				replace `Var' = `Var'_mother if InterIsland_FamilyMig_father==InterIsland_FamilyMig_mother & InterIsland_FamilyMig_mother==1 & `Var'==. & `Var'_mother!=.
				replace `Var' = `Var'_father if IntraIsland_FamilyMig_father==IntraIsland_FamilyMig_mother & IntraIsland_FamilyMig_father==1 & `Var'==. & `Var'_father!=.
				
				replace `Var' = `Var'_mother if `Var'==. & Family_Move_mother==1 & `Var'_mother!=.
				replace `Var' = `Var'_father if `Var'==. & Family_Move_father==1 & `Var'_father!=.	
				
			display("Child Only Migrations")
				replace `Var' = `Var'_mother if Children_Only_Move_mother==1 & `Var'==. & `Var'_mother!=.
				replace `Var' = `Var'_father if Children_Only_Move_father==1 & `Var'==. & `Var'_father!=.
			
			display("The location of the parent as long as the parent has not undertaken a singular migration")
				replace `Var' = `Var'_mother if `Var'==. & Children_Only_Move_mother!=1 & Family_Move_mother!=1 & InterIslandMig_mother!=1 & IntraIslandMig_mother!=1 & `Var'_mother!=.
				replace `Var' = `Var'_father if `Var'==. & Children_Only_Move_father!=1 & Family_Move_father!=1 & InterIslandMig_father!=1 & IntraIslandMig_father!=1 & `Var'_father!=.
				
			
		}
	
		* fill in the remaining codes
		
			* Update the Island information
	
			replace Islandmov=1 if (ProvCode>=11 & ProvCode<=19)
			
			replace Islandmov= 2 if (ProvCode>=31 & ProvCode<=35)
			replace Islandmov= 3 if (ProvCode>=51 & ProvCode<=53)
			replace Islandmov= 4 if (ProvCode>=61 & ProvCode<=64)
			replace Islandmov= 5 if (ProvCode>=71 & ProvCode<=74)
			replace Islandmov= 6 if ProvCode==81 
			replace Islandmov= 7 if ProvCode==91
			
			* Update all the Location info
			sort pidlink year
	
			foreach Var of varlist ProvCode Islandmov Urbanization{
	
				by pidlink: replace `Var'=`Var'[_n-1] if pidlink[_n]==pidlink[_n-1] & `Var'[_n]==. & `Var'[_n-1]!=.
		
			}
			
		* Update the migration dummy codes
			
			by pidlink: replace InterIslandMig=1 if InterIslandMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] &  ///
													((InterIslandMig_mother==1 & Children_Only_Move_mother==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) | ///
													 (InterIslandMig_father==1 & Children_Only_Move_father==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) )
													 
			by pidlink: replace IntraIslandMig=1 if IntraIslandMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] &  ///
													((IntraIslandMig_mother==1 & Children_Only_Move_mother==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) | ///
													 (IntraIslandMig_father==1 & Children_Only_Move_father==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) )
													 
			by pidlink: replace InterIsland_FamilyMig=1 if InterIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] &  ///
														   ((InterIsland_FamilyMig_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) | ///
														    (InterIsland_FamilyMig_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) )
			
			by pidlink: replace IntraIsland_FamilyMig=1 if IntraIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & /// 
														   ((IntraIsland_FamilyMig_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) | ///
														    (IntraIsland_FamilyMig_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) )
		
			by pidlink: replace InterIsland_FamilyMig=1 if InterIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & ///
														  ((Family_Move_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) | ///
														   (Family_Move_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) )
				   
			by pidlink: replace IntraIsland_FamilyMig=1 if IntraIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] &  ///  
														  ((Family_Move_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) | ///
														   (Family_Move_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) )
		
		foreach Var in InterIslandMig IntraIslandMig InterIsland_FamilyMig IntraIsland_FamilyMig{
		
			replace `Var'=0 if `Var'==. & ProvCode!=.
			replace `Var'=1 if "`Var'"=="IntraIslandMig" & IntraIsland_FamilyMig==1
			replace `Var'=1 if "`Var'"=="InterIslandMig" & InterIsland_FamilyMig==1
			
		}
		
		drop ProvCode_father-Children_Only_Move_father ProvCode_mother-Children_Only_Move_mother
		
		* Update the original children file
		
			save "$maindir$tmp/Temp Round 1.dta", replace
		
			use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
		
			keep if Adult==1
			
			append using "$maindir$tmp/Children of Children.dta"
				erase "$maindir$tmp/Children of Children.dta"
		
			append using "$maindir$tmp/Temp Round 1.dta"
				erase "$maindir$tmp/Temp Round 1.dta"
			
			* Identify those who were updated based on being children of those in the adult data set
				bys pidlink (year): egen MergeMax_mother=max(merge_mother)
				by pidlink: egen MergeMax_father=max(merge_father)
				
				replace merge_mother=MergeMax_mother
				replace merge_father=MergeMax_father
					drop MergeMax_*
		
		save "$maindir$tmp/Longitudinal Migration Data - Children.dta", replace
	
	restore	
	
	
* Round 2: Update parental location for those Children whose parents are in the Child dataset
	
	preserve
	
		use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
		
		keep if merge_father==3 | merge_mother==3
	
		* fathers
		
		drop pidlink_*
		
		drop if pidlink2==.
		
		rename pidlink2 pidlink_father
		
		foreach Var of varlist ProvCode Islandmov Urbanization Family_Move InterIslandMig InterIsland_FamilyMig IntraIslandMig IntraIsland_FamilyMig Children_Only_Move {
		
				rename `Var' `Var'_father
			}
			
		keep year *_father
			drop merge_father
		
		save "$maindir$tmp/father.dta", replace
		
		* mothers
		
		use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
		
		keep if merge_father==3 | merge_mother==3
		
		drop pidlink_*
		
		drop if pidlink2==.
		
		rename pidlink2 pidlink_mother
		
		foreach Var of varlist ProvCode Islandmov Urbanization Family_Move InterIslandMig InterIsland_FamilyMig IntraIslandMig IntraIsland_FamilyMig Children_Only_Move {
		
				rename `Var' `Var'_mother
			}
			
		keep year *_mother
			drop merge_mother
		
		save "$maindir$tmp/mother.dta", replace
	
	restore
	
	* Update the child dataset with parental locations
	
	preserve
	
		use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
		
		* Keep only the data for childhood
		keep if Adult==. & merge_father==1 & merge_mother==1
			drop merge_*
		
		foreach Parent in father mother{
		
			merge m:1 pidlink_`Parent' year using "$maindir$tmp/`Parent'.dta", keepusing(*_`Parent') keep(1 3) gen(merge_`Parent')
				erase "$maindir$tmp/`Parent'.dta"
		
		}
		
		* Max of the merge variable (in case there are variable merges wthin a pidlink)
		bys pidlink (year): egen MergeMax_mother=max(merge_mother)
		by pidlink: egen MergeMax_father=max(merge_father)
		
		replace merge_mother=MergeMax_mother
		replace merge_father=MergeMax_father
			drop MergeMax_*

		* Adjust the location information to account for parental locations
		
		foreach Var of varlist ProvCode Islandmov Urbanization{
		
			display("`Var'")
		
			display("Age 0")
				replace `Var' = `Var'_mother if age==0 & `Var'==. & Children_Only_Move_mother!=1 & Family_Move_mother!=1 & InterIslandMig_mother!=1 & IntraIslandMig_mother!=1 & `Var'_mother!=.
				replace `Var' = `Var'_father if age==0 & `Var'==. & Children_Only_Move_father!=1 & Family_Move_father!=1 & InterIslandMig_father!=1 & IntraIslandMig_father!=1 & `Var'_father!=.
			
				display("if one of parents move with the children")
				replace `Var' = `Var'_mother if age==0 & `Var'==. & Children_Only_Move_mother==1 & `Var'_mother!=.
				replace `Var' = `Var'_father if age==0 & `Var'==. & Children_Only_Move_father==1 & `Var'_father!=.
				
				display("if there is a family move")
				replace `Var' = `Var'_mother if age==0 & `Var'==. & Family_Move_mother==1 & `Var'_mother!=.
				replace `Var' = `Var'_father if age==0 & `Var'==. & Family_Move_father==1 & `Var'_father!=.	
				
			display("Family Migration")
				replace `Var' = `Var'_mother if ((InterIsland_FamilyMig_mother==1 & InterIsland_FamilyMig_father==.) | (IntraIsland_FamilyMig_mother==1 & IntraIsland_FamilyMig_father==.)) & `Var'==. & `Var'_mother!=.
				replace `Var' = `Var'_father if ((InterIsland_FamilyMig_father==1 & InterIsland_FamilyMig_mother==.) | (IntraIsland_FamilyMig_father==1 & IntraIsland_FamilyMig_mother==.)) & `Var'==. & `Var'_father!=.
			
				replace `Var' = `Var'_mother if InterIsland_FamilyMig_father==InterIsland_FamilyMig_mother & InterIsland_FamilyMig_mother==1 & `Var'==. & `Var'_mother!=.
				replace `Var' = `Var'_father if IntraIsland_FamilyMig_father==IntraIsland_FamilyMig_mother & IntraIsland_FamilyMig_father==1 & `Var'==. & `Var'_father!=.
				
				replace `Var' = `Var'_mother if `Var'==. & Family_Move_mother==1 & `Var'_mother!=.
				replace `Var' = `Var'_father if `Var'==. & Family_Move_father==1 & `Var'_father!=.	
				
			display("Child Only Migrations")
				replace `Var' = `Var'_mother if Children_Only_Move_mother==1 & `Var'==. & `Var'_mother!=.
				replace `Var' = `Var'_father if Children_Only_Move_father==1 & `Var'==. & `Var'_father!=.
			
			display("The location of the parent as long as the parent has not undertaken a singular migration")
				replace `Var' = `Var'_mother if `Var'==. & Children_Only_Move_mother!=1 & Family_Move_mother!=1 & InterIslandMig_mother!=1 & IntraIslandMig_mother!=1 & `Var'_mother!=.
				replace `Var' = `Var'_father if `Var'==. & Children_Only_Move_father!=1 & Family_Move_father!=1 & InterIslandMig_father!=1 & IntraIslandMig_father!=1 & `Var'_father!=.
				
		}
		
		* fill in the remaining codes
		
			* Update the Island information
	
			replace Islandmov=1 if (ProvCode>=11 & ProvCode<=19)
			
			replace Islandmov= 2 if (ProvCode>=31 & ProvCode<=35)
			replace Islandmov= 3 if (ProvCode>=51 & ProvCode<=53)
			replace Islandmov= 4 if (ProvCode>=61 & ProvCode<=64)
			replace Islandmov= 5 if (ProvCode>=71 & ProvCode<=74)
			replace Islandmov= 6 if ProvCode==81 
			replace Islandmov= 7 if ProvCode==91
			
			* Update all the Location info
			sort pidlink year
	
			foreach Var of varlist ProvCode Islandmov Urbanization{
	
				by pidlink: replace `Var'=`Var'[_n-1] if pidlink[_n]==pidlink[_n-1] & `Var'[_n]==. & `Var'[_n-1]!=.
		
			}
			
			* Update the migration dummy codes
			
			by pidlink: replace InterIslandMig=1 if InterIslandMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & ///
													((InterIslandMig_mother==1 & Children_Only_Move_mother==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) | ///
													 (InterIslandMig_father==1 & Children_Only_Move_father==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) )
													 
			by pidlink: replace IntraIslandMig=1 if IntraIslandMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & ///
													((IntraIslandMig_mother==1 & Children_Only_Move_mother==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) | ///
													 (IntraIslandMig_father==1 & Children_Only_Move_father==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) )
													 
			by pidlink: replace InterIsland_FamilyMig=1 if InterIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & ///
														   ((InterIsland_FamilyMig_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) | ///
														    (InterIsland_FamilyMig_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) )
			
			by pidlink: replace IntraIsland_FamilyMig=1 if IntraIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & /// 
														   ((IntraIsland_FamilyMig_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) | ///
														    (IntraIsland_FamilyMig_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) )
		
			by pidlink: replace InterIsland_FamilyMig=1 if InterIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & ///
														  ((Family_Move_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) | ///
														   (Family_Move_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) )
				   
			by pidlink: replace IntraIsland_FamilyMig=1 if IntraIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & ///  
														  ((Family_Move_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) | ///
														   (Family_Move_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) )
		
		foreach Var in InterIslandMig IntraIslandMig InterIsland_FamilyMig IntraIsland_FamilyMig{
		
			replace `Var'=0 if `Var'==. & ProvCode!=.
			replace `Var'=1 if "`Var'"=="IntraIslandMig" & IntraIsland_FamilyMig==1
			replace `Var'=1 if "`Var'"=="InterIslandMig" & InterIsland_FamilyMig==1
			
		}
		
		drop ProvCode_father-Children_Only_Move_father ProvCode_mother-Children_Only_Move_mother
		
		save "$maindir$tmp/Updated Children.dta", replace
		
		* Update the original children file with the new info
		
			use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
		
			keep if Adult==1 & merge_father==1 & merge_mother==1
		
			append using "$maindir$tmp/Updated Children.dta"
			
			* Identify those who were updated based on being children of those in the adult data set
				bys pidlink (year): egen MergeMax_mother=max(merge_mother)
				by pidlink: egen MergeMax_father=max(merge_father)
				
				replace merge_mother=MergeMax_mother
				replace merge_father=MergeMax_father
					drop MergeMax_*
					
			save "$maindir$tmp/Updated Children.dta", replace
			
		* Update the original children file to account for the updated children
		
			use "$maindir$tmp/Longitudinal Migration Data - Children.dta", clear
			
			drop if merge_father==1 & merge_mother==1
			
			append using "$maindir$tmp/Updated Children.dta"
				erase "$maindir$tmp/Updated Children.dta"
				
			drop merge_*
			
		* Fill in the location information one more time
		
			* Update the Island information
	
			replace Islandmov=1 if (ProvCode>=11 & ProvCode<=19)
			
			replace Islandmov= 2 if (ProvCode>=31 & ProvCode<=35)
			replace Islandmov= 3 if (ProvCode>=51 & ProvCode<=53)
			replace Islandmov= 4 if (ProvCode>=61 & ProvCode<=64)
			replace Islandmov= 5 if (ProvCode>=71 & ProvCode<=74)
			replace Islandmov= 6 if ProvCode==81 
			replace Islandmov= 7 if ProvCode==91
			
			* Update all the Location info
			sort pidlink year
	
			foreach Var of varlist ProvCode Islandmov Urbanization{
	
				by pidlink: replace `Var'=`Var'[_n-1] if pidlink[_n]==pidlink[_n-1] & `Var'[_n]==. & `Var'[_n-1]!=.
		
			}
			
			* Update migration dummies of Adult Children
			by pidlink: replace InterIslandMig=1 if InterIslandMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & ProvCode[_n-1]!=. & Islandmov[_n-1]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & Adult==1
			by pidlink: replace IntraIslandMig=1 if IntraIslandMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & ProvCode[_n-1]!=. & Islandmov[_n-1]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & Adult==1
			replace InterIsland_FamilyMig = 1 if Family_Move==1 & InterIslandMig==1 & Adult==1
			replace IntraIsland_FamilyMig = 1 if Family_Move==1 & IntraIslandMig==1 & Adult==1
			
			foreach Var in InterIslandMig IntraIslandMig InterIsland_FamilyMig IntraIsland_FamilyMig{
		
				replace `Var'=0 if `Var'==. & ProvCode!=.
				replace `Var'=1 if "`Var'"=="IntraIslandMig" & IntraIsland_FamilyMig==1
				replace `Var'=1 if "`Var'"=="InterIslandMig" & InterIsland_FamilyMig==1
			
			}
			
		compress
		
		save "$maindir$tmp/Longitudinal Migration Data - Children.dta", replace
	
	restore	
	
********************************************************************************	
* 12) Reappend the Child dataset to create the final consolidated set

	append using "$maindir$tmp/Longitudinal Migration Data - Children.dta"
		erase "$maindir$tmp/Longitudinal Migration Data - Children.dta"
		erase "$maindir$tmp/Parent Info Merge.dta"

	*drop Children_Only_Move Adult
	
save "$maindir$tmp/Longitudinal Expansion of Persons in years and age.dta", replace
