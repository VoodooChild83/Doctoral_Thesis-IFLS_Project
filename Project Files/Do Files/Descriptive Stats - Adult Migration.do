// Descriptive Statistics generation

** This file will do the topline descriptive statistics (keep adding to it as time goes by
** And more information is accumulated)

cd "/Users/idiosyncrasy58/" 

clear

********************************************************************************
//Set global directory information for files

*quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
quietly do "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Do the Year-Share Migrants 2 do file

quietly do "$maindir$project/Do Files/Year-Share Migrants.do"

********************************************************************************
// Summary Statistics: Cleaning Variables

use "$maindir$project/Migration Movements/Year-Share.dta"

	* First, identify migrants as migrants throughout all waves
	
	by pidlink: egen mover2=max(mover)
	replace mover=mover2
	drop mover2
	replace mover=0 if mover==.
	
	* Second, find the final observation for each person
	
	by pidlink: g obs=_n if stage>=15
	by pidlink: g flag_finalobs=1 if obs==_N
	drop obs
	
	replace mover=. if flag_finalobs==.
	
	* Third, recode the Tally & sex variables to 0 if they are missing
	
	recode *Tally_* (.=0)
	recode sex (3=0)
	
	* Fourth, generate flags for Migration Movements
	
		foreach mig in /*"IntraKec" "IntraKab" "IntraProv"*/ InterProv InterIntraProv {
				
				if "`mig'"=="InterIntraProv" gen flag_`mig'_Cohort=1 if Cohort_Tally_IntraProvMig>0 | Cohort_Tally_InterProvMig>0
				
				else gen flag_`mig'_Cohort=1 if  Cohort_Tally_`mig'Mig>0
				
				replace  flag_`mig'_Cohort=0 if  flag_`mig'_Cohort==.
				bysort pidlink Cohort (stage): egen flag_`mig'max=max(flag_`mig'_Cohort)  /* Now fill in information for all the migrants */
				replace flag_`mig'_Cohort=flag_`mig'max
				drop *_`mig'max
				replace  flag_`mig'_Cohort=. if flag_finalobsCohort==.
				}
				
	* Repeat Movers at the Intra- & InterProvincial level of migration movements (those with migration events that are greater than 1)
	
		by pidlink Cohort (stage): gen flag_RepeatMoves=1 if (Cohort_Tally_IntraProvMig>1 |  Cohort_Tally_InterProvMig>1)
		by pidlink Cohort (stage): replace flag_RepeatMoves=0 if (Cohort_Tally_IntraProvMig==1 |  Cohort_Tally_InterProvMig==1)
		by pidlink Cohort (stage): egen flag_RepeatMoves2=max(flag_RepeatMoves)
		replace flag_RepeatMoves=flag_RepeatMoves2
		replace flag_RepeatMoves=. if flag_InterIntraProv_Cohort==.
		drop flag_RepeatMoves2
		
	* Repeat Movers (for any migration movement)
		
		by pidlink Cohort (stage): gen flag_RepeatMoves_All=1 if TotalMovesCohort>1 & moverCohort==1
		by pidlink Cohort (stage): replace flag_RepeatMoves_All=0 if TotalMovesCohort==1 & moverCohort==1
	
	* Schooling Levels
	
	gen flag_Schooling=0 if MaxSchLvl<=0 //No schooling or kindergarten only
	replace flag_Schooling=1 if MaxSchLvl==1
	replace flag_Schooling=2 if MaxSchLvl==2
	replace flag_Schooling=3 if MaxSchLvl==3
	replace flag_Schooling=4 if MaxSchLvl>3
	replace flag_Schooling=. if MaxSchYrs==.
	replace flag_Schooling=. if flag_finalobsCohort==.

	* Total Moves
	bysort pidlink (wave): egen TotalMoves2=sum(movenum)
	replace TotalMoves2=. if flag_finalobs==.
	replace TotalMoves=TotalMoves2
	drop TotalMoves2
	
********************************************************************************
// Proportion of individuals who move from birth to age-12 location

egen id=concat(kecmov kabmov provmov) if stage==0 | stage==12

by pidlink: gen Moved=1 if id[2]!=id[1] & id!=""
by pidlink: replace Moved=0 if id[2]==id[1] & id!=""

by pidlink: gen obs=_n if id!=""
by pidlink: egen flag_finalobs2=max(obs)
by pidlink: replace flag_finalobs2=. if flag_finalobs2!=obs
recode flag_finalobs2 2=1

by pidlink: replace Moved=. if flag_finalobs2==.

drop obs flag_finalobs2 id 

by pidlink: egen Moved2=max(Moved)
by pidlink: gen obs=_n
by pidlink: replace Moved2=. if obs!=_N
replace Moved=Moved2

drop Moved2 obs
		
********************************************************************************
* Interisland migrations
	
	* Sumatra-Bangka
	
	* Sumatra to Java:
	bysort pidlink (stage): gen flag_SumJava=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=11 & provmov[_n]<=19) & (provmov[_n+1]>=31 & provmov[_n+1]<=36) ) | ((provmov[_n]>=31 & provmov[_n]<=36) & (provmov[_n+1]>=11 & provmov[_n+1]<=19)  )
	bysort pidlink Cohort (stage): egen flag_SumJava_total=sum(flag_SumJava), missing
	by pidlink Cohort (stage): egen  flag_SumJava1=max( flag_SumJava)
	replace  flag_SumJava= flag_SumJava1
	drop flag_SumJava1
	count if flag_SumJava==1 & flag_finalobs==1		//1286 people
	
	* Sumatra Bali
	bysort pidlink (stage): gen flag_SumBali=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=11 & provmov[_n]<=19) & (provmov[_n+1]==51) ) | ((provmov[_n]==51) & (provmov[_n+1]>=11 & provmov[_n+1]<=19)  )
	bysort pidlink Cohort (stage): egen flag_SumBali_total=sum(flag_SumBali), missing
	by pidlink Cohort (stage): egen  flag_SumBali1=max( flag_SumBali)
	replace  flag_SumBali= flag_SumBali1
	drop flag_SumBali1
	count if flag_SumBali==1 & flag_finalobs==1	// 9 people
	
	* Sumatra to Kalimantan
	bysort pidlink (stage): gen flag_SumKal=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=11 & provmov[_n]<=19) & (provmov[_n+1]>=61 & provmov[_n+1]<=65) ) | ((provmov[_n]>=61 & provmov[_n]<=65) & (provmov[_n+1]>=11 & provmov[_n+1]<=19)  )
	bysort pidlink Cohort (stage): egen flag_SumKal_total=sum(flag_SumKal), missing
	by pidlink Cohort (stage): egen  flag_SumKal1=max( flag_SumKal)
	replace  flag_SumKal= flag_SumKal1
	drop flag_SumKal1
	count if flag_SumKal==1 & flag_finalobs==1		//39 people
	
	* Sumatra to Sulawesi
	bysort pidlink (stage): gen flag_SumSuw=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=11 & provmov[_n]<=19) & (provmov[_n+1]>=71 & provmov[_n+1]<=76) ) | ((provmov[_n]>=71 & provmov[_n]<=76) & (provmov[_n+1]>=11 & provmov[_n+1]<=19)  )
	bysort pidlink Cohort (stage): egen flag_SumSuw_total=sum(flag_SumSuw), missing
	by pidlink Cohort (stage): egen  flag_SumSuw1=max( flag_SumSuw)
	replace  flag_SumKal= flag_SumSuw1
	drop flag_SumSuw1
	count if flag_SumSuw==1 & flag_finalobs==1 //0 people
	
	* Sumatra Nusa(East-West)
	bysort pidlink (stage): gen flag_SumNus=1 if provmov[_n]!=provmov[_n+1] & (provmov[_n]>=11 & provmov[_n]<=19 & provmov[_n+1]>=52 & provmov[_n+1]<=53 ) | (provmov[_n]>=52 & provmov[_n]<=53 & provmov[_n+1]>=11 & provmov[_n+1]<=19  )
	bysort pidlink Cohort (stage): egen flag_SumNus_total=sum(flag_SumNus), missing
	by pidlink Cohort (stage):egen  flag_SumNus1=max( flag_SumNus)
	replace  flag_SumKal= flag_SumNus1
	drop flag_SumNus1
	count if flag_SumNus==1 & flag_finalobs==1 //0 people
	
	* Sumatra to Maluku(North-South)
	bysort pidlink (stage):gen flag_SumMal=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=11 & provmov[_n]<=19) & (provmov[_n+1]>=81 & provmov[_n+1]<=82) ) | ((provmov[_n]>=81 & provmov[_n]<=82) & (provmov[_n+1]>=11 & provmov[_n+1]<=19)  )
	bysort pidlink Cohort (stage): egen flag_SumMal_total=sum(flag_SumMal), missing
	by pidlink Cohort (stage): egen  flag_SumMal1=max( flag_SumMal)
	replace  flag_SumMal= flag_SumMal1
	drop flag_SumMal1
	count if flag_SumMal==1 & flag_finalobs==1 //2 people
	
	* Sumatra Papua
	bysort pidlink (stage): gen flag_SumPapua=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=11 & provmov[_n]<=19) & (provmov[_n+1]>=91 & provmov[_n+1]<=94) ) | ((provmov[_n]>=91 & provmov[_n]<=94) & (provmov[_n+1]>=11 & provmov[_n+1]<=19)  )
	bysort pidlink Cohort (stage): egen flag_SumPapua_total=sum(flag_SumPapua), missing
	by pidlink Cohort (stage): egen  flag_SumPapua1=max( flag_SumPapua)
	replace  flag_SumPapua= flag_SumPapua1
	drop flag_SumPapua1							//6 people
	count if flag_SumPapua==1 & flag_finalobs==1 
	
	* Java
	
	* Java Kalimantan
	bysort pidlink (stage): gen flag_JakKal=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=31 & provmov[_n]<=36) & (provmov[_n+1]>=61 & provmov[_n+1]<=65) ) | ((provmov[_n]>=61 & provmov[_n]<=65) & (provmov[_n+1]>=31 & provmov[_n+1]<=36)  )
	bysort pidlink Cohort (stage): egen flag_JakKal_total=sum(flag_JakKal), missing
	by pidlink Cohort (stage):egen  flag_JakKal1=max( flag_JakKal)
	replace  flag_JakKal= flag_JakKal1
	drop flag_JakKal1							//321 people
	count if flag_JakKal==1 & flag_finalobs==1 
	
	* Java Bali
	bysort pidlink (stage): gen flag_JakBali=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=31 & provmov[_n]<=36) & (provmov[_n+1]==51) ) | ((provmov[_n]==51) & (provmov[_n+1]>=31 & provmov[_n+1]<=36)  )
	bysort pidlink Cohort (stage): egen flag_JakBali_total=sum(flag_JakBali), missing
	by pidlink Cohort (stage): egen  flag_JakBali1=max( flag_JakBali)
	replace  flag_JakBali= flag_JakBali1
	drop flag_JakBali1
	count if flag_JakBali==1 & flag_finalobs==1 // 183 people
	
	* Java Nusa(East-West)
	bysort pidlink (stage): gen flag_JakNus=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=31 & provmov[_n]<=36) & (provmov[_n+1]>=52 & provmov[_n+1]<=53) ) | ((provmov[_n]>=52 & provmov[_n]<=53) & (provmov[_n+1]>=31 & provmov[_n+1]<=36)  )
	bysort pidlink Cohort (stage): egen flag_JakNus_total=sum(flag_JakNus), missing
	by pidlink Cohort (stage): egen  flag_JakNus1=max( flag_JakNus)
	replace  flag_JakNus= flag_JakNus1
	drop flag_JakNus1							//82 people
	count if flag_JakNus==1 & flag_finalobs==1 
	
	* Java Sulawesi
	bysort pidlink (stage): gen flag_JakSul=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=31 & provmov[_n]<=36) & (provmov[_n+1]>=71 & provmov[_n+1]<=76) ) | ((provmov[_n]>=71 & provmov[_n]<=76) & (provmov[_n+1]>=31 & provmov[_n+1]<=36)  )
	bysort pidlink Cohort (stage): egen flag_JakSul_total=sum(flag_JakSul), missing
	by pidlink Cohort (stage): egen  flag_JakSul1=max( flag_JakSul)
	replace  flag_JakSul= flag_JakSul1
	drop flag_JakSul1							//78 people
	count if flag_JakSul==1 & flag_finalobs==1 
	
	* Java Maluku(North-South)
	bysort pidlink (stage): gen flag_JakMal=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=31 & provmov[_n]<=36) & (provmov[_n+1]>=81 & provmov[_n+1]<=82) ) | ((provmov[_n]>=81 & provmov[_n]<=82) & (provmov[_n+1]>=31 & provmov[_n+1]<=36)  )
	bysort pidlink Cohort (stage): egen flag_JakMal_total=sum(flag_JakMal), missing
	by pidlink Cohort (stage): egen  flag_JakMal1=max( flag_JakMal)
	replace  flag_JakMal= flag_JakMal1
	drop flag_JakMal1							//43 people
	count if flag_JakMal==1 & flag_finalobs==1 
	
	* Java Papua(West-East)
	bysort pidlink (stage): gen flag_JakPapua=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=31 & provmov[_n]<=36) & (provmov[_n+1]>=91 & provmov[_n+1]<=94) ) | ((provmov[_n]>=91 & provmov[_n]<=94) & (provmov[_n+1]>=31 & provmov[_n+1]<=36)  )
	bysort pidlink Cohort (stage): egen flag_JakPapua_total=sum(flag_JakPapua), missing
	by pidlink Cohort (stage): egen  flag_JakPapua1=max( flag_JakPapua)
	replace  flag_JakPapua= flag_JakPapua1
	drop flag_JakPapua1							//16 people
	count if flag_JakPapua==1 & flag_finalobs==1 
	
	* Kalimatan
	
	* Kalimatan Sulawesi
	bysort pidlink (stage): gen flag_KalSul=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=61 & provmov[_n]<=65) & (provmov[_n+1]>=71 & provmov[_n+1]<=76) ) | ((provmov[_n]>=71 & provmov[_n]<=76) & (provmov[_n+1]>=61 & provmov[_n+1]<=65)  )
	bysort pidlink Cohort (stage): egen flag_KalSul_total=sum(flag_KalSul), missing
	by pidlink Cohort (stage): egen  flag_KalSul1=max( flag_KalSul)
	replace  flag_KalSul= flag_KalSul1
	drop flag_KalSul1							//84 people
	count if flag_KalSul==1 & flag_finalobs==1
	
	* Kalimatan Bali
	bysort pidlink (stage): gen flag_KalBali=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=61 & provmov[_n]<=65) & (provmov[_n+1]==51) ) | ((provmov[_n]==51) & (provmov[_n+1]>=61 & provmov[_n+1]<=65)  )
	bysort pidlink Cohort (stage): egen flag_KalBali_total=sum(flag_KalBali), missing
	by pidlink Cohort (stage): egen  flag_KalBali1=max( flag_KalBali)
	replace  flag_KalBali= flag_KalBali1
	drop flag_KalBali1
	count if flag_KalBali==1 & flag_finalobs==1 //4 people
	
	* Kalimatan Nusa(East-West)
	bysort pidlink (stage): gen flag_KalNus=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=61 & provmov[_n]<=65) & (provmov[_n+1]>=52 & provmov[_n+1]<=53) ) | ((provmov[_n]>=52 & provmov[_n]<=53) & (provmov[_n+1]>=61 & provmov[_n+1]<=65)  )
	bysort pidlink Cohort (stage): egen flag_KalNus_total=sum(flag_KalNus), missing
	by pidlink Cohort (stage): egen  flag_KalNus1=max( flag_KalNus)
	replace  flag_KalNus= flag_KalNus1
	drop flag_KalNus1							//20 people
	count if flag_KalNus==1 & flag_finalobs==1
	
	* Kalimatan Maluku(North-South)
	bysort pidlink (stage): gen flag_KalMal=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=61 & provmov[_n]<=65) & (provmov[_n+1]>=81 & provmov[_n+1]<=82) ) | ((provmov[_n]>=81 & provmov[_n]<=82) & (provmov[_n+1]>=61 & provmov[_n+1]<=65)  )
	bysort pidlink Cohort (stage): egen flag_KalMal_total=sum(flag_KalMal), missing
	by pidlink Cohort (stage): egen  flag_KalMal1=max( flag_KalMal)
	replace  flag_KalMal= flag_KalMal1
	drop flag_KalMal1							//4 people
	count if flag_KalMal==1 & flag_finalobs==1
	
	* Kalimatan Papua(East-West)
	bysort pidlink (stage):gen flag_KalPapua=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=61 & provmov[_n]<=65) & (provmov[_n+1]>=91 & provmov[_n+1]<=94 )) | ((provmov[_n]>=91 & provmov[_n]<=94) & (provmov[_n+1]>=61 & provmov[_n+1]<=65)  )
	bysort pidlink Cohort (stage): egen flag_KalPapua_total=sum(flag_KalPapua), missing
	by pidlink Cohort (stage): egen  flag_KalPapua1=max( flag_KalPapua)
	replace  flag_KalPapua= flag_KalPapua1
	drop flag_KalPapua1							//1 people
	count if flag_KalPapua==1 & flag_finalobs==1
	
	* Sulawesi
	
	*Sulawesi Bali
	bysort pidlink (stage): gen flag_SulBali=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=71 & provmov[_n]<=76) & (provmov[_n+1]==51) ) | ((provmov[_n]==51) & (provmov[_n+1]>=71 & provmov[_n+1]<=76)  )
	bysort pidlink Cohort (stage): egen flag_SulBali_total=sum(flag_SulBali), missing
	by pidlink Cohort (stage): egen  flag_SulBali1=max( flag_SulBali)
	replace  flag_SulBali= flag_SulBali1
	drop flag_SulBali1
	count if flag_SulBali==1 & flag_finalobs==1 //17 people
	
	* Sulawesi Nusa(East-West)
	bysort pidlink (stage): gen flag_SulNus=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=71 & provmov[_n]<=76) & (provmov[_n+1]>=52 & provmov[_n+1]<=53) ) | ((provmov[_n]>=52 & provmov[_n]<=53) & (provmov[_n+1]>=71 & provmov[_n+1]<=76)  )
	bysort pidlink Cohort (stage): egen flag_SulNus_total=sum(flag_SulNus), missing
	by pidlink Cohort (stage):egen  flag_SulNus1=max( flag_SulNus)
	replace  flag_SulNus= flag_SulNus1
	drop flag_SulNus1							//28 people
	count if flag_SulNus==1 & flag_finalobs==1
	
	* Sulawesi Maluku(North-South)
	bysort pidlink (stage):gen flag_SulMal=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=71 & provmov[_n]<=76) & (provmov[_n+1]>=81 & provmov[_n+1]<=82) ) | ((provmov[_n]>=81 & provmov[_n]<=82) & (provmov[_n+1]>=71 & provmov[_n+1]<=76)  )
	bysort pidlink Cohort (stage): egen flag_SulMal_total=sum(flag_SulMal), missing
	by pidlink Cohort (stage): egen  flag_SulMal1=max( flag_SulMal)
	replace  flag_SulMal= flag_SulMal1
	drop flag_SulMal1							//20 people
	count if flag_SulMal==1 & flag_finalobs==1
	
	* Sulawesi Papua(East-West)
	bysort pidlink (stage): gen flag_SulPapua=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=71 & provmov[_n]<=76) & (provmov[_n+1]>=91 & provmov[_n+1]<=94 )) | ((provmov[_n]>=91 & provmov[_n]<=94) & (provmov[_n+1]>=71 & provmov[_n+1]<=76)  )
	bysort pidlink Cohort (stage): egen flag_SulPapua_total=sum(flag_SulPapua), missing
	by pidlink Cohort (stage): egen  flag_SulPapua1=max( flag_SulPapua)
	replace  flag_SulPapua= flag_SulPapua1
	drop flag_SulPapua1							//15 people
	count if flag_SulPapua==1 & flag_finalobs==1
	
	* Maluku(North-South)
	
	* Maluku Bali
	bysort pidlink (stage): gen flag_MalBali=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=81 & provmov[_n]<=82) & (provmov[_n+1]==51) ) | ((provmov[_n]==51) & (provmov[_n+1]>=81 & provmov[_n+1]<=82)  )
	bysort pidlink Cohort (stage): egen flag_MalBali_total=sum(flag_MalBali), missing
	by pidlink Cohort (stage): egen  flag_MalBali1=max( flag_MalBali)
	replace  flag_MalBali= flag_MalBali1
	drop flag_MalBali1
	count if flag_MalBali==1 & flag_finalobs==1 //0 People
	
	* Maluku Nusa(East-West)
	bysort pidlink (stage): gen flag_MalNus=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=81 & provmov[_n]<=82) & (provmov[_n+1]>=52 & provmov[_n+1]<=53) ) | ((provmov[_n]>=52 & provmov[_n]<=53) & (provmov[_n+1]>=81 & provmov[_n+1]<=82)  )
	bysort pidlink Cohort (stage): egen flag_MalNus_total=sum(flag_MalNus), missing
	by pidlink Cohort (stage):egen  flag_MalNus1=max( flag_MalNus)
	replace  flag_MalNus= flag_MalNus1
	drop flag_MalNus1							//0 people
	count if flag_MalNus==1 & flag_finalobs==1
	
	* Maluku Papua(East-West)
	bysort pidlink (stage): gen flag_MalPapua=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=81 & provmov[_n]<=82) & (provmov[_n+1]>=91 & provmov[_n+1]<=94 )) | ((provmov[_n]>=91 & provmov[_n]<=94) & (provmov[_n+1]>=81 & provmov[_n+1]<=82)  )
	bysort pidlink Cohort (stage): egen flag_MalPapua_total=sum(flag_MalPapua), missing
	by pidlink Cohort (stage): egen  flag_MalPapua1=max( flag_MalPapua)
	replace  flag_MalPapua= flag_MalPapua1
	drop flag_MalPapua1							//3 people
	count if flag_MalPapua==1 & flag_finalobs==1
	
	* Nusa(East-West)
	
	* Nusa Bali
	bysort pidlink (stage): gen flag_NusBali=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=52 & provmov[_n]<=53) & (provmov[_n+1]==51) ) | ((provmov[_n]==51) & (provmov[_n+1]>=52 & provmov[_n+1]<=53)  )
	bysort pidlink Cohort (stage): egen flag_NusBali_total=sum(flag_NusBali), missing
	by pidlink Cohort (stage): egen  flag_NusBali1=max( flag_NusBali)
	replace  flag_NusBali= flag_NusBali1
	drop flag_NusBali1
	count if flag_NusBali==1 & flag_finalobs==1 //57 people
	
	* Nusa Papua(East-West)
	bysort pidlink (stage): gen flag_NusPapua=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]>=52 & provmov[_n]<=53) & (provmov[_n+1]>=91 & provmov[_n+1]<=94 )) | ((provmov[_n]>=91 & provmov[_n]<=94) & (provmov[_n+1]>=52 & provmov[_n+1]<=53)  )
	bysort pidlink Cohort (stage): egen flag_NusPapua_total=sum(flag_NusPapua), missing
	by pidlink Cohort (stage):egen  flag_NusPapua1=max( flag_NusPapua)
	replace  flag_NusPapua= flag_NusPapua1
	drop flag_NusPapua1							//3 people
	count if flag_NusPapua==1 & flag_finalobs==1
	
	* Riau (not observed as a province anyone has ever occupied)
	
	* Bali
	
	* Bali Papua(East-West)
	bysort pidlink (stage): gen flag_BaliPapua=1 if provmov[_n]!=provmov[_n+1] & ((provmov[_n]==51) & (provmov[_n+1]>=91 & provmov[_n+1]<=94 )) | ((provmov[_n]>=91 & provmov[_n]<=94) & (provmov[_n+1]==51)  )
	bysort pidlink Cohort (stage): egen flag_BaliPapua_total=sum(flag_BaliPapua), missing
	by pidlink Cohort (stage): egen  flag_BaliPapua1=max( flag_BaliPapua)
	replace  flag_BaliPapua= flag_BaliPapua1
	drop flag_BaliPapua1							//3 people
	count if flag_BaliPapua==1 & flag_finalobs==1
	
* Find all the unique Island hoppers
	
	* Number of hops per hopper
	egen flag_IslandMoves=rsum(*_total) /*if flag_finalobs==1*/
	by pidlink Cohort (stage): egen flag_IslandMovesCohort=max(flag_IslandMoves)
	replace flag_IslandMovesCohort=. if flag_finalobsCohort==.
	drop flag_IslandMoves

	* Cohort Hoppers
	gen flag_IslandHopperCohort=1 if  flag_IslandMovesCohort>0 &  flag_IslandMoves!=. & flag_finalobsCohort==1
	replace  flag_IslandHopperCohort=0 if  flag_IslandHopperCohort==. & flag_finalobsCohort==1
	
	* Unique Hoppers
	by pidlink: egen flag_IslandHopper1=max(flag_IslandHopperCohort)
	gen flag_IslandHopper=1 if  flag_IslandHopper1==1 & flag_finalobs==1
	replace  flag_IslandHopper=0 if  flag_IslandHopper==. & flag_finalobs==1
	drop flag_IslandHopper1
	
	drop flag_Sum* flag_Jak* flag_Kal* flag_Mal* flag_Sul* flag_Nus* flag_Bali*
	
*u, replace
********************************************************************************
// Migration Shares

	* Share of sample with any migration history	
	sum mover 
	
	* Average number of moves across whole dataset
	sum TotalMoves
	
	* Share of sample that moved between their birth location to their age 12 location
	sum Moved
		* Share of sample that subsequently migrated
		sum Moved if mover==1
		* Share of sample that did not migrate thereafter
		sum Moved if mover==0
	
	* Share of sample with only interregency (intraprovincial) and interprovincial migration
	*sum flag_interintraprov
		*sum flag_interintraprov if mover==1
	
	* Share of sample with only interprovincial migration
	*sum flag_interprov
		*sum flag_interprov if mover==1
	
	* Share of sample that has migrated across one of the Island groups
	sum flag_IslandHopper
	
		* Share of migrants that have an island hop
		sum  flag_IslandHopper if mover==1
		
	* Repeat Movers
	tab Cohort, sum ( flag_RepeatMoves_All)
		* According to my most relevant geographical divisions
		tab Cohort, sum (flag_RepeatMoves)
		
********************************************************************************
// Migration Numbers: Moves per movers (weighted average of cohorts)

* Any migration
	tab Cohort if moverCohort==1, sum (TotalMovesCohort)
	
	*Cohort Shares
	tab Cohort, sum ( moverCohort)

	* Nonparametrically test if the mean moves of the movers are significantly different across cohorts 
		kwallis TotalMovesCohort if  moverCohort==1, by(Cohort)

	/* The above migration events are significantly different from each other */

* Inter and Intra Provincial migrations
	tab Cohort if flag_InterIntraProv_Cohort==1, sum (TotalMovesCohort)
	
	*Cohort Shares
	tab Cohort, sum (flag_InterIntraProv_Cohort)
	
	* Nonparametrically test if the mean moves of the movers are significantly different across cohorts 
		kwallis TotalMovesCohort if flag_InterIntraProv_Cohort ==1, by(Cohort)

* Interprovincial Migrations
	tab Cohort if flag_InterProv_Cohort==1, sum (TotalMovesCohort)
	
	*Cohort Shares
	tab Cohort, sum (flag_InterProv_Cohort)
	
	* Nonparametrically test if the mean moves of the movers are significantly different across cohorts 
		kwallis TotalMovesCohort if flag_InterProv_Cohort==1, by(Cohort)

* Island Hoppers (Special case of Interprovincial migrants)
	tab Cohort if flag_IslandHopperCohort==1, sum (TotalMovesCohort)

	* Nonparametrically test if the mean moves of the movers who ever move between an island are significantly different across cohorts
		kwallis TotalMovesCohort if flag_IslandHopperCohort==1, by(Cohort )
	
	/* The mean moves are significantly different from each other */

	tab Cohort if flag_IslandHopperCohort==1, sum (flag_IslandMovesCohort) 

	 * Nonparametrically test if the mean moves among the island moves of the movers who have ever moved between islands are significantly different across cohorts
		kwallis flag_IslandMovesCohort if flag_IslandHopperCohort==1, by(Cohort )
	 
	 /* The number of island moves across cohorts is not significantly different */
	 
* Cohort person equilvalents

by pidlink Cohort (stage): gen CohortPerson=_n if Cohort!=""
by pidlink Cohort (stage): replace CohortPerson=. if _n!=_N

tab Cohort, sum(CohortPerson)

********************************************************************************
* Generate descriptive stats

	* Entire sample
	
		* sex
		sum sex if flag_finalobs==1
		tab mover, sum (sex)
			*Cohort Shares
			 tab Cohort if moverCohort==1, sum (sex)
			 tab Cohort if flag_InterIntraProv_Cohort==1, sum (sex)
		
		*age
		sum stage if flag_finalobs==1
		tab mover, sum (stage)
		
		* schooling
		sum MaxSchYrs if flag_finalobs==1
		tab  mover, sum (MaxSchYrs)
		
		*sum MaxSchYrs if flag_interintraprov==1
		*sum MaxSchYrs if flag_interprov==1
		sum MaxSchYrs if flag_IslandHopper==1
		
		* Urbanization
		sum UrbBirth if flag_finalobs==1
		tab mover, sum (UrbBirth)
		
		* By schooling level and Cohort
		tab Cohort  flag_Schooling if moverCohort==1, sum (TotalMovesCohort)
			*Cohort Shares
			tab Cohort  flag_Schooling, sum( moverCohort)
			* According to my most relevant geographical migration levels (Interdistrict migrations)
				tab Cohort  flag_Schooling if flag_InterIntraProv_Cohort==1, sum(TotalMovesCohort)
				*Cohort Shares
				tab Cohort flag_Schooling, sum(flag_InterIntraProv_Cohort)
		
		* Marriage
			*shares total
			tab Marriage if flag_finalobs==1
			tab Marriage if mover==1
			tab Marriage if mover==0
			*Cohort Shares
			tab Cohort  Marriage, sum( moverCohort)
	
********************************************************************************
// Generate Graphs

* Urbanization at birth

foreach name in Cohort sex UrbBirth {

	use "$maindir$project/Migration Movements/`name'.dta"

	g SDMean= SDMovs/sqrt( SizeMoves)
	g UCL= MeanMoves+1.96* SDMean
	g LCL= MeanMoves-1.96* SDMean

	save "$maindir$project/Migration Movements/`name'.dta", replace
	
	}
	
	use "$maindir$project/Migration Movements/UrbBirth.dta"
	
	twoway (line  MeanMoves MaxSchYrs if UrbBirth==0 & MaxSchYrs!=., lc(blue)) ///
	(line  MeanMoves MaxSchYrs if UrbBirth==1 & MaxSchYrs!=.,lc(red)) ///
	(line  UCL MaxSchYrs if UrbBirth==0 & MaxSchYrs!=., lp(dash) lc(blue)) ///
	(line LCL MaxSchYrs if UrbBirth==0 & MaxSchYrs!=., lp(dash) lc(blue)) ///
	(line UCL MaxSchYrs  if UrbBirth==1 & MaxSchYrs!=., lp(dash) lc(red)) ///
	(line LCL MaxSchYrs  if UrbBirth==1 & MaxSchYrs!=., lp(dash) lc(red)) 
	
	graph save "$maindir$project/Graphs/UrbBirth.jpg", replace

	use "$maindir$project/Migration Movements/sex.dta"
	
	twoway (line  MeanMoves MaxSchYrs if sex==1 & MaxSchYrs!=. & UrbBirth==0, lc(blue)) ///
	(line  MeanMoves MaxSchYrs if sex==1 & MaxSchYrs!=. & UrbBirth==1,lc(red)) (line   ///
	MeanMoves MaxSchYrs if sex==3 & MaxSchYrs!=. & UrbBirth==0, lp(dash) lc(blue)) (line ///
	MeanMoves MaxSchYrs if sex==3 & MaxSchYrs!=. & UrbBirth==1, lp(dash) lc(red)) 

	graph save "$maindir$project/Graphs/sex.jpg", replace

	
