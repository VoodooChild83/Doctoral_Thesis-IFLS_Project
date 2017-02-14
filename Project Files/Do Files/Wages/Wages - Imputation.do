* Test file for learning how to impute in STATA

********************************************************************************
* Do (or use) the file that gets us the wage database

qui do "$maindir$project$Do/Wages/Consolidate Wages - Longitudinal Data.do"

********************************************************************************
* Append the IPUMS dataset
/*
preserve

	use "$maindir$project$ipums/Project Files/Census Wage Data.dta", clear
	
	* update IPUMS occupation codes to harmonize

	replace occ2="0X" if occ2=="00"
	replace occ2="08" if occ2=="0X"|occ2=="09"
	replace occ2="21" if occ2=="24"
	replace occ2="26" if occ2=="27"
	replace occ2="45" if occ2=="48"|occ2=="49"|occ2=="4X"
	replace occ2="89" if occ2=="8X"
	replace occ2="95" if occ2=="96"
	replace occ2="99" if occ2=="9X"|occ2=="999"
	replace occ2="100" if occ2=="X2"|occ2=="XX"
	replace occ2="79" if occ2=="7X"
	replace occ2="75" if occ2=="76"
	replace occ2="64" if occ2=="69"
	replace occ2="51" if occ2=="52"|occ2=="50"
	replace occ2="29" if occ2=="2X"
	replace occ2="05" if occ2=="04"
	replace occ2="35" if occ2=="34"
	replace occ2="28" if occ2=="29"
	replace occ2="86" if occ2=="87"
	replace occ2="90" if occ2=="91"
	replace occ2="01" if occ2=="02"
	replace occ2="00" if occ2=="MM"|occ2=="M1"|occ2=="M2"
	replace occ2="39" if occ2=="3X"
	
	save "$maindir$tmp/IPUMS.dta", replace
	
restore

append using "$maindir$tmp/IPUMS.dta"
erase "$maindir$tmp/IPUMS.dta"
*/	
* Drop the second job 

	drop if job==2
	
save  "$maindir$tmp/Wage Database1.dta", replace
	
********************************************************************************
* Generate the markets for imputation

	* the Island of Sumatra and Jawa are one market; the other provinces across other 
	* islands are all another market
	
		gen Market=1 if (provmov>=11 & provmov<=19)
			
			replace Market= 2 if (provmov>=31 & provmov<=36)
			replace Market= 3 if (provmov>=51 & provmov<=53)
			replace Market= 4 if (provmov>=61 & provmov<=65)|provmov==21
			replace Market= 5 if (provmov>=71 & provmov<=76)
			replace Market= 6 if (provmov>=81 & provmov<=94)
			
	* generate a market migration event
	
		bys pidlink2 (year): gen InterMarketMig= (pidlink[_n]==pidlink[_n-1] & Market[_n]!=Market[_n-1] & Market[_n]!=. & Market[_n-1]!=. & pidlink!="")
			replace InterMarketMig=. if Market==.
		*gen IntraMarketMig= ((IntraProvMig==1 | (InterMarketMig!=1 & InterProvMig==1) & Market!=.))
		gen IntraMarketMig= (InterMarketMig!=1 & InterProvMig==1 & Market!=.)
			replace IntraMarketMig=. if Market==.
		
	* generate the forever migrant - MUST FIX THE CONTINUATION VALUE VARIABLE
	
		gen MarketMover=InterMarketMig
			bys pidlink2: replace MarketMover=1 if pidlink[_n]==pidlink[_n-1] & MarketMover[_n-1]==1
		gen IntraMarketMover=IntraMarketMig
			bys pidlink2: replace IntraMarketMover=1 if pidlink[_n]==pidlink[_n-1] & IntraMarketMover[_n-1]==1
			
		* Update the
		
********************************************************************************
* Generate the variables for imputation (collapse the occupation codes for 
* low observation counts in the distinct markets)
			
* gen log hours work
	
	gen ln_hrs_wk=ln(hrs_wk)
	
* generate the fixed effects for years
	
	*qui tab year if year>1960, gen(year_fe)
	
* replace military code with 200
	
		replace occ2="200" if occ2=="00"
		
* replace farmers as 600
		replace occ2="600" if occ2=="62"
		
* realize occupation string

	gen int Occupation=real(occ2)
	
* gen the aggragate occupations

	gen AggOcc=int(Occupation/10)
	
* replace as missing those wages that are extreme

	replace ln_wage_hr=. if (provmov==36|provmov==76|provmov==91|provmov==94) & r_wage_hr>50 & r_wage_hr!=.
	replace r_wage_hr=. if (provmov==36|provmov==76|provmov==91|provmov==94) & r_wage_hr>50 & r_wage_hr!=.
	
* make sure those with 0 wages are not imputed

	gen flag_0wage=1 if r_wage_hr==0
	
********************************************************************************
* Impute the wages using (PMM) 

* Prepare data for imputation

	mi set flongsep wagesimp
	
	mi register imputed ln_wage_hr 
	
	mi register regular pidlink-occ2 hrs_wk wks_yr hrs_mth hrs_yr mth_yr r_wage_hr r_wage_mth-IntraMarketMover ln_hrs_wk Occupation AggOcc

* Impute missing values using the mincer regression equation

	mi impute pmm ln_wage_hr=MaxSchYrs age age_2 Sex Urban Religion InterMarketMig IntraMarketMig if year>=1961 & flag_0wage!=1, add(1) by(AggOcc Market) force knn(3)
	
* Extract the file

	mi extract 1
		drop __000000 __000002
		
	erase wagesimp.dta
	erase _1_wagesimp.dta
	/*
	 drop if version=="IPUMS"
		drop serial-Literacy
	*/
********************************************************************************
* Update the impute real wages based on the imputed values of log wages

	replace r_wage_hr=exp(ln_wage_hr) if r_wage_hr==. & ln_wage_hr!=. & flag_0wage!=1
	
* Generate the markets for solving the dynamic program (keep Sumatra as the main island group)

	recode Market (1 = 1) (2/5=0), gen(Market2)
	
	gen Schooling=(SchLvl>0)
	
	* Generate the median wages in both markets according to schooling 
	
		bys Market2 Schooling: egen Med_Wage=median(ln_wage_hr) if age>=18
		
	* Generate median of child wages
	
		 bys Market2: egen Med_Wage_Child=median(ln_wage_hr) if age<18
		 bys Market2 Schooling: egen Med_Wage_Child2=median(ln_wage_hr) if age<18
		
	* Obtain the median wages in the two markets
	
		tab Market2 Schooling if r_wage_hr!=., sum(Med_Wage)
		tab Market2, sum(Med_Wage_Child)
		tab Market2 Schooling, sum(Med_Wage_Child2)
		
	compress pidlink-year_start kecmov-Med_Wage	
	
	replace occ2="00" if occ2=="200" 
	replace occ2="62" if occ2=="600"
