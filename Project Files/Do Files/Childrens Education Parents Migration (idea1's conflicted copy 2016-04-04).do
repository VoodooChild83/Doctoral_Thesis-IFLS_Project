/* Finding the Migrant Parent's Children and obtaining the correlation of their educational
   attainment and the migration of their parents. c*/

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Do the Migration Consolidation Do file

*quietly do "$maindir$project/Do Files/Migration Consolidation.do"

********************************************************************************
// Do the Education dates for adults

*quietly do "$maindir$project/Do Files/EducationDates.do"

********************************************************************************
// Do the Cognitive Participation do file

quietly do "$maindir$project/Do Files/Cognitive Participation.do"

********************************************************************************
// Prepare the Birth Urbanization information
			
				use "$maindir$tmp/Birth-Age12geo.dta"
			
			preserve
			
				drop if stage==12
				
				save "$maindir$tmp/Birth-Age12geo2.dta", replace
				
			restore
			
********************************************************************************
// Impute the Education Start and End Years to create the Education Window

use "$maindir$project/MasterTrack2.dta"

	* Drop the observations that don't have a hhid
		drop if hhid==""

sort hhid wave pid

keep newid - flag_LastWave hhid mover birthyr age sex ar02b ar10-ar14 ar15* Max* flag_InSch flag_OutSch sc05
drop MaxMig newid
rename (sc05 ar02b wave ar10 ar11 ar13 ar14) (Urbanization Relate Wave Father Mother marriage marrpartner)

* Impute School Window starting from age=6 for those out of school	

	gen YearEnt=birthyr+6 if flag_OutSch==1
	gen YearExit=YearEnt+MaxSchYrs if flag_OutSch==1 & MaxSchYrs<13
	
	* Replace the Exit Year for those that have college education with 12
	
		replace YearExit=YearEnt+12 if flag_OutSch==1 & MaxSchYrs==13
	
	* For those who are currently in college, give them the full 12 years
		replace YearEnt=birthyr+6 if flag_InSch==1 & MaxSchYrs==13
		replace YearExit=YearEnt+12 if flag_InSch==1 & MaxSchYrs==13	
	
	* For those who are currently in school, give them only the entrance year
		replace YearEnt=birthyr+6 if flag_InSch==1
	
	* Fill in the Year Enter and Start for all waves
		bysort pidlink: egen YearEntSch=max(YearEnt)
		by pidlink: egen YearExitSch=max(YearExit)
		by pidlink: egen MaxSchYrs1=max(MaxSchYrs)
		
		replace YearEnt= YearEntSch
		replace YearExit= YearExitSch
		drop  YearEntSch YearExitSch
		
		replace MaxSchYrs=MaxSchYrs1 if MaxSchYrs==.
		drop MaxSchYrs1
		
********************************************************************************
// Merge in Cognitive Participation

merge m:1 pidlink using "$maindir$tmp/CognitiveTest.dta"

drop if _merge==2
drop _merge

replace CogTest=0 if CogTest==.
replace CogTestKidsAdult=0 if CogTestKidsAdult==.

erase "$maindir$tmp/CognitiveTest.dta"

********************************************************************************
// Merge in the Birth Urbanization information

merge m:1 pidlink using "$maindir$tmp/Birth-Age12geo2.dta", keepusing(UrbRurmov)

drop if _merge==2
drop _merge
				
erase "$maindir$tmp/Birth-Age12geo2.dta"
				
rename UrbRurmov UrbBirth
				
* recode some variables
	recode Urbanization UrbBirth (2=0)
	recode sex (3=0)

bysort pidlink: egen UrbBirth1=max(UrbBirth)
replace UrbBirth=UrbBirth1 if UrbBirth==.
drop UrbBirth1

********************************************************************************
// Merge in the consolidated migration information

merge m:m pidlink Wave using "$maindir$tmp/MigrationEvents-RepsurvDropConsolidated.dta", keepusing(Mig* TotalMoves Tally*)
drop if _merge==2
drop _merge

* Fix the Total Moves to reflect the total recorded in each wave
	egen TotalMoves2=rsum(Tally_IntraKecMig-Tally_IntraProvMig)

	replace TotalMoves=TotalMoves2
	drop TotalMoves2

drop TotalMoves Tally*

erase "$maindir$tmp/MigrationEvents-RepsurvDropConsolidated.dta"

********************************************************************************
// Merge in the grade repeats
sort pidlink
merge m:1 pidlink using "$maindir$project/EducStartStop.dta", gen(Educ_merge) keepusing(GrRep* *Ind Admin Kinder)
drop if Educ_merge==2

* Adjust the Year Exit dates to account for the grade repeats

	egen GrRep=rsum(GrRep*), missing

	*replace YearExit=YearExit+GrRep if YearExit!=. & GrRep!=.
	
	drop Educ_merge
	
	sort hhid Wave pid

********************************************************************************
// Correct the father and mother PID codes by generating new ones

* Identify the Cildren with Parents in the Household

	gen flag_parents=1 if (Relate==3 /*|Relate==10|Relate==13|Relate==14*/ ) & (Father<=51 | Mother<=51)
	
	drop newhhid
	
	sort hhid Wave Relate birthyr
	egen newhhid=group(hhid Wave)
	bysort newhhid (Relate birthyr): gen newid=_n
	
	order newhhid newid
	
	*save "$maindir$tmp/linkage.dta", replace
	
/* Run the following do-file to Correct the PID identifier for parents (especially 
   for parents whose PID does not point to same _n in a "by" grouping */

	preserve
		qui do "$maindir$project/Do Files/Linkage Correction.do"
	restore
	
	sort pidlink hhid Wave

	merge m:m newhhid newid using "$maindir$tmp/linkage2.dta", keepusing(Father2 Mother2) nogen

	erase "$maindir$tmp/linkage2.dta"

	order newhhid hhid newid pid pidlink Relate Father* Mother* flag_parents
	sort newhhid newid 

********************************************************************************
// Merge in the migration dummies.

preserve
	quietly do "$maindir$project/Do Files/Migration Year Dummies.do"
restore

*use "$maindir$tmp/linkage.dta"

merge m:1 pidlink using "$maindir$tmp/MigrationYeardummies.dta"

drop if _merge==2
drop _merge

erase "$maindir$tmp/MigrationYeardummies.dta"		
	 
********************************************************************************
// Link the Parental data to the child's data

* Find the Parent's migration events and link it to child's
	
	* Cycle through the data to link parent and child information
	
	levelsof Father2 if (Relate==3 /*|Relate==10|Relate==13|Relate==14*/ ) & Father2<51, local(dad)
	levelsof Mother2 if (Relate==3 /*|Relate==10|Relate==13|Relate==14*/ ) & Mother2<51, local(mom)
		
	foreach var in Father Mother{
			
		foreach mig in MigStart MigEnd MaxSchYrs marriage marrpartner CogTest CogTestKidsAdult birthyr UrbBirth ///
							   GrRep SpeakInd ReadInd WriteInd Admin Kinder Mig_1916 Mig_1916_InterKabMig       ///
							   Mig_1916_IntraKabMig Mig_1918 Mig_1918_InterKabMig Mig_1918_IntraKabMig Mig_1922 ///
							   Mig_1922_InterKabMig Mig_1922_IntraKabMig Mig_1924 Mig_1924_InterKabMig Mig_1924_IntraKabMig ///
							   Mig_1925 Mig_1925_InterKabMig Mig_1925_IntraKabMig Mig_1926 Mig_1926_InterKabMig ///
							   Mig_1926_IntraKabMig Mig_1927 Mig_1927_InterKabMig Mig_1927_IntraKabMig Mig_1928 ///
							   Mig_1928_InterKabMig Mig_1928_IntraKabMig Mig_1929 Mig_1929_InterKabMig Mig_1929_IntraKabMig ///
							   Mig_1930 Mig_1930_InterKabMig Mig_1930_IntraKabMig Mig_1931 Mig_1931_InterKabMig ///
							   Mig_1931_IntraKabMig Mig_1932 Mig_1932_InterKabMig Mig_1932_IntraKabMig Mig_1933 ///
							   Mig_1933_InterKabMig Mig_1933_IntraKabMig Mig_1934 Mig_1934_InterKabMig Mig_1934_IntraKabMig ///
							   Mig_1935 Mig_1935_InterKabMig Mig_1935_IntraKabMig Mig_1936 Mig_1936_InterKabMig ///
							   Mig_1936_IntraKabMig Mig_1937 Mig_1937_InterKabMig Mig_1937_IntraKabMig Mig_1938 ///
							   Mig_1938_InterKabMig Mig_1938_IntraKabMig Mig_1939 Mig_1939_InterKabMig Mig_1939_IntraKabMig ///
							   Mig_1940 Mig_1940_InterKabMig Mig_1940_IntraKabMig Mig_1941 Mig_1941_InterKabMig ///
							   Mig_1941_IntraKabMig Mig_1942 Mig_1942_InterKabMig Mig_1942_IntraKabMig Mig_1943 ///
							   Mig_1943_InterKabMig Mig_1943_IntraKabMig Mig_1944 Mig_1944_InterKabMig Mig_1944_IntraKabMig ///
							   Mig_1945 Mig_1945_InterKabMig Mig_1945_IntraKabMig Mig_1946 Mig_1946_InterKabMig ///
							   Mig_1946_IntraKabMig Mig_1947 Mig_1947_InterKabMig Mig_1947_IntraKabMig Mig_1948 ///
							   Mig_1948_InterKabMig Mig_1948_IntraKabMig Mig_1949 Mig_1949_InterKabMig Mig_1949_IntraKabMig ///
							   Mig_1950 Mig_1950_InterKabMig Mig_1950_IntraKabMig Mig_1951 Mig_1951_InterKabMig ///
							   Mig_1951_IntraKabMig Mig_1952 Mig_1952_InterKabMig Mig_1952_IntraKabMig Mig_1953 ///
							   Mig_1953_InterKabMig Mig_1953_IntraKabMig Mig_1954 Mig_1954_InterKabMig Mig_1954_IntraKabMig ///
							   Mig_1955 Mig_1955_InterKabMig Mig_1955_IntraKabMig Mig_1956 Mig_1956_InterKabMig ///
							   Mig_1956_IntraKabMig Mig_1957 Mig_1957_InterKabMig Mig_1957_IntraKabMig Mig_1958 ///
							   Mig_1958_InterKabMig Mig_1958_IntraKabMig Mig_1959 Mig_1959_InterKabMig Mig_1959_IntraKabMig ///
							   Mig_1960 Mig_1960_InterKabMig Mig_1960_IntraKabMig Mig_1961 Mig_1961_InterKabMig ///
							   Mig_1961_IntraKabMig Mig_1962 Mig_1962_InterKabMig Mig_1962_IntraKabMig Mig_1963 ///
							   Mig_1963_InterKabMig Mig_1963_IntraKabMig Mig_1964 Mig_1964_InterKabMig Mig_1964_IntraKabMig ///
							   Mig_1965 Mig_1965_InterKabMig Mig_1965_IntraKabMig Mig_1966 Mig_1966_InterKabMig ///
							   Mig_1966_IntraKabMig Mig_1967 Mig_1967_InterKabMig Mig_1967_IntraKabMig Mig_1968 ///
							   Mig_1968_InterKabMig Mig_1968_IntraKabMig Mig_1969 Mig_1969_InterKabMig Mig_1969_IntraKabMig ///
							   Mig_1970 Mig_1970_InterKabMig Mig_1970_IntraKabMig Mig_1971 Mig_1971_InterKabMig ///
							   Mig_1971_IntraKabMig Mig_1972 Mig_1972_InterKabMig Mig_1972_IntraKabMig Mig_1973 ///
							   Mig_1973_InterKabMig Mig_1973_IntraKabMig Mig_1974 Mig_1974_InterKabMig Mig_1974_IntraKabMig ///
							   Mig_1975 Mig_1975_InterKabMig Mig_1975_IntraKabMig Mig_1976 Mig_1976_InterKabMig ///
							   Mig_1976_IntraKabMig Mig_1977 Mig_1977_InterKabMig Mig_1977_IntraKabMig Mig_1978 ///
							   Mig_1978_InterKabMig Mig_1978_IntraKabMig Mig_1979 Mig_1979_InterKabMig Mig_1979_IntraKabMig ///
							   Mig_1980 Mig_1980_InterKabMig Mig_1980_IntraKabMig Mig_1981 Mig_1981_InterKabMig ///
							   Mig_1981_IntraKabMig Mig_1982 Mig_1982_InterKabMig Mig_1982_IntraKabMig Mig_1983 ///
							   Mig_1983_InterKabMig Mig_1983_IntraKabMig Mig_1984 Mig_1984_InterKabMig Mig_1984_IntraKabMig ///
							   Mig_1985 Mig_1985_InterKabMig Mig_1985_IntraKabMig Mig_1986 Mig_1986_InterKabMig ///
							   Mig_1986_IntraKabMig Mig_1987 Mig_1987_InterKabMig Mig_1987_IntraKabMig Mig_1988 ///
							   Mig_1988_InterKabMig Mig_1988_IntraKabMig Mig_1989 Mig_1989_InterKabMig Mig_1989_IntraKabMig ///
							   Mig_1990 Mig_1990_InterKabMig Mig_1990_IntraKabMig Mig_1991 Mig_1991_InterKabMig ///
							   Mig_1991_IntraKabMig Mig_1992 Mig_1992_InterKabMig Mig_1992_IntraKabMig Mig_1993 ///
							   Mig_1993_InterKabMig Mig_1993_IntraKabMig Mig_1994 Mig_1994_InterKabMig Mig_1994_IntraKabMig ///
							   Mig_1995 Mig_1995_InterKabMig Mig_1995_IntraKabMig Mig_1996 Mig_1996_InterKabMig ///
							   Mig_1996_IntraKabMig Mig_1997 Mig_1997_InterKabMig Mig_1997_IntraKabMig Mig_1998 ///
							   Mig_1998_InterKabMig Mig_1998_IntraKabMig Mig_1999 Mig_1999_InterKabMig Mig_1999_IntraKabMig ///
							   Mig_2000 Mig_2000_InterKabMig Mig_2000_IntraKabMig Mig_2001 Mig_2001_InterKabMig ///
							   Mig_2001_IntraKabMig Mig_2002 Mig_2002_InterKabMig Mig_2002_IntraKabMig Mig_2003 ///
							   Mig_2003_InterKabMig Mig_2003_IntraKabMig Mig_2004 Mig_2004_InterKabMig Mig_2004_IntraKabMig ///
							   Mig_2005 Mig_2005_InterKabMig Mig_2005_IntraKabMig Mig_2006 Mig_2006_InterKabMig ///
							   Mig_2006_IntraKabMig Mig_2007 Mig_2007_InterKabMig Mig_2007_IntraKabMig Mig_2008 ///
							   Mig_2008_InterKabMig Mig_2008_IntraKabMig {
								
				gen `var'_`mig'=.
				
				if "`var'"=="Father" {
				
					foreach d of local dad {
					
							bysort newhhid (newid): replace `var'_`mig'=`mig'[`d'] if flag_parents==1 & `var'2==`d' & `mig'[`d']!=.
					}
				}
				
				else {
				
					foreach m of local mom {
					
							bysort newhhid (newid): replace `var'_`mig'=`mig'[`m'] if flag_parents==1 & `var'2==`m' & `mig'[`m']!=.
					}
				}
				
				
		}
	}

	qui compress
********************************************************************************
// Birth Order

/*preserve*/

	foreach progeny in Child /*GrandChild Nephew Cousin*/ {
	
	if "`progeny'"=="Child" {
		local code=3
		bysort hhid Wave Father Mother (Relate birthyr): gen BO`progeny'=_n if flag_parents==1 & Relate==`code'
		bysort hhid Wave Father Mother (Relate birthyr): egen BO`progeny'2=rank(BO`progeny') if BO`progeny'!=.
		replace BO`progeny'=BO`progeny'2
		drop BO`progeny'2
		}
	/*if "`progeny'"=="GrandChild" {
		local code=10
		bysort hhid Wave Father Mother (Relate birthyr): gen BO`progeny'=_n if flag_parents==1 & Relate==`code'
		bysort hhid Wave Father Mother (Relate birthyr): egen BO`progeny'2=rank(BO`progeny') if BO`progeny'!=.
		replace BO`progeny'=BO`progeny'2
		drop BO`progeny'2
		}
	if "`progeny'"=="Nephew" {
		local code=13
		bysort hhid Wave Father Mother (Relate birthyr): gen BO`progeny'=_n if flag_parents==1 & Relate==`code'
		bysort hhid Wave Father Mother (Relate birthyr): egen BO`progeny'2=rank(BO`progeny') if BO`progeny'!=.
		replace BO`progeny'=BO`progeny'2
		drop BO`progeny'2
		}
	if "`progeny'"=="Cousin" {
		local code=14
		bysort hhid Wave Father Mother (Relate birthyr): gen BO`progeny'=_n if flag_parents==1 & Relate==`code'
		bysort hhid Wave Father Mother (Relate birthyr): egen BO`progeny'2=rank(BO`progeny') if BO`progeny'!=.
		replace BO`progeny'=BO`progeny'2
		drop BO`progeny'2
		}*/
	}

	egen BO=rsum(BO*), missing
	
	drop BOChild /*BOGrandChild BONephew BOCousin*/
	

********************************************************************************
// Find the Children whose parents migrated while they attended school

foreach var in Father Mother{

		gen InSch`var'Mig=.
		
		bysort hhid Wave (pid): replace InSch`var'Mig=1 if ((YearEnt<=`var'_MigStart & `var'_MigEnd<=YearExit) | ///
															(`var'_MigStart<=YearEnt & YearExit<=`var'_MigEnd) | ///
															(YearEnt<=`var'_MigStart & YearExit<=`var'_MigEnd &  ///
															!(`var'_MigStart>YearExit)) | (`var'_MigStart<=YearEnt ///
															& `var'_MigEnd<=YearExit & !(`var'_MigEnd<YearEnt))) & ///
															flag_parents==1 & `var'_MigStart!=. & `var'_MigEnd!=. & ///
															YearEnt!=. & YearExit!=. & `var'<51
		
		* Replace the parent's migration event with 0 for those children whose parents never migrated while they were in school
		replace InSch`var'Mig=0 if InSch`var'Mig==. & YearEnt!=. & YearExit!=. & flag_parents==1 & `var'<51
		
		}
		
********************************************************************************
// Generate School Year dummies

quietly sum YearEnt if flag_parents==1
local MinYear=`r(min)'
local MaxYear=`r(max)'

forvalues i=`MinYear'/`MaxYear' {

		gen byte Sch_`i'= (YearEnt<=`i' & (YearExit-1)>=`i' & flag_parents==1 & YearEnt!=. & YearExit!=. )  

}

********************************************************************************
//Clean the dataset: place all values in the person's last observed wave

* Generate Marriage of Parent:

gen FaMoMarr = ((Father_marriage==2 & Mother_marriage==2)|(Father_marriage==2 & Father_marrpartner<=51) ///
				|(Mother_marriage==2 & Mother_marrpartner<=51)|(Father_marriage==5 & Father_marrpartner==52) ///
				|(Mother_marriage==5 & Mother_marrpartner==52))
bysort pidlink: egen FaMoMarr2=max(FaMoMarr)
replace FaMoMarr=FaMoMarr2
replace FaMoMarr=. if flag_LastWave==.
drop FaMoMarr2

recode *marriage (1 3 4 5 6 7 8 9=0)
recode *marriage (2=1)

* Place all values in last observation

foreach parent in Father Mother{
	foreach var in `parent'_MigStart `parent'_MigEnd `parent'_MaxSchYrs InSch`parent'Mig ///
				   `parent'_CogTest `parent'_CogTestKidsAdult `parent'_birthyr `parent'_UrbBirth ///
				   `parent'_GrRep `parent'_SpeakInd `parent'_ReadInd `parent'_WriteInd `parent'_Admin `parent'_Kinder{
				   
					bysort pidlink: egen `var'1=max(`var')
					by pidlink: replace `var'=`var'1
					drop `var'1		
	}
}
	
* Generate flag that Identifies those where parent and children have participated in cognitive tests

gen flag_CogTest= (CogTest==1 &  Father_CogTest==1 &  Mother_CogTest==1)
by pidlink: egen flag_CogTest2=max(flag_CogTest)
replace flag_CogTest=flag_CogTest2
replace flag_CogTest=. if flag_LastWave==.
drop flag_CogTest2

gen flag_CogTest2= (CogTest==1 &  Father_CogTest==1) |  (CogTest==1 & Mother_CogTest==1)
by pidlink: egen flag_CogTest3=max(flag_CogTest2)
replace flag_CogTest2=flag_CogTest3
replace flag_CogTest2=. if flag_LastWave==.
drop flag_CogTest3

save "$maindir$tmp/linkage.dta"  , replace	

sort pidlink Wave

********************************************************************************
// Collapse the data 

collapse (lastnm) Wave sex MaxSchLvl *MaxSchYrs *Kinder GrRep *_GrRep *Admin *Ind ///
		 (firstnm) *birthyr BO Father Mother Father2 Mother2 Relate *_marriage ///
		 (lastnm) *YearEnt *YearExit Urbanization *UrbBirth *CogTest* FaMoMarr *MigStart *MigEnd InSch* ///
		 (max) GrRep1_1 GrRep2_1 GrRep3_1 GrRep4_1 GrRep5_1 GrRep6_1 GrRep1_2 GrRep2_2 GrRep3_2 GrRep1_3 GrRep2_3 GrRep3_3 ///
			   Mig_* *_Mig_* Sch_*, by (pidlink)

* Keep only the identified Children who have finished school and whose parents were identifiable

drop if InSchFatherMig==. & InSchMotherMig==.

********************************************************************************
// Organize and generate variables on family

* Original household is contained in the person's pidlink: break it apart - first 7 characters
	gen OrigHHid=substr(pidlink, 1,7)

	order pidlink OrigHHid
	
* Family ID

	sort OrigHHid Father Mother Mother_birthyr
	egen FamID=group (OrigHHid Father Mother)
	
	order pidlink OrigHHid FamID
	
* Reclassify the In School Parents Mig dummies to make them mutually exclusive

gen FaMig=InSchFatherMig
replace FaMig=0 if InSchFatherMig==1 & InSchMotherMig ==1

gen MoMig=InSchMotherMig
replace MoMig=0 if  InSchFatherMig==1 & InSchMotherMig ==1

gen FaMoMig=1 if InSchFatherMig==1 & InSchMotherMig ==1
replace FaMoMig=0 if InSchFatherMig==0 & InSchMotherMig ==0
replace FaMoMig=0 if (FaMig==0 & MoMig==1)
replace FaMoMig=0 if (MoMig==0 & FaMig==1)

* How many children moved from age 0 to age 12 location, if different?

	preserve

		keep pidlink
	
		gen id=_n
	
		merge 1:m pidlink using "$maindir$tmp/Birth-Age12geo.dta", keepusing(stage UrbRur* kecmov kabmov provmov)
		drop if _merge!=3
		drop _merge id
	
		egen id=concat(kecmov kabmov provmov) 

		bysort pidlink: gen Moved012= (id[2]!=id[1] & id!="")

		by pidlink: gen obs=_n if id!=""
		by pidlink: egen flag_finalobs2=max(obs)
		by pidlink: replace flag_finalobs2=. if flag_finalobs2!=obs
		recode flag_finalobs2 2=1

		by pidlink: replace Moved012=. if flag_finalobs2==.

		drop obs flag_finalobs2 id 

		drop if Moved012==.
	
		keep pidlink Moved012
	
		save "$maindir$tmp/birthage12moved.dta", replace
	
	restore
	
	merge 1:1 pidlink using "$maindir$tmp/birthage12moved.dta", nogen 
	erase "$maindir$tmp/birthage12moved.dta"

* Average Number of Children in a household (including generational children - grandchildren)

	* Identify the Number of households that remain and the average number of ichildren
	* in a household with identifiable parents (use this for clustering standard errors as well)

	bysort OrigHHid: gen obs=_n
	bysort OrigHHid: gen HH=1 if obs==_N
	by OrigHHid: egen NumChild=max(obs)
	replace NumChild=. if  HH==.
	drop obs HH

*  Num of Children in HH where at least one parent Migrates while at least one child is in School

	gen MigHH=(InSchFatherMig==1|InSchMotherMig==1)
	bysort OrigHHid: egen MigHH1=max(MigHH)
	replace MigHH=MigHH1
	by OrigHHid: gen obs=_n
	by OrigHHid: replace MigHH=. if obs!=_N
	drop MigHH1 obs

* Count the availability of parents in families (family and HH are different since there are more than one family in a HH)

	bysort OrigHHid Father Mother (Relate BO): gen Parents= 1 if _n==_N
	by OrigHHid Father Mother (Relate BO): gen Parents_Father= 1 if Father_birthyr!=. & _n==_N
	by OrigHHid Father Mother (Relate BO): gen Parents_Mother= 1 if Mother_birthyr!=. & _n==_N	
	
* Number of Children in a Family

	by OrigHHid: gen FamNumChild=BO if Parents==1
	
* Size of Families

	egen FamSize=rsum(FamNumChild Parents_*), missing
	
* Size of Households

bysort FamID (birthyr Mother_birthyr Father_birthyr Father Mother): gen obs=_n if _n==_N
egen FamParents=rsum(Parents_* obs)
bysort OrigHHid: egen HHsize=sum(FamParents)
bysort OrigHHid: replace HHsize=. if _n!=_N
drop obs FamParents
	
* Number of Families in a HouseHold

	bysort OrigHHid (pidlink): egen NumFam=sum(Parents)
	by OrigHHid: replace NumFam=. if _n!=_N
	
* Average Human Capital in Family
	egen FamEduc=rsum(*_MaxSchYrs)
	replace  FamEduc= FamEduc/2 if Parents_Father==1 & Parents_Mother==1
	replace FamEduc=. if Parents==.
	bysort FamID: egen FamEduc2=max(FamEduc)
	/* If either one of the parents is not in the household - single parent HH - then
	   leaving alone is the same as dividing by 1 */
	   
* Average Human Capital in Household
	bysort OrigHHid (pidlink): egen HHEducFathers=sum(Father_MaxSchYrs) if Parents_Father==1
	bysort OrigHHid (pidlink): egen HHEducMothers=sum(Mother_MaxSchYrs) if Parents_Mother==1
	egen HHEducTot=rsum(HHEduc*) if Parents==1
	by OrigHHid: egen HHEducTot2=max(HHEducTot)
	by OrigHHid: replace HHEducTot=HHEducTot2 if _n==_N
	by OrigHHid: replace HHEducTot=. if _n!=_N
	drop HHEducTot2 HHEducFathers HHEducMothers
	
	by OrigHHid: egen TotFathers=sum(Parents_Father) if Parents_Father==1
	by OrigHHid: egen TotMothers=sum(Parents_Mother) if Parents_Mother==1
	egen HHAdults=rsum(TotFathers TotMothers) if Parents==1
	by OrigHHid: egen HHAdults2=max(HHAdults)
	by OrigHHid: replace HHAdults=HHAdults2 if _n==_N
	by OrigHHid: replace HHAdults=. if _n!=_N
	drop TotFathers TotMothers HHAdults2
	
	gen HHEduc=HHEducTot/HHAdults
	drop HHEducTot HHAdults
	
sort pidlink BO

* Child's age when they leave school

gen Child_AgeExit=YearExit-birthyr

* Parent Age when First Child was born
bysort FamID (birthyr Father Mother): gen flag_FirstChild=1 if _n==1

gen Father_AgeBirth=birthyr-Father_birthyr if flag_FirstChild==1
gen Mother_AgeBirth=birthyr-Mother_birthyr if flag_FirstChild==1

* Proportion of Children/Parents with a grade repeat
gen flag_GrRep= (GrRep!=.)
gen flag_Father_GrRep=(Father_GrRep!=.) if Parents_Father==1
gen flag_Mother_GrRep=(Mother_GrRep!=.) if Parents_Mother==1

* Parent's schooling level

foreach parent in Father Mother{
	gen `parent'_SchLvl=0 if Parents==1 & `parent'_MaxSchYrs==0 & `parent'_MaxSchYrs!=.
	replace `parent'_SchLvl=1 if Parents==1 & `parent'_MaxSchYrs>0 & `parent'_MaxSchYrs<=6 & `parent'_MaxSchYrs!=.
	replace `parent'_SchLvl=2 if Parents==1 & `parent'_MaxSchYrs>6 & `parent'_MaxSchYrs<=9 & `parent'_MaxSchYrs!=.
	replace `parent'_SchLvl=3 if Parents==1 & `parent'_MaxSchYrs>9 & `parent'_MaxSchYrs<=12 & `parent'_MaxSchYrs!=.
	replace `parent'_SchLvl=4 if Parents==1 & `parent'_MaxSchYrs>12 & `parent'_MaxSchYrs!=.

}

* generate migration groups

			 egen mig=group(FaMig MoMig)
			 replace mig=1 if (FaMig==0|FaMig==.) & (MoMig==0 | MoMig==.)
			 replace mig=2 if (FaMig==1) & (MoMig==0 | MoMig==.)
			 replace mig=3 if (FaMig==0|FaMig==.) & (MoMig==1)
			 replace mig=4 if FaMoMig==1
			 
* Education in terms of share (demensionless)
	
		* Children
		
		gen ChildShare=MaxSchYrs/12
		replace ChildShare=1 if ChildShare>1 & ChildShare!=.
		 
	    * Parents
		
		gen Father_Share=Father_MaxSchYrs/12
		replace Father_Share=1 if Father_Share>1 & Father_Share!=.
		
		gen Mother_Share=Mother_MaxSchYrs/12
		replace Mother_Share=1 if Mother_Share>1 & Mother_Share!=.
		
		gen MaxSchYrs2=ChildShare*12
		gen Father_MaxSchYrs2=Father_Share*12
		gen Mother_MaxSchYrs2=Mother_Share*12
		
		order pidlink -MaxSchLvl MaxSchYrs* ChildShare Father_MaxSchYrs* Father_Share Mother_MaxSchYrs* Mother_Share
		
********************************************************************************
//Generate interaction variables
	
* BO
	gen SexBO=sex*BO
	
* Sex Urb
	gen SexUrbBirth=UrbBirth*sex


save "$maindir$project/linkage.dta", replace
erase "$maindir$tmp/linkage.dta"

/* * This Code to use the actual information in the survey

use "$maindir$project/MasterTrack2.dta"

merge m:1 pidlink using "$maindir$project/EducStartStop.dta", gen(Educ_merge) keepusing(GrRep)

drop if Educ_merge==2
replace Educ_merge=. if flag_LastWave!=.
*drop _merge

// Impute the missing School Start Years based on an age=6 enter date for primary

replace YearEntSch=. if flag_LastWave!=1
replace YearExitSch=. if flag_LastWave!=1

gen flag_ImpYrSchEnt=1 if YearEntSch==. & flag_LastWave==1 & Educ_merge==3 // flag those who will be imputed
replace YearEntSch=birthyr+6 if flag_ImpYrSchEnt==1 & MaxSchLvl>=1

gen flag_ImpYrSchExt=1 if YearExitSch==. & flag_LastWave==1 & Educ_merge==3
replace YearExitSch=birthyr+6+MaxSchYrs if flag_ImpYrSchExt==1 & MaxSchLvl>=1

drop Educ_merge
*/
********************************************************************************
