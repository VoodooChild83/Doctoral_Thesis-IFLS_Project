* This file will consolidate all the migration data sets and clean it 

// Append all the wave datasets for Birth-Age12 data

use "$maindir$tmp/b3a_mg1_2014.dta"
gen wave=2014

foreach year in 2007 2000 1997 1993{

	append using "$maindir$tmp/b3a_mg1_`year'.dta", keep(pidlink hhid* pid* stage kecmov kabmov provmov UrbRurmov birthyr) gen(_append)
	replace wave=`year' if _append==1
	drop _append
	}
	
* For those with all missing values in the year 12 location, assume they live in the same location as in birth location

egen id=concat(UrbRur* kec* kab* prov*) if UrbRurmov==. & kecmov==. & kabmov==. & provmov==. & stage==12 /* to change all locations at the same time and not individually - could 
																											screw up the province coding by mixing across waves */

	foreach geo in UrbRur kec kab prov{
			
			bysort pidlink wave (stage): replace `geo'mov=`geo'mov[_n-1] if `geo'mov[_n]==. & `geo'mov[_n-1]!=. & stage==12 & id=="...."
			}
			
* Identify the occurance of geographical coding sequences within a wave that are most complete

	foreach geo in kec kab prov{
		
			bysort pidlink wave (stage): gen flag_`geo'=1 if `geo'mov!=.
			}
		
	egen flag_geocount=rsum(flag*), missing
	by pidlink: egen flag_highestseqcount=max(flag_geocount)		/* Fill in the rest of wave observation with value of thie highest sequence count */
	
	/* Note: The above code requires the following corection to make sure that the proceeding pre-drop (prior to the collapse) does not drop the birth or 12 year
	         stage from a surveyed participant - everyone should have two observations. */
	
			* Make sure that the pre-drop does not drop one of the age stages - Forwards and backwards
	
				by pidlink wave: replace flag_geocount=flag_highestseqcount if flag_geocount[_n+1]==flag_highestseqcount[_n+1] & flag_geocount[_n]!=flag_highestseqcount[_n]
				by pidlink wave: replace flag_geocount=flag_highestseqcount if flag_geocount[_n-1]==flag_highestseqcount[_n-1] & flag_geocount[_n]!=flag_highestseqcount[_n]
	
* Conduct a first passby drop to get rid of incomplete information per surveyed person

	by pidlink: drop if flag_geocount!=flag_highestseqcount
	
	drop flag* id

* Collapse the data and grab the sequence from the most current wave with non-missing value	
	
	gen MigYear=birthyr if stage==0 
	replace MigYear=birthyr+12 if stage==12 & !(birthyr+12>wave+1)
	
	collapse (lastnm) UrbRurmov kec* kab* prov* MigYear, by (pidlink stage)
	
* Recode provinces to match 1993 codes
					
	recode provmov (94=91) (82=81) (36=32) (20 21=14) (75=71) (19=16) (76=73) (65=64)
	
	replace provmov=. if provmov<11 | (provmov>21&provmov<31) | (provmov>36&provmov<51) | ///
					     (provmov>53&provmov<61) | (provmov>64&provmov<71) | (provmov>76&provmov<81) | /// 
					     (provmov>82&provmov<91) | (provmov>91&provmov<94) | provmov>94
						 
	replace kabmov=. if provmov==.
	replace kecmov=. if provmov==.
	
* Create Island Designations

	gen Islandmov=1 if (provmov>=11 & provmov<=19)
			
			replace Islandmov= 2 if (provmov>=31 & provmov<=35)
			replace Islandmov= 3 if (provmov>=51 & provmov<=53)
			replace Islandmov= 4 if (provmov>=61 & provmov<=64)
			replace Islandmov= 5 if (provmov>=71 & provmov<=74)
			replace Islandmov= 6 if provmov==81 
			replace Islandmov= 7 if provmov==91
	
save "$maindir$tmp/Birth-Age12geo.dta", replace

foreach year in 1993 1997 2000 2007 2014{
		erase "$maindir$tmp/b3a_mg1_`year'.dta"
		}
	
********************************************************************************
// Append all the migration datasets for the post 12 year old events

use "$maindir$tmp/b3a_mg2_2014.dta"
gen wave=2014

foreach year in 2007 2000 1997 1993{

	append using "$maindir$tmp/b3a_mg2_`year'.dta", gen(_append)
	replace wave=`year' if _append==1
	drop _append
	}

gen panel93=1 if wave==1993
label values panel93 panew

order pidlink pid* hhid* panel* movenum MigYear wave mg35 mg36 UrbRurmov kecmov flag_kec* kabmov flag_kab* provmov flag_prov*
 
sort pidlink MigYear wave movenum panel93 panel97 panel00 panel07 panel14

* Recode provinces to match 1993 codes
					
	recode provmov (94=91) (82=81) (36=32) (20 21=14) (75=71) (19=16) (76=73) (65=64)
	
	replace provmov=. if provmov<11 | (provmov>21&provmov<31) | (provmov>36&provmov<51) | ///
					     (provmov>53&provmov<61) | (provmov>64&provmov<71) | (provmov>76&provmov<81) | /// 
					     (provmov>82&provmov<91) | (provmov>91&provmov<94) | provmov>94
						 
	replace kabmov=. if provmov==.
	replace kecmov=. if provmov==.
	
* Create Island Designations

	gen Islandmov=1 if (provmov>=11 & provmov<=19)
			
			replace Islandmov= 2 if (provmov>=31 & provmov<=35)
			replace Islandmov= 3 if (provmov>=51 & provmov<=53)
			replace Islandmov= 4 if (provmov>=61 & provmov<=64)
			replace Islandmov= 5 if (provmov>=71 & provmov<=74)
			replace Islandmov= 6 if provmov==81 
			replace Islandmov= 7 if provmov==91

save "$maindir$tmp/MigrationEvents.dta", replace

********************************************************************************
// Identify the repeats of the Migration Events: by (1) survey wave, (2) repeated kec, (3) repeated kabs

	/* Identify possible repeats: this code will leave the last observation as the acceptable observation to keep (other
	   option is to use the [_n-1] form to keep the first observation of the repeats) */


		foreach rep in surv /*kec kab*/{
		
			gen flag_Rep`rep'=.
		
			if "`rep'"=="surv" by pidlink: replace flag_Rep`rep'=1 if wave[_n+1]!=wave[_n] & MigYear[_n+1]==MigYear[_n] & MigYear!=.
	
			if "`rep'"=="kec" by pidlink: replace flag_Rep`rep'=1 if wave[_n+1]!=wave[_n] & kecmov[_n]==kecmov[_n+1] & kabmov[_n]==kabmov[_n+1] & provmov[_n]==provmov[_n+1] & MigYear[_n+1]==MigYear[_n] 
			
			else by pidlink: replace flag_Rep`rep'=1 if wave[_n+1]!=wave[_n] & kabmov[_n]==kabmov[_n+1] & provmov[_n]==provmov[_n+1] & MigYear[_n+1]==MigYear[_n] 
			
			* Identify the pidlinks with repeated events
				by pidlink: egen flag_view=max(flag_Rep`rep') if MigYear!=.
			
				gen a=1
				by pidlink: egen b=sum(a) if flag_view==1
				replace flag_Rep`rep'=1 if b==1
			
				drop a b flag_view
			
			}
			
gen Family_Move = regexm(mg36,"A.*G")

bys pidlink MigYear (wave): egen Family_MoveMax=max(Family_Move)
drop Family_Move
rename Family_MoveMax Family_Move
recode Family 0=.
			
	/* Note: flag_Repsurv nests flag_Repkab nests flag_Repkec: use these to create conservative to liberal migration events captures*/

* Fill in the hhid for all the years to make sure that last observation per waves has a hhid
	
	foreach year in 93 97 00 07 14{
			by pidlink: replace hhid`year'=hhid`year'[_n-1] if hhid`year'[_n-1]!="" & hhid`year'[_n]==""
			by pidlink: replace hhid`year'=hhid`year'[_n+1] if hhid`year'[_n+1]!="" & hhid`year'[_n]==""
			}
			
	* Check that the final codes are not missing
			
	foreach year in 93 97 00 07 14{
			bysort pidlink hhid`year': gen obs`year'=_n if hhid`year'!=""
			by pidlink: gen flag_hhid`year'=1 if hhid`year'=="" & obs`year'==_N
			}
	
	drop obs* flag_hhid*

* Drop the observations for which there are possible repeats, keeping only the most recent catalougued event

	* Conservative: Drop any repeated Migration Year Events that are captured in different waves - keep most recent recorded event
	* Middle: Drop any repeated Migration Year events with same Kab-Prov movements
	* Liberal: Drop any repeated Migration Year events with same Kec-Kab-Prov movements
	
********************************************************************************
// Clean the datasets
	
foreach rep in surv /*kec kab*/ {
	
		preserve
			
			by pidlink: drop if flag_Rep`rep'==1
			
			by pidlink: gen obs=_n
			
			replace movenum=obs
			
			*by pidlink: gen flag_FinalObs=1 if movenum==_N // The last observation per pidlink (useful for the counting of the migration event between waves)
			
			drop flag* obs
			
			gen flag_data=1 // Identifies the original data prior to merge to get rid of those with birth-age12 info and no migration events
							// in case there are people with migration events that don't have birth-age12 information.
		
			* Append in the Birth-Age12 dataset to set initial point based from age 12 location
			
				append using "$maindir$tmp/Birth-Age12geo.dta"
				
				order pidlink pid* hhid* panel* stage movenum
 
				sort pidlink MigYear stage movenum panel93 panel97 panel00 panel07 panel14
				
				*erase "$maindir$tmp/Birth-Age12geo.dta"
				
			* Drop those who don't have migration information: will have only b==2 observations per pidlink
				
				gen a=1
				
				by pidlink: egen b=sum(a)
				
				drop if b==2 & flag_data!=1 
				
				drop a b flag_data
				
			* Identify those who have a migration event prior to their birth and eliminate these individuals from the dataset:
				
				by pidlink: gen obs=_n
				by pidlink: gen flag_birthOOO=1 if stage==0 & obs!=1 & MigYear!=.
				by pidlink: egen d=max(flag_birthOOO)
				drop if d==1
				drop d flag_birthOOO obs
				
			* Identify those who have a migration event prior to age 12 and recode their movements to account
			* for recorded pre-age 12 migrations
			
				bysort pidlink (MigYear stage movenum): gen flag=_n if stage!=. // since age 12 should always be in second position
				by pidlink: gen flag2=1 if stage==12 & flag!=2 & MigYear!=.
				by pidlink: gen flag3=1 if flag!=1 & stage==0  & MigYear!=.
				
				by pidlink: gen flag4=1 if MigYear<MigYear[1]+12 & MigYear!=. & movenum!=. 
				bysort pidlink (stage MigYear): gen stage2=MigYear-MigYear[1] if stage==. & MigYear[1]!=.

				* For those with missing MigYear in stage==0 &/or stage==12 replace flag4==. (since these are unknown)
			
					by pidlink: replace flag4=. if stage2==. & flag4==1
					
					replace movenum=. if flag4==1
				
				* Generate the wave for each migration event
				
				gen Wave=.
				
				order pidlink-movenum Wave
				
				foreach year in 93 97 00 07 14{
						
						by pidlink: egen panel`year'2=max(panel`year')
					
						if `year'==93| `year'==97 local var=1900+`year'
						else local var=2000+`year'
					
						bysort pidlink panel`year': replace Wave=`var' if MigYear<=`var'+1 & movenum!=. & Wave==. & panel`year'2!=.
						
						drop panel`year'2
						}
				
				drop if Wave==. & MigYear==. & stage==.
				
				drop wave panel*
				
				* Drop Migration events that have all missing information
					sort pidlink stage MigYear
				
					egen id=concat(kec* kab* prov*) if stage==. & movenum!=.
					
					gen flag5=1 if id=="..."
					drop if flag5==1
				
				* Recode the migration events (movenum) after age 12
				
					bysort pidlink Wave (stage MigYear): gen flag7=_n if movenum!=.
					replace movenum=flag7 
					
				* For those with a migration event between 0 and 12:
				
					* Replace Stage with stage2
					
					by pidlink: replace stage=stage2 if stage==. & stage2!=.
				
					*bysort pidlink (stage Wave movenum): gen flag8=1 if stage==. & movenum==.
					*by pidlink: replace stage=MigYear-MigYear[1] if flag8==1
					
				* Assign Cohorts
				
					gen Cohort="1524" if stage>=15 & stage<=24
					replace Cohort="2534" if stage>=25 & stage<=34
					replace Cohort="3544" if stage>=35 & stage<=44
					replace Cohort="4554" if stage>=45 & stage<=54
					replace Cohort="5564" if stage>=55 & stage<=64
					replace Cohort="65" if stage>64
					
				* Find the final observation of each Wave
				
					foreach year in 1993 1997 2000 2007 2014{
							bysort pidlink Wave (stage movenum): gen flag_FinalObs`year'=1 if movenum==_N & Wave==`year'
							}
							
					sort pidlink stage Wave movenum
				
					drop flag flag2 flag3 flag4 flag5 flag7 stage2 id
					
			drop if MigYear>2015
				
			save "$maindir$tmp/MigrationEvents-RepsurvDrop.dta", replace
		
		restore
		}
		

save "$maindir$tmp/MigrationEvents.dta", replace

foreach year in 1993 1997 2000 2007 2014{
		erase "$maindir$tmp/b3a_mg2_`year'.dta"
		}

********************************************************************************
// Start cycling through migration events to get the kind of moves.

	use "$maindir$tmp/MigrationEvents-RepsurvDrop.dta"

	* Find the Start and End Migration Dates for all the Sub Waves
	
		bysort pidlink Wave (stage movenum): gen MigStart=MigYear if movenum==1
	
		gen MigEnd=.
	
		foreach year in 1993 1997 2000 2007 2014{
			by pidlink: replace MigEnd=MigYear if flag_FinalObs`year'==1
			}
		
		foreach var in MigStart MigEnd{
			foreach year in 1993 1997 2000 2007 2014{
				bysort pidlink Wave (MigYear): egen `var'`year'=max(`var')
				replace `var'`year'=. if flag_FinalObs`year'!=1
				}
			}
	
		drop MigStart MigEnd
		
		egen MigStart=rsum(MigStart*), missing
		egen MigEnd= rsum(MigEnd*), missing
	
		foreach year in 1993 1997 2000 2007 2014{
			drop MigStart`year' MigEnd`year'
			}
		
		sort pidlink stage Wave movenum
	
	* Initialize the Counting Cycles

	gen flag_kecmig=.
	gen flag_kabmig=.
	gen flag_provmig=.  		// interprovincial migration also includes possible international migration since these are not distinguished

	gen flag_villmigsame=.		// a village migration within the same kec
	gen flag_kecmigsame=.		// intraregency migration (a subregency change within the same heirarchy of regency and province)
	gen flag_kabmigsame=.		// intraprovincial migration (a subregency and regency change within the hierarchy of province)

	gen flag_UrbRurmig=.		// did migrations take place between rural and urban
	gen flag_Islandmig=.
	
	by pidlink: gen obs=_n if movenum!=.
	by pidlink: egen TotalMoves=rank(obs) if obs!=.	// To iterate cycle along all the observed moves of an individual
	drop obs

	levelsof TotalMoves, local(levels)

	* First, find the inter-geographical migration events
	
	foreach var in prov Island UrbRur kec kab {

			foreach l of local levels{
					by pidlink: replace flag_`var'mig=1 if TotalMoves==`l' & `var'mov[_n-1]!=`var'mov[_n]
					}
			}

	* Second, find the intra-geographical migration events (that is, events that occur intraregency (implies same province) and/or intraprovincially)
	
	quietly foreach var in kec kab vill{
		
				if "`var'"=="kec" egen id=concat(provmov kabmov)
				if "`var'"=="kab" egen id=concat(provmov)
				if "`var'"=="vill" egen id=concat(provmov kabmov kecmov)
		
				if "`var'"=="kec"|"`var'"=="kab"{
					foreach l of local levels{
							bys pidlink (stage): replace flag_`var'migsame=1 if TotalMoves==`l' & `var'mov[_n-1]!=`var'mov[_n] & id[_n-1]==id[_n] /*& `var'mov[_n-1]!=. & `var'mov[_n]!=.*/
							}
				drop id
				}
				if "`var'"=="vill"{
					foreach l of local levels{
							bys pidlink (stage): replace flag_`var'migsame=1 if TotalMoves==`l' & id[_n-1]==id[_n] 
							}
				drop id
				}
				
			}
	
		*drop movenumMaster
			
		rename (*provmig *Islandmig *kecmigsame *kabmigsame *villmigsame) (*InterProvMig *InterIslandMig *IntraKabMig *IntraProvMig *IntraKecMig)

	*save "$maindir$tmp/MigrationEvents-RepsurvDrop.dta", replace
	*save "$maindir$tmp/MigrationEvents-RepsurvDrop-For Mig Year Dummeis.dta", replace


	* Count the types of migration events that occur

		quietly foreach var in IntraKecMig InterProvMig IntraKabMig IntraProvMig InterIslandMig UrbRur{
					foreach year in 1993 1997 2000 2007 2014{
						bysort pidlink (stage Wave movenum): egen Count_`var'`year'=count(flag_`var') if Wave==`year'
						replace Count_`var'`year'=. if flag_FinalObs`year'!=1  
						recode Count_`var'`year' 0=.
						}
					egen Tally_`var'=rsum(Count_`var'*), missing
					drop Count_`var'*
					}
				
	* Repeat for Cohorts
	
		bysort pidlink Cohort (stage): gen obs=_n if Cohort!=""
		by pidlink Cohort (stage): gen flag_finalobsCohort=1 if obs==_N
		drop obs
				
		quietly levelsof Cohort, local(levels)
		
		quietly foreach var in IntraKecMig InterProvMig IntraKabMig IntraProvMig InterIslandMig UrbRur{
					foreach c of local levels{
						bysort pidlink Cohort (stage Wave movenum): egen Count_`var'`c'=count(flag_`var') if Cohort=="`c'"
						replace Count_`var'`c'=. if flag_finalobsCohort!=1  & Cohort=="`c'"
						recode Count_`var'`c' 0=.
						}
					egen Cohort_Tally_`var'=rsum(Count_`var'*), missing
					drop Count_`var'*
					}
					
		drop flag_finalobsCohort
		
		* Check that the migration number of events has been properly aggregated into the groupings

			egen TotalEvents=rsum(Tally_IntraKecMig - Tally_IntraProvMig), missing
		
			foreach year in 1993 1997 2000 2007 2014{
				gen flag_InconsisMov`year'=1 if TotalEvents!=movenum & flag_FinalObs`year'==1
				}
			
			egen flag_InconsisMov=rsum(flag_InconsisMov*), missing
			tab flag_InconsisMov 
		
		* Drop the inconsistent Migration Event
		
			by pidlink: egen flag=max(flag_InconsisMov)
			drop if flag==1
	
				//Migration events have been properly aggregated into groups//

		drop TotalEvents flag_InconsisMov* flag
	
	preserve	
	
		drop flag_Final* flag_kec* flag_kab* flag_IntraKecMig flag_IntraKabMig flag_IntraProvMig Tally_IntraKecMig Tally_IntraKabMig Tally_IntraProvMig
		
		* Count the Family Migration events
		
		foreach mov in Prov Island{
		
			*bys pidlink (MigYear movenum): egen Family_`mov'Mig=count(Family_Move) if flag_Inter`mov'Mig==1
			
			gen flag_Family_`mov'Mov = 1 if Family_Mov==1 & flag_Inter`mov'Mig!=.
		
			*by pidlink: replace Family_`mov'Mig=. if _n!=_N
		}
		
		
		
		save "$maindir$tmp/MigrationEvents-RepsurvDrop.dta", replace
	
	restore

	// Drop what isn't needed for initial pass through
	
	drop if flag_FinalObs1993!=1 & flag_FinalObs1997!=1 & flag_FinalObs2000!=1 & flag_FinalObs2007!=1
	drop mg35 mg36 flag* MigYear Cohort* kec* kab* prov* UrbRur* movenum

	save "$maindir$tmp/MigrationEvents-RepsurvDropConsolidated.dta", replace
	
