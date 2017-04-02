// Creation of the Dataset

use "$maindir$tmp/Identified Children.dta", clear

drop dup* *_Avail* flag_*

********************************************************************************
/* Merge in the marriage year to get the start date of the parent's creation of
   the household
*/

preserve

	use "$maindir$tmp/Marriage History Database - Couples only 1 Marriage.dta", clear
	
	foreach parent in father mother{
	
		gen double pidlink_`parent' = pidlink2
		gen year_start_`parent' = year_start
		gen year_end_`parent' = year_end
	
	}
	
	save "$maindir$tmp/Marriage - Dynasty Dataset.dta", replace

restore

* merge in the marriage information

	foreach parent in father mother{
	
		merge m:1 pidlink_`parent' using "$maindir$tmp/Marriage - Dynasty Dataset.dta", keepusing(*_`parent') keep(1 3) gen(merge_`parent')
	
	}
	erase "$maindir$tmp/Marriage - Dynasty Dataset.dta"
	
* Keep only those where both parents are observed as merged in and where both start years are the same

	keep if merge_father==merge_mother & merge_father==3
	drop merge*
	
	drop if year_start_father!=year_start_mother
	
	* keep only one of the couple's start/end years
	drop year_start_mother year_end_mother
	rename (year_start_father year_end_father) (year_start year_end)
	
* Check if the person's age is younger than 18 years old when the parents ended marriage

	gen flag_YoungMarrEnd = 1 if year_end-birthyr<18 & year_end!=.
	
	drop if flag_YoungMarrEnd==1
	drop flag_YoungMarrEnd
	
* Reshape the data long to get the 
	
	reshape long year@, i(pidlink) j(Event) s
	
	gsort pidlink -Event
	
* Merge in th last observed wave year

preserve

	use "$maindir$project/MasterTrack2.dta", clear
	
	keep if flag_LastWave==1
	
	keep pidlink wave flag_OutSch sex
	
	save "$maindir$tmp/LastWave.dta", replace

restore

	merge m:1 pidlink using "$maindir$tmp/LastWave.dta",update keep(1 3 4 5) nogen
		erase "$maindir$tmp/LastWave.dta"
	
* Append wave in year

preserve

	keep pidlink Event wave
	
	rename wave year
	
	replace Event = "_a_last_wave"
	
	duplicates drop pidlink, force
	
	save "$maindir$tmp/Last Wave.dta", replace

restore

	drop wave
	
	append using "$maindir$tmp/Last Wave.dta"
		erase "$maindir$tmp/Last Wave.dta"
	
	gsort pidlink -Event
	
* There are some households where the child was born before the parents were married. We will say that the household started when the child was born

	replace year=birthyr if birthyr<year & Event=="_start"
	
* Correct the last year if the marriage ended after the last wave year

	by pidlink: egen yearMax=max(year)
	
	gen flag=1 if yearMax>year & Event=="_a_last_wave"
		by pidlink: egen flagMax=max(flag)
	replace year=yearMax if Event=="_a_last_wave" & flag==1
		replace year=. if Event=="_end" & flagMax==1
		
		drop yearMax flag flagMax
	
* Prepare for expansion of dataset

	by pidlink: egen First_Year = min(year)
	by pidlink: egen Last_Year = max(year)
	
	* generate the difference between final year and current year
	
		by pidlink: gen Diff=year[_N]-year[1]
		
		bys pidlink (year) : gen last = _n == _N
		
	* Expand
	
		qui sum Diff
		local DiffMax=`r(max)'
			
		expand `DiffMax' if last
		drop Diff
	
	* Fill in the years
			
		bys pidlink (year): replace year=. if _n!=1
		
		by pidlink: replace year=year[_n-1]+1 if year[_n]==. & year[_n-1]!=.
		
		drop Event last
		
	* Remove years if they fall out of bounds
	
		by pidlink: replace year=. if year>Last_Year
		drop if year==.
			drop *_Year
			
		order pidlink pidlink2 pidlink_* 
		
		* Make sure that no values from the expand are missing
		
			foreach Var of varlist pidlink2 pidlink_* birthyr{
			
				by pidlink: replace `Var'=`Var'[_n-1] if `Var'==. & `Var'[_n-1]!=.
			
			}
			
********************************************************************************
* Merge in the educational histories into the dataset

preserve
	qui do "$maindir$project$Do/Education/Childrens Education - Longitudinal Dataset for Master Data.do"
restore

merge 1:1 pidlink year using "$maindir$tmp/Longitudinal Data Set - Education.dta", keep(1 3) nogen
	erase "$maindir$tmp/Longitudinal Data Set - Education.dta"

	drop age_* UrbBirth Urb12 *max *min *_Mover HiLvl LowLvl MaxSchYrs_2 d_GrRep
		
* Update Dynasty variable to find out who is missing
	
	gsort pidlink -Dynasty
	by pidlink: replace Dynasty=Dynasty[_n-1] if Dynasty==. & Dynasty[_n-1]!=.
	
	sort pidlink year
	
* Keep in a seperate file those who have their educational history information

	preserve
	
		keep if Dynasty==.
		
		qui do "$maindir$project$Do/Longitudinal Data for estimation - Missing Education Histroy.do"
	
	restore
	
	drop if Dynasty==.
	
	append using "$maindir$tmp/Education History Missing.dta"
		erase "$maindir$tmp/Education History Missing.dta"
		
	sort pidlink year
	
	* Update Age
	
	
	foreach Var of varlist age{
			
		by pidlink: replace `Var'=`Var'[_n-1]+1 if `Var'==. & `Var'[_n-1]!=.
			
	}
	
********************************************************************************
* Merge in the Child's current location from the migration data set

	merge 1:1 pidlink year using "$maindir$tmp/Longitudinal Expansion of Persons in years and age.dta", keepusing(ProvCode Urbanization Islandmov InterIsland* IntraIsland*) keep(1 3 4 5) update replace
	
	bys pidlink (year): egen MergeMax=max(_merge)
	replace _merge=MergeMax
		drop MergeMax
	
	* Some people are not in the adult data set associated with migrations because there were not adults, but they are still viable for use. Update their locations here
	
		preserve
		
			use "$maindir$tmp/Longitudinal Expansion of Persons in years and age.dta", clear
			
			drop pidlink_father pidlink_mother
			
			drop if pidlink2==.
			
			foreach Parent in father mother{
			
				gen long pidlink_`Parent' = pidlink2
		
				foreach Var in ProvCode Islandmov Urbanization Family_Move InterIslandMig InterIsland_FamilyMig IntraIslandMig IntraIsland_FamilyMig Children_Only_Move{
		
				gen byte `Var'_`Parent'=`Var'
					
				}
			}
		
			keep year *_father *_mother
		
			save "$maindir$tmp/Parental Mig.dta", replace
	
		restore
		
	
		* Update children's location for those who are missing location data

			preserve
		
				keep if _merge==1
				
				foreach Parent in father mother{
				
					merge 1:1 pidlink_`Parent' year using "$maindir$tmp/Parental Mig.dta", keepusing(*_`Parent') keep(1 3) gen(merge_`Parent')
				
				}
					erase "$maindir$tmp/Parental Mig.dta"
				
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
						replace `Var' = `Var'_mother if ((InterIsland_FamilyMig_mother==1 & InterIsland_FamilyMig_father==.) | (IntraIsland_FamilyMig_mother==1 & IntraIsland_FamilyMig_father==.)) & `Var'==. & `Var'_mother!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
						replace `Var' = `Var'_father if ((InterIsland_FamilyMig_father==1 & InterIsland_FamilyMig_mother==.) | (IntraIsland_FamilyMig_father==1 & IntraIsland_FamilyMig_mother==.)) & `Var'==. & `Var'_father!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
			
						replace `Var' = `Var'_mother if InterIsland_FamilyMig_father==InterIsland_FamilyMig_mother & InterIsland_FamilyMig_mother==1 & `Var'==. & `Var'_mother!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
						replace `Var' = `Var'_father if IntraIsland_FamilyMig_father==IntraIsland_FamilyMig_mother & IntraIsland_FamilyMig_father==1 & `Var'==. & `Var'_father!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
				
						replace `Var' = `Var'_mother if `Var'==. & Family_Move_mother==1 & `Var'_mother!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
						replace `Var' = `Var'_father if `Var'==. & Family_Move_father==1 & `Var'_father!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
				
					display("Child Only Migrations")
						replace `Var' = `Var'_mother if Children_Only_Move_mother==1 & `Var'==. & `Var'_mother!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
						replace `Var' = `Var'_father if Children_Only_Move_father==1 & `Var'==. & `Var'_father!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
			
					display("The location of the parent as long as the parent has not undertaken a singular migration")
						replace `Var' = `Var'_mother if `Var'==. & Children_Only_Move_mother!=1 & Family_Move_mother!=1 & InterIslandMig_mother!=1 & IntraIslandMig_mother!=1 & `Var'_mother!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
						replace `Var' = `Var'_father if `Var'==. & Children_Only_Move_father!=1 & Family_Move_father!=1 & InterIslandMig_father!=1 & IntraIslandMig_father!=1 & `Var'_father!=. & ((age!=. & age<15)|(age!=. & Grade!=.))
				
			
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
			
					* Update the migration dummy codes <-- May need to update this to be independent of parents since some children seem to move when the parents don't (Inter/IntraIslandMig to change)
			
					by pidlink: replace InterIslandMig=1 if InterIslandMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] &  ///
													((InterIslandMig_mother==1 & Children_Only_Move_mother==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) | ///
													 (InterIslandMig_father==1 & Children_Only_Move_father==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) ) & ((age!=. & age<15)|(age!=. & Grade!=.))
													 
					by pidlink: replace IntraIslandMig=1 if IntraIslandMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] &  ///
													((IntraIslandMig_mother==1 & Children_Only_Move_mother==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) | ///
													 (IntraIslandMig_father==1 & Children_Only_Move_father==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) ) & ((age!=. & age<15)|(age!=. & Grade!=.))
													 
					by pidlink: replace InterIsland_FamilyMig=1 if InterIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] &  ///
														   ((InterIsland_FamilyMig_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) | ///
														    (InterIsland_FamilyMig_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) ) & ((age!=. & age<15)|(age!=. & Grade!=.))
			
					by pidlink: replace IntraIsland_FamilyMig=1 if IntraIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & /// 
														   ((IntraIsland_FamilyMig_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) | ///
														    (IntraIsland_FamilyMig_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) ) & ((age!=. & age<15)|(age!=. & Grade!=.))
		
					by pidlink: replace InterIsland_FamilyMig=1 if InterIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]!=Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] & ///
														  ((Family_Move_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]!=Islandmov_father[_n-1]) | ///
														   (Family_Move_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]!=Islandmov_mother[_n-1]) ) & ((age!=. & age<15)|(age!=. & Grade!=.))
				   
					by pidlink: replace IntraIsland_FamilyMig=1 if IntraIsland_FamilyMig[_n]==. & ProvCode[_n]!=ProvCode[_n-1] & ProvCode[_n]!=. & Islandmov[_n]!=. & Islandmov[_n]==Islandmov[_n-1] & pidlink[_n]==pidlink[_n-1] &  ///  
														  ((Family_Move_father[_n]==1 & ProvCode_father[_n]!=ProvCode_father[_n-1] & Islandmov_father[_n]==Islandmov_father[_n-1]) | ///
														   (Family_Move_mother[_n]==1 & ProvCode_mother[_n]!=ProvCode_mother[_n-1] & Islandmov_mother[_n]==Islandmov_mother[_n-1]) ) & ((age!=. & age<15)|(age!=. & Grade!=.))
		
					foreach Var in InterIslandMig IntraIslandMig InterIsland_FamilyMig IntraIsland_FamilyMig{
		
						replace `Var'=0 if `Var'==. & ProvCode!=.
						replace `Var'=1 if "`Var'"=="IntraIslandMig" & IntraIsland_FamilyMig==1
						replace `Var'=1 if "`Var'"=="InterIslandMig" & InterIsland_FamilyMig==1
			
					}
		
				drop ProvCode_father-Children_Only_Move_father ProvCode_mother-Children_Only_Move_mother merge_mother merge_father
				
				compress
				
				save "$maindir$tmp/Unmatched Children.dta", replace
					
			restore
			
			keep if _merge!=1
			
			append using "$maindir$tmp/Unmatched Children.dta"
				erase "$maindir$tmp/Unmatched Children.dta"
				
				drop _merge

	* Update the location codes
	
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


********************************************************************************
* Merge in educational histories of parents (update in case there are missing)

	preserve
	
		use "$maindir$tmp/MasterTrack.dta", clear
		
		foreach Parent in mother father{
		
			gen long pidlink_`Parent'=pidlink2
		
			gen MaxSchYrs_`Parent'=MaxSchYrs
		}
		
		keep pidlink *_father *_mother
		
		drop if pidlink_mother==. | pidlink_father==.
		
		save "$maindir$tmp/Parental Schooling.dta", replace
	
	restore
	
	foreach Parent in father mother{
	
		merge m:1 pidlink_`Parent' using  "$maindir$tmp/Parental Schooling.dta", keepusing(*_`Parent') keep(1 3 4 5) update nogen
	}
		erase "$maindir$tmp/Parental Schooling.dta"
		
	drop ParentalSchAvg
		
	egen float ParentalSchAvg = rowmean(MaxSchYrs_father MaxSchYrs_mother)
	
********************************************************************************
* Drop unnecessary variables 
	
	 drop Level SpeakInd ReadInd WriteInd Kinder Worked Prov_FamilyMig Religion Ethnicity birthyr
	 
	 order pidlink* Dynasty sex year age Grade flag_* MaxSchYrs* ParentalSchAvg ProvCode Islandmov Urbanization InterIsland* IntraIsland*

********************************************************************************
* Drop those who are not in School, Missing School, or Parental Schooling is missing

	merge m:1 pidlink using "$maindir$tmp/MasterTrack.dta", keepusing(flag_InSch flag_NotInSch) keep(1 3) nogen
	
	* Not in School --> all these children are age 5 or less, so just get rid of them
		drop if flag_NotInSch!=.
			drop flag_NotInSch
			
	* Drop those who are still in School
		bys pidlink (year): gen byte flag_LastObs=1 if _n==_N
		
		gen byte flag_DropInSch=1 if flag_InSch==1 & age>=6 & Grade!=. & MaxSchYrs!=. & flag_LastObs==1
			by pidlink: egen byte flag_DropInSchMax=max(flag_DropInSch)
		
		drop if flag_DropInSchMax==1
			drop *_DropInSch* flag_InSch
			
	* Make sure the maximum schooling in years is in each person's observation
	
		by pidlink: egen byte SchYrs=max(MaxSchYrs)
			replace MaxSchYrs=SchYrs if age!=.
				drop SchYrs
				
	
				
	* Drop those who have no schooling
	
		by pidlink: gen byte flag=1 if MaxSchYrs==. & age!=.
		by pidlink: egen byte flag_Max=max(flag)
			drop if flag_Max==1
				drop flag flag_Max
				
	* Drop those whose parental schooling average is missing
		
		by pidlink: gen byte flag=1 if ParentalSchAvg==.
		by pidlink: egen byte flag_Max=max(flag)
			drop if flag_Max==1
				drop flag flag_Max

********************************************************************************
* Create the children variable

	gen byte Adult = age>=15 & Grade==.
		replace Adult=. if age==.
		
	order pidlink pidlink2 pidlink_* Dynasty sex year age Adult
	
********************************************************************************
* Generate the Market Movement and the Market Migration Dummies

	recode Islandmov (3/7 = 1 "Outer Islands") (2 = 2 "Java"), gen(MarketCode) l(MarketName)
	
	gen byte InterMarketMig =.
	gen byte IntraMarketMig =.
	gen byte InterMarket_FamilyMig =.
	gen byte IntraMarket_FamilyMig =.
	
	by pidlink: replace InterMarketMig = 1 if pidlink[_n]==pidlink[_n-1] & MarketCode[_n]!=Market[_n-1] & MarketCode[_n-1]!=. & InterIslandMig[_n]==1
		replace InterMarketMig=0 if InterMarketMig==. & InterIslandMig!=.
		
	by pidlink: replace IntraMarketMig = 1 if pidlink[_n]==pidlink[_n-1] & MarketCode[_n]==Market[_n-1] & MarketCode[_n-1]!=. & (IntraIslandMig[_n]==1|InterIslandMig[_n]==1)
		replace IntraMarketMig=0 if IntraMarketMig==. & IntraIslandMig!=.
	
	by pidlink: replace InterMarket_FamilyMig = 1 if pidlink[_n]==pidlink[_n-1] & MarketCode[_n]!=Market[_n-1] & MarketCode[_n-1]!=. & InterIsland_FamilyMig[_n]==1
		replace InterMarket_FamilyMig=0 if InterMarket_FamilyMig==. & InterIsland_FamilyMig!=.
		
	by pidlink: replace IntraMarket_FamilyMig = 1 if pidlink[_n]==pidlink[_n-1] & MarketCode[_n]==Market[_n-1] & MarketCode[_n-1]!=. & (IntraIsland_FamilyMig[_n]==1|InterIsland_FamilyMig[_n]==1)
		replace IntraMarket_FamilyMig=0 if IntraMarket_FamilyMig==. & IntraIsland_FamilyMig!=.
		
********************************************************************************
* Create the skill level based on whether the child has 9+ years of schooling or 12+ years of schooling

	recode MaxSchYrs ( 0/8 = 0 "< 9: Low Skilled") (9/13 = 1 "9+: High Skilled"), gen(Skill_Level_1) l(SkillLvl1)
	recode MaxSchYrs ( 0/11 = 0 "< 12: Low Skilled") (12/13 = 1 "12+: High Skilled"), gen(Skill_Level_2) l(SkillLvl2)
	recode MaxSchYrs ( 0/8 = 0 "< 9: Low Skilled") (9/11 = 1 "< 12: Medium Skilled") (12/13 = 2 "12+: High Skilled"), gen(Skill_Level_3) l(SkillLvl3)

	
	* Skill Level of Parents
	
	recode ParentalSchAvg ( . 0/8.5 = 0 "< 9: Low Skilled") (9/13 = 1 "9+: High Skilled"), gen(Skill_Level_1_Parents) l(SkillLvl1_P)
	recode ParentalSchAvg ( . 0/11.5 = 0 "< 12: Low Skilled") (12/13 = 1 "12+: High Skilled"), gen(Skill_Level_2_Parents) l(SkillLvl2_P)
	recode ParentalSchAvg ( . 0/8.5 = 0 "< 9: Low Skilled") (9/11.5 = 1 "< 12: Medium Skilled") (12/13 = 2 "12+: High Skilled"), gen(Skill_Level_3_Parents) l(SkillLvl3_P)
	
********************************************************************************
* Merge in Parental Wages to understand if one or both parents work

	preserve
	
		use "$maindir$tmp/Wage Database1.dta", clear
		
		keep if job==1
		
		foreach Parent in father mother {
		
			gen long pidlink_`Parent' = pidlink2
			
			gen float r_wage_hr_`Parent' = r_wage_hr
		
		}
		
		keep year *_father *_mother
		
		compress
		save "$maindir$tmp/Parental Wages.dta", replace
	
	restore
	
********************************************************************************
* Seperate the Children from Adult life stages and assign the parental wages

	* Drop the pre-birth observations
	
	drop if age==.

	* Identify those who are children up to the end of their lives
		
	preserve
	
		keep if Adult==1
		
		save "$maindir$tmp/Adults.dta", replace
	
	restore
	
	keep if Adult!=1
	
	* Merge in the parental wages to identify who works
	
	foreach Parent in father mother{
	
		merge m:1 year pidlink_`Parent' using "$maindir$tmp/Parental Wages.dta", keepusing(*_`Parent') keep(1 3) nogen
		
		gen byte Worked_`Parent' = 1 if r_wage_hr_`Parent'!=.
			bys pidlink (year): egen byte Worked_`Parent'max=max(Worked_`Parent')
			replace Worked_`Parent' = Worked_`Parent'max
				drop Worked_`Parent'max r_wage_hr_`Parent'
	
	}
	
	erase "$maindir$tmp/Parental Wages.dta"
	
	* Give the parents wages according to their location and skill level
	
		* Generate each individual parent's wage and combine for a two-parent wage
		
			* Skill Level 1
			
			gen float Wage_1_father = 1 if MarketCode==2 & (MaxSchYrs_father<9 |MaxSchYrs_father==.) & Worked_father==1
			replace Wage_1_father  = 2.406 if MarketCode==2 & MaxSchYrs_father>=9 & MaxSchYrs_father!=. & Worked_father==1
			replace Wage_1_father  = 1.054 if MarketCode==1 & (MaxSchYrs_father<9 | MaxSchYrs_father==.) & Worked_father==1
			replace Wage_1_father  = 2.335 if MarketCode==1 & MaxSchYrs_father>=9 & MaxSchYrs_father!=. & Worked_father==1
			
			gen float Wage_1_mother = 1 if MarketCode==2 & (MaxSchYrs_mother<9 | MaxSchYrs_mother==.) & Worked_mother==1
			replace Wage_1_mother  = 2.406 if MarketCode==2 & MaxSchYrs_mother>=9 & MaxSchYrs_mother!=. & Worked_mother==1
			replace Wage_1_mother  = 1.054 if MarketCode==1 & (MaxSchYrs_mother<9 | MaxSchYrs_mother==.) & Worked_mother==1
			replace Wage_1_mother  = 2.335 if MarketCode==1 & MaxSchYrs_mother>=9 & MaxSchYrs_mother!=. & Worked_mother==1
			
			egen Wage_1_Parents = rowtotal(Wage_1_*)
				drop Wage_1_father Wage_1_mother
			
			* Skill Level 2
			
			gen float Wage_2_father = 1 if MarketCode==2 & (MaxSchYrs_father<12 | MaxSchYrs_father==.) & Worked_father==1
			replace Wage_2_father  = 2.626 if MarketCode==2 & MaxSchYrs_father>=12 & MaxSchYrs_father!=. & Worked_father==1
			replace Wage_2_father  = 1.047 if MarketCode==1 & (MaxSchYrs_father<12 | MaxSchYrs_father==.) & Worked_father==1
			replace Wage_2_father  = 2.513 if MarketCode==1 & MaxSchYrs_father>=12 & MaxSchYrs_father!=. & Worked_father==1
			
			gen float Wage_2_mother = 1 if MarketCode==2 & (MaxSchYrs_mother<12 | MaxSchYrs_mother==.) & Worked_mother==1
			replace Wage_2_mother  = 2.626 if MarketCode==2 & MaxSchYrs_mother>=12 & MaxSchYrs_mother!=. & Worked_mother==1
			replace Wage_2_mother  = 1.047 if MarketCode==1 & (MaxSchYrs_mother<12 | MaxSchYrs_mother==.) & Worked_mother==1
			replace Wage_2_mother  = 2.513 if MarketCode==1 & MaxSchYrs_mother>=12 & MaxSchYrs_mother!=. & Worked_mother==1
			
			egen Wage_2_Parents = rowtotal(Wage_2_*)
				drop Wage_2_father Wage_2_mother
			
			* Skill Level 3
			
			gen float Wage_3_father = 1 if MarketCode==2 & (MaxSchYrs_father<9 | MaxSchYrs_father==.) & Worked_father==1
			replace Wage_3_father  = 1.547 if MarketCode==2 & MaxSchYrs_father>=9 & MaxSchYrs_father<12 & MaxSchYrs_father!=. & Worked_father==1
			replace Wage_3_father  = 2.851 if MarketCode==2 & MaxSchYrs_father>=12 & MaxSchYrs_father!=. & Worked_father==1
			replace Wage_3_father  = 1.054 if MarketCode==1 & (MaxSchYrs_father<9 | MaxSchYrs_father==.) & Worked_father==1
			replace Wage_3_father  = 1.541 if MarketCode==1 & MaxSchYrs_father>=9 & MaxSchYrs_father<12 & MaxSchYrs_father!=. & Worked_father==1
			replace Wage_3_father  = 2.731 if MarketCode==1 & MaxSchYrs_father>=12 & MaxSchYrs_father!=. & Worked_father==1
			
			gen float Wage_3_mother = 1 if MarketCode==2 & (MaxSchYrs_mother<9 | MaxSchYrs_mother==.) & Worked_mother==1
			replace Wage_3_mother  = 1.547 if MarketCode==2 & MaxSchYrs_mother>=9 & MaxSchYrs_mother<12 & MaxSchYrs_mother!=. & Worked_mother==1
			replace Wage_3_mother  = 2.851 if MarketCode==2 & MaxSchYrs_mother>=12 & MaxSchYrs_mother!=. & Worked_mother==1
			replace Wage_3_mother  = 1.054 if MarketCode==1 & (MaxSchYrs_mother<9 | MaxSchYrs_mother==.) & Worked_mother==1
			replace Wage_3_mother  = 1.541 if MarketCode==1 & MaxSchYrs_mother>=9 & MaxSchYrs_mother<12 & MaxSchYrs_mother!=. & Worked_mother==1
			replace Wage_3_mother  = 2.731 if MarketCode==1 & MaxSchYrs_mother>=12 & MaxSchYrs_mother!=. & Worked_mother==1
		
			egen Wage_3_Parents = rowtotal(Wage_3_*)
				drop Wage_3_father Wage_3_mother
				
		* One Household Wage
	
			* Skill Level 1 both parents
		
			gen float Wage_1_HH = 1 if MarketCode==2 & Skill_Level_1_Parents==0
			replace Wage_1_HH = 2.406 if MarketCode==2 & Skill_Level_1_Parents==1
			replace Wage_1_HH = 1.054 if MarketCode==1 & Skill_Level_1_Parents==0
			replace Wage_1_HH = 2.335 if MarketCode==1 & Skill_Level_1_Parents==1
			
			* Skill Level 2 both parents
		
			gen float Wage_2_HH = 1 if MarketCode==2 & Skill_Level_2_Parents==0
			replace Wage_2_HH = 2.626 if MarketCode==2 & Skill_Level_2_Parents==1
			replace Wage_2_HH = 1.047 if MarketCode==1 & Skill_Level_2_Parents==0
			replace Wage_2_HH = 2.513 if MarketCode==1 & Skill_Level_2_Parents==1
			
			* Skill Level 3 both parents
		
			gen float Wage_3_HH = 1 if MarketCode==2 & Skill_Level_3_Parents==0
			replace Wage_3_HH = 1.547 if MarketCode==2 & Skill_Level_3_Parents==1
			replace Wage_3_HH = 2.851 if MarketCode==2 & Skill_Level_3_Parents==2
			replace Wage_3_HH = 1.054 if MarketCode==1 & Skill_Level_3_Parents==0
			replace Wage_3_HH = 1.541 if MarketCode==1 & Skill_Level_3_Parents==1
			replace Wage_3_HH = 2.731 if MarketCode==1 & Skill_Level_3_Parents==2
		
		
	
	
	
*	save "$maindir$tmp/Children.dta", replace
/*
	preserve
	
		use "$maindir$tmp/Wage Database1.dta", clear
		
		keep if job==1
		
		save "$maindir$tmp/Wages.dta", replace
	
	restore
