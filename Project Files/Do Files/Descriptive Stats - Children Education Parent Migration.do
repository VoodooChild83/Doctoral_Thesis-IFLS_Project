// Analysis of Children's Education when Parents Migrate

/* This files is purely for the first pass analysis of the data to see if the idea
   that parents migation is correlated with children's educational outcome exists 
   in the data.
*/

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"


********************************************************************************
// Quietly do the file that builds the dataset

quietly do "$maindir$project/Do Files/Childrens Education Parents Migration.do"
** The above code will take forever to run because of the linkage correction do files

use "$maindir$project/linkage.dta"
********************************************************************************
// Descriptive stats

* The average number of children that moved between age 0 and age 12
	
	tab sex, sum (Moved012)
	tab UrbBirth, sum(Moved012)
	
	
* Average characteristics of children
	sum birthyr Child_AgeExit sex MaxSchYrs UrbBirth flag_GrRep Moved012 SpeakInd WriteInd ReadInd Kinder Admin
	
	bysort mig: sum birthyr Child_AgeExit sex MaxSchYrs UrbBirth flag_GrRep Moved012 SpeakInd WriteInd ReadInd Kinder Admin
	
		* Histogram
		hist age 
	
* School Years

sum MaxSchYrs ,d // All Children done with school whose parents have been identified

sum MaxSchYrs if  flag_OutSch==1,d // All adults done with school

	* By Sex
	tab sex, sum (MaxSchYrs)
	
		* Full Compulsory
		 tab UrbBirth if MaxSchYrs==9 , sum(sex)
		
		* Full Education
		 tab UrbBirth if MaxSchYrs==12 , sum(sex)
		 
		* Go to College
		tab UrbBirth if MaxSchYrs==13 , sum(sex)
	
		* By Urbanization
		 tab sex if   UrbBirth ==0, sum (MaxSchYrs)
		 * statistically significantly different (boys get more education)
		 
		 tab sex if  UrbBirth ==1, sum (MaxSchYrs)
		 * Not significantly different (girls get the same amount as boys)
		
		* By Marriage and Urbanization
		tab sex  if FaMoMarr==1 & UrbBirth ==0, sum (MaxSchYrs)
		tab sex  if Mother_marriage==1 & Father_marriage==0 & UrbBirth ==0, sum (MaxSchYrs)
		tab sex  if Mother_marriage==0 & Father_marriage==1 & UrbBirth ==0, sum (MaxSchYrs)
		tab sex  if FaMoMarr==0 & UrbBirth ==0, sum (MaxSchYrs) 
		
		tab sex  if FaMoMarr==1 & UrbBirth ==1, sum (MaxSchYrs)
		tab sex  if Mother_marriage==1 & Father_marriage==0 & UrbBirth ==1, sum (MaxSchYrs)
		tab sex  if Mother_marriage==0 & Father_marriage==1 & UrbBirth ==1, sum (MaxSchYrs)
		tab sex  if FaMoMarr==0 & UrbBirth ==1, sum (MaxSchYrs)

* Parent Characteristics

	* Parents
	sum *_MaxSchYrs *_UrbBirth *_TotalMoves flag_*_GrRep *_Admin *_SpeakInd *_WriteInd *_ReadInd *_Kinder  if Parents==1
	by mig: sum *_MaxSchYrs *_UrbBirth *_AgeSchStart *_TotalMoves flag_*_GrRep *_Admin *_SpeakInd *_WriteInd *_ReadInd *_Kinder  if Parents==1
	
	* parent age when first child born
	sum *_AgeBirth
	bysort mig: sum *_AgeBirth
	
	* Assortative Matching Contingency Table
	tab  Father_SchLvl Mother_SchLvl if FaMoMarr==1, chi ce exp
	
	* Family
	
	sum FamNumChild FamSize FamEduc FaMoMarr if Parents==1
	
	bysort mig: sum FamNumChild  FamSize FamEduc FaMoMarr if Parents==1
	
		* Kwallis Tests to identify if there are differences among the groupings
		
			 kwallis  FamNumChild, by(mig)
			 kwallis  FamSize, by(mig)
			 kwallis  FamEduc, by(mig)
			 kwallis  FaMoMarr if Parents==1, by(mig)
	
	* House Hold
	sum NumChild HHEduc HHsize
	sum NumChild HHEduc HHsize if MigHH==1
	sum NumChild HHEduc HHsize if MigHH==0
	

