* This file will clean the parent linkages and generate the dynasties. It will 
* create a flag to drop the entire dynasty when there is an instance of inconsistant
* parentage across waves. 

* There are total (up to wave 4/2007 survey) of 151 children with inconsistent 
* parentage, out of an identified 34,990 children of directed generations (parents, 
* children, grandchildren). This is about 0.43% of the entire children sample. 

* Upon identifing the dynasties to drop, this results in 2028 observations to drop
* or about 3.04%.

* There are a total of 10422 identified direcly-related dynasties in my dataset. 
* The variable to identify the dynasty drop results in 149 dropped dynasties in 
* my dataset, or 1.43% of my available dynasties. 

* Eventually, a merge against the marriage dataset where only one marriage ever
* occurred will be conducted to identify those couples that have not divroced
* (up to the observed, final wave - inclusion of the newest wave not withstanding). 
* So Dynasties will be dropped if parents divorced or had inconsistencies that
* excluded their inclusion in the ONE MARRIAGE database. 

********************************************************************************
// Collapse the dataset and correct missing values from drop

use "$maindir$tmp/Parent Child Link - Master.dta", clear

* Drop observation with missing or nonsensicle identifiers

	drop if pidlink2==.

	* Drop hhids that contain a character in them
	
	destring hhid, gen(hhid2) force
	drop if hhid2==.

* Merge in the couple pidlinks to identify couples:
* 1) Merge in the pidlink_spouse using the multi-wave information to correctly map the spouses, especially 
*	 since in cases of divorce/remarriage we may see someone wil different spouses.
* 2) Once the spouses are identified, merge in the pidlink_couple ID

	merge m:1 pidlink2 wave using "$maindir$tmp/Husband Wife Link.dta", keepusing(pidlink_spouse sex) keep(1 3) nogen
		*erase "$maindir$tmp/Husband Wife Link.dta"
		
	merge m:1 pidlink2 pidlink_spouse using "$maindir$tmp/Husband Wife ID Link.dta", keepusing(pidlink_couple) keep(1 3) nogen
	
* Merge in the Relate variable

	merge 1:1 pidlink wave using "$maindir$project/MasterTrack2.dta", keepusing(ar02b) keep(1 3) nogen
		rename ar02b Relate

* Check that children have consistent identifiers for parents

	* Find the mean of the pidlinks of parents: the mean should be the same as the identifier IF the identifier
	* is consistent throughout the waves of the survey - deviations from the mean imply inconsistencies
	
		sort pidlink wave
	
		foreach par in father mother{
		
			by pidlink: egen double mean_`par'=mean(pidlink_`par')
			gen byte flag_`par'=1 if pidlink_`par'!=mean_`par' & mean_`par'!=. & pidlink_`par'!=.
			
		}
		
		gen flag_Children=1 if mean_father!=.|mean_mother!=.
		
		* Generate a drop variable for children who
		* 	a) have inconsistent parentage
		*   b) those who have the same identifier for the father and the mother (error in coding the child)
		
			egen byte flag_ChildrenDrop=rsum(flag_father flag_mother), missing
				replace flag_ChildrenDrop=1 if flag_ChildrenDrop==2 
			
* Generate a PRELIMINARY Dynasty Identifier - This variable will be updated later as the household variable is an
* unreliable generator of Dynasties as there are several in a household given the structure of Indonesian households
			
			gen Dyn=substr(hhid,1,5)
				sort Dyn
	
			egen int Dynasty=group(Dyn)
				drop Dyn
				
	* Generate a flag that drops the entire dynasty when there is an inconsistent parentage
		
			bysort Dynasty (hhid wave pidlink): egen flag_DropDyn=max(flag_ChildrenDrop)
			
* Collapse the dataset to obtain just one observation per person
		
	collapseandpreserve (firstnm) Dynasty wave (lastnm) hhid pidlink_spouse /*pidlink_couple*/ (max) Relate ///
						(firstnm) pidlink2 sex pidlink_father pidlink_mother ///
								  flag_Children flag_ChildrenDrop flag_DropDyn, by(pidlink pidlink_couple) omitstatfromvarlabel
								  
						drop flag_DropDyn
	
	* Make sure all people have the same parents in their ID after this multiple person collapse (collapsing with pidlink_couple
	* in the by(...) means I will observe the same person multiple times - some people will not have their parent identifiers because
	* in a future wave with their spouse they were in a different household and so their parents no longer lived with them --> needs
	* to be corrected with the following codes for consistency checks later)
	
		preserve
		
			collapseandpreserve (firstnm) pidlink_father pidlink_mother, by(pidlink) omitstatfromvarlabel
			
			save "$maindir$tmp/Parental ID.dta", replace
		
		restore
		
		merge m:1 pidlink using "$maindir$tmp/Parental ID.dta", keep(1 3 4 5) update replace nogen
			erase "$maindir$tmp/Parental ID.dta"
			
	order Dyn hhid wave Relate sex pidlink pidlink2 pidlink_spouse pidlink_couple pidlink_father pidlink_mother
	sort Dynasty wave pidlink
				
* Merge in the parent's couple ID to have the parent identifier consolidated, through the
* father as the head of the dynasty

	preserve
	
		use "$maindir$tmp/Husband Wife ID Link.dta", clear
		
		keep if sex==1
		
		rename (pidlink2 pidlink_spouse pidlink_couple) (pidlink_father pidlink_mother pidlink_parent)
		
		drop pidlink sex
		
		save "$maindir$tmp/Parental ID.dta", replace
	
	restore
	
	merge m:1 pidlink_father pidlink_mother using "$maindir$tmp/Parental ID.dta", keep(1 3) nogen 
		erase "$maindir$tmp/Parental ID.dta"
		
	order Dyn hhid wave Relate sex pidlink pidlink2 pidlink_spouse pidlink_couple pidlink_parent
	sort Dynasty wave hhid pidlink_couple pidlink
	
******** CREATE A DUPLICATE OBSERVATION FOR MARRIED CHILDREN THAT DON'T HAVE AN OBS IN PARENTAL HH *********

* For those children who are marred but who have only the marriage observation and are
* never seen as a child in the parent's HH (partially because they entered the survey
* already married) we will create a duplicate observation for them to have them in the
* parent's household. 

	* Flag the children who are married
	
		gen flag_MarriedChildren=1 if pidlink_couple!=. & flag_Children==1
		
	* Find the duplicates of people
	
		duplicates tag pidlink2 if flag_Children==1, gen(DupObs)
		
	* Generate a duplicate observation of the children who are married but have only one observation
	
		gen flag_ChildrenMissingChildObs=1 if DupObs==0 & flag_MarriedChildren==1
		
	* Find if there are children who are observed multiply married but don't have the non-married observation
	
		bys pidlink2 (pidlink_couple): replace flag_ChildrenMissingChildObs=1 if DupObs>0 & DupObs!=. & flag_MarriedChildren==1 & pidlink_couple[_N]!=.
			drop flag_MarriedChildren DupObs
			
	* Append the new observation to the data to get the child observation for these children who
	* started out observed only married (that is, have an observation that can be placed into the household.
	
		preserve
		
			keep if flag_ChildrenMissingChildObs==1
				drop flag_ChildrenMissingChildObs
				
			duplicates drop pidlink2, force
			
			replace pidlink_couple=. 
			replace pidlink_spouse=.
			
			save "$maindir$tmp/Dup Child Obs.dta", replace
		
		restore
		
		append using "$maindir$tmp/Dup Child Obs.dta"
			erase "$maindir$tmp/Dup Child Obs.dta"
		
******** UPDATE SINGLE PARENT HOUSEHOLDS TO MAKE SURE THEIR DYNASTIES ARE ACCOUNTED FOR **********

qui do "$maindir$project$Do/Longitudinal Panel DataSet/Dynasty Builder - Single Parents.do"
	
******* FIND WHAT ARE SEEMINGLY INCESTUOUS PAIRINGS AND PEOPLE WITH SAME CODE FOR FATHER AND MOTHER, IDENTIFY THEM  *********

	* Find observations where the mother and the father are identified as the same person
	
			gen flag_Ident=1 if pidlink_father==pidlink_mother & pidlink_father!=. & pidlink_mother!=.
				replace flag_ChildrenDrop=1 if flag_Ident==1
			
		* Now find those who have the same parents and are married to each other - we will need to 
		* do this through both father and mother as sometimes one of the parent's pidlinks is missing in the 
		* relationship (they were not in the household during the survey or were dead, and so are not known).
		* We will drop these dynasties from the dataset due to inconsistencies.
		
			foreach pers in mother father{
			
				duplicates tag pidlink_couple pidlink_`pers' if pidlink_`pers'!=. & pidlink_couple!=., gen(Incest_`pers')
				
			}
			
			egen Incest=rsum(Incest_*), missing
				recode Incest (0=.) (1/2=1) // Correct for the double count from the individual parent sums
					drop Incest_*
				
*************** CLEAN OUT THE MULTIPLE OBSERVATIONS OF PEOPLE ******************

* Here I will clean out the multiple observations for people using duplicates to
* identify those observation of people that are superfluous (are not constructing
* dynasties and merely live in the household). There are several things to note 
* based on generational structures:
*	- Generation G=1:
*			The first generation will not have any parental identifiers, as they
*			are the progenitors of their dynasty (and through this couple the
*			dynasty is established and will later be used to clean when there are
*			people from a dynasty that are placed in another dynasty by error of
*           using the houshold id variable to establish the preliminary dyansty).
*	- Generation G>1:
*			Subsequent generations in a dynasty where a child is married, or even
*			married and then divorced and remarried, or in a polygamous marriage,
*			will show up multiple times. However, none of their observations will
*			be dropped as it is possible that their first observation was as a child
*			in their parents' household, and subsequent observations should have them
* 			with an entry in the pidlink_couple (even if they are a single parent),
*			so we drop only on the following conditions:
*				a) repeated observation of the same child but with no entry in 
*				   pidlink_couple - in which case we keep the first observation (that
*				   of the earliest wave) since this child will presumably be in parents
*				   household (THIS SHOULD NOT HAPPEN GIVEN THE COLLAPSE)
*	- Extra people without families:
*			There are extra people in the households who are not, basically, doing anything
*			by way of creating families

				duplicates report pidlink2 if pidlink_couple==.	// No such cases of (a)
					
		* Generate a duplicates identifier for those cases when the pidlink is repeated

			duplicates tag pidlink2, gen(DupPidlink)
				
		* Generate a new identifier for when there is no couple id
			
			duplicates tag pidlink2 if pidlink_couple==., gen(DupPidlinkNoCoupleID)
				
		* Generate the duplicate pidlink drop variable (making sure not to drop G>1 people)
			
			gen flag_DupPidlinkDrop=1 if DupPidlink>0 & DupPidlinkNoCoupleID==0 & pidlink_parent==.
			
		* We can actually use the above variables that identify duplicates to remove extraneous people
		* from the households (those that are not basically apart of the immediate family and have not 
		* established their own dynasties. 
		
			gen flag_DupExtraneousPeople=1 if flag_DupPidlinkDrop!=1 & DupPidlink!=. & DupPidlinkNoCoupleID==0 & pidlink_parent==.
			
		* Drop identified observations
			
		drop if flag_DupPidlinkDrop==1|flag_DupExtraneousPeople==1
			drop *Dup*	
		
********************************************************************************	
* Create a family variable by summing into it the variable of pidlink_couple and then replacing with the
* pidlink_parent (parents will have missing values in the Family ID and we can replace them into it)

	egen double Family=rsum(pidlink_couple pidlink_parent) if pidlink_parent==., missing
		format Family %12.0f
		replace Family=pidlink_parent if Family==.
		
	gsort Dynasty Family pidlink_couple pidlink
		order Dynasty Family		
		
******* CLEAN THE DYNASTY VARIABLE BY PLACING ALL RELATED, DIRECT FAMILY MEMBERS INTO THE SAME FAMILY*********

* Now we need to clean the dynasties, as there are occurances where the same family identifier
* is in different dynasties (as there may be multiple generations in a household who later move
* out of the household and create their own). 

**** Need to have the spouse placed into the family of their spouse as well (If the spouse comes from another IFLS family
**** then they will have their family ID will be based on their parent ID. So need to make sure that everyone of these are
**** in the same family (that is, the partner that moved into their spouses household will be in their spouses
**** dynasty). 

* To accomplish this I will keep all the information of a pidlink_couple where the relate variable
* identifies a child code (that is, the child of a previous generation). As such this person 
* "should" have parental identifiers; their spouse should not have parental identifiers UNLESS the spouse
* comes from another IFLS household or the parents live in the same household as the parents of their IFLS spouse -
* the "child" I am identifying here. In this way I can then start to remerge into their children's 
* information the couple ID of the grandparents (and great grandparents if this should be the case). <----NO! DO NOT FOLLOW THIS METHOD
* 		Need to further make sure that there are no IFLS spouses who may have been "children" (code 3) and then become
*		a "son/daughter-in-law" (code>3) or any other code in a household and in which case the above collapse command makes them
*       stay with their highest Relate code, and any filtering algorithm misses them if based on the Relate variable. So need to check those with 
* 		a pidlink_spouse code who are not a child and have a pidlink_parent ID (indicating that we can observe their
*       parents - even if only one of them). 
* 		The best way to proceed is to notice that in any generation s.t. G>1, it is always the case that 
*		there should be at least one parent observable. Spouses that do not come from an IFLS household will not have parental identifiers
* 		and as such only the spouse who is the child of an IFLS previous generation will be kept. Since the RELATE variable is 
*		inherently unstable due to the collapse it can not be used at any cost. The best way to proceed is to use the parental identifiers directly.  
	
	forvalues i=1/3 {

		preserve
				qui do "$maindir$project$Do/Longitudinal Panel DataSet/Dynasty Cleaner.do"
		restore	

		* Merge in the Spousal Partner Family ID Updater

			merge m:1 pidlink_couple using "$maindir$tmp/Spousal Partner Family ID Updater.dta", update replace keepusing(Family) keep(1 3 4 5) nogen
			
		if `i'<3 {
		
			* Merge in the parent's Family identifier to clean the dynasty information
	
				merge m:1 pidlink_parent using "$maindir$tmp/Dynasty Updater.dta", update replace keepusing(Family) keep(1 3 4 5) nogen
		}
	}
	
		erase "$maindir$tmp/Spousal Partner Family ID Updater.dta"
		erase "$maindir$tmp/Dynasty Updater.dta"
		
	* Rebuild the Dynasty variale using the newly integrated families
	
		sort Family pidlink_couple pidlink_parent pidlink wave	
			drop Dynasty
			
		egen int Dynasty=group(Family)
			order Dynasty Family
			
* Identify the dynasties to drop based on inconsistencies in parentage, incestuous pairings, or having the same
* code for both fathers and mothers.
		
	* Generate a flag that drops the entire dynasty when there is an inconsistent parentage
		
		bysort Dynasty (Family pidlink_couple pidlink_parent pidlink): egen flag_DropDyn=max(flag_ChildrenDrop)
		
	* Create the flag to identify the entire dynsaty to drop due to having the same parental identifier for both parents
	
		bysort Dynasty: egen flag_IdentDropDyn=max(flag_Ident)
	
	* Create the flag to identify the entire dynsaty to drop due to incestuous pairings
		
		by Dynasty: egen flag_IncestDrop=max(Incest)
		
	* Flag the Dynasties where the dynasty builder was not able to place the spousal partner and child into the dynasty (use 
	* pidlink_couple to understand where people are not in the same dynasties: go forwards and backwards to grab both dynasties)
	* LATER CHECK FOR A WAY TO CORRECT THIS
	
		* Find the people
	
			bys pidlink_couple: gen flag_DynWrong=1 if pidlink_couple[_n]==pidlink_couple[_n+1] & Dynasty[_n]!=Dynasty[_n+1] & pidlink_couple!=.
			bys pidlink_couple: replace flag_DynWrong=1 if pidlink_couple[_n]==pidlink_couple[_n-1] & Dynasty[_n]!=Dynasty[_n-1] & pidlink_couple!=.
			
		* Flag for droping
		
			bys Dynasty: egen flag_DynWrongMax=max(flag_DynWrong) 
				
	* Update the flag_DropDyn variable to account for the inconsistencies
		
		replace flag_DropDyn=1 if flag_IncestDrop==1|flag_IdentDropDyn==1|flag_DynWrongMax==1
			drop flag_IncestDrop flag_Ident* flag_ChildrenDrop flag_DynWrong*
			
* Create the new Family variable to identify families in a dynasty. 

	 gen double Family2=pidlink_parent
	 replace Family2=pidlink_couple if Family2==. | (Family2!=. & pidlink_parent!=. & pidlink_couple!=.)
	 replace Family=Family2
		drop Family2
