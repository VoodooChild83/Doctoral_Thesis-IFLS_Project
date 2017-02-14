* This file will help generate transition probabilities*

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
* A) The migration data set

	* Do the initial migration data set builder

		qui do "$maindir$project/Do Files/Longitudinal Panel DataSet/Migration Longitudinal Builder.do"
		
		drop if pidlink2==.
		
		drop if age<15
	
	* Create the 5 different markets
	
		gen Market=1 if (provmov>=11 & provmov<=19)
			
			replace Market= 2 if (provmov>=31 & provmov<=36)
			replace Market= 3 if (provmov>=51 & provmov<=53)
			replace Market= 4 if (provmov>=61 & provmov<=65)|provmov==21
			replace Market= 5 if (provmov>=71 & provmov<=76)
			replace Market= 6 if (provmov>=81 & provmov<=94)
			
	* Create the two types of markets (sumatra and everywhere else)
	
		recode Market (1/2 = 1) (3/6=2), gen(Market2)
		
	* Create the Market2 migration variable
	
		bys pidlink (year): gen InterMarket2Mig= (pidlink[_n]==pidlink[_n-1] & Market2[_n]!=Market2[_n-1] & Market2[_n]!=. & Market2[_n-1]!=. & pidlink!="")
			replace InterMarket2Mig=. if Market2==.
			
	* Collapse the dataset
	
		collapseandpreserve (firstnm) pidlink_spouse pidlink_couple Market2 (max) InterMarket2Mig, by(pidlink2) omitstatfromvarlabel
		
	* Generate pidlink identifiers
	
		gen double pidlink_father=pidlink2
		gen double pidlink_mother=pidlink2
		
	* Generate the Migration identifiers
	
		foreach pers in father mother{
			gen InitialMarket_`pers'=Market2
			gen MarketMig_`pers'=InterMarket2Mig
		}
		
		gen MarketMig=InterMarket2Mig
		
	save "$maindir$tmp/Trans Func - Migration.dta", replace
	
********************************************************************************
* B) Education

	use "$maindir$project/MasterTrack2.dta", clear
	
		keep if flag_LastWave==1
			drop pidlink2
		
	* Generate pidlink2
	
		gen double pidlink2= real(pidlink)
			format pidlink2 %12.0f
			
	* Generate the pidlink identifiers
	
		gen double pidlink_father=pidlink2
		gen double pidlink_mother=pidlink2
		
	* Generate Schooling (either schooled or not)
	
		gen school_father=MaxSchYrs
		gen school_mother=MaxSchYrs
		gen school=MaxSchYrs
		
		recode school* (0=0) (1/13=1)
		
		* Unsure schooling outcome if investment is 1 (anything below 6 years of schooling is no hc)
			gen school2=(MaxSchYrs>=6 & MaxSchYrs!=.)
			gen school2_father=(MaxSchYrs>=6 & MaxSchYrs!=.)
			gen school2_mother=(MaxSchYrs>=6 & MaxSchYrs!=.)
			
		* Unsure schooling outcome if investment is 1 (anything below 9 years of schooling is no hc for child (not for parent))
			gen school3=(MaxSchYrs>=9 & MaxSchYrs!=.)
			
	* Generate the Educational Investment variable
	
		* Deterministic investment in education
			gen invest=(school==1)
		
	* Keep only the relevant variables
	
		keep pidlink2 pidlink_* school* flag_OutSch invest*
		
		keep if flag_OutSch==1
			drop flag_OutSch
			
	save "$maindir$tmp/Trans Func - Education.dta", replace
	
********************************************************************************
* C) Merge into Dynasty Information

	* do the dynasty builder dataset
	
		use "$maindir$tmp/Dynasty Build.dta", clear
		
	* Merge in the variables from the other datasets
		
		foreach pers in father mother {
		
			merge m:1 pidlink_`pers' using "$maindir$tmp/Trans Func - Migration.dta", keep(1 3) keepusing(MarketMig_`pers' InitialMarket_`pers') nogen
			merge m:1 pidlink_`pers' using "$maindir$tmp/Trans Func - Education.dta", keep(1 3) keepusing(school_`pers' school2_`pers') nogen
		
		}
		
		merge m:1 pidlink2 using "$maindir$tmp/Trans Func - Migration.dta", keep(1 3) keepusing(MarketMig) nogen
		merge m:1 pidlink2 using "$maindir$tmp/Trans Func - Education.dta", keep(1 3) keepusing(school school2 school3 invest) nogen
		
	* Collapse to obtain just one observation per person
		
		collapseandpreserve (firstnm) Dynasty Generation Family pidlink_father pidlink_mother school3 ///
							MarketMig_father school_father school2_father MarketMig_mother school_mother MarketMig school school2 ///
							school2_mother InitialMarket_mother InitialMarket_father invest, by(pidlink2) omitstatfromvarlabel
							
		sort Dynasty Family Generation pidlink2
		
	* Group Parental Events
		
		egen MarketMig_parent=rsum(MarketMig_*), missing
			replace MarketMig_parent=1 if MarketMig_parent==2
			
		egen school_parent=rsum(school_*), missing
			recode school_parent (0 1=0) (2=1)
			
		egen school2_parent=rsum(school2_*), missing
			recode school2_parent (0 1=0) (2=1)
		
	* Keep only the observations with observed variables
	
		keep if MarketMig!=. & school!=. & MarketMig_parent!=. & school_parent!=.
		
	* Define labels
	
		#delimit ;
			label define educ 0 "e=0"
							  1 "e=1";
			label define HC 0 "h=0"
							1 "h=1";
			label define mig 0 "mig=0"
							 1 "mig=1";
			label define island 1 "l=1"
								2 "l=2";
		#delimit cr
		
			label values school* HC 
			label values MarketMig* mig
			label values invest educ
			
			
********************************************************************************
* Transition Probabilities

	* Group the variables to create the states for a transition function on decisions to migrate
	
		egen State1_1=group(school_parent MarketMig_parent), lname(state1_1)
		egen State1_2=group(school MarketMig), lname(state1_2)	
			
	* Create the transition function of initial location states
	
		* generate the initial location of the parents:
			
			* if both parents are in the same location, flag them generate the initial location of parent
				
				gen flag=1 if InitialMarket_father== InitialMarket_mother & InitialMarket_mother!=. & InitialMarket_father!=.      // Concordance
					replace flag=0 if InitialMarket_father!=InitialMarket_mother & InitialMarket_mother!=. & InitialMarket_father!=. // non-concordance; missing=single parent and/or missing parent information
				
				gen InitialMarket_parent=InitialMarket_father if flag==1
				
					* If single parent information, replace the initial market of the parent with the single parent information
					
						replace InitialMarket_parent=InitialMarket_father if flag==. & InitialMarket_mother==. & InitialMarket_father!=.
						replace InitialMarket_parent=InitialMarket_mother if flag==. & InitialMarket_mother!=. & InitialMarket_father==.
					
					* If flag=0, then make the initial location that of the mother
				
						replace InitialMarket_parent=InitialMarket_mother if flag==0
						
			* generate the initial location of the child based on the initial location of the parent and whether they moved
			
				gen InitialMarket=1 if InitialMarket_parent==1 & MarketMig_parent==0
					replace InitialMarket=2 if InitialMarket_parent==1 & MarketMig_parent==1
					replace InitialMarket=2 if InitialMarket_parent==2 & MarketMig_parent==0
					replace InitialMarket=1 if InitialMarket_parent==2 & MarketMig_parent==1
				
				label values InitialMarket* island
				
			* Generate the transition states of initial locations
			
				egen State2_1=group(school_parent InitialMarket_parent), lname(state2_1)
				egen State2_2=group(school InitialMarket), lname(state2_2)
		
			* Generate transitions 
			
				egen State3_1=group(school_parent InitialMarket_parent MarketMig_parent), lname(state3_1)
				egen State3_2=group(school InitialMarket MarketMig), lname(state3_2)
				
			* Generate the transition of z,I_{k,t=2}=1 for non-risky educational investment
			
				egen State4_1=group(school_parent InitialMarket_parent MarketMig_parent invest), lname(state4_1)
				
			* Generate the transition of z,I_{k,t=2}=1 for risky educational investment (schooling below primary is not hc)
			
				*egen State5_1=group(school2_parent InitialMarket_parent MarketMig_parent invest), lname(state5_1)
				egen State5_2=group(school2 InitialMarket), lname(state5_2)
				
			* Generate the transition of z,I_{k,t=2}=1 for risky educational investment (schooling below obl-secondary is not hc)
			
				*egen State6_1=group(school_parent InitialMarket_parent MarketMig_parent invest), lname(state6_1)
				egen State6_2=group(school3 InitialMarket), lname(state6_2)
				
	* Display the transition states to grab the empirical frequencies 
	/*
		* States based on migration choice
		
			tab State1*, row nof 
			
		* States based on initial locations and educational atainment
		
			tab State2*, row nof
			
		* States based on initial locations and educational atainment and the decision to migrate
		
			tab State3*, row nof
	*/		
		* Transition function for parents states and choices, and children's state based on a non-risky educational investment
		
			tab State4_1 State2_2, row nof
			
		* Transition function for parents states and choices, and children's state based on a risky educational investment (anything under primary is hc=0)
	
			tab State4_1 State5_2, row nof
			
		* Transition function for parents states and choices, and children's state based on a non-risky educational investment (anything under obl-secondary is hc=0)
		
			tab State4_1 State6_2, row nof
			
********************************************************************************
* Save the dataset

keep pidlink2 pidlink_father pidlink_mother Dynasty Generation Family MarketMig_parent InitialMarket_parent invest ///
	 InitialMarket MarketMig school* State*
	 
save "$maindir$tmp/Transition Functions.dta", replace

erase "$maindir$tmp/Trans Func - Education.dta"
erase "$maindir$tmp/Trans Func - Migration.dta"		

********************************************************************************
* Incorporate Wage Information

* Merge in Child Wage info
merge 1:1 pidlink2 using "$maindir$tmp/First Wages of Children.dta", keepusing(birthyr Skill_Level ln_wage_hr unpaid *OK *Mover *Mig provmov) keep(1 3)	nogen
		
sort Dynasty Generation Family birthyr

*Keep only whole households
drop if pidlink_father==. | pidlink_mother==.

*Keep only first observed child
collapse (firstnm) pidlink2-Family school3-Skill_Level, by(pidlink_father pidlink_mother)

preserve

	use "$maindir$tmp/First Wages of Adults.dta", clear
	
	gen double pidlink_father=pidlink2
	gen double pidlink_mother=pidlink2
	
	gen Skill_Level_father = Skill_Level
	gen Skill_Level_mother = Skill_Level
	 
	gen ln_wage_hr_father= ln_wage_hr
	gen ln_wage_hr_mother=ln_wage_hr
	
	gen unpaid_mother=unpaid
	gen unpaid_father=unpaid
	
	gen provmov_father=provmov
	gen provmov_mother=provmov
	
	save "$maindir$tmp/First Wages of Adults.dta", replace

restore

merge m:1 pidlink_father using "$maindir$tmp/First Wages of Adults.dta", keepusing(Skill_Level_father ln_wage_hr_father unpaid_father provmov_father) keep(1 3) nogen
merge m:1 pidlink_mother using "$maindir$tmp/First Wages of Adults.dta", keepusing(Skill_Level_mother ln_wage_hr_mother unpaid_mother provmov_mother) keep(1 3) nogen

foreach pers in father mother {
	gen Market_`pers'=1 if (provmov_`pers'>=11 & provmov_`pers'<=19)
	replace Market_`pers'=2 if (provmov_`pers'>=31 & provmov_`pers'<=36)
	replace Market_`pers'=3 if (provmov_`pers'>=51 & provmov_`pers'<=53)
	replace Market_`pers'=4 if (provmov_`pers'>=61 & provmov_`pers'<=64)
	replace Market_`pers'=5 if (provmov_`pers'>=72 & provmov_`pers'<=76)
	replace Market_`pers'=6 if (provmov_`pers'>=81 & provmov_`pers'<=94)
}



