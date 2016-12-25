/* This do file will build the database for the survival and NonParametric Hazard 
   database */
   
cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
//Do the linkage dataset

quietly do "$maindir$project/Do Files/Childrens Education Parents Migration.do"
** The above code will take forever to run because of the linkage correction do files

use "$maindir$project/linkage.dta"
********************************************************************************
// First, generate the longform dataset that accounts for the grade repititions

	drop Mig_* 
	/* Since I don't care about the child's migration events (for now) */

	reshape long Sch_@ Father_Mig_@ Mother_Mig_@ Father_Mig_@_InterKabMig Mother_Mig_@_InterKabMig Father_Mig_@_IntraKabMig Mother_Mig_@_IntraKabMig, i(pidlink) j(year)
	
	rename (Father_Mig__InterKabMig Mother_Mig__InterKabMig Father_Mig__IntraKabMig Mother_Mig__IntraKabMig ) ///
	       (Father_Mig_InterKabMig_ Mother_Mig_InterKabMig_ Father_Mig_IntraKabMig_ Mother_Mig_IntraKabMig_)
		   
	* now remove years that are before entrance and years after exit

	by pidlink: drop if year<YearEnt
	
/* DO NOT IMPLEMENT a repeated grade expansion correction as this will cause problems

	* Prior to grade correction, keep the parent's migration events to remerge later
	preserve
		keep pidlink year Father_Mig_ Mother_Mig_ Father_Mig_InterKabMig_ Mother_Mig_InterKabMig_ Father_Mig_IntraKabMig_ Mother_Mig_IntraKabMig_
		 save "$maindir$tmp/Long Parental Mig.dta", replace
	restore
	
	* Generate school grades

	by pidlink (year): gen SchoolGrade=_n if Sch==1
	by pidlink: replace SchoolGrade=0 if MaxSchYrs==0 & _n==1

	* Correct for the grade repeats
	recode Grade* (.=0)
*/
	forvalues i=1/12{
		by pidlink: replace Grade`i'=0 if SchoolGrade!=`i'
	}

	egen GradeRepTotal=rsum(Grade*)
	
	drop flag_GrRep
	gen flag_Gr_Rep=(GradeRepTotal>0)
	
/*	replace GradeRepTotal=GradeRepTotal+1 if GradeRepTotal!=0
	order  pidlink- Grade12 GradeRepTotal
	
	* The above code will then expand the school grade according to the amount of times that Grade Repeats

	expand GradeRepTotal
	sort pidlink year SchoolGrade

	* correct years to account for extra grade repeats
	
	by pidlink: gen  YearAdjust=_n if _n>1 & SchoolGrade!=.
	by pidlink: egen  YearAdjust1=rank(YearAdjust) if YearAdjust!=.
	by pidlink: gen  Yearfix=YearEnt+YearAdjust1
	by pidlink: replace Yearfix=YearEnt if Yearfix==. &_n==1
	by pidlink: replace Yearfix=Yearfix[_n-1]+1 if Yearfix[_n]==.
	
	drop if Yearfix>2008
	
	replace year=Yearfix
	
	rename ( Father_Mig_ Father_Mig_InterKabMig_ Mother_Mig_ Mother_Mig_InterKabMig_ Father_Mig_IntraKabMig_ Mother_Mig_IntraKabMig_) ///
		   ( Father2_Mig_ Father2_Mig_InterKabMig_ Mother2_Mig_ Mother2_Mig_InterKabMig_ Father2_Mig_IntraKabMig_ Mother2_Mig_IntraKabMig_)

*/
		   
	drop Grade*  MigStart- Mother_MigEnd Year*
/*	
	merge m:m pidlink year using "$maindir$tmp/Long Parental Mig.dta", nogen
	erase "$maindir$tmp/Long Parental Mig.dta"
	
	drop Father2_Mig_- Mother2_Mig_IntraKabMig_
*/	
	drop if SchoolGrade==.
	
	* Rename to make it easier to create the migration event dummies
	
	rename (Father_Mig_ Father_Mig_InterKabMig_ Mother_Mig_ Mother_Mig_InterKabMig_ Father_Mig_IntraKabMig_ Mother_Mig_IntraKabMig_) ///
		   (Father_Mig_ Father_InterKabMig_ Mother_Mig_ Mother_InterKabMig_ Father_IntraKabMig_ Mother_IntraKabMig_)
	
	* Now create the school migration events
	
	foreach parent in Father Mother{
		foreach mig in Mig IntraKabMig InterKabMig{
			gen byte `parent'`mig'_Sch_= `parent'_`mig'_ * Sch_
		}
	}
	
	* Generate the failure event: use college entrance as the censoring point to capture those who finish
    * school and don't go to college (compeletion of all pre-tertiary schooling) 
	
	bysort pidlink (year): gen byte GradDropOut=(MaxSchYrs2<12 & _n==_N)
	
	* correct the parent's migration events to create mutually exclusive categories

	drop FaMig MoMig FaMoMig
	
		*Any Migration
		gen byte FaMig=FatherMig_Sch_
		replace FaMig=0 if FatherMig_Sch_==1 & MotherMig_Sch_==1
	
		gen byte MoMig=MotherMig_Sch_
		replace MoMig=0 if MotherMig_Sch_==1 & FatherMig_Sch_==1

		gen byte FaMoMig=1 if FatherMig_Sch_==1 & MotherMig_Sch_==1
		replace FaMoMig=0 if FatherMig_Sch_==0 & MotherMig_Sch_==0
		replace FaMoMig=0 if (FaMig==0 & MoMig==1)
		replace FaMoMig=0 if (MoMig==0 & FaMig==1)
	
		* Interkab Migration
		gen byte FaMigOK=FatherInterKabMig_Sch_
		replace FaMigOK=0 if FatherInterKabMig_Sch_==1 & MotherInterKabMig_Sch_==1

		gen byte MoMigOK=MotherInterKabMig_Sch_
		replace MoMigOK=0 if  MotherInterKabMig_Sch_==1 & FatherInterKabMig_Sch_==1

		gen byte FaMoMigOK=1 if MotherInterKabMig_Sch_==1 & FatherInterKabMig_Sch_==1
		replace FaMoMigOK=0 if MotherInterKabMig_Sch_==0 & FatherInterKabMig_Sch_==0
		replace FaMoMigOK=0 if (FaMigOK==0 & MoMigOK==1)
		replace FaMoMigOK=0 if (MoMigOK==0 & FaMigOK==1)
	
		* Intrakab Migration
		gen byte FaMigIK=FatherIntraKabMig_Sch_
		replace FaMigIK=0 if FatherIntraKabMig_Sch_==1 & MotherIntraKabMig_Sch_==1

		gen byte MoMigIK=MotherIntraKabMig_Sch_
		replace MoMigIK=0 if  MotherIntraKabMig_Sch_==1 & FatherIntraKabMig_Sch_==1

		gen byte FaMoMigIK=1 if MotherIntraKabMig_Sch_==1 & FatherIntraKabMig_Sch_==1
		replace FaMoMigIK=0 if MotherIntraKabMig_Sch_==0 & FatherIntraKabMig_Sch_==0
		replace FaMoMigIK=0 if (FaMigIK==0 & MoMigIK==1)
		replace FaMoMigIK=0 if (MoMigIK==0 & FaMigIK==1)
	
		drop *_Mig_* *Mig_*
		
	* Generate the lag of educational level
	by pidlink: gen byte SchGradelag=SchoolGrade[_n-1]
	by pidlink: replace SchGradelag=Kinder if /*lag==. &*/ Kinder==1 & _n==1
	by pidlink: replace SchGradelag=0 if SchGradelag==. & _n==1
	
	preserve
* fix this part to properly collapse and retain the variables of interest. 
		collapse (lastnm) year - GradDropOut (max) FaMig - FaMoMigIK, by (pidlink)
		save "$maindir$project/Survival dataset.dta" , replace
	
	restore
	
save "$maindir$project/Longitudinal Survival dataset.dta", replace


	
	
