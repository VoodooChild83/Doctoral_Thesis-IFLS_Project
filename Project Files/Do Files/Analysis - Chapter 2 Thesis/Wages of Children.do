* Child of parent who migrated

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
		
		drop if age<10
	
	* Create the 5 different markets
	
		gen Market=1 if (provmov>=11 & provmov<=19)
			
			replace Market= 2 if (provmov>=31 & provmov<=36)
			replace Market= 3 if (provmov>=51 & provmov<=53)
			replace Market= 4 if (provmov>=61 & provmov<=65)|provmov==21
			replace Market= 5 if (provmov>=71 & provmov<=76)
			replace Market= 6 if (provmov>=81 & provmov<=94)
			
			
	* Create Provincial and Intraprovincial migration events
	
		bys pidlink2 (year): gen InterProvMig=(pidlink2[_n]==pidlink2[_n-1] & provmov[_n]!=provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=. & pidlink!="")
			replace InterProvMig=. if provmov==. 
			
		bys pidlink2 (year): gen IntraProvMig=(pidlink2[_n]==pidlink2[_n-1] & provmov[_n]==provmov[_n-1] & provmov[_n]!=. & provmov[_n-1]!=. & kabmov[_n]!=kabmov[_n-1] &  kabmov[_n]!=. & kabmov[_n-1]!=. & pidlink!="")
			replace IntraProvMig=. if (kabmov==. & provmov!=.) | (kabmov!=. & provmov==.) | (kabmov==. & provmov==.)
		
	* Create the Market and Intramarket migration variable
	
		bys pidlink2 (year): gen InterMarketMig= (pidlink2[_n]==pidlink2[_n-1] & Market[_n]!=Market[_n-1] & Market[_n]!=. & Market[_n-1]!=. & pidlink!="")
			replace InterMarketMig=. if Market==.
			
		gen IntraMarketMig= (((IntraProvMig==1 | (InterMarketMig!=1 & InterProvMig==1)) & Market!=.))
			replace IntraMarketMig=. if Market==.
			
		collapseandpreserve (firstnm) pidlink_spouse pidlink_couple Market (max) InterProvMig IntraProvMig InterMarketMig IntraMarketMig, by(pidlink2) omitstatfromvarlabel
		
	* Pidlinks
	
		gen double pidlink_father=pidlink2
		gen double pidlink_mother=pidlink2
		
	* Rename variables
	
	foreach pers in father mother{
		foreach mig of varlist Inter* Intra*{
			gen `mig'_`pers'=`mig'
		}
	}
	
	drop *_father_mother InterProvMig IntraProvMig InterMarketMig IntraMarketMig pidlink2-Market
	
	save "$maindir$tmp/parentalmig.dta", replace
	
********************************************************************************
* Merge into the Transition Functions dataset that already has the dynastic information
	 
	use "$maindir$tmp/Transition Functions.dta", clear
	
	foreach pers in father mother {
		
			merge m:1 pidlink_`pers' using "$maindir$tmp/parentalmig.dta", keep(1 3) keepusing(*_`pers') nogen
	
	}
	
	foreach mig of varlist Inter*_father Intra*_father{
		local j=reverse(substr(reverse("`mig'"),7,.))
		egen `j'parent=rsum(`j'*), missing
			replace `j'parent=1 if `j'parent==2
	}
	
	keep pidlink2 Inter*_parent Intra*_parent
	
	save "$maindir$tmp/parentalmig.dta", replace
	
********************************************************************************
* Merge in the parental migration dummmies to the wage dataset
	
	use "$maindir$tmp/Wage Database2.dta", clear
	
	merge m:1 pidlink2 using "$maindir$tmp/parentalmig.dta", keep(1 3) nogen
		erase "$maindir$tmp/parentalmig.dta"
	
		bys pidlink2 (year): gen FirstWageChild=1 if _n==1 & InterProvMig_parent!=.
	
	save "$maindir$tmp/Wage Database2.dta", replace
