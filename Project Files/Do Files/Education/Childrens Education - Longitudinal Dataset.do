* This file will generate a panel data of the schooling years and the grade repeats
* This file will generate a panel data of the schooling years and the grade repeats

********************************************************************************

use "$maindir$tmp/EducStartStop.dta",clear

********************************************************************************
// Make the data longitudinal

	* Reshape the data 

		reshape long GrRep1_@ GrRep2_@ GrRep3_@ GrRep4_@ GrRep5_@ GrRep6_@ Admin_@ Worked_@ flag_OutSch_@, i(pidlink) j(Level)

		rename *_ *

		reshape long GrRep@, i(pidlink Level) j(Grade)

		drop if Level>1 & Grade>3

	* recode grades
		recode Grade (1=7) (2=8) (3=9) if Level==2
		recode Grade (1=10) (2=11) (3=12) if Level==3

		drop if GrRep==.

	* Merge in the MaxSchYrs completed at each level

		preserve
		
			use "$maindir$project/MasterTrack2.dta", clear
			
			keep if flag_LastWave==1
			
			foreach parent in father mother{
				
				gen long pidlink_`parent'=pidlink2
				gen MaxSchYrs_`parent'=MaxSchYrs
				
			}
			
			drop if pidlink_father==.
			drop if pidlink_mother==.
			
			save "$maindir$tmp/MasterTrack.dta", replace
			
		restore

		rename flag_OutSch flag_OutSch_1
		merge m:1 pidlink using "$maindir$tmp/MasterTrack.dta", keepusing(MaxSchYrs flag_OutSch) keep(1 3) nogen
		
		recode MaxSchYrs (13=12), gen(MaxSchYrs_2)
		
		replace flag_OutSch_1=flag_OutSch if flag_OutSch_1==. & flag_OutSch==1
		drop flag_OutSch
		rename flag_OutSch_1 flag_OutSch
		
		keep if Grade<=MaxSchYrs_2

	* Drop Inconsistencies

		bys pidlink (Level Grade): gen flag=1 if MaxSchYrs_2!= Grade & _n==_N
		
		by pidlink: egen FlagMax=max(flag)
		drop if FlagMax==1
		drop Flag flag

	* Create Year Variable
	
		bys pidlink (Level Grade): gen year=YearEntSch
		
		by pidlink: replace year=. if _n!=1
	
/*
	* Expand according to Grade Repeats
		replace GrRep=GrRep+1 if GrRep>0
		
		expand GrRep
		
		sort pidlink Grade
			
		* drop duplicate years from expand
			bys pidlink (Grade): replace year=. if _n!=1
*/

	* Expand the longitudinal data to account for migrations that happen before schooling start
	
		preserve
		
			keep pidlink birthyr YearEntSch
			
			drop if YearEntSch==.
		
			rename birthyr YearBirth
			
			duplicates drop pidlink, force
			
			reshape long Year@, i(pidlink) j(stage) s
			 drop stage
			 rename Year year
			 
			bys pidlink (year) : gen last = _n == _N
			
			gen YearEntSch=year if last==1
			
			by pidlink: gen Diff=year-year[_n-1] if _n==_N
			
			qui sum Diff
			local DiffMax=`r(max)'
			
			expand `DiffMax' if last
				drop Diff
			
			sort pidlink year
			
			by pidlink: replace year=. if _n!=1
			
			* Fill in the years
		
			by pidlink: replace year=year[_n-1]+1 if year[_n]==. & year[_n-1]!=.
			
			by pidlink: drop if year>=YearEntSch & YearEntSch!=.
			
			keep pidlink year
			
			save "$maindir$tmp/Birth.dta", replace
		
		restore

		append using "$maindir$tmp/Birth.dta"
		erase "$maindir$tmp/Birth.dta"
		
		sort pidlink year Grade
		
	* Fill in the years

		bys pidlink (year Grade): replace year=year[_n-1]+1 if year[_n]==. & year[_n-1]!=.
		
	* Fill in birthyr
		
		sort pidlink -year
		
		by pidlink: replace birthyr=birthyr[_n-1] if birthyr[_n-1]!=. & birthyr[_n]==.
		
		gen age=year-birthyr
		
		order pidlink year age Level Grade 
		sort pidlink year Grade

********************************************************************************
// Drop those who are still in School

	* Generate dummy for repeats in a grade level
		gen d_GrRep= GrRep>0  & GrRep!=.
			replace d_GrRep=. if Level==.
			drop GrRep
	
	* Drop those who are in school but are not in college
		bys pidlink (Grade): gen DROP=1 if flag_OutSch==0 & HiLvl!=4 & Grade!=.
		by pidlink: egen DropMax=max(DROP)
		drop if DropMax==1
		drop DropMax DROP
	
	* Drop missing years
		bys pidlink (Grade): gen DROP=1 if YearEntSch==. & Grade!=.
		by pidlink: egen DropMax=max(DROP)
		drop if DropMax==1
		drop DropMax DROP
		
	* Drop those who are still in school in high school 
	
		bys pidlink (Grade): gen Drop=1 if flag_OutSch==0 & MaxSchYrs<13 & MaxSchYrs!=.
		by pidlink: egen DropMax=max(Drop)
		drop if DropMax==1
		drop DropMax Drop flag_OutSch
		
	drop Year* wave
		
	sort pidlink year Grade

********************************************************************************
// Identify those who are children of identifiable parents

	* Identify the relevant children by finding their parents from the dynasty set (or from the child - parent linkage file)

		preserve
		
			use "$maindir$tmp/Dynasty Build.dta", clear
			
			duplicates drop pidlink, force
			
			save "$maindir$tmp/Dynasty Children.dta", replace
			
		restore

	*merge m:1 pidlink using "$maindir$tmp/Identified Children.dta", keepusing(pidlink) keep(1 3) 
	
	merge m:1 pidlink using "$maindir$tmp/Dynasty Children.dta", keepusing(pidlink2 pidlink_father pidlink_mother Dynasty) keep(3) nogen
	erase "$maindir$tmp/Dynasty Children.dta"

	keep if pidlink_father!=. & pidlink_mother!=.
	
order pidlink* Dynasty birthyr year age Level Grade Admin

********************************************************************************
// Merge in Geographical information (urbanization, location, and migration of parents)

	* Merge in the Birth urbanization and age 12 urbanization
		preserve
		
			use "$maindir$tmp/Birth-Age12geo.dta", clear
			
			gen UrbBirth=UrbRurmov if stage==0
			gen Urb12=UrbRurmov if stage==12
			
			rename (stage provmov) (age ProvCode)
			
			keep pidlink UrbBirth Urb12 UrbRurmov ProvCode age
			
			*collapse (firstnm) UrbBirth Urb12 ProvCode, by(pidlink)
			
			save "$maindir$tmp/Birth Characteristics.dta", replace
			
		restore

		merge m:1 pidlink age using "$maindir$tmp/Birth Characteristics.dta", keep(1 3) nogen
		erase "$maindir$tmp/Birth Characteristics.dta"
		
	* Merge in Parental migration information
	
		foreach parent in father mother{

			preserve
		
				use  "$maindir$project/Migration Movements/Year-Share.dta", clear
			
				rename MigYear year
			
				gen double pidlink2= real(pidlink)
					format pidlink2 %12.0f
			
			
				gen long pidlink_`parent'=pidlink2
				gen InterIslandMig_`parent'=InterIslandMig
				gen IntraIslandMig_`parent'=IntraIslandMig
				gen InterIsland_FamilyMig_`parent'=InterIsland_FamilyMig
				gen IntraIsland_FamilyMig_`parent'=IntraIsland_FamilyMig
				gen Mig_`parent'=Mig
				gen ProvCode_`parent'=provmov
				gen UrbRurmov_`parent'=flag_UrbRurmig
				gen age_`parent'=stage
			
				keep *_`parent' year
			
				save "$maindir$tmp/MigrationEvents `parent'.dta", replace
		
			restore

			* Merge in the information of the parents
		
				joinby pidlink_`parent' year using "$maindir$tmp/MigrationEvents `parent'.dta", unm(m)
				drop _merge
				
				erase "$maindir$tmp/MigrationEvents `parent'.dta"
				
		}
	
	order pidlink - d_GrRep ProvCode* Urb* Inter* Intra* Mig*
	
********************************************************************************
// Clean the Geo Information

	* Fill in the Prov Code variable with father and mother's location
	
		* Test that there are no faults
		
			*assert ProvCode_father== ProvCode_mother if ProvCode_father!=. & ProvCode_mother!=.
			*assert UrbRurmov_father== UrbRurmov_mother if UrbRurmov_father!=. & UrbRurmov_mother!=.
			* not false
		
		* Replace the Prov Code
		
			replace ProvCode=ProvCode_father if ProvCode_father!=. & ProvCode==.
			replace ProvCode=ProvCode_mother if ProvCode_mother!=. & ProvCode==.
				drop ProvCode_*
				
		* Replace Urbanization based on parent's migration
		
			replace UrbRurmov=UrbRurmov_father if UrbRurmov_father!=. & UrbRurmov!=.
			replace UrbRurmov=UrbRurmov_mother if UrbRurmov_mother!=. & UrbRurmov!=.
				drop UrbRurmov_*
			
			rename UrbRurmov Urbanization
			
	* Fill in the location across time
	
	foreach Var in ProvCode Urbanization UrbBirth Urb12 {
	
		* forward
		bys pidlink (year): replace `Var'=`Var'[_n-1] if `Var'[_n]==. & `Var'[_n-1]!=.
		
		* backwards
		gsort pidlink -year
		by pidlink: replace `Var'=`Var'[_n-1] if `Var'[_n-1]!=. & `Var'[_n]==.
	
	}
	
	sort pidlink year Grade
		
********************************************************************************
* Create Family Migration Variables

	* Create Family Migration
	
		foreach Mov in InterIsland IntraIsland{
			gen `Mov'_FamilyMig=.
				replace `Mov'_FamilyMig=1 if `Mov'_FamilyMig_father==1 & `Mov'_FamilyMig_mother==1
				replace `Mov'_FamilyMig=1 if `Mov'_FamilyMig_father!=1 & `Mov'_FamilyMig_mother==1
				replace `Mov'_FamilyMig=1 if `Mov'_FamilyMig_father==1 & `Mov'_FamilyMig_mother!=1
				replace `Mov'_FamilyMig=1 if `Mov'Mig_father==1 & `Mov'Mig_mother==1 & `Mov'_FamilyMig!=1
		}
	
		egen Prov_FamilyMig=rsum(*_FamilyMig), missing
		replace Prov_FamilyMig=1 if Prov_FamilyMig>1 & Prov_FamilyMig!=.
		
		recode *_FamilyMig (.=0)
	
		foreach Mov in IntraIsland InterIsland Prov{
		
			bys pidlink (year): egen `Mov'max=max(`Mov'_FamilyMig)
			by pidlink: replace `Mov'max=. if _n!=_N
		
		}
		
		
		drop InterIslandMig_father-Mig_mother

	* Forever Mover: Identify effect of moving
	
		foreach Mov in InterIsland IntraIsland Prov{
		
			gen `Mov'_Mover = 0
			
			by pidlink: replace `Mov'_Mover=1 if `Mov'_FamilyMig[_n-1]==1
			by pidlink: replace `Mov'_Mover=1 if `Mov'_Mover[_n-1]==1 & `Mov'_Mover[_n]==0
		
		}
		
		gen Prov_Mover_2=Prov_FamilyMig 
		replace Prov_Mover_2=Prov_FamilyMig if Prov_FamilyMig==1 & Prov_Mover_2==0
		
		foreach parent in father mother{
		
			bys pidlink (year): egen age_`parent'min=min(age_`parent') if Prov_Mover_2==1
			by pidlink: replace age_`parent'min=. if _n!=_N
		}
		drop Prov_Mover_2
	
	* Drop if Level is missing (that is, drop all the observations pre schooling system)
	
		drop if Level==.
	
/*	* Only for longitudinal samples with grade repeats
	* Generate the lag of educational level
		by pidlink: gen byte SchGradelag=Grade[_n-1]
		by pidlink: replace SchGradelag=Kinder if /*lag==. &*/ Kinder==1 & _n==1
		by pidlink: replace SchGradelag=0 if SchGradelag==. & _n==1
*/
********************************************************************************
// Merge in Other Observables
	
	merge m:1 pidlink using "$maindir$tmp/MasterTrack.dta", keepusing(sex ar15*) keep(1 3) nogen
	merge m:1 pidlink_father using "$maindir$tmp/MasterTrack.dta", keepusing(MaxSchYrs_father) keep(1 3) nogen
	merge m:1 pidlink_mother using "$maindir$tmp/MasterTrack.dta", keepusing(MaxSchYrs_mother) keep(1 3) nogen
	erase "$maindir$tmp/MasterTrack.dta"
	
	* Recode Sex
		recode sex 3=0
		
	* Clean the religion and ethnicity codes
		recode ar15 (1=0 "Islam") (2/95=1 "Other"), gen(Religion) 
			drop ar15
		
	* Clean Ethnicity Codes
		recode ar15d (.=98)
		rename ar15d Ethnicity
		
/*
		sort pidlink -year
		
		by pidlink: replace MaxSchYrs_2= MaxSchYrs_2[_n-1] if MaxSchYrs_2[_n-1]!=. & MaxSchYrs_2[_n]==.
		by pidlink: replace MaxSchYrs= MaxSchYrs_2[_n-1] if MaxSchYrs[_n-1]!=. & MaxSchYrs[_n]==.
		
		sort pidlink year
*/	
	
	* Create parental education variable
		egen ParentalSchAvg=rmean(MaxSchYrs_father MaxSchYrs_mother)

********************************************************************************
