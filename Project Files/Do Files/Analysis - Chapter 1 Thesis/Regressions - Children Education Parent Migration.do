/* Regressions and Analysis of the Child Parent information */

clear matrix
clear mata

set maxvar 20000
set matsize 11000

********************************************************************************
//Set global directory information for files

quietly do "/Users/idiosyncrasy58/OneDrive/Documents/IFLS/Project Files/Do Files/Global Variables.do"
*quietly do "/Users/idiosyncrasy58/Dropbox/Documents/IFLS/Project Files/Do Files/Global Variables.do"

********************************************************************************
// Quietly do the file that builds the dataset

quietly do "$maindir$project/Do Files/Childrens Education Parents Migration.do"
* The above code will take forever to run

use "$maindir$project/linkage.dta"

********************************************************************************
// Find the correlation of Parental Migration on Child's Educational Attainment
// conditional on the migration occuring while the child is in school:

pwcorr (MaxSchYrs2 InSchFatherMig InSchMotherMig), sig
spearman MaxSchYrs2 InSchFatherMig InSchMotherMig, pw stats(rho p)

pwcorr (MaxSchYrs2 InSchFatherIntraProvMig InSchMotherIntraProvMig), sig

/* It seems that the correlations are robust in the sense that all types of migrations
   and those that are intraprovincial (and interprovisional is also to an extent) have
   similar correlations. */
   
 * Correlations of Parent's and Children's schooling
 
pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2), sig

pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2) if InSchFatherMig==0, sig
pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2) if InSchMotherMig==0, sig
pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2) if InSchFatherMig==0 & InSchMotherMig==0, sig

pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2) if InSchFatherMig==1, sig
pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2) if InSchMotherMig==1, sig
pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2) if InSchFatherMig==1 & InSchMotherMig==1, sig

pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2) if InSchFatherMig==1 & InSchMotherMig==0, sig
pwcorr (MaxSchYrs2  Father_MaxSchYrs2 Mother_MaxSchYrs2) if InSchFatherMig==0 & InSchMotherMig==1, sig
 

********************************************************************************
// Run some dummy regressions to see how parental migration is correlated to educational
// attainment of their children.

reg MaxSchYrs2 InSchFatherMig InSchMotherMig, vce(cluster FamID)
reg MaxSchYrs2 InSchFatherMig InSchMotherMig sex, vce(cluster FamID)
reg MaxSchYrs2 InSchFatherMig InSchMotherMig sex UrbBirth, vce(cluster FamID)

//Parent's Migration Purely
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur, vce(cluster FamID)
 
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur sex, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur UrbBirth, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur i.UrbBirth*i.sex, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur if UrbBirth==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur if UrbBirth==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur sex if UrbBirth==0, vce(cluster FamID)		// These are important = girls seem to get less education and it is significant (see stats summary)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur sex if UrbBirth==1, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur if UrbBirth==0 & sex==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur if UrbBirth==0 & sex==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur if UrbBirth==1 & sex==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur if UrbBirth==1 & sex==0, vce(cluster FamID)

//Parents' Education
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig sex, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig i.sex*i.UrbBirth, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig if UrbBirth==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig if UrbBirth==1, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig sex if UrbBirth==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig sex if UrbBirth==1, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig if UrbBirth==0 & sex==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig if UrbBirth==0 & sex==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig if UrbBirth==1 & sex==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MaxSchYrs2 *SchMig if UrbBirth==1 & sex==1, vce(cluster FamID)

	* Include MigrationDuration
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig sex, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig i.sex*i.UrbBirth, vce(cluster FamID)

	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig if UrbBirth==0, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig if UrbBirth==1, vce(cluster FamID)

	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig sex if UrbBirth==0, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig sex if UrbBirth==1, vce(cluster FamID)

	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig if UrbBirth==0 & sex==0, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig if UrbBirth==0 & sex==1, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig if UrbBirth==1 & sex==0, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur *_MaxSchYrs2 *SchMig if UrbBirth==1 & sex==1, vce(cluster FamID)

//Marriage
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr sex, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr sex UrbBirth, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr i.sex*i.UrbBirth, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig i.FaMoMarr*i.sex UrbBirth, vce(cluster FamID)

	* Add Mig Duration
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur FaMoMarr, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur FaMoMarr sex, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur FaMoMarr sex UrbBirth, vce(cluster FamID)

	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur FaMoMarr i.sex*i.UrbBirth, vce(cluster FamID)
	xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur i.FaMoMarr*i.sex UrbBirth, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr if UrbBirth==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr if UrbBirth==1, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur FaMoMarr if UrbBirth==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *MigDur FaMoMarr if UrbBirth==1, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MigDur FaMoMarr if UrbBirth==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MigDur FaMoMarr if UrbBirth==1, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig *_MigDur FaMoMarr *_MaxSchYrs2 *SchMig, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig if UrbBirth==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig if UrbBirth==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig if UrbBirth==0 & sex==0, vce(cluster FamID) //Important: rural girls seem to be more impacted by marriage of parents than boys and the migration of both parents
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig if UrbBirth==0 & sex==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig if UrbBirth==1 & sex==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig if UrbBirth==1 & sex==1, vce(cluster FamID)

// Birth Order 
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO, vce(cluster FamID) 
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO sex, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO sex UrbBirth, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO i.sex*i.UrbBirth, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO sex UrbBirth FaMoMarr, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO sex UrbBirth FaMoMarr *_MaxSchYrs2 *SchMig, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO if UrbBirth==0 & sex==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO if UrbBirth==0 & sex==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO if UrbBirth==1 & sex==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO if UrbBirth==1 & sex==0, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO *_MaxSchYrs2 *SchMig if UrbBirth==0 & sex==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO *_MaxSchYrs2 *SchMig if UrbBirth==0 & sex==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO *_MaxSchYrs2 *SchMig if UrbBirth==1 & sex==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig BO *_MaxSchYrs2 *SchMig if UrbBirth==1 & sex==0, vce(cluster FamID)

xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig BO, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig BO if UrbBirth==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig BO if UrbBirth==1, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig BO if UrbBirth==0 & sex==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig BO if UrbBirth==0 & sex==1, vce(cluster FamID) // It seems that the mother imparts more to rural girls education than boys; and fathers rather the same amount - father's migration still negatie overall but if mother migrates effects of migration are negated 
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig BO if UrbBirth==1 & sex==0, vce(cluster FamID)
xi: reg MaxSchYrs2 i.InSchFatherMig*i.InSchMotherMig FaMoMarr *_MaxSchYrs2 *SchMig BO if UrbBirth==1 & sex==1, vce(cluster FamID)

* save "$maindir$project/Analysis-Parent Child Migration.dta", replace

