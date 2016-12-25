// IFLS East Merging of variable from the ar books to create the Master Tracker


********************************************************************************
// 1) Merge in the information from the Roster books

* Start merging in the variables that were in the same Master_Track for the IFLS survey

use "$maindir$wave_East/BK_AR1.dta", clear

* Merge in the pidlink identifier

merge 1:1 hhid12 pid12 using "$maindir$tmp/IFLS_East/pidlink.dta", keepusing(pidlink pwt) keep(1 3) nogen

* merge in the rest of the AR books (the rosters)

forvalues i=2/4 {

	merge 1:1 pid12 hhid12 using "$maindir$wave_East/BK_AR`i'.dta", nogen

}

********************************************************************************
// 2) Merge in the information from the location book

* Merge in the house hold locations from the sc book

merge m:1 hhid using "$maindir$wave_East/BK_SC1.dta", keepusing(sc01 sc02 sc03 sc05) keep(1 3) nogen

********************************************************************************
// 3) Start Renaming and organizng variables

* 1) Remove all the ar00a, ar00b, ... variables

drop ar00*

* 2) Rename variables to match Master_Tracker

rename (ar07 ar08yr ar09) (sex bth_year age)

replace bth_year=. if bth_year==9998

* 3) Drop all variables that end with an x

drop *x ar01d ar08day ar08mth ar15d_ot ar15a ar15b ar15c ar18a ar19d

* 4) Rename all variables to have 2012 at the end

foreach var of varlist ar* pwt sc05 age commid12 pid12 hhid12 {

	if substr("`var'",-2,.)=="12" & substr("`var'",1,2)!="ar" {
	
		local newname=reverse(substr(reverse("`var'"),3,.))
	
		rename `var' `newname'2012
	}
	
	else {
		rename `var' `var'2012
	}
	
}

rename (sc01 sc02 sc03) (provmov2012 kabmov2012 kecmov2012)

* 5) Keep in a seperate file the location of the schooling (this will be checked later in the eudcation module)

preserve

	keep pidlink ar20*
	
	rename (ar20d12012 ar20c12012 ar20b12012) (provmov kabmov kecmov)
	
	save "$maindir$tmp/IFLS_East/School_Location_2012.dta", replace

restore

drop ar20*

********************************************************************************
* IFLS East Person Weights

/* Adjust person weights to account for the fact that these are based on 2012 populations
   and we have to normalize to 1993 populations. For this we can estimate the population 
   in each of the provinces using data on the internet. We know that the person weights sum
   to the population of the region in 2012. So we can normalize this by taking the ratio of
   Pop_1993/Pop_2012, where Pop_2012 is the sum of person weights by province. */
   
* First, replace all values of province for Maluaku Utara with Maluaku since this was a 1999 split
* and we don't have population estimates for the split province

gen provmov_new=provmov2012

replace provmov_new=81 if provmov_new==82

* Generate the total population by province (sum the weights)

bysort provmov_new: egen PopTot=sum(pwt2012)

* Merge in the populations of the provinces

merge m:1 provmov_new using "$maindir$project/IFLS East Population Estimates/Population1993_IFLSEast.dta", keepusing(Population) keep(1 3) nogen

* Generate the ratio

gen Ratio= Population/PopTot

* Generate the person weight in 1993 population

gen pwt_new=pwt2012*Ratio

replace pwt2012=pwt_new

drop provmov_new pwt_new Population PopTot Ratio

save "$maindir$tmp/IFLS_East/Master_Track_IFLS_East.dta", replace




