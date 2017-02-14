* Clean person weights by grabbing their longitudinal weights of their last most 
* wave participation

keep pw* pidlink

preserve

keep pwt_5_waves_l pwt14la pwt07la pwt939700_07lr pwt00la pwt00lb pwt97inl pwt97l pwt93 pwt93in pidlink

* Keep only those who have a longitudinal weight
egen Have_Weight = rsum(pw*), missing

drop if Have_Weight==.
drop Have_Weight

* Rename the variables

*rename (pid93 pid97 pid00 pid07) (pid1993 pid1997 pid2000 pid2007)

rename (pwt93 pwt93in) (pwt1993a pwt1993b)

rename (pwt97l pwt97inl) (pwt1997a pwt1997b)

rename (pwt00la pwt00lb) (pwt2000a pwt2000b)

rename (pwt07la pwt939700_07lr) (pwt2007a pwt2007b)

rename (pwt14la pwt_5_waves_l) (pwt2014a pwt2014b)

reshape long pwt@a pwt@b, i(pidlink) j(wave)

* Find the last wave the participant was in

by pidlink: gen Count=_n if pwta!=. | pwtb!=.
by pidlink: egen Max_Count=max(Count) if Count!=.
gen Flag_LastWave=1 if Count==Max_Count & Count!=.

drop *Count

* Keep the Person Weights according to the one we observe (b supersceeds a if there
* are repeats)

* Replace all weights from previous years if these waves are not the last observed ones
replace pwta=. if Flag_LastWave==.
replace pwtb=. if Flag_LastWave==.

replace pwta=. if pwtb!=.

drop Flag_LastWave

reshape wide

foreach year in 1993 1997 2000 2007 2014{

	egen pwt`year'=rsum(pwt`year'*), missing

}

drop *a *b

save "$maindir$tmp/Person Longitudinal Weights.dta", replace

restore

* Merge in those who have their weights already assigned from the longitudinal types

bys pidlink: drop if _n>1

merge 1:1 pidlink using "$maindir$tmp/Person Longitudinal Weights.dta"

keep if _merge==1
drop _merge pwt1993 pwt1997 pwt2000 pwt2007 pwt2014

keep pwt00xa pwt97x pwt07xa pwt14xa pidlink

rename (pwt97x pwt00xa pwt07xa pwt14xa) (pwt1997 pwt2000 pwt2007 pwt2014)

reshape long pwt@, i(pidlink) j(wave)

* Find the last wave the participant was in

bys pidlink (wave): gen Count=_n if pwt!=.
bys pidlink (wave): egen Max_Count=max(Count) if Count!=.
gen Flag_LastWave=1 if Count==Max_Count & Count!=.

drop *Count

replace pwt=. if Flag_LastWave==.

drop Flag*

reshape wide

append using "$maindir$tmp/Person Longitudinal Weights.dta"

sort pidlink

save "$maindir$tmp/Person Longitudinal Weights.dta", replace
