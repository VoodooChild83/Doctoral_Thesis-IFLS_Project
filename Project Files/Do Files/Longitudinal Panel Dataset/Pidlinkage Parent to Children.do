********************************************************************************

*        This do file will link parent and child through their pidlinks        *
   
********************************************************************************
//Set global directory information for files

cd "/Users/idiosyncrasy58/" 

clear

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************

use "$maindir$tmp/linkage2.dta"

/* Commence the cleaning protocal. */

	* Generate the pidlink2 based on taking the real of the sring instead of destringing
	
		gen double pidlink2= real(pidlink)
		format pidlink2 %12.0f

	* Get the levels of the parents' id codes
	
		drop newhhid
	
		sort hhid Wave Relate birthyr
	
		keep pid pidlink* hhid Relate Father Mother flag_parents Wave birthyr
		
		* update flag_parents to include grandchildren in the even that multiple
		* generations are in the household
		
			replace flag_parents=1 if flag_parents==. & Relate==10
	
	* Create the HHID, PersonID and ObservationID 
		
		egen newhhid=group(hhid Wave)
		bysort newhhid (Relate birthyr): gen newid=_n
	 
		gen Obs=_n

	* Generate the new Mother and Father pidlink variables 
	 
		gen double pidlink_father=.
		gen double pidlink_mother=.
	
		order newhhid newid Obs pid pidlink* hhid Relate Father Mother flag_parents

		quietly sum newhhid
		local tothh=`r(max)'
	
		sort newhhid newid 
								
		forvalues i=1/`tothh' {
			
			quietly sum Obs if newhhid==`i'
			local peoplemin=`r(min)'
			local peoplemax=`r(max)'
		
			forvalues p =`peoplemin'/`peoplemax' {
				
						gen double FatherChild1=Father[`p'] if newhhid==`i' & Father[`p']<51 
						gen double MotherChild1=Mother[`p'] if newhhid==`i' & Mother[`p']<51 
						
						gen byte flag_FatherChild1=1 if FatherChild1==pid & newhhid==`i' & pid!=.
						replace FatherChild1=pidlink2 if flag_FatherChild1==1 & newhhid==`i'
						
						gen byte flag_MotherChild1=1 if MotherChild1==pid & newhhid==`i' & pid!=.
						replace MotherChild1=pidlink2 if flag_MotherChild1==1 & newhhid==`i'
						
						gen byte FatherID=newid if  flag_FatherChild1==1
						gen byte FatherPID=pid if flag_FatherChild1==1
						gen byte MotherID=newid if flag_MotherChild1==1
						gen byte MotherPID=pid if  flag_MotherChild1==1
						
						egen byte FatherID2=max(FatherID) if newhhid==`i'
						egen byte FatherPID2=max(FatherPID) if newhhid==`i'
						egen byte MotherID2=max(MotherID) if newhhid==`i'
						egen byte MotherPID2=max(MotherPID) if newhhid==`i'
						
						egen byte flag_FatherChild12=max(flag_FatherChild1) if newhhid==`i'
						egen byte flag_MotherChild12=max(flag_MotherChild1) if newhhid==`i'
						
						
						if  FatherID2[`p']>FatherPID2[`p']{
							egen double FatherChild12=max(FatherChild1) if newhhid==`i'
							replace pidlink_father=FatherChild12 if Obs==`p'  & flag_parents==1 & newhhid==`i' & flag_FatherChild12==1
							
							}
						if  FatherID2[`p']<=FatherPID2[`p'] {
							egen double FatherChild12=max(FatherChild1) if newhhid==`i'
							replace pidlink_father=FatherChild12 if Obs==`p'  & flag_parents==1 & newhhid==`i' & flag_FatherChild12==1
							
							}
					
						if MotherID2[`p']>MotherPID2[`p'] {
							egen double MotherChild12=max(MotherChild1) if newhhid==`i'
							replace pidlink_mother=MotherChild12 if Obs==`p'  &  flag_parents==1 & newhhid==`i' & flag_MotherChild12==1
							
							}
						if MotherID2[`p']<=MotherPID2[`p'] {
							egen double MotherChild12=max(MotherChild1) if newhhid==`i'
							replace pidlink_mother=MotherChild12 if Obs==`p'  &  flag_parents==1 & newhhid==`i' & flag_MotherChild12==1
							
							}
						
							drop *FatherChild* *MotherChild* FatherID* MotherID* FatherPID* MotherPID*
							
							*if int(`i'/10000)==`i'/10000 save "$maindir$tmp/linkage2.dta", replace //this adsjustment was made on 12-1-2016 from 
																								   //the original to make sure that the saving protocal occurs	
				}																				   //in intervals of 10000 households in case the program crashes
				
			}
			
keep pidlink* hhid Wave

rename Wave wave

save "$maindir$tmp/Parent Child Link - Master.dta", replace

********************************************************************************		
