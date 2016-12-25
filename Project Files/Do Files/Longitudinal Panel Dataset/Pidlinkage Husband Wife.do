* This file will link husband and wife data

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Use the Master Track File

use "$maindir$project/MasterTrack2.dta"

********************************************************************************
// Clean and keep only the marriage 

	* Drop all the data that have misisng PID numbers for waves
	
	drop if pid==.
	
	sort newid newhhid pid pidlink wave
	
	keep newhhid newid pid pidlink wave hhid sex ar02b ar14 
	
	rename (ar02b ar14) (Relate pid_spouse)
	
	
********************************************************************************
// Link the Spouse pidlinks to each other

	drop newhhid newid
	
	gen double pidlink2= real(pidlink)
		format pidlink2 %12.0f
	
	sort hhid wave Relate
	
	* Create the HHID, PersonID and ObservationID 
	 egen newhhid=group(hhid wave)
	 bysort newhhid (Relate): gen newid=_n
	 
	 gen Obs=_n

	 order newhhid newid Obs pid pidlink pidlink2

	* Generate the new spouse pidlink identifier variable
	 
	 gen double pidlink_spouse=.
		format pidlink_spouse %12.0f
	 
	 quietly sum newhhid
	 local tothh=`r(max)'
	
	 sort newhhid newid 
								
		forvalues i=1/`tothh' {
			
			quietly sum Obs if newhhid==`i'
			local peoplemin=`r(min)'
			local peoplemax=`r(max)'
		
			forvalues p =`peoplemin'/`peoplemax' {
			
					*noisily display `p'
				
						gen double Spouse1=pid_spouse[`p'] if newhhid==`i' & pid_spouse[`p']<51
						
						gen byte flag_Spouse1=1 if newhhid==`i' & pid_spouse[`p']<51 & Spouse1==pid & pid!=.
						replace Spouse1=pidlink2 if flag_Spouse1==1 & newhhid==`i'  
						
						gen byte SpouseID=newid if  flag_Spouse1==1
						gen byte SpousePID=pid if flag_Spouse1==1
						
						egen byte SpouseID2=max(SpouseID) if newhhid==`i'
						egen byte SpousePID2=max(SpousePID) if newhhid==`i'
						
						egen byte flag_Spouse12=max(flag_Spouse1) if newhhid==`i'
						
						if  SpouseID2[`p']>SpousePID2[`p']{
							egen double Spouse12=max(Spouse1) if newhhid==`i'
							replace pidlink_spouse=Spouse12 if Obs==`p' & newhhid==`i' & flag_Spouse12==1
							}
							
						if  SpouseID2[`p']<=SpousePID2[`p'] {
							egen double Spouse12=max(Spouse1) if newhhid==`i'
							replace pidlink_spouse=Spouse12 if Obs==`p' & newhhid==`i' & flag_Spouse12==1
							}
					
							drop *Spouse*
							
							*if int(`i'/10000)==`i'/10000 save "$maindir$tmp/Husband Wife Link.dta", replace 
																											 	
				}																				   			
				
			}
			

save "$maindir$tmp/Husband Wife Link - Master.dta", replace

keep *link* wave sex

drop if pidlink_spouse==. | pidlink2==.

sort pidlink2 wave

save "$maindir$tmp/Husband Wife Link.dta", replace

********************************************************************************
// Create Couple IDs
	
	* Create a couple ID with the female spouse as the first identifier
	
		egen double pidlink_couple=group(pidlink2 pidlink_spouse) if sex==3
			format pidlink_couple %12.0f
		
	* Keep only the female data and invert the individual and spouse ID to merge in the males
	
	preserve

		keep if sex==3

		keep pidlink2 pidlink_spouse pidlink_couple wave
	
		rename (pidlink_spouse pidlink2) (pidlink2 pidlink_spouse)
		
		save "$maindir$tmp/Couple ID - through female.dta", replace

	restore
	
	merge 1:1 pidlink2 wave pidlink_spouse using "$maindir$tmp/Couple ID - through female.dta", update keep(1 3 4) nogen
		erase "$maindir$tmp/Couple ID - through female.dta"
		
	* Keep only two observations of for each couple 
		
		collapseandpreserve (firstnm) pidlink pidlink_couple sex, by(pidlink2 pidlink_spouse) omitstatfromvarlabel
		
	* Remove the observations for which a couple ID is either missing or there is only one person 
	
		bysort pidlink_couple (sex): gen obs=_N
		
		tab obs
		
		drop if obs!=2
			drop obs
			
	save "$maindir$tmp/Husband Wife ID Link.dta", replace
	
	
	


