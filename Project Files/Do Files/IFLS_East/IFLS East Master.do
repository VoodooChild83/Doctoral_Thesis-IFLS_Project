/* Create the files for IFLS East Master Tracker to bring into the main Master Tracker */

********************************************************************************

* Build the pidlink association file

qui do "$maindir$project$Do/IFLS_East/pidlink_and_weights.do"

* Create the IFLS Master Tracker to integrate into the other IFLS Dataset

qui do "$maindir$project$Do/IFLS_East/IFLS East Cleaner.do"
