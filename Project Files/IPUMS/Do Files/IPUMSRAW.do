* NOTE: You need to set the Stata working directory to the path
* where the data file is located.

cd "/Users/idiosyncrasy58/Dropbox/Documents/College/Universitat Autonoma de Barcelona/IDEA - Economics/Doctoral Thesis Ideas/Migration/IFLS/Project Files/IPUMS/Raw Data" 


set more off

clear
quietly infix                 ///
  int     country    1-3      ///
  int     year       4-7      ///
  double  sample     8-16     ///
  double  serial     17-26    ///
  byte    urban      27-27    ///
  long    geo1_id    28-33    ///
  byte    geo1_idx   34-35    ///
  int     geo2_idx   36-39    ///
  byte    livehood   40-41    ///
  int     pernum     42-44    ///
  float   perwt      45-52    ///
  byte    relate     53-53    ///
  int     related    54-57    ///
  int     age        58-60    ///
  byte    sex        61-61    ///
  byte    marst      62-62    ///
  int     marstd     63-65    ///
  byte    agemarr    66-67    ///
  int     marryr     68-71    ///
  byte    marrnum    72-72    ///
  int     birthyr    73-76    ///
  byte    birthmo    77-78    ///
  byte    bplid      79-80    ///
  byte    religion   81-81    ///
  int     religiond  82-85    ///
  byte    langid     86-86    ///
  byte    lit        87-87    ///
  byte    edattain   88-88    ///
  int     edattaind  89-91    ///
  byte    yrschool   92-93    ///
  int     educid     94-96    ///
  byte    empstat    97-97    ///
  int     empstatd   98-100   ///
  byte    occisco    101-102  ///
  int     occ        103-106  ///
  int     isco68a    107-109  ///
  int     indgen     110-112  ///
  long    ind        113-117  ///
  byte    classwk    118-118  ///
  int     classwkd   119-121  ///
  byte    dayswrk    122-122  ///
  int     hrswork1   123-125  ///
  int     hrsmain    126-128  ///
  long    incwage    129-135  ///
  using `"ipumsi_00002.dat"'

replace perwt     = perwt     / 100

format sample    %9.0f
format serial    %10.0f
format perwt     %8.2f

label var country   `"Country"'
label var year      `"Year"'
label var sample    `"IPUMS sample identifier"'
label var serial    `"Household serial number"'
label var urban     `"Urban-rural status"'
label var geo1_id   `"Indonesia, Province 1971 - 2010 [Level 1; consistent boundaries, GIS]"'
label var geo1_idx  `"Indonesia, Province 1971 - 2010 [Level 1; inconsistent boundaries, harmonized by"'
label var geo2_idx  `"Indonesia, Regency 1971 - 2010 [Level 2; inconsistent boundaries, harmonized by "'
label var livehood  `"Main source of livelihood"'
label var pernum    `"Person number"'
label var perwt     `"Person weight"'
label var relate    `"Relationship to household head [general version]"'
label var related   `"Relationship to household head [detailed version]"'
label var age       `"Age"'
label var sex       `"Sex"'
label var marst     `"Marital status [general version]"'
label var marstd    `"Marital status [detailed version]"'
label var agemarr   `"Age at first marriage or union"'
label var marryr    `"Year of first marriage"'
label var marrnum   `"Number of marriages or unions"'
label var birthyr   `"Year of birth"'
label var birthmo   `"Month of birth"'
label var bplid     `"Province of birth, Indonesia"'
label var religion  `"Religion [general version]"'
label var religiond `"Religion [detailed version]"'
label var langid    `"Language spoken at home, Indonesia"'
label var lit       `"Literacy"'
label var edattain  `"Educational attainment, international recode [general version]"'
label var edattaind `"Educational attainment, international recode [detailed version]"'
label var yrschool  `"Years of schooling"'
label var educid    `"Educational attainment, Indonesia"'
label var empstat   `"Activity status (employment status) [general version]"'
label var empstatd  `"Activity status (employment status) [detailed version]"'
label var occisco   `"Occupation, ISCO general"'
label var occ       `"Occupation, unrecoded"'
label var isco68a   `"Occupation, ISCO-1968, 3-digit"'
label var indgen    `"Industry, general recode"'
label var ind       `"Industry, unrecoded"'
label var classwk   `"Status in employment (class of worker) [general version]"'
label var classwkd  `"Status in employment (class of worker) [detailed version]"'
label var dayswrk   `"Days worked last week"'
label var hrswork1  `"Hours worked per week"'
label var hrsmain   `"Hours worked in main occupation"'
label var incwage   `"Wage and salary income"'

label define country_lbl 032 `"Argentina"'
label define country_lbl 051 `"Armenia"', add
label define country_lbl 040 `"Austria"', add
label define country_lbl 050 `"Bangladesh"', add
label define country_lbl 112 `"Belarus"', add
label define country_lbl 068 `"Bolivia"', add
label define country_lbl 076 `"Brazil"', add
label define country_lbl 854 `"Burkina Faso"', add
label define country_lbl 116 `"Cambodia"', add
label define country_lbl 120 `"Cameroon"', add
label define country_lbl 124 `"Canada"', add
label define country_lbl 152 `"Chile"', add
label define country_lbl 156 `"China"', add
label define country_lbl 170 `"Colombia"', add
label define country_lbl 188 `"Costa Rica"', add
label define country_lbl 192 `"Cuba"', add
label define country_lbl 214 `"Dominican Republic"', add
label define country_lbl 218 `"Ecuador"', add
label define country_lbl 818 `"Egypt"', add
label define country_lbl 222 `"El Salvador"', add
label define country_lbl 231 `"Ethiopia"', add
label define country_lbl 242 `"Fiji"', add
label define country_lbl 250 `"France"', add
label define country_lbl 276 `"Germany"', add
label define country_lbl 288 `"Ghana"', add
label define country_lbl 300 `"Greece"', add
label define country_lbl 324 `"Guinea"', add
label define country_lbl 332 `"Haiti"', add
label define country_lbl 348 `"Hungary"', add
label define country_lbl 356 `"India"', add
label define country_lbl 360 `"Indonesia"', add
label define country_lbl 364 `"Iran"', add
label define country_lbl 368 `"Iraq"', add
label define country_lbl 372 `"Ireland"', add
label define country_lbl 376 `"Israel"', add
label define country_lbl 380 `"Italy"', add
label define country_lbl 388 `"Jamaica"', add
label define country_lbl 400 `"Jordan"', add
label define country_lbl 404 `"Kenya"', add
label define country_lbl 417 `"Kyrgyz Republic"', add
label define country_lbl 430 `"Liberia"', add
label define country_lbl 454 `"Malawi"', add
label define country_lbl 458 `"Malaysia"', add
label define country_lbl 466 `"Mali"', add
label define country_lbl 484 `"Mexico"', add
label define country_lbl 496 `"Mongolia"', add
label define country_lbl 504 `"Morocco"', add
label define country_lbl 508 `"Mozambique"', add
label define country_lbl 524 `"Nepal"', add
label define country_lbl 528 `"Netherlands"', add
label define country_lbl 558 `"Nicaragua"', add
label define country_lbl 566 `"Nigeria"', add
label define country_lbl 586 `"Pakistan"', add
label define country_lbl 275 `"Palestine"', add
label define country_lbl 591 `"Panama"', add
label define country_lbl 600 `"Paraguay"', add
label define country_lbl 604 `"Peru"', add
label define country_lbl 608 `"Philippines"', add
label define country_lbl 620 `"Portugal"', add
label define country_lbl 630 `"Puerto Rico"', add
label define country_lbl 642 `"Romania"', add
label define country_lbl 646 `"Rwanda"', add
label define country_lbl 662 `"Saint Lucia"', add
label define country_lbl 686 `"Senegal"', add
label define country_lbl 694 `"Sierra Leone"', add
label define country_lbl 705 `"Slovenia"', add
label define country_lbl 710 `"South Africa"', add
label define country_lbl 728 `"South Sudan"', add
label define country_lbl 724 `"Spain"', add
label define country_lbl 729 `"Sudan"', add
label define country_lbl 756 `"Switzerland"', add
label define country_lbl 834 `"Tanzania"', add
label define country_lbl 764 `"Thailand"', add
label define country_lbl 792 `"Turkey"', add
label define country_lbl 800 `"Uganda"', add
label define country_lbl 804 `"Ukraine"', add
label define country_lbl 826 `"United Kingdom"', add
label define country_lbl 840 `"United States"', add
label define country_lbl 858 `"Uruguay"', add
label define country_lbl 862 `"Venezuela"', add
label define country_lbl 704 `"Vietnam"', add
label define country_lbl 894 `"Zambia"', add
label values country country_lbl

label define year_lbl 1960 `"1960"'
label define year_lbl 1962 `"1962"', add
label define year_lbl 1963 `"1963"', add
label define year_lbl 1964 `"1964"', add
label define year_lbl 1966 `"1966"', add
label define year_lbl 1968 `"1968"', add
label define year_lbl 1969 `"1969"', add
label define year_lbl 1970 `"1970"', add
label define year_lbl 1971 `"1971"', add
label define year_lbl 1972 `"1972"', add
label define year_lbl 1973 `"1973"', add
label define year_lbl 1974 `"1974"', add
label define year_lbl 1975 `"1975"', add
label define year_lbl 1976 `"1976"', add
label define year_lbl 1977 `"1977"', add
label define year_lbl 1979 `"1979"', add
label define year_lbl 1980 `"1980"', add
label define year_lbl 1981 `"1981"', add
label define year_lbl 1982 `"1982"', add
label define year_lbl 1983 `"1983"', add
label define year_lbl 1984 `"1984"', add
label define year_lbl 1985 `"1985"', add
label define year_lbl 1986 `"1986"', add
label define year_lbl 1987 `"1987"', add
label define year_lbl 1989 `"1989"', add
label define year_lbl 1990 `"1990"', add
label define year_lbl 1991 `"1991"', add
label define year_lbl 1992 `"1992"', add
label define year_lbl 1993 `"1993"', add
label define year_lbl 1994 `"1994"', add
label define year_lbl 1995 `"1995"', add
label define year_lbl 1996 `"1996"', add
label define year_lbl 1997 `"1997"', add
label define year_lbl 1998 `"1998"', add
label define year_lbl 1999 `"1999"', add
label define year_lbl 2000 `"2000"', add
label define year_lbl 2001 `"2001"', add
label define year_lbl 2002 `"2002"', add
label define year_lbl 2003 `"2003"', add
label define year_lbl 2004 `"2004"', add
label define year_lbl 2005 `"2005"', add
label define year_lbl 2006 `"2006"', add
label define year_lbl 2007 `"2007"', add
label define year_lbl 2008 `"2008"', add
label define year_lbl 2009 `"2009"', add
label define year_lbl 2010 `"2010"', add
label define year_lbl 2011 `"2011"', add
label values year year_lbl

label define sample_lbl 032197001 `"Argentina 1970"'
label define sample_lbl 032219801 `"Argentina 1980"', add
label define sample_lbl 032199101 `"Argentina 1991"', add
label define sample_lbl 032200101 `"Argentina 2001"', add
label define sample_lbl 032201001 `"Argentina 2010"', add
label define sample_lbl 051200101 `"Armenia 2001"', add
label define sample_lbl 051201101 `"Armenia 2011"', add
label define sample_lbl 040197101 `"Austria 1971"', add
label define sample_lbl 040198101 `"Austria 1981"', add
label define sample_lbl 040199101 `"Austria 1991"', add
label define sample_lbl 040200101 `"Austria 2001"', add
label define sample_lbl 040201101 `"Austria 2011"', add
label define sample_lbl 050199101 `"Bangladesh 1991"', add
label define sample_lbl 050200101 `"Bangladesh 2001"', add
label define sample_lbl 050201101 `"Bangladesh 2011"', add
label define sample_lbl 112199901 `"Belarus 1999"', add
label define sample_lbl 068197601 `"Bolivia 1976"', add
label define sample_lbl 068199201 `"Bolivia 1992"', add
label define sample_lbl 068200101 `"Bolivia 2001"', add
label define sample_lbl 076196001 `"Brazil 1960"', add
label define sample_lbl 076197001 `"Brazil 1970"', add
label define sample_lbl 076198001 `"Brazil 1980"', add
label define sample_lbl 076199101 `"Brazil 1991"', add
label define sample_lbl 076200001 `"Brazil 2000"', add
label define sample_lbl 076201001 `"Brazil 2010"', add
label define sample_lbl 854198501 `"Burkina Faso 1985"', add
label define sample_lbl 854199601 `"Burkina Faso 1996"', add
label define sample_lbl 854200601 `"Burkina Faso 2006"', add
label define sample_lbl 116199801 `"Cambodia 1998"', add
label define sample_lbl 116200801 `"Cambodia 2008"', add
label define sample_lbl 120197601 `"Cameroon 1976"', add
label define sample_lbl 120198701 `"Cameroon 1987"', add
label define sample_lbl 120200501 `"Cameroon 2005"', add
label define sample_lbl 124197101 `"Canada 1971"', add
label define sample_lbl 124198101 `"Canada 1981"', add
label define sample_lbl 124199101 `"Canada 1991"', add
label define sample_lbl 124200101 `"Canada 2001"', add
label define sample_lbl 152196001 `"Chile 1960"', add
label define sample_lbl 152197001 `"Chile 1970"', add
label define sample_lbl 152198201 `"Chile 1982"', add
label define sample_lbl 152199201 `"Chile 1992"', add
label define sample_lbl 152200201 `"Chile 2002"', add
label define sample_lbl 156198201 `"China 1982"', add
label define sample_lbl 156199001 `"China 1990"', add
label define sample_lbl 170196401 `"Colombia 1964"', add
label define sample_lbl 170197301 `"Colombia 1973"', add
label define sample_lbl 170198501 `"Colombia 1985"', add
label define sample_lbl 170199301 `"Colombia 1993"', add
label define sample_lbl 170200501 `"Colombia 2005"', add
label define sample_lbl 188196301 `"Costa Rica 1963"', add
label define sample_lbl 188197301 `"Costa Rica 1973"', add
label define sample_lbl 188198401 `"Costa Rica 1984"', add
label define sample_lbl 188200001 `"Costa Rica 2000"', add
label define sample_lbl 188201101 `"Costa Rica 2011"', add
label define sample_lbl 192200201 `"Cuba 2002"', add
label define sample_lbl 214196001 `"Dominican Republic 1960"', add
label define sample_lbl 214197001 `"Dominican Republic 1970"', add
label define sample_lbl 214198101 `"Dominican Republic 1981"', add
label define sample_lbl 214200201 `"Dominican Republic 2002"', add
label define sample_lbl 214201001 `"Dominican Republic 2010"', add
label define sample_lbl 218196201 `"Ecuador 1962"', add
label define sample_lbl 218197401 `"Ecuador 1974"', add
label define sample_lbl 218198201 `"Ecuador 1982"', add
label define sample_lbl 218199001 `"Ecuador 1990"', add
label define sample_lbl 218200101 `"Ecuador 2001"', add
label define sample_lbl 218201001 `"Ecuador 2010"', add
label define sample_lbl 818199601 `"Egypt 1996"', add
label define sample_lbl 818200601 `"Egypt 2006"', add
label define sample_lbl 222199201 `"El Salvador 1992"', add
label define sample_lbl 222200701 `"El Salvador 2007"', add
label define sample_lbl 231198401 `"Ethiopia 1984"', add
label define sample_lbl 231199401 `"Ethiopia 1994"', add
label define sample_lbl 231200701 `"Ethiopia 2007"', add
label define sample_lbl 242196601 `"Fiji 1966"', add
label define sample_lbl 242197601 `"Fiji 1976"', add
label define sample_lbl 242198601 `"Fiji 1986"', add
label define sample_lbl 242199601 `"Fiji 1996"', add
label define sample_lbl 242200701 `"Fiji 2007"', add
label define sample_lbl 250196201 `"France 1962"', add
label define sample_lbl 250196801 `"France 1968"', add
label define sample_lbl 250197501 `"France 1975"', add
label define sample_lbl 250198201 `"France 1982"', add
label define sample_lbl 250199001 `"France 1990"', add
label define sample_lbl 250199901 `"France 1999"', add
label define sample_lbl 250200601 `"France 2006"', add
label define sample_lbl 250201101 `"France 2011"', add
label define sample_lbl 276197001 `"Germany 1970 (West)"', add
label define sample_lbl 276197101 `"Germany 1971 (East)"', add
label define sample_lbl 276198101 `"Germany 1981 (East)"', add
label define sample_lbl 276198701 `"Germany 1987 (West)"', add
label define sample_lbl 288198401 `"Ghana 1984"', add
label define sample_lbl 288200001 `"Ghana 2000"', add
label define sample_lbl 288201001 `"Ghana 2010"', add
label define sample_lbl 300197101 `"Greece 1971"', add
label define sample_lbl 300198101 `"Greece 1981"', add
label define sample_lbl 300199101 `"Greece 1991"', add
label define sample_lbl 300200101 `"Greece 2001"', add
label define sample_lbl 324198301 `"Guinea 1983"', add
label define sample_lbl 324199601 `"Guinea 1996"', add
label define sample_lbl 332197101 `"Haiti 1971"', add
label define sample_lbl 332198201 `"Haiti 1982"', add
label define sample_lbl 332200301 `"Haiti 2003"', add
label define sample_lbl 348197001 `"Hungary 1970"', add
label define sample_lbl 348198001 `"Hungary 1980"', add
label define sample_lbl 348199001 `"Hungary 1990"', add
label define sample_lbl 348200101 `"Hungary 2001"', add
label define sample_lbl 356198341 `"India 1983"', add
label define sample_lbl 356198741 `"India 1987"', add
label define sample_lbl 356199341 `"India 1993"', add
label define sample_lbl 356199941 `"India 1999"', add
label define sample_lbl 356200441 `"India 2004"', add
label define sample_lbl 360197101 `"Indonesia 1971"', add
label define sample_lbl 360197601 `"Indonesia 1976"', add
label define sample_lbl 360198001 `"Indonesia 1980"', add
label define sample_lbl 360198501 `"Indonesia 1985"', add
label define sample_lbl 360199001 `"Indonesia 1990"', add
label define sample_lbl 360199501 `"Indonesia 1995"', add
label define sample_lbl 360200001 `"Indonesia 2000"', add
label define sample_lbl 360200501 `"Indonesia 2005"', add
label define sample_lbl 360201001 `"Indonesia 2010"', add
label define sample_lbl 364200601 `"Iran 2006"', add
label define sample_lbl 368199701 `"Iraq 1997"', add
label define sample_lbl 372197101 `"Ireland 1971"', add
label define sample_lbl 372197901 `"Ireland 1979"', add
label define sample_lbl 372198101 `"Ireland 1981"', add
label define sample_lbl 372198601 `"Ireland 1986"', add
label define sample_lbl 372199101 `"Ireland 1991"', add
label define sample_lbl 372199601 `"Ireland 1996"', add
label define sample_lbl 372200201 `"Ireland 2002"', add
label define sample_lbl 372200601 `"Ireland 2006"', add
label define sample_lbl 372201101 `"Ireland 2011"', add
label define sample_lbl 376197201 `"Israel 1972"', add
label define sample_lbl 376198301 `"Israel 1983"', add
label define sample_lbl 376199501 `"Israel 1995"', add
label define sample_lbl 380200101 `"Italy 2001"', add
label define sample_lbl 388198201 `"Jamaica 1982"', add
label define sample_lbl 388199101 `"Jamaica 1991"', add
label define sample_lbl 388200101 `"Jamaica 2001"', add
label define sample_lbl 400200401 `"Jordan 2004"', add
label define sample_lbl 404196901 `"Kenya 1969"', add
label define sample_lbl 404197901 `"Kenya 1979"', add
label define sample_lbl 404198901 `"Kenya 1989"', add
label define sample_lbl 404199901 `"Kenya 1999"', add
label define sample_lbl 404200901 `"Kenya 2009"', add
label define sample_lbl 417199901 `"Kyrgyz Republic 1999"', add
label define sample_lbl 417200901 `"Kyrgyz Republic 2009"', add
label define sample_lbl 430197401 `"Liberia 1974"', add
label define sample_lbl 430200801 `"Liberia 2008"', add
label define sample_lbl 454198701 `"Malawi 1987"', add
label define sample_lbl 454199801 `"Malawi 1998"', add
label define sample_lbl 454200801 `"Malawi 2008"', add
label define sample_lbl 458197001 `"Malaysia 1970"', add
label define sample_lbl 458198001 `"Malaysia 1980"', add
label define sample_lbl 458199101 `"Malaysia 1991"', add
label define sample_lbl 458200001 `"Malaysia 2000"', add
label define sample_lbl 466198701 `"Mali 1987"', add
label define sample_lbl 466199801 `"Mali 1998"', add
label define sample_lbl 466200901 `"Mali 2009"', add
label define sample_lbl 484196001 `"Mexico 1960"', add
label define sample_lbl 484197001 `"Mexico 1970"', add
label define sample_lbl 484199001 `"Mexico 1990"', add
label define sample_lbl 484199501 `"Mexico 1995"', add
label define sample_lbl 484200001 `"Mexico 2000"', add
label define sample_lbl 484200501 `"Mexico 2005"', add
label define sample_lbl 484201001 `"Mexico 2010"', add
label define sample_lbl 496198901 `"Mongolia 1989"', add
label define sample_lbl 496200001 `"Mongolia 2000"', add
label define sample_lbl 504198201 `"Morocco 1982"', add
label define sample_lbl 504199401 `"Morocco 1994"', add
label define sample_lbl 504200401 `"Morocco 2004"', add
label define sample_lbl 508199701 `"Mozambique 1997"', add
label define sample_lbl 508200701 `"Mozambique 2007"', add
label define sample_lbl 524200101 `"Nepal 2001"', add
label define sample_lbl 528196001 `"Netherlands 1960"', add
label define sample_lbl 528197101 `"Netherlands 1971"', add
label define sample_lbl 528200101 `"Netherlands 2001"', add
label define sample_lbl 558197101 `"Nicaragua 1971"', add
label define sample_lbl 558199501 `"Nicaragua 1995"', add
label define sample_lbl 558200501 `"Nicaragua 2005"', add
label define sample_lbl 566200621 `"Nigeria 2006"', add
label define sample_lbl 566200721 `"Nigeria 2007"', add
label define sample_lbl 566200821 `"Nigeria 2008"', add
label define sample_lbl 566200921 `"Nigeria 2009"', add
label define sample_lbl 566201021 `"Nigeria 2010"', add
label define sample_lbl 586197301 `"Pakistan 1973"', add
label define sample_lbl 586198101 `"Pakistan 1981"', add
label define sample_lbl 586199801 `"Pakistan 1998"', add
label define sample_lbl 275199701 `"Palestine 1997"', add
label define sample_lbl 275200701 `"Palestine 2007"', add
label define sample_lbl 591196001 `"Panama 1960"', add
label define sample_lbl 591197001 `"Panama 1970"', add
label define sample_lbl 591198001 `"Panama 1980"', add
label define sample_lbl 591199001 `"Panama 1990"', add
label define sample_lbl 591200001 `"Panama 2000"', add
label define sample_lbl 591201001 `"Panama 2010"', add
label define sample_lbl 600196201 `"Paraguay 1962"', add
label define sample_lbl 600197201 `"Paraguay 1972"', add
label define sample_lbl 600198201 `"Paraguay 1982"', add
label define sample_lbl 600199201 `"Paraguay 1992"', add
label define sample_lbl 600200201 `"Paraguay 2002"', add
label define sample_lbl 604199301 `"Peru 1993"', add
label define sample_lbl 604200701 `"Peru 2007"', add
label define sample_lbl 608199001 `"Philippines 1990"', add
label define sample_lbl 608199501 `"Philippines 1995"', add
label define sample_lbl 608200001 `"Philippines 2000"', add
label define sample_lbl 620198101 `"Portugal 1981"', add
label define sample_lbl 620199101 `"Portugal 1991"', add
label define sample_lbl 620200101 `"Portugal 2001"', add
label define sample_lbl 620201101 `"Portugal 2011"', add
label define sample_lbl 630197001 `"Puerto Rico 1970"', add
label define sample_lbl 630198001 `"Puerto Rico 1980"', add
label define sample_lbl 630199001 `"Puerto Rico 1990"', add
label define sample_lbl 630200001 `"Puerto Rico 2000"', add
label define sample_lbl 630200501 `"Puerto Rico 2005"', add
label define sample_lbl 630201001 `"Puerto Rico 2010"', add
label define sample_lbl 642197701 `"Romania 1977"', add
label define sample_lbl 642199201 `"Romania 1992"', add
label define sample_lbl 642200201 `"Romania 2002"', add
label define sample_lbl 646199101 `"Rwanda 1991"', add
label define sample_lbl 646200201 `"Rwanda 2002"', add
label define sample_lbl 662198001 `"Saint Lucia 1980"', add
label define sample_lbl 662199101 `"Saint Lucia 1991"', add
label define sample_lbl 686198801 `"Senegal 1988"', add
label define sample_lbl 686200201 `"Senegal 2002"', add
label define sample_lbl 694200401 `"Sierra Leone 2004"', add
label define sample_lbl 705200201 `"Slovenia 2002"', add
label define sample_lbl 710199601 `"South Africa 1996"', add
label define sample_lbl 710200101 `"South Africa 2001"', add
label define sample_lbl 710200701 `"South Africa 2007"', add
label define sample_lbl 710201101 `"South Africa 2011"', add
label define sample_lbl 724198101 `"Spain 1981"', add
label define sample_lbl 724199101 `"Spain 1991"', add
label define sample_lbl 724200101 `"Spain 2001"', add
label define sample_lbl 724201101 `"Spain 2011"', add
label define sample_lbl 728200801 `"South Sudan 2008"', add
label define sample_lbl 729200801 `"Sudan 2008"', add
label define sample_lbl 756197001 `"Switzerland 1970"', add
label define sample_lbl 756198001 `"Switzerland 1980"', add
label define sample_lbl 756199001 `"Switzerland 1990"', add
label define sample_lbl 756200001 `"Switzerland 2000"', add
label define sample_lbl 834198801 `"Tanzania 1988"', add
label define sample_lbl 834200201 `"Tanzania 2002"', add
label define sample_lbl 764197001 `"Thailand 1970"', add
label define sample_lbl 764198001 `"Thailand 1980"', add
label define sample_lbl 764199001 `"Thailand 1990"', add
label define sample_lbl 764200001 `"Thailand 2000"', add
label define sample_lbl 792198501 `"Turkey 1985"', add
label define sample_lbl 792199001 `"Turkey 1990"', add
label define sample_lbl 792200001 `"Turkey 2000"', add
label define sample_lbl 800199101 `"Uganda 1991"', add
label define sample_lbl 800200201 `"Uganda 2002"', add
label define sample_lbl 804200101 `"Ukraine 2001"', add
label define sample_lbl 826199101 `"United Kingdom 1991"', add
label define sample_lbl 826200101 `"United Kingdom 2001"', add
label define sample_lbl 840196001 `"United States 1960"', add
label define sample_lbl 840197001 `"United States 1970"', add
label define sample_lbl 840198001 `"United States 1980"', add
label define sample_lbl 840199001 `"United States 1990"', add
label define sample_lbl 840200001 `"United States 2000"', add
label define sample_lbl 840200501 `"United States 2005"', add
label define sample_lbl 840201001 `"United States 2010"', add
label define sample_lbl 858196301 `"Uruguay 1963"', add
label define sample_lbl 858197501 `"Uruguay 1975"', add
label define sample_lbl 858198501 `"Uruguay 1985"', add
label define sample_lbl 858199601 `"Uruguay 1996"', add
label define sample_lbl 858200621 `"Uruguay 2006"', add
label define sample_lbl 858201101 `"Uruguay 2011"', add
label define sample_lbl 862197101 `"Venezuela 1971"', add
label define sample_lbl 862198101 `"Venezuela 1981"', add
label define sample_lbl 862199001 `"Venezuela 1990"', add
label define sample_lbl 862200101 `"Venezuela 2001"', add
label define sample_lbl 704198901 `"Vietnam 1989"', add
label define sample_lbl 704199901 `"Vietnam 1999"', add
label define sample_lbl 704200901 `"Vietnam 2009"', add
label define sample_lbl 894199001 `"Zambia 1990"', add
label define sample_lbl 894200001 `"Zambia 2000"', add
label define sample_lbl 894201001 `"Zambia 2010"', add
label values sample sample_lbl

label define urban_lbl 1 `"Rural"'
label define urban_lbl 2 `"Urban"', add
label define urban_lbl 9 `"Unknown"', add
label values urban urban_lbl

label define geo1_id_lbl 360011 `"Nanggroe Aceh Darussalam"'
label define geo1_id_lbl 360012 `"Sumatera Utara"', add
label define geo1_id_lbl 360013 `"Sumatera Barat"', add
label define geo1_id_lbl 360014 `"Riau and Kepulauan Riau"', add
label define geo1_id_lbl 360015 `"Jambi"', add
label define geo1_id_lbl 360016 `"Sumatera Selatan and Bangka Belitung"', add
label define geo1_id_lbl 360017 `"Bengkulu"', add
label define geo1_id_lbl 360018 `"Lampung"', add
label define geo1_id_lbl 360031 `"DKI Jakarta"', add
label define geo1_id_lbl 360032 `"West Java and Banten"', add
label define geo1_id_lbl 360033 `"Jawa Tengah"', add
label define geo1_id_lbl 360034 `"DI Yogyakarta"', add
label define geo1_id_lbl 360035 `"Jawa Timur"', add
label define geo1_id_lbl 360051 `"Bali"', add
label define geo1_id_lbl 360052 `"Nusa Tenggara Barat"', add
label define geo1_id_lbl 360053 `"East Nusa Tenggara"', add
label define geo1_id_lbl 360061 `"Kalimantan Barat"', add
label define geo1_id_lbl 360062 `"Kalimantan Tengah"', add
label define geo1_id_lbl 360063 `"Kalimantan Selatan"', add
label define geo1_id_lbl 360064 `"Kalimantan Timur"', add
label define geo1_id_lbl 360071 `"Sulawesi Utara  and Gorontalo"', add
label define geo1_id_lbl 360072 `"Sulawesi Tengah"', add
label define geo1_id_lbl 360073 `"Sulawesi Selatan, Sulawesi Tenggara and Sulawesi Barat"', add
label define geo1_id_lbl 360081 `"Maluku and Maluku Utara"', add
label define geo1_id_lbl 360094 `"Papua and Papua Barat"', add
label values geo1_id geo1_id_lbl

label define geo1_idx_lbl 11 `"Nanggroe Aceh Darussalam"'
label define geo1_idx_lbl 12 `"Sumatera Utara"', add
label define geo1_idx_lbl 13 `"Sumatera Barat"', add
label define geo1_idx_lbl 14 `"Riau"', add
label define geo1_idx_lbl 15 `"Jambi"', add
label define geo1_idx_lbl 16 `"Sumatera Selatan"', add
label define geo1_idx_lbl 17 `"Bengkulu"', add
label define geo1_idx_lbl 18 `"Lampung"', add
label define geo1_idx_lbl 19 `"Bangka Belitung"', add
label define geo1_idx_lbl 21 `"Kepulauan Riau"', add
label define geo1_idx_lbl 31 `"DKI Jakarta"', add
label define geo1_idx_lbl 32 `"Jawa Barat"', add
label define geo1_idx_lbl 33 `"Jawa Tengah"', add
label define geo1_idx_lbl 34 `"DI Yogyakarta"', add
label define geo1_idx_lbl 35 `"Jawa Timur"', add
label define geo1_idx_lbl 36 `"Banten"', add
label define geo1_idx_lbl 51 `"Bali"', add
label define geo1_idx_lbl 52 `"Nusa Tenggara Barat"', add
label define geo1_idx_lbl 53 `"Nusa Tenggara Timur"', add
label define geo1_idx_lbl 54 `"East Timor"', add
label define geo1_idx_lbl 61 `"Kalimantan Barat"', add
label define geo1_idx_lbl 62 `"Kalimantan Tengah"', add
label define geo1_idx_lbl 63 `"Kalimantan Selatan"', add
label define geo1_idx_lbl 64 `"Kalimantan Timur"', add
label define geo1_idx_lbl 71 `"Sulawesi Utara"', add
label define geo1_idx_lbl 72 `"Sulawesi Tengah"', add
label define geo1_idx_lbl 73 `"Sulawesi Selatan"', add
label define geo1_idx_lbl 74 `"Sulawesi Tenggara"', add
label define geo1_idx_lbl 75 `"Gorontalo"', add
label define geo1_idx_lbl 76 `"Sulawesi Barat"', add
label define geo1_idx_lbl 81 `"Maluku"', add
label define geo1_idx_lbl 82 `"Maluku Utara"', add
label define geo1_idx_lbl 91 `"Papua Barat"', add
label define geo1_idx_lbl 94 `"Papua"', add
label values geo1_idx geo1_idx_lbl

label define geo2_idx_lbl 1101 `"Simeulue"'
label define geo2_idx_lbl 1102 `"Aceh Singkil"', add
label define geo2_idx_lbl 1103 `"Aceh Selatan"', add
label define geo2_idx_lbl 1104 `"Aceh Tenggara"', add
label define geo2_idx_lbl 1105 `"Aceh Timur"', add
label define geo2_idx_lbl 1106 `"Aceh Tengah"', add
label define geo2_idx_lbl 1107 `"Aceh Barat"', add
label define geo2_idx_lbl 1108 `"Aceh Besar"', add
label define geo2_idx_lbl 1109 `"Pidie"', add
label define geo2_idx_lbl 1110 `"Bireuen"', add
label define geo2_idx_lbl 1111 `"Aceh Utara"', add
label define geo2_idx_lbl 1112 `"Aceh Barat Daya"', add
label define geo2_idx_lbl 1113 `"Gayo Lues"', add
label define geo2_idx_lbl 1114 `"Aceh Tamiang"', add
label define geo2_idx_lbl 1115 `"Nagan Raya"', add
label define geo2_idx_lbl 1116 `"Aceh Jaya"', add
label define geo2_idx_lbl 1117 `"Bener Meriah"', add
label define geo2_idx_lbl 1118 `"Pidie Jaya"', add
label define geo2_idx_lbl 1171 `"Kota Banda Aceh"', add
label define geo2_idx_lbl 1172 `"Kota Sabang"', add
label define geo2_idx_lbl 1173 `"Kota Langsa"', add
label define geo2_idx_lbl 1174 `"Kota Lhoksumawe"', add
label define geo2_idx_lbl 1175 `"Subulussalam"', add
label define geo2_idx_lbl 1201 `"Nias"', add
label define geo2_idx_lbl 1202 `"Mandailing Natal"', add
label define geo2_idx_lbl 1203 `"Tapanuli Selatan"', add
label define geo2_idx_lbl 1204 `"Tapanuli Tengah"', add
label define geo2_idx_lbl 1205 `"Tapanuli Utara"', add
label define geo2_idx_lbl 1206 `"Toba Samosir"', add
label define geo2_idx_lbl 1207 `"Labuhan Batu"', add
label define geo2_idx_lbl 1208 `"Asahan"', add
label define geo2_idx_lbl 1209 `"Simalungun"', add
label define geo2_idx_lbl 1210 `"Dairi"', add
label define geo2_idx_lbl 1211 `"Karo"', add
label define geo2_idx_lbl 1212 `"Deli Serdang"', add
label define geo2_idx_lbl 1213 `"Langkat"', add
label define geo2_idx_lbl 1214 `"Nias Selatan"', add
label define geo2_idx_lbl 1215 `"Humbang Hasundutan"', add
label define geo2_idx_lbl 1216 `"Papak Bharat"', add
label define geo2_idx_lbl 1217 `"Samosir"', add
label define geo2_idx_lbl 1218 `"Serdang Bedagai"', add
label define geo2_idx_lbl 1219 `"Batu Bara"', add
label define geo2_idx_lbl 1220 `"Padang Lawas Utara"', add
label define geo2_idx_lbl 1221 `"Padang Lawas"', add
label define geo2_idx_lbl 1222 `"Labuhan Batu Selatan"', add
label define geo2_idx_lbl 1223 `"Labuhan Batu Utara"', add
label define geo2_idx_lbl 1224 `"Nias Utara"', add
label define geo2_idx_lbl 1225 `"Nias Barat"', add
label define geo2_idx_lbl 1271 `"Kota Sibolga"', add
label define geo2_idx_lbl 1272 `"Kota Tanjung Balai"', add
label define geo2_idx_lbl 1273 `"Kota Pematang Siantar"', add
label define geo2_idx_lbl 1274 `"Kota Tebing Tinggi"', add
label define geo2_idx_lbl 1275 `"Kota Medan"', add
label define geo2_idx_lbl 1276 `"Kota Binjai"', add
label define geo2_idx_lbl 1277 `"Kota Padang Sidempuan"', add
label define geo2_idx_lbl 1278 `"Kota Gunungsitoli"', add
label define geo2_idx_lbl 1298 `"Regency of Grindings"', add
label define geo2_idx_lbl 1301 `"Kepulauan Mentawai"', add
label define geo2_idx_lbl 1302 `"Pesisir Selatan"', add
label define geo2_idx_lbl 1303 `"Solok"', add
label define geo2_idx_lbl 1304 `"Sawahlunto/Sijunjung"', add
label define geo2_idx_lbl 1305 `"Tanah Datar"', add
label define geo2_idx_lbl 1306 `"Padang Pariaman"', add
label define geo2_idx_lbl 1307 `"Agam"', add
label define geo2_idx_lbl 1308 `"Lima Puluh Koto"', add
label define geo2_idx_lbl 1309 `"Pasaman"', add
label define geo2_idx_lbl 1310 `"Solok Selatan"', add
label define geo2_idx_lbl 1311 `"Dharmasraya"', add
label define geo2_idx_lbl 1312 `"Pasaman Barat"', add
label define geo2_idx_lbl 1371 `"Kota Padang"', add
label define geo2_idx_lbl 1372 `"Kota Solok"', add
label define geo2_idx_lbl 1373 `"Kota Sawah Lunto"', add
label define geo2_idx_lbl 1374 `"Kota Padang Panjang"', add
label define geo2_idx_lbl 1375 `"Kota Bukittinggi"', add
label define geo2_idx_lbl 1376 `"Kota Payakumbuh"', add
label define geo2_idx_lbl 1377 `"Kota Pariaman"', add
label define geo2_idx_lbl 1401 `"Kuantan Singingi"', add
label define geo2_idx_lbl 1402 `"Indragiri Hulu"', add
label define geo2_idx_lbl 1403 `"Indragiri Hilir"', add
label define geo2_idx_lbl 1404 `"Pelalawan"', add
label define geo2_idx_lbl 1405 `"Siak"', add
label define geo2_idx_lbl 1406 `"Kampar"', add
label define geo2_idx_lbl 1407 `"Rokan Hulu"', add
label define geo2_idx_lbl 1408 `"Bengkalis"', add
label define geo2_idx_lbl 1409 `"Rokan Hilir"', add
label define geo2_idx_lbl 1410 `"Kepulauan Meranti"', add
label define geo2_idx_lbl 1411 `"Karimun"', add
label define geo2_idx_lbl 1412 `"Natuna"', add
label define geo2_idx_lbl 1471 `"Pekan Baru"', add
label define geo2_idx_lbl 1472 `"Batam"', add
label define geo2_idx_lbl 1473 `"Dumai"', add
label define geo2_idx_lbl 1480 `"Kepulauan Riau"', add
label define geo2_idx_lbl 1481 `"Lingga"', add
label define geo2_idx_lbl 1482 `"Kepulauan Anambas"', add
label define geo2_idx_lbl 1483 `"Tanjung Pinang"', add
label define geo2_idx_lbl 1501 `"Kerinci"', add
label define geo2_idx_lbl 1502 `"Merangin"', add
label define geo2_idx_lbl 1503 `"Sarolangun"', add
label define geo2_idx_lbl 1504 `"Batanghari"', add
label define geo2_idx_lbl 1505 `"Muaro Jambi"', add
label define geo2_idx_lbl 1506 `"Tanjung Jabung Timur"', add
label define geo2_idx_lbl 1507 `"Tanjung Jabung Barat"', add
label define geo2_idx_lbl 1508 `"Tebo"', add
label define geo2_idx_lbl 1509 `"Bungo"', add
label define geo2_idx_lbl 1571 `"Jambi"', add
label define geo2_idx_lbl 1572 `"Kota Sungai Penuh"', add
label define geo2_idx_lbl 1601 `"Oku"', add
label define geo2_idx_lbl 1602 `"Oki"', add
label define geo2_idx_lbl 1603 `"Muara Enim"', add
label define geo2_idx_lbl 1604 `"Lahat"', add
label define geo2_idx_lbl 1605 `"Musi Rawas"', add
label define geo2_idx_lbl 1606 `"Musi Banyu Asin"', add
label define geo2_idx_lbl 1607 `"Banyu Asin"', add
label define geo2_idx_lbl 1608 `"Oku Selatan"', add
label define geo2_idx_lbl 1609 `"Oku Timur"', add
label define geo2_idx_lbl 1610 `"Ogan Ilir"', add
label define geo2_idx_lbl 1611 `"Empat Lawang"', add
label define geo2_idx_lbl 1671 `"Palembang"', add
label define geo2_idx_lbl 1672 `"Prabumulih"', add
label define geo2_idx_lbl 1673 `"Pagar Alam"', add
label define geo2_idx_lbl 1674 `"Lubuk Lingga"', add
label define geo2_idx_lbl 1680 `"Bangka"', add
label define geo2_idx_lbl 1681 `"Belitung"', add
label define geo2_idx_lbl 1682 `"Bangka Barat"', add
label define geo2_idx_lbl 1683 `"Bangka Tengah"', add
label define geo2_idx_lbl 1684 `"Bangka Selatan"', add
label define geo2_idx_lbl 1685 `"Belitung Timur"', add
label define geo2_idx_lbl 1686 `"Pangkal Pinang"', add
label define geo2_idx_lbl 1701 `"Bengkulu Selatan"', add
label define geo2_idx_lbl 1702 `"Rejang Lebong"', add
label define geo2_idx_lbl 1703 `"Bengkulu Utara"', add
label define geo2_idx_lbl 1704 `"Kaur"', add
label define geo2_idx_lbl 1705 `"Seluma"', add
label define geo2_idx_lbl 1706 `"Mukomuko"', add
label define geo2_idx_lbl 1707 `"Lebong"', add
label define geo2_idx_lbl 1708 `"Kepahing"', add
label define geo2_idx_lbl 1709 `"Bengkulu Tengah"', add
label define geo2_idx_lbl 1771 `"Bengkulu"', add
label define geo2_idx_lbl 1801 `"Lampung Barat"', add
label define geo2_idx_lbl 1802 `"Tanggamus"', add
label define geo2_idx_lbl 1803 `"Lampung Selatan"', add
label define geo2_idx_lbl 1804 `"Lampung Timur"', add
label define geo2_idx_lbl 1805 `"Lampung Tengah"', add
label define geo2_idx_lbl 1806 `"Lampung Utara"', add
label define geo2_idx_lbl 1807 `"Way Kanan"', add
label define geo2_idx_lbl 1808 `"Tulang Bawang"', add
label define geo2_idx_lbl 1809 `"Pesawaran"', add
label define geo2_idx_lbl 1810 `"Pringsewu"', add
label define geo2_idx_lbl 1811 `"Mesuji"', add
label define geo2_idx_lbl 1812 `"Tulangbawang Barat"', add
label define geo2_idx_lbl 1871 `"Bandar Lampung"', add
label define geo2_idx_lbl 1872 `"Metro"', add
label define geo2_idx_lbl 3101 `"Kepulauan Seribu"', add
label define geo2_idx_lbl 3171 `"Jakarta Selatan"', add
label define geo2_idx_lbl 3172 `"Jakarta Timur"', add
label define geo2_idx_lbl 3173 `"Jakarta Pusat"', add
label define geo2_idx_lbl 3174 `"Jakarta Barat"', add
label define geo2_idx_lbl 3175 `"Jakarta Utara"', add
label define geo2_idx_lbl 3201 `"Bogor"', add
label define geo2_idx_lbl 3202 `"Sukabumi"', add
label define geo2_idx_lbl 3203 `"Cianjur"', add
label define geo2_idx_lbl 3204 `"Bandung"', add
label define geo2_idx_lbl 3205 `"Garut"', add
label define geo2_idx_lbl 3206 `"Tasikmalaya"', add
label define geo2_idx_lbl 3207 `"Ciamis"', add
label define geo2_idx_lbl 3208 `"Kuningan"', add
label define geo2_idx_lbl 3209 `"Cirebon"', add
label define geo2_idx_lbl 3210 `"Majalengka"', add
label define geo2_idx_lbl 3211 `"Sumedang"', add
label define geo2_idx_lbl 3212 `"Indramayu"', add
label define geo2_idx_lbl 3213 `"Subang"', add
label define geo2_idx_lbl 3214 `"Purwakarta"', add
label define geo2_idx_lbl 3215 `"Karawang"', add
label define geo2_idx_lbl 3216 `"Bekasi"', add
label define geo2_idx_lbl 3217 `"Bandung Barat"', add
label define geo2_idx_lbl 3271 `"Bogor"', add
label define geo2_idx_lbl 3272 `"Sukabumi"', add
label define geo2_idx_lbl 3273 `"Bandung"', add
label define geo2_idx_lbl 3274 `"Cirebon"', add
label define geo2_idx_lbl 3275 `"Bekasi city"', add
label define geo2_idx_lbl 3276 `"Depok"', add
label define geo2_idx_lbl 3277 `"Cimahi"', add
label define geo2_idx_lbl 3278 `"Tasikmalaya"', add
label define geo2_idx_lbl 3279 `"Banjar"', add
label define geo2_idx_lbl 3280 `"Pandeglang"', add
label define geo2_idx_lbl 3281 `"Lebak"', add
label define geo2_idx_lbl 3282 `"Tangerang"', add
label define geo2_idx_lbl 3283 `"Serang"', add
label define geo2_idx_lbl 3284 `"Tangerang city"', add
label define geo2_idx_lbl 3285 `"Cilegon"', add
label define geo2_idx_lbl 3286 `"Serang city"', add
label define geo2_idx_lbl 3287 `"Kota Tangerang Selatan"', add
label define geo2_idx_lbl 3301 `"Cilacap"', add
label define geo2_idx_lbl 3302 `"Banyumas"', add
label define geo2_idx_lbl 3303 `"Purbalingga"', add
label define geo2_idx_lbl 3304 `"Banjarnegara"', add
label define geo2_idx_lbl 3305 `"Kebumen"', add
label define geo2_idx_lbl 3306 `"Purworejo"', add
label define geo2_idx_lbl 3307 `"Wonosobo"', add
label define geo2_idx_lbl 3308 `"Magelang"', add
label define geo2_idx_lbl 3309 `"Boyolali"', add
label define geo2_idx_lbl 3310 `"Klaten"', add
label define geo2_idx_lbl 3311 `"Sukoharjo"', add
label define geo2_idx_lbl 3312 `"Wonogiri"', add
label define geo2_idx_lbl 3313 `"Karanganyar"', add
label define geo2_idx_lbl 3314 `"Sragen"', add
label define geo2_idx_lbl 3315 `"Grobogan"', add
label define geo2_idx_lbl 3316 `"Blora"', add
label define geo2_idx_lbl 3317 `"Rembang"', add
label define geo2_idx_lbl 3318 `"Pati"', add
label define geo2_idx_lbl 3319 `"Kudus"', add
label define geo2_idx_lbl 3320 `"Jepara"', add
label define geo2_idx_lbl 3321 `"Demak"', add
label define geo2_idx_lbl 3322 `"Semarang"', add
label define geo2_idx_lbl 3323 `"Temanggung"', add
label define geo2_idx_lbl 3324 `"Kendal"', add
label define geo2_idx_lbl 3325 `"Batang"', add
label define geo2_idx_lbl 3326 `"Pekalongan"', add
label define geo2_idx_lbl 3327 `"Pemalang"', add
label define geo2_idx_lbl 3328 `"Tegal"', add
label define geo2_idx_lbl 3329 `"Brebes"', add
label define geo2_idx_lbl 3371 `"Magelang"', add
label define geo2_idx_lbl 3372 `"Surakarta"', add
label define geo2_idx_lbl 3373 `"Salatiga"', add
label define geo2_idx_lbl 3374 `"Semarang"', add
label define geo2_idx_lbl 3375 `"Pekalongan"', add
label define geo2_idx_lbl 3376 `"Tegal"', add
label define geo2_idx_lbl 3401 `"Kulon Progo"', add
label define geo2_idx_lbl 3402 `"Bantul"', add
label define geo2_idx_lbl 3403 `"Gunung Kidul"', add
label define geo2_idx_lbl 3404 `"Sleman"', add
label define geo2_idx_lbl 3471 `"Yogyakarta"', add
label define geo2_idx_lbl 3501 `"Pacitan"', add
label define geo2_idx_lbl 3502 `"Ponorogo"', add
label define geo2_idx_lbl 3503 `"Trenggalek"', add
label define geo2_idx_lbl 3504 `"Tulungagung"', add
label define geo2_idx_lbl 3505 `"Kab. Blitar"', add
label define geo2_idx_lbl 3506 `"Kab. Kediri"', add
label define geo2_idx_lbl 3507 `"Kab. Malang"', add
label define geo2_idx_lbl 3508 `"Lumajang"', add
label define geo2_idx_lbl 3509 `"Jember"', add
label define geo2_idx_lbl 3510 `"Banyuwangi"', add
label define geo2_idx_lbl 3511 `"Bondowoso"', add
label define geo2_idx_lbl 3512 `"Situbondo"', add
label define geo2_idx_lbl 3513 `"Kab. Probolinggo"', add
label define geo2_idx_lbl 3514 `"Kab. Pasuruan"', add
label define geo2_idx_lbl 3515 `"Sidoarjo"', add
label define geo2_idx_lbl 3516 `"Kab. Mojokerto"', add
label define geo2_idx_lbl 3517 `"Jombang"', add
label define geo2_idx_lbl 3518 `"Nganjuk"', add
label define geo2_idx_lbl 3519 `"Kab. Madiun"', add
label define geo2_idx_lbl 3520 `"Magetan"', add
label define geo2_idx_lbl 3521 `"Ngawi"', add
label define geo2_idx_lbl 3522 `"Bojonegoro"', add
label define geo2_idx_lbl 3523 `"Tuban"', add
label define geo2_idx_lbl 3524 `"Lamongan"', add
label define geo2_idx_lbl 3525 `"Gresik"', add
label define geo2_idx_lbl 3526 `"Bangkalan"', add
label define geo2_idx_lbl 3527 `"Sampang"', add
label define geo2_idx_lbl 3528 `"Pamekasan"', add
label define geo2_idx_lbl 3529 `"Sumenep"', add
label define geo2_idx_lbl 3571 `"Kota Kediri"', add
label define geo2_idx_lbl 3572 `"Kota Blitar"', add
label define geo2_idx_lbl 3573 `"Kota Malang"', add
label define geo2_idx_lbl 3574 `"Kota Probolinggo"', add
label define geo2_idx_lbl 3575 `"Kota Pasuruan"', add
label define geo2_idx_lbl 3576 `"Kota Mojokerto"', add
label define geo2_idx_lbl 3577 `"Kota Madiun"', add
label define geo2_idx_lbl 3578 `"Surabaya"', add
label define geo2_idx_lbl 3579 `"Batu"', add
label define geo2_idx_lbl 5101 `"Jembrana"', add
label define geo2_idx_lbl 5102 `"Tabanan"', add
label define geo2_idx_lbl 5103 `"Badung"', add
label define geo2_idx_lbl 5104 `"Gianyar"', add
label define geo2_idx_lbl 5105 `"Klungkung"', add
label define geo2_idx_lbl 5106 `"Bangli"', add
label define geo2_idx_lbl 5107 `"Karangasem"', add
label define geo2_idx_lbl 5108 `"Buleleng"', add
label define geo2_idx_lbl 5171 `"Denpasar"', add
label define geo2_idx_lbl 5201 `"Lombok Barat"', add
label define geo2_idx_lbl 5202 `"Lombok Tengah"', add
label define geo2_idx_lbl 5203 `"Lombok Timur"', add
label define geo2_idx_lbl 5204 `"Sumbawa"', add
label define geo2_idx_lbl 5205 `"Dompu"', add
label define geo2_idx_lbl 5206 `"Bima"', add
label define geo2_idx_lbl 5207 `"Sumbawa Barat"', add
label define geo2_idx_lbl 5208 `"Lombok Utara"', add
label define geo2_idx_lbl 5271 `"Mataram"', add
label define geo2_idx_lbl 5272 `"Bima city"', add
label define geo2_idx_lbl 5301 `"Sumba Barat"', add
label define geo2_idx_lbl 5302 `"Sumba Timur"', add
label define geo2_idx_lbl 5303 `"Kupang"', add
label define geo2_idx_lbl 5304 `"Timor Tengah Selatan"', add
label define geo2_idx_lbl 5305 `"Timor Tengah Utara"', add
label define geo2_idx_lbl 5306 `"Belu"', add
label define geo2_idx_lbl 5307 `"Alor"', add
label define geo2_idx_lbl 5308 `"Lembata"', add
label define geo2_idx_lbl 5309 `"Flores Timur"', add
label define geo2_idx_lbl 5310 `"Sikka"', add
label define geo2_idx_lbl 5311 `"Ende"', add
label define geo2_idx_lbl 5312 `"Ngada"', add
label define geo2_idx_lbl 5313 `"Manggarai"', add
label define geo2_idx_lbl 5314 `"Rote Ndao"', add
label define geo2_idx_lbl 5315 `"Manggarai Barat"', add
label define geo2_idx_lbl 5316 `"Sumba Tengah"', add
label define geo2_idx_lbl 5317 `"Sumba Barat Daya"', add
label define geo2_idx_lbl 5318 `"Nagekeo"', add
label define geo2_idx_lbl 5319 `"Manggarai Timur"', add
label define geo2_idx_lbl 5320 `"Sabu Raijua"', add
label define geo2_idx_lbl 5371 `"Kupang city"', add
label define geo2_idx_lbl 5401 `"Covalima"', add
label define geo2_idx_lbl 5402 `"Ainaro"', add
label define geo2_idx_lbl 5403 `"Manufahi"', add
label define geo2_idx_lbl 5404 `"Viqueque"', add
label define geo2_idx_lbl 5405 `"Lautem"', add
label define geo2_idx_lbl 5406 `"Baucau"', add
label define geo2_idx_lbl 5407 `"Manatuto"', add
label define geo2_idx_lbl 5408 `"Dili"', add
label define geo2_idx_lbl 5409 `"Aileu"', add
label define geo2_idx_lbl 5410 `"Liquica"', add
label define geo2_idx_lbl 5411 `"Ermera"', add
label define geo2_idx_lbl 5412 `"Bobonaro"', add
label define geo2_idx_lbl 5413 `"Ambeno"', add
label define geo2_idx_lbl 6101 `"Sambas"', add
label define geo2_idx_lbl 6102 `"Bengkayang"', add
label define geo2_idx_lbl 6103 `"Landak"', add
label define geo2_idx_lbl 6104 `"Pontianak"', add
label define geo2_idx_lbl 6105 `"Sanggau"', add
label define geo2_idx_lbl 6106 `"Ketapang"', add
label define geo2_idx_lbl 6107 `"Sintang"', add
label define geo2_idx_lbl 6108 `"Kapuas Hulu"', add
label define geo2_idx_lbl 6109 `"Sekadau"', add
label define geo2_idx_lbl 6110 `"Melawai"', add
label define geo2_idx_lbl 6111 `"Kayong Utara"', add
label define geo2_idx_lbl 6112 `"Kubu Raya"', add
label define geo2_idx_lbl 6171 `"Pontianak city"', add
label define geo2_idx_lbl 6172 `"Singkawang"', add
label define geo2_idx_lbl 6201 `"Kotawaringin Barat"', add
label define geo2_idx_lbl 6202 `"Kotawaringin Timur"', add
label define geo2_idx_lbl 6203 `"Kapuas"', add
label define geo2_idx_lbl 6204 `"Barito Selatan"', add
label define geo2_idx_lbl 6205 `"Barito Utara"', add
label define geo2_idx_lbl 6206 `"Sukamara"', add
label define geo2_idx_lbl 6207 `"Lamandau"', add
label define geo2_idx_lbl 6208 `"Seruyan"', add
label define geo2_idx_lbl 6209 `"Katingan"', add
label define geo2_idx_lbl 6210 `"Pulang Pisau"', add
label define geo2_idx_lbl 6211 `"Gunung Mas"', add
label define geo2_idx_lbl 6212 `"Barito Timur"', add
label define geo2_idx_lbl 6213 `"Murung Raya"', add
label define geo2_idx_lbl 6271 `"Palangka Raya"', add
label define geo2_idx_lbl 6301 `"Tanah Laut"', add
label define geo2_idx_lbl 6302 `"Kotabaru"', add
label define geo2_idx_lbl 6303 `"Banjar"', add
label define geo2_idx_lbl 6304 `"Barito Kuala"', add
label define geo2_idx_lbl 6305 `"Tapin"', add
label define geo2_idx_lbl 6306 `"Hulu Sungai Selatan"', add
label define geo2_idx_lbl 6307 `"Hulu Sungai Tengah"', add
label define geo2_idx_lbl 6308 `"Hulu Sungai Utara"', add
label define geo2_idx_lbl 6309 `"Tabalong"', add
label define geo2_idx_lbl 6310 `"Tanah Bumbu"', add
label define geo2_idx_lbl 6311 `"Balangan"', add
label define geo2_idx_lbl 6371 `"Banjarmasin"', add
label define geo2_idx_lbl 6372 `"Banjarbaru"', add
label define geo2_idx_lbl 6401 `"Pasir"', add
label define geo2_idx_lbl 6402 `"Kutai Barat"', add
label define geo2_idx_lbl 6403 `"Kutai Kartanegara"', add
label define geo2_idx_lbl 6404 `"Kutai Timur"', add
label define geo2_idx_lbl 6405 `"Berau"', add
label define geo2_idx_lbl 6406 `"Malinau"', add
label define geo2_idx_lbl 6407 `"Bulongan"', add
label define geo2_idx_lbl 6408 `"Nunukan"', add
label define geo2_idx_lbl 6409 `"Penajam Paser Utara"', add
label define geo2_idx_lbl 6471 `"Balikpapan"', add
label define geo2_idx_lbl 6472 `"Samarinda"', add
label define geo2_idx_lbl 6473 `"Tarakan and Tana Tidung"', add
label define geo2_idx_lbl 6474 `"Bontang"', add
label define geo2_idx_lbl 7101 `"Bolaang Mongondow"', add
label define geo2_idx_lbl 7102 `"Minahasa"', add
label define geo2_idx_lbl 7103 `"Kepulauan Sangihe"', add
label define geo2_idx_lbl 7104 `"Kepualuan Talaud"', add
label define geo2_idx_lbl 7105 `"Minahasa Selatan"', add
label define geo2_idx_lbl 7106 `"Minahasa Utara"', add
label define geo2_idx_lbl 7107 `"Bolaang Mongondow Utara"', add
label define geo2_idx_lbl 7108 `"Siau Tagulandang Biaro"', add
label define geo2_idx_lbl 7109 `"Minahasa Tenggara"', add
label define geo2_idx_lbl 7110 `"Bolaang Mongondow Selatan"', add
label define geo2_idx_lbl 7111 `"Bolaang Mongondow Timur"', add
label define geo2_idx_lbl 7171 `"Manado"', add
label define geo2_idx_lbl 7172 `"Bitung"', add
label define geo2_idx_lbl 7173 `"Tomohon"', add
label define geo2_idx_lbl 7174 `"Kotamobagu"', add
label define geo2_idx_lbl 7190 `"Boalemo"', add
label define geo2_idx_lbl 7191 `"Kodya. Gorontalo"', add
label define geo2_idx_lbl 7192 `"Pohuwato"', add
label define geo2_idx_lbl 7193 `"Bone Bolango"', add
label define geo2_idx_lbl 7194 `"Gorontalo Utara"', add
label define geo2_idx_lbl 7195 `"Kota Gorontalo"', add
label define geo2_idx_lbl 7201 `"Banggai Kepulauan"', add
label define geo2_idx_lbl 7202 `"Banggai"', add
label define geo2_idx_lbl 7203 `"Morowali"', add
label define geo2_idx_lbl 7204 `"Poso"', add
label define geo2_idx_lbl 7205 `"Donggala"', add
label define geo2_idx_lbl 7206 `"Toli-Toli"', add
label define geo2_idx_lbl 7207 `"Buol"', add
label define geo2_idx_lbl 7208 `"Parigi Moutong"', add
label define geo2_idx_lbl 7209 `"Tojo Una-Una"', add
label define geo2_idx_lbl 7210 `"Sigi"', add
label define geo2_idx_lbl 7271 `"Palu"', add
label define geo2_idx_lbl 7301 `"Selayar"', add
label define geo2_idx_lbl 7302 `"Bulukumba"', add
label define geo2_idx_lbl 7303 `"Bantaeng"', add
label define geo2_idx_lbl 7304 `"Jeneponto"', add
label define geo2_idx_lbl 7305 `"Takalar"', add
label define geo2_idx_lbl 7306 `"Gowa"', add
label define geo2_idx_lbl 7307 `"Sinjai"', add
label define geo2_idx_lbl 7308 `"Maros"', add
label define geo2_idx_lbl 7309 `"Pangkajene Kepulauan"', add
label define geo2_idx_lbl 7310 `"Barru"', add
label define geo2_idx_lbl 7311 `"Bone"', add
label define geo2_idx_lbl 7312 `"Soppeng"', add
label define geo2_idx_lbl 7313 `"Wajo"', add
label define geo2_idx_lbl 7314 `"Sidenreng Rappang"', add
label define geo2_idx_lbl 7315 `"Pinrang"', add
label define geo2_idx_lbl 7316 `"Enrekang"', add
label define geo2_idx_lbl 7317 `"Luwu"', add
label define geo2_idx_lbl 7318 `"Tana Toraja"', add
label define geo2_idx_lbl 7319 `"Polewali Mamasa"', add
label define geo2_idx_lbl 7320 `"Majene"', add
label define geo2_idx_lbl 7321 `"Mamuju"', add
label define geo2_idx_lbl 7322 `"Luwu Utara"', add
label define geo2_idx_lbl 7323 `"Mamasa"', add
label define geo2_idx_lbl 7324 `"Mamuju Utara"', add
label define geo2_idx_lbl 7325 `"Luwu Timur"', add
label define geo2_idx_lbl 7326 `"Toraja Utara"', add
label define geo2_idx_lbl 7371 `"Ujung Pandang"', add
label define geo2_idx_lbl 7372 `"Pare-Pare"', add
label define geo2_idx_lbl 7373 `"Palopo"', add
label define geo2_idx_lbl 7401 `"Buton"', add
label define geo2_idx_lbl 7402 `"Muna"', add
label define geo2_idx_lbl 7403 `"Konawe"', add
label define geo2_idx_lbl 7404 `"Kolaka"', add
label define geo2_idx_lbl 7405 `"Konawe Selatan"', add
label define geo2_idx_lbl 7406 `"Bombana"', add
label define geo2_idx_lbl 7407 `"Wakatobi"', add
label define geo2_idx_lbl 7408 `"Kolaka Utara"', add
label define geo2_idx_lbl 7409 `"Buton Utara"', add
label define geo2_idx_lbl 7410 `"Konawe Utara"', add
label define geo2_idx_lbl 7471 `"Kendari"', add
label define geo2_idx_lbl 7472 `"Bau Bau"', add
label define geo2_idx_lbl 8101 `"Maluku Tenggara Barat"', add
label define geo2_idx_lbl 8102 `"Maluku Tenggara"', add
label define geo2_idx_lbl 8103 `"Maluku Tengah"', add
label define geo2_idx_lbl 8104 `"Buru"', add
label define geo2_idx_lbl 8105 `"Kepulauan Aru"', add
label define geo2_idx_lbl 8106 `"Seram Bagian Barat"', add
label define geo2_idx_lbl 8107 `"Seram Bagian Timur"', add
label define geo2_idx_lbl 8108 `"Maluku Barat Daya"', add
label define geo2_idx_lbl 8109 `"Buru Selatan"', add
label define geo2_idx_lbl 8171 `"Ambon"', add
label define geo2_idx_lbl 8172 `"Tual"', add
label define geo2_idx_lbl 8180 `"Halmahera Barat"', add
label define geo2_idx_lbl 8182 `"Halmahera Tengah"', add
label define geo2_idx_lbl 8184 `"Kepulauan Sula"', add
label define geo2_idx_lbl 8186 `"Halmahera Selatan"', add
label define geo2_idx_lbl 8188 `"Halmahera Utara"', add
label define geo2_idx_lbl 8190 `"Halmahera Timur"', add
label define geo2_idx_lbl 8192 `"Pulau Morotai"', add
label define geo2_idx_lbl 8194 `"Ternate"', add
label define geo2_idx_lbl 8196 `"Tidore Kepulauan"', add
label define geo2_idx_lbl 8198 `"Maluku Utara"', add
label define geo2_idx_lbl 9401 `"Fakfak"', add
label define geo2_idx_lbl 9402 `"Kaimana"', add
label define geo2_idx_lbl 9403 `"Teluk Wondama"', add
label define geo2_idx_lbl 9404 `"Teluk Bintuni"', add
label define geo2_idx_lbl 9405 `"Manokwari"', add
label define geo2_idx_lbl 9406 `"Sorong Selatan"', add
label define geo2_idx_lbl 9407 `"Sorong and Tambrauw"', add
label define geo2_idx_lbl 9408 `"Raja Ampat"', add
label define geo2_idx_lbl 9410 `"Maybrat"', add
label define geo2_idx_lbl 9420 `"Sorong city"', add
label define geo2_idx_lbl 9430 `"Merauke"', add
label define geo2_idx_lbl 9431 `"Jayawijaya"', add
label define geo2_idx_lbl 9432 `"Jayapura"', add
label define geo2_idx_lbl 9433 `"Nabire"', add
label define geo2_idx_lbl 9434 `"Yapen Waropen"', add
label define geo2_idx_lbl 9435 `"Biak Numfor"', add
label define geo2_idx_lbl 9436 `"Paniai"', add
label define geo2_idx_lbl 9437 `"Puncak Jaya"', add
label define geo2_idx_lbl 9438 `"Mimika"', add
label define geo2_idx_lbl 9439 `"Boven Digoel"', add
label define geo2_idx_lbl 9440 `"Mappi"', add
label define geo2_idx_lbl 9441 `"Asmat"', add
label define geo2_idx_lbl 9442 `"Yahukimo"', add
label define geo2_idx_lbl 9443 `"Pegunungan Bintang"', add
label define geo2_idx_lbl 9444 `"Tolikara"', add
label define geo2_idx_lbl 9445 `"Sarmi"', add
label define geo2_idx_lbl 9446 `"Keerom"', add
label define geo2_idx_lbl 9447 `"Waropen"', add
label define geo2_idx_lbl 9448 `"Supiori and Mamberamo Raya"', add
label define geo2_idx_lbl 9449 `"Nduga"', add
label define geo2_idx_lbl 9450 `"Lanny Jaya"', add
label define geo2_idx_lbl 9451 `"Mamberano Tengah"', add
label define geo2_idx_lbl 9452 `"Yalimo"', add
label define geo2_idx_lbl 9453 `"Puncak"', add
label define geo2_idx_lbl 9454 `"Dogiyai"', add
label define geo2_idx_lbl 9455 `"Intan Jaya"', add
label define geo2_idx_lbl 9456 `"Deiyai"', add
label define geo2_idx_lbl 9457 `"Jayapura City"', add
label define geo2_idx_lbl 9499 `"West Papua province, regency unknown"', add
label values geo2_idx geo2_idx_lbl

label define livehood_lbl 00 `"NIU (not in universe)"'
label define livehood_lbl 10 `"Agricultural activities"', add
label define livehood_lbl 11 `"Subsistence animal husbandry"', add
label define livehood_lbl 12 `"Subsistence farming"', add
label define livehood_lbl 13 `"Commercial farming"', add
label define livehood_lbl 14 `"Fishing"', add
label define livehood_lbl 20 `"Employment income"', add
label define livehood_lbl 30 `"Business enterprise"', add
label define livehood_lbl 31 `"Formal trading"', add
label define livehood_lbl 32 `"Petty trading"', add
label define livehood_lbl 40 `"Cottage industry"', add
label define livehood_lbl 50 `"Property income"', add
label define livehood_lbl 60 `"Family support/remittances"', add
label define livehood_lbl 70 `"Humanitarian aid"', add
label define livehood_lbl 80 `"Other"', add
label define livehood_lbl 81 `"Rent or remittances"', add
label define livehood_lbl 82 `"Religious work"', add
label define livehood_lbl 83 `"Pension"', add
label define livehood_lbl 99 `"Unknown"', add
label values livehood livehood_lbl

label define relate_lbl 1 `"Head"'
label define relate_lbl 2 `"Spouse/partner"', add
label define relate_lbl 3 `"Child"', add
label define relate_lbl 4 `"Other relative"', add
label define relate_lbl 5 `"Non-relative"', add
label define relate_lbl 6 `"Other relative or non-relative"', add
label define relate_lbl 9 `"Unknown"', add
label values relate relate_lbl

label define related_lbl 1000 `"Head"'
label define related_lbl 2000 `"Spouse/partner"', add
label define related_lbl 2100 `"Spouse"', add
label define related_lbl 2200 `"Unmarried partner"', add
label define related_lbl 2300 `"Same-sex spouse/partner"', add
label define related_lbl 3000 `"Child"', add
label define related_lbl 3100 `"Biological child"', add
label define related_lbl 3200 `"Adopted child"', add
label define related_lbl 3300 `"Stepchild"', add
label define related_lbl 3400 `"Child/child-in-law"', add
label define related_lbl 3500 `"Child/child-in-law/grandchild"', add
label define related_lbl 3600 `"Child of unmarried partner"', add
label define related_lbl 4000 `"Other relative"', add
label define related_lbl 4100 `"Grandchild"', add
label define related_lbl 4110 `"Grandchild or great grandchild"', add
label define related_lbl 4120 `"Great grandchild"', add
label define related_lbl 4130 `"Great-great grandchild"', add
label define related_lbl 4200 `"Parent/parent-in-law"', add
label define related_lbl 4210 `"Parent"', add
label define related_lbl 4211 `"Stepparent"', add
label define related_lbl 4220 `"Parent-in-law"', add
label define related_lbl 4300 `"Child-in-law"', add
label define related_lbl 4301 `"Daughter-in-law"', add
label define related_lbl 4302 `"Spouse/partner of child"', add
label define related_lbl 4310 `"Unmarried partner of child"', add
label define related_lbl 4400 `"Sibling/sibling-in-law"', add
label define related_lbl 4410 `"Sibling"', add
label define related_lbl 4420 `"Stepsibling"', add
label define related_lbl 4430 `"Sibling-in-law"', add
label define related_lbl 4431 `"Sibling of spouse/partner"', add
label define related_lbl 4432 `"Spouse/partner of sibling"', add
label define related_lbl 4500 `"Grandparent"', add
label define related_lbl 4510 `"Great grandparent"', add
label define related_lbl 4600 `"Parent/grandparent/ascendant"', add
label define related_lbl 4700 `"Aunt/uncle"', add
label define related_lbl 4800 `"Other specified relative"', add
label define related_lbl 4810 `"Nephew/niece"', add
label define related_lbl 4820 `"Cousin"', add
label define related_lbl 4830 `"Sibling of sibling-in-law"', add
label define related_lbl 4900 `"Other relative, not elsewhere classified"', add
label define related_lbl 4910 `"Other relative with same family name"', add
label define related_lbl 4920 `"Other relative with different family name"', add
label define related_lbl 4930 `"Other relative, not specified (secondary family)"', add
label define related_lbl 5000 `"Non-relative"', add
label define related_lbl 5100 `"Friend/guest/visitor/partner"', add
label define related_lbl 5110 `"Partner/friend"', add
label define related_lbl 5111 `"Friend"', add
label define related_lbl 5112 `"Partner/roommate"', add
label define related_lbl 5113 `"Housemate/roommate"', add
label define related_lbl 5120 `"Visitor"', add
label define related_lbl 5130 `"Ex-spouse"', add
label define related_lbl 5140 `"Godparent"', add
label define related_lbl 5150 `"Godchild"', add
label define related_lbl 5200 `"Employee"', add
label define related_lbl 5210 `"Domestic employee"', add
label define related_lbl 5220 `"Relative of employee, n.s."', add
label define related_lbl 5221 `"Spouse of servant"', add
label define related_lbl 5222 `"Child of servant"', add
label define related_lbl 5223 `"Other relative of servant"', add
label define related_lbl 5300 `"Roomer/boarder/lodger/foster child"', add
label define related_lbl 5310 `"Boarder"', add
label define related_lbl 5311 `"Boarder or guest"', add
label define related_lbl 5320 `"Lodger"', add
label define related_lbl 5330 `"Foster child"', add
label define related_lbl 5340 `"Tutored/foster child"', add
label define related_lbl 5350 `"Tutored child"', add
label define related_lbl 5400 `"Employee, boarder or guest"', add
label define related_lbl 5500 `"Other specified non-relative"', add
label define related_lbl 5510 `"Agregado"', add
label define related_lbl 5520 `"Temporary resident, guest"', add
label define related_lbl 5600 `"Group quarters"', add
label define related_lbl 5610 `"Group quarters, non-inmates"', add
label define related_lbl 5620 `"Institutional inmates"', add
label define related_lbl 5900 `"Non-relative, n.e.c."', add
label define related_lbl 6000 `"Other relative or non-relative"', add
label define related_lbl 9999 `"Unknown"', add
label values related related_lbl

label define age_lbl 000 `"Less than 1 year"'
label define age_lbl 001 `"1 year"', add
label define age_lbl 002 `"2 years"', add
label define age_lbl 003 `"3"', add
label define age_lbl 004 `"4"', add
label define age_lbl 005 `"5"', add
label define age_lbl 006 `"6"', add
label define age_lbl 007 `"7"', add
label define age_lbl 008 `"8"', add
label define age_lbl 009 `"9"', add
label define age_lbl 010 `"10"', add
label define age_lbl 011 `"11"', add
label define age_lbl 012 `"12"', add
label define age_lbl 013 `"13"', add
label define age_lbl 014 `"14"', add
label define age_lbl 015 `"15"', add
label define age_lbl 016 `"16"', add
label define age_lbl 017 `"17"', add
label define age_lbl 018 `"18"', add
label define age_lbl 019 `"19"', add
label define age_lbl 020 `"20"', add
label define age_lbl 021 `"21"', add
label define age_lbl 022 `"22"', add
label define age_lbl 023 `"23"', add
label define age_lbl 024 `"24"', add
label define age_lbl 025 `"25"', add
label define age_lbl 026 `"26"', add
label define age_lbl 027 `"27"', add
label define age_lbl 028 `"28"', add
label define age_lbl 029 `"29"', add
label define age_lbl 030 `"30"', add
label define age_lbl 031 `"31"', add
label define age_lbl 032 `"32"', add
label define age_lbl 033 `"33"', add
label define age_lbl 034 `"34"', add
label define age_lbl 035 `"35"', add
label define age_lbl 036 `"36"', add
label define age_lbl 037 `"37"', add
label define age_lbl 038 `"38"', add
label define age_lbl 039 `"39"', add
label define age_lbl 040 `"40"', add
label define age_lbl 041 `"41"', add
label define age_lbl 042 `"42"', add
label define age_lbl 043 `"43"', add
label define age_lbl 044 `"44"', add
label define age_lbl 045 `"45"', add
label define age_lbl 046 `"46"', add
label define age_lbl 047 `"47"', add
label define age_lbl 048 `"48"', add
label define age_lbl 049 `"49"', add
label define age_lbl 050 `"50"', add
label define age_lbl 051 `"51"', add
label define age_lbl 052 `"52"', add
label define age_lbl 053 `"53"', add
label define age_lbl 054 `"54"', add
label define age_lbl 055 `"55"', add
label define age_lbl 056 `"56"', add
label define age_lbl 057 `"57"', add
label define age_lbl 058 `"58"', add
label define age_lbl 059 `"59"', add
label define age_lbl 060 `"60"', add
label define age_lbl 061 `"61"', add
label define age_lbl 062 `"62"', add
label define age_lbl 063 `"63"', add
label define age_lbl 064 `"64"', add
label define age_lbl 065 `"65"', add
label define age_lbl 066 `"66"', add
label define age_lbl 067 `"67"', add
label define age_lbl 068 `"68"', add
label define age_lbl 069 `"69"', add
label define age_lbl 070 `"70"', add
label define age_lbl 071 `"71"', add
label define age_lbl 072 `"72"', add
label define age_lbl 073 `"73"', add
label define age_lbl 074 `"74"', add
label define age_lbl 075 `"75"', add
label define age_lbl 076 `"76"', add
label define age_lbl 077 `"77"', add
label define age_lbl 078 `"78"', add
label define age_lbl 079 `"79"', add
label define age_lbl 080 `"80"', add
label define age_lbl 081 `"81"', add
label define age_lbl 082 `"82"', add
label define age_lbl 083 `"83"', add
label define age_lbl 084 `"84"', add
label define age_lbl 085 `"85"', add
label define age_lbl 086 `"86"', add
label define age_lbl 087 `"87"', add
label define age_lbl 088 `"88"', add
label define age_lbl 089 `"89"', add
label define age_lbl 090 `"90"', add
label define age_lbl 091 `"91"', add
label define age_lbl 092 `"92"', add
label define age_lbl 093 `"93"', add
label define age_lbl 094 `"94"', add
label define age_lbl 095 `"95"', add
label define age_lbl 096 `"96"', add
label define age_lbl 097 `"97"', add
label define age_lbl 098 `"98"', add
label define age_lbl 099 `"99"', add
label define age_lbl 100 `"100+"', add
label define age_lbl 999 `"Not reported/missing"', add
label values age age_lbl

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label define sex_lbl 9 `"Unknown"', add
label values sex sex_lbl

label define marst_lbl 0 `"NIU (not in universe)"'
label define marst_lbl 1 `"Single/never married"', add
label define marst_lbl 2 `"Married/in union"', add
label define marst_lbl 3 `"Separated/divorced/spouse absent"', add
label define marst_lbl 4 `"Widowed"', add
label define marst_lbl 9 `"Unknown/missing"', add
label values marst marst_lbl

label define marstd_lbl 000 `"NIU (not in universe)"'
label define marstd_lbl 100 `"Single/never married"', add
label define marstd_lbl 110 `"Engaged"', add
label define marstd_lbl 111 `"Never married and never cohabited"', add
label define marstd_lbl 200 `"Married or consensual union"', add
label define marstd_lbl 210 `"Married, formally"', add
label define marstd_lbl 211 `"Married, civil"', add
label define marstd_lbl 212 `"Married, religious"', add
label define marstd_lbl 213 `"Married, civil and religious"', add
label define marstd_lbl 214 `"Married, civil or religious"', add
label define marstd_lbl 215 `"Married, traditional/customary"', add
label define marstd_lbl 216 `"Married, monogamous"', add
label define marstd_lbl 217 `"Married, polygamous"', add
label define marstd_lbl 220 `"Consensual union"', add
label define marstd_lbl 300 `"Separated/divorced/spouse absent"', add
label define marstd_lbl 310 `"Separated or divorced"', add
label define marstd_lbl 320 `"Separated or annulled"', add
label define marstd_lbl 330 `"Separated"', add
label define marstd_lbl 331 `"Separated legally"', add
label define marstd_lbl 332 `"Separated de facto"', add
label define marstd_lbl 333 `"Separated from marriage"', add
label define marstd_lbl 334 `"Separated from consensual union"', add
label define marstd_lbl 335 `"Separated from consensual union or marriage"', add
label define marstd_lbl 340 `"Annulled"', add
label define marstd_lbl 350 `"Divorced"', add
label define marstd_lbl 360 `"Married, spouse absent"', add
label define marstd_lbl 400 `"Widowed"', add
label define marstd_lbl 410 `"Widowed or divorced"', add
label define marstd_lbl 411 `"Widowed from consensual union or marriage"', add
label define marstd_lbl 412 `"Widowed from marriage"', add
label define marstd_lbl 413 `"Widowed from consensual union"', add
label define marstd_lbl 420 `"Widowed, divorced, or separated"', add
label define marstd_lbl 999 `"Unknown/missing"', add
label values marstd marstd_lbl

label define agemarr_lbl 00 `"NIU (not in universe)"'
label define agemarr_lbl 10 `"10 or younger"', add
label define agemarr_lbl 11 `"11"', add
label define agemarr_lbl 12 `"12"', add
label define agemarr_lbl 13 `"13"', add
label define agemarr_lbl 14 `"14"', add
label define agemarr_lbl 15 `"15"', add
label define agemarr_lbl 16 `"16"', add
label define agemarr_lbl 17 `"17"', add
label define agemarr_lbl 18 `"18"', add
label define agemarr_lbl 19 `"19"', add
label define agemarr_lbl 20 `"20"', add
label define agemarr_lbl 21 `"21"', add
label define agemarr_lbl 22 `"22"', add
label define agemarr_lbl 23 `"23"', add
label define agemarr_lbl 24 `"24"', add
label define agemarr_lbl 25 `"25"', add
label define agemarr_lbl 26 `"26"', add
label define agemarr_lbl 27 `"27"', add
label define agemarr_lbl 28 `"28"', add
label define agemarr_lbl 29 `"29"', add
label define agemarr_lbl 30 `"30"', add
label define agemarr_lbl 31 `"31"', add
label define agemarr_lbl 32 `"32"', add
label define agemarr_lbl 33 `"33"', add
label define agemarr_lbl 34 `"34"', add
label define agemarr_lbl 35 `"35"', add
label define agemarr_lbl 36 `"36"', add
label define agemarr_lbl 37 `"37"', add
label define agemarr_lbl 38 `"38"', add
label define agemarr_lbl 39 `"39"', add
label define agemarr_lbl 40 `"40"', add
label define agemarr_lbl 41 `"41"', add
label define agemarr_lbl 42 `"42"', add
label define agemarr_lbl 43 `"43"', add
label define agemarr_lbl 44 `"44"', add
label define agemarr_lbl 45 `"45"', add
label define agemarr_lbl 46 `"46"', add
label define agemarr_lbl 47 `"47"', add
label define agemarr_lbl 48 `"48"', add
label define agemarr_lbl 49 `"49"', add
label define agemarr_lbl 50 `"50"', add
label define agemarr_lbl 51 `"51"', add
label define agemarr_lbl 52 `"52"', add
label define agemarr_lbl 53 `"53"', add
label define agemarr_lbl 54 `"54"', add
label define agemarr_lbl 55 `"55"', add
label define agemarr_lbl 56 `"56"', add
label define agemarr_lbl 57 `"57"', add
label define agemarr_lbl 58 `"58"', add
label define agemarr_lbl 59 `"59"', add
label define agemarr_lbl 60 `"60"', add
label define agemarr_lbl 61 `"61"', add
label define agemarr_lbl 62 `"62"', add
label define agemarr_lbl 63 `"63"', add
label define agemarr_lbl 64 `"64"', add
label define agemarr_lbl 65 `"65"', add
label define agemarr_lbl 66 `"66"', add
label define agemarr_lbl 67 `"67"', add
label define agemarr_lbl 68 `"68"', add
label define agemarr_lbl 69 `"69"', add
label define agemarr_lbl 70 `"70"', add
label define agemarr_lbl 71 `"71"', add
label define agemarr_lbl 72 `"72"', add
label define agemarr_lbl 73 `"73"', add
label define agemarr_lbl 74 `"74"', add
label define agemarr_lbl 75 `"75"', add
label define agemarr_lbl 76 `"76"', add
label define agemarr_lbl 77 `"77"', add
label define agemarr_lbl 78 `"78"', add
label define agemarr_lbl 79 `"79"', add
label define agemarr_lbl 80 `"80"', add
label define agemarr_lbl 81 `"81"', add
label define agemarr_lbl 82 `"82"', add
label define agemarr_lbl 83 `"83"', add
label define agemarr_lbl 84 `"84"', add
label define agemarr_lbl 85 `"85"', add
label define agemarr_lbl 86 `"86"', add
label define agemarr_lbl 87 `"87"', add
label define agemarr_lbl 88 `"88"', add
label define agemarr_lbl 89 `"89"', add
label define agemarr_lbl 90 `"90"', add
label define agemarr_lbl 91 `"91"', add
label define agemarr_lbl 92 `"92"', add
label define agemarr_lbl 93 `"93"', add
label define agemarr_lbl 94 `"94"', add
label define agemarr_lbl 95 `"95"', add
label define agemarr_lbl 96 `"96"', add
label define agemarr_lbl 97 `"97"', add
label define agemarr_lbl 98 `"98"', add
label define agemarr_lbl 99 `"Unknown"', add
label values agemarr agemarr_lbl

label define marryr_lbl 1887 `"1887"'
label define marryr_lbl 1890 `"1890"', add
label define marryr_lbl 1892 `"1892"', add
label define marryr_lbl 1895 `"1895"', add
label define marryr_lbl 1896 `"1896"', add
label define marryr_lbl 1897 `"1897"', add
label define marryr_lbl 1900 `"1900"', add
label define marryr_lbl 1901 `"1901"', add
label define marryr_lbl 1902 `"1902"', add
label define marryr_lbl 1903 `"1903"', add
label define marryr_lbl 1904 `"1904"', add
label define marryr_lbl 1905 `"1905"', add
label define marryr_lbl 1906 `"1906"', add
label define marryr_lbl 1907 `"1907"', add
label define marryr_lbl 1908 `"1908"', add
label define marryr_lbl 1909 `"1909"', add
label define marryr_lbl 1910 `"1910"', add
label define marryr_lbl 1911 `"1911"', add
label define marryr_lbl 1912 `"1912"', add
label define marryr_lbl 1913 `"1913"', add
label define marryr_lbl 1914 `"1914"', add
label define marryr_lbl 1915 `"1915"', add
label define marryr_lbl 1916 `"1916"', add
label define marryr_lbl 1917 `"1917"', add
label define marryr_lbl 1918 `"1918"', add
label define marryr_lbl 1919 `"1919"', add
label define marryr_lbl 1920 `"1920"', add
label define marryr_lbl 1921 `"1921"', add
label define marryr_lbl 1922 `"1922"', add
label define marryr_lbl 1923 `"1923"', add
label define marryr_lbl 1924 `"1924"', add
label define marryr_lbl 1925 `"1925"', add
label define marryr_lbl 1926 `"1926"', add
label define marryr_lbl 1927 `"1927"', add
label define marryr_lbl 1928 `"1928"', add
label define marryr_lbl 1929 `"1929"', add
label define marryr_lbl 1930 `"1930"', add
label define marryr_lbl 1931 `"1931"', add
label define marryr_lbl 1932 `"1932"', add
label define marryr_lbl 1933 `"1933"', add
label define marryr_lbl 1934 `"1934"', add
label define marryr_lbl 1935 `"1935"', add
label define marryr_lbl 1936 `"1936"', add
label define marryr_lbl 1937 `"1937"', add
label define marryr_lbl 1938 `"1938"', add
label define marryr_lbl 1939 `"1939"', add
label define marryr_lbl 1940 `"1940"', add
label define marryr_lbl 1941 `"1941"', add
label define marryr_lbl 1942 `"1942"', add
label define marryr_lbl 1943 `"1943"', add
label define marryr_lbl 1944 `"1944"', add
label define marryr_lbl 1945 `"1945"', add
label define marryr_lbl 1946 `"1946"', add
label define marryr_lbl 1947 `"1947"', add
label define marryr_lbl 1948 `"1948"', add
label define marryr_lbl 1949 `"1949"', add
label define marryr_lbl 1950 `"1950"', add
label define marryr_lbl 1951 `"1951"', add
label define marryr_lbl 1952 `"1952"', add
label define marryr_lbl 1953 `"1953"', add
label define marryr_lbl 1954 `"1954"', add
label define marryr_lbl 1955 `"1955"', add
label define marryr_lbl 1956 `"1956"', add
label define marryr_lbl 1957 `"1957"', add
label define marryr_lbl 1958 `"1958"', add
label define marryr_lbl 1959 `"1959"', add
label define marryr_lbl 1960 `"1960"', add
label define marryr_lbl 1961 `"1961"', add
label define marryr_lbl 1962 `"1962"', add
label define marryr_lbl 1963 `"1963"', add
label define marryr_lbl 1964 `"1964"', add
label define marryr_lbl 1965 `"1965"', add
label define marryr_lbl 1966 `"1966"', add
label define marryr_lbl 1967 `"1967"', add
label define marryr_lbl 1968 `"1968"', add
label define marryr_lbl 1969 `"1969"', add
label define marryr_lbl 1970 `"1970"', add
label define marryr_lbl 1971 `"1971"', add
label define marryr_lbl 1972 `"1972"', add
label define marryr_lbl 1973 `"1973"', add
label define marryr_lbl 1974 `"1974"', add
label define marryr_lbl 1975 `"1975"', add
label define marryr_lbl 1976 `"1976"', add
label define marryr_lbl 1977 `"1977"', add
label define marryr_lbl 1978 `"1978"', add
label define marryr_lbl 1979 `"1979"', add
label define marryr_lbl 1980 `"1980"', add
label define marryr_lbl 1981 `"1981"', add
label define marryr_lbl 1982 `"1982"', add
label define marryr_lbl 1983 `"1983"', add
label define marryr_lbl 1984 `"1984"', add
label define marryr_lbl 1985 `"1985"', add
label define marryr_lbl 1986 `"1986"', add
label define marryr_lbl 1987 `"1987"', add
label define marryr_lbl 1988 `"1988"', add
label define marryr_lbl 1989 `"1989"', add
label define marryr_lbl 1990 `"1990"', add
label define marryr_lbl 1991 `"1991"', add
label define marryr_lbl 1992 `"1992"', add
label define marryr_lbl 1993 `"1993"', add
label define marryr_lbl 1994 `"1994"', add
label define marryr_lbl 1995 `"1995"', add
label define marryr_lbl 1996 `"1996"', add
label define marryr_lbl 1997 `"1997"', add
label define marryr_lbl 1998 `"1998"', add
label define marryr_lbl 1999 `"1999"', add
label define marryr_lbl 2000 `"2000"', add
label define marryr_lbl 2001 `"2001"', add
label define marryr_lbl 2002 `"2002"', add
label define marryr_lbl 2003 `"2003"', add
label define marryr_lbl 2004 `"2004"', add
label define marryr_lbl 2005 `"2005"', add
label define marryr_lbl 9998 `"Unknown"', add
label define marryr_lbl 9999 `"NIU (not in universe)"', add
label values marryr marryr_lbl

label define marrnum_lbl 0 `"NIU (not in universe)"'
label define marrnum_lbl 1 `"1"', add
label define marrnum_lbl 2 `"2"', add
label define marrnum_lbl 3 `"3"', add
label define marrnum_lbl 4 `"4"', add
label define marrnum_lbl 5 `"5"', add
label define marrnum_lbl 6 `"6"', add
label define marrnum_lbl 7 `"7"', add
label define marrnum_lbl 8 `"8+"', add
label define marrnum_lbl 9 `"Unknown"', add
label values marrnum marrnum_lbl

label define birthyr_lbl 0000 `"NIU (not in universe)"'
label define birthyr_lbl 1843 `"1843"', add
label define birthyr_lbl 1845 `"1845"', add
label define birthyr_lbl 1850 `"1850"', add
label define birthyr_lbl 1853 `"1853"', add
label define birthyr_lbl 1854 `"1854"', add
label define birthyr_lbl 1856 `"1856"', add
label define birthyr_lbl 1858 `"1858"', add
label define birthyr_lbl 1859 `"1859"', add
label define birthyr_lbl 1860 `"1860"', add
label define birthyr_lbl 1861 `"1861"', add
label define birthyr_lbl 1862 `"1862"', add
label define birthyr_lbl 1863 `"1863"', add
label define birthyr_lbl 1864 `"1864"', add
label define birthyr_lbl 1865 `"1865"', add
label define birthyr_lbl 1866 `"1866"', add
label define birthyr_lbl 1867 `"1867"', add
label define birthyr_lbl 1868 `"1868"', add
label define birthyr_lbl 1869 `"1869"', add
label define birthyr_lbl 1870 `"1870"', add
label define birthyr_lbl 1871 `"1871"', add
label define birthyr_lbl 1872 `"1872"', add
label define birthyr_lbl 1873 `"1873"', add
label define birthyr_lbl 1874 `"1874"', add
label define birthyr_lbl 1875 `"1875"', add
label define birthyr_lbl 1876 `"1876"', add
label define birthyr_lbl 1877 `"1877"', add
label define birthyr_lbl 1878 `"1878"', add
label define birthyr_lbl 1879 `"1879"', add
label define birthyr_lbl 1880 `"1880"', add
label define birthyr_lbl 1881 `"1881"', add
label define birthyr_lbl 1882 `"1882"', add
label define birthyr_lbl 1883 `"1883"', add
label define birthyr_lbl 1884 `"1884"', add
label define birthyr_lbl 1885 `"1885"', add
label define birthyr_lbl 1886 `"1886"', add
label define birthyr_lbl 1887 `"1887"', add
label define birthyr_lbl 1888 `"1888"', add
label define birthyr_lbl 1889 `"1889"', add
label define birthyr_lbl 1890 `"1890"', add
label define birthyr_lbl 1891 `"1891"', add
label define birthyr_lbl 1892 `"1892"', add
label define birthyr_lbl 1893 `"1893"', add
label define birthyr_lbl 1894 `"1894"', add
label define birthyr_lbl 1895 `"1895"', add
label define birthyr_lbl 1896 `"1896"', add
label define birthyr_lbl 1897 `"1897"', add
label define birthyr_lbl 1898 `"1898"', add
label define birthyr_lbl 1899 `"1899"', add
label define birthyr_lbl 1900 `"1900"', add
label define birthyr_lbl 1901 `"1901"', add
label define birthyr_lbl 1902 `"1902"', add
label define birthyr_lbl 1903 `"1903"', add
label define birthyr_lbl 1904 `"1904"', add
label define birthyr_lbl 1905 `"1905"', add
label define birthyr_lbl 1906 `"1906"', add
label define birthyr_lbl 1907 `"1907"', add
label define birthyr_lbl 1908 `"1908"', add
label define birthyr_lbl 1909 `"1909"', add
label define birthyr_lbl 1910 `"1910"', add
label define birthyr_lbl 1911 `"1911"', add
label define birthyr_lbl 1912 `"1912"', add
label define birthyr_lbl 1913 `"1913"', add
label define birthyr_lbl 1914 `"1914"', add
label define birthyr_lbl 1915 `"1915"', add
label define birthyr_lbl 1916 `"1916"', add
label define birthyr_lbl 1917 `"1917"', add
label define birthyr_lbl 1918 `"1918"', add
label define birthyr_lbl 1919 `"1919"', add
label define birthyr_lbl 1920 `"1920"', add
label define birthyr_lbl 1921 `"1921"', add
label define birthyr_lbl 1922 `"1922"', add
label define birthyr_lbl 1923 `"1923"', add
label define birthyr_lbl 1924 `"1924"', add
label define birthyr_lbl 1925 `"1925"', add
label define birthyr_lbl 1926 `"1926"', add
label define birthyr_lbl 1927 `"1927"', add
label define birthyr_lbl 1928 `"1928"', add
label define birthyr_lbl 1929 `"1929"', add
label define birthyr_lbl 1930 `"1930"', add
label define birthyr_lbl 1931 `"1931"', add
label define birthyr_lbl 1932 `"1932"', add
label define birthyr_lbl 1933 `"1933"', add
label define birthyr_lbl 1934 `"1934"', add
label define birthyr_lbl 1935 `"1935"', add
label define birthyr_lbl 1936 `"1936"', add
label define birthyr_lbl 1937 `"1937"', add
label define birthyr_lbl 1938 `"1938"', add
label define birthyr_lbl 1939 `"1939"', add
label define birthyr_lbl 1940 `"1940"', add
label define birthyr_lbl 1941 `"1941"', add
label define birthyr_lbl 1942 `"1942"', add
label define birthyr_lbl 1943 `"1943"', add
label define birthyr_lbl 1944 `"1944"', add
label define birthyr_lbl 1945 `"1945"', add
label define birthyr_lbl 1946 `"1946"', add
label define birthyr_lbl 1947 `"1947"', add
label define birthyr_lbl 1948 `"1948"', add
label define birthyr_lbl 1949 `"1949"', add
label define birthyr_lbl 1950 `"1950"', add
label define birthyr_lbl 1951 `"1951"', add
label define birthyr_lbl 1952 `"1952"', add
label define birthyr_lbl 1953 `"1953"', add
label define birthyr_lbl 1954 `"1954"', add
label define birthyr_lbl 1955 `"1955"', add
label define birthyr_lbl 1956 `"1956"', add
label define birthyr_lbl 1957 `"1957"', add
label define birthyr_lbl 1958 `"1958"', add
label define birthyr_lbl 1959 `"1959"', add
label define birthyr_lbl 1960 `"1960"', add
label define birthyr_lbl 1961 `"1961"', add
label define birthyr_lbl 1962 `"1962"', add
label define birthyr_lbl 1963 `"1963"', add
label define birthyr_lbl 1964 `"1964"', add
label define birthyr_lbl 1965 `"1965"', add
label define birthyr_lbl 1966 `"1966"', add
label define birthyr_lbl 1967 `"1967"', add
label define birthyr_lbl 1968 `"1968"', add
label define birthyr_lbl 1969 `"1969"', add
label define birthyr_lbl 1970 `"1970"', add
label define birthyr_lbl 1971 `"1971"', add
label define birthyr_lbl 1972 `"1972"', add
label define birthyr_lbl 1973 `"1973"', add
label define birthyr_lbl 1974 `"1974"', add
label define birthyr_lbl 1975 `"1975"', add
label define birthyr_lbl 1976 `"1976"', add
label define birthyr_lbl 1977 `"1977"', add
label define birthyr_lbl 1978 `"1978"', add
label define birthyr_lbl 1979 `"1979"', add
label define birthyr_lbl 1980 `"1980"', add
label define birthyr_lbl 1981 `"1981"', add
label define birthyr_lbl 1982 `"1982"', add
label define birthyr_lbl 1983 `"1983"', add
label define birthyr_lbl 1984 `"1984"', add
label define birthyr_lbl 1985 `"1985"', add
label define birthyr_lbl 1986 `"1986"', add
label define birthyr_lbl 1987 `"1987"', add
label define birthyr_lbl 1988 `"1988"', add
label define birthyr_lbl 1989 `"1989"', add
label define birthyr_lbl 1990 `"1990"', add
label define birthyr_lbl 1991 `"1991"', add
label define birthyr_lbl 1992 `"1992"', add
label define birthyr_lbl 1993 `"1993"', add
label define birthyr_lbl 1994 `"1994"', add
label define birthyr_lbl 1995 `"1995"', add
label define birthyr_lbl 1996 `"1996"', add
label define birthyr_lbl 1997 `"1997"', add
label define birthyr_lbl 1998 `"1998"', add
label define birthyr_lbl 1999 `"1999"', add
label define birthyr_lbl 2000 `"2000"', add
label define birthyr_lbl 2001 `"2001"', add
label define birthyr_lbl 2002 `"2002"', add
label define birthyr_lbl 2003 `"2003"', add
label define birthyr_lbl 2004 `"2004"', add
label define birthyr_lbl 2005 `"2005"', add
label define birthyr_lbl 2006 `"2006"', add
label define birthyr_lbl 2007 `"2007"', add
label define birthyr_lbl 2008 `"2008"', add
label define birthyr_lbl 2009 `"2009"', add
label define birthyr_lbl 2010 `"2010"', add
label define birthyr_lbl 2011 `"2011"', add
label define birthyr_lbl 2012 `"2012"', add
label define birthyr_lbl 2013 `"2013"', add
label define birthyr_lbl 9999 `"Unknown"', add
label values birthyr birthyr_lbl

label define birthmo_lbl 01 `"January"'
label define birthmo_lbl 02 `"February"', add
label define birthmo_lbl 03 `"March"', add
label define birthmo_lbl 04 `"April"', add
label define birthmo_lbl 05 `"May"', add
label define birthmo_lbl 06 `"June"', add
label define birthmo_lbl 07 `"July"', add
label define birthmo_lbl 08 `"August"', add
label define birthmo_lbl 09 `"September"', add
label define birthmo_lbl 10 `"October"', add
label define birthmo_lbl 11 `"November"', add
label define birthmo_lbl 12 `"December"', add
label define birthmo_lbl 98 `"Unknown"', add
label define birthmo_lbl 99 `"NIU (not in universe)"', add
label values birthmo birthmo_lbl

label define bplid_lbl 11 `"Special Region of Aceh"'
label define bplid_lbl 12 `"North Sumatra"', add
label define bplid_lbl 13 `"West Sumatra"', add
label define bplid_lbl 14 `"Riau and Kepulauan Riau"', add
label define bplid_lbl 15 `"Jambi"', add
label define bplid_lbl 16 `"South Sumatra and Bangka Belitung"', add
label define bplid_lbl 17 `"Bengkulu"', add
label define bplid_lbl 18 `"Lampung"', add
label define bplid_lbl 31 `"Special Capital Region of Jakarta"', add
label define bplid_lbl 32 `"West Java and Banten"', add
label define bplid_lbl 33 `"Central Java"', add
label define bplid_lbl 34 `"Special Region of Jogyakarta"', add
label define bplid_lbl 35 `"East Java"', add
label define bplid_lbl 51 `"Bali"', add
label define bplid_lbl 52 `"West Nusa Tenggara"', add
label define bplid_lbl 53 `"East Nusa Tenggara"', add
label define bplid_lbl 54 `"East Timor"', add
label define bplid_lbl 61 `"West Kalimantan"', add
label define bplid_lbl 62 `"Central Kalimantan"', add
label define bplid_lbl 63 `"South Kalimantan"', add
label define bplid_lbl 64 `"East Kalimantan"', add
label define bplid_lbl 71 `"North Sulawesi and Gorontalo"', add
label define bplid_lbl 72 `"Central Sulawesi"', add
label define bplid_lbl 73 `"South Sulawesi and West Sulawesi"', add
label define bplid_lbl 74 `"Southeast Sulawesi"', add
label define bplid_lbl 81 `"Maluku and North Maluku"', add
label define bplid_lbl 94 `"Papua and West Papua"', add
label define bplid_lbl 98 `"Abroad"', add
label define bplid_lbl 99 `"Unknown"', add
label values bplid bplid_lbl

label define religion_lbl 0 `"NIU (not in universe)"'
label define religion_lbl 1 `"No religion"', add
label define religion_lbl 2 `"Buddhist"', add
label define religion_lbl 3 `"Hindu"', add
label define religion_lbl 4 `"Jewish"', add
label define religion_lbl 5 `"Muslim"', add
label define religion_lbl 6 `"Christian"', add
label define religion_lbl 7 `"Other"', add
label define religion_lbl 9 `"Unknown"', add
label values religion religion_lbl

label define religiond_lbl 0000 `"NIU (not in universe)"'
label define religiond_lbl 1000 `"No religion"', add
label define religiond_lbl 1001 `"Atheist"', add
label define religiond_lbl 1002 `"Without religion"', add
label define religiond_lbl 2000 `"Buddhist"', add
label define religiond_lbl 3000 `"Hindu"', add
label define religiond_lbl 4000 `"Jewish"', add
label define religiond_lbl 5000 `"Muslim"', add
label define religiond_lbl 5001 `"Khadrya"', add
label define religiond_lbl 5002 `"Layenne"', add
label define religiond_lbl 5003 `"Mouride"', add
label define religiond_lbl 5004 `"Tidjane"', add
label define religiond_lbl 5005 `"Ahmadis"', add
label define religiond_lbl 5006 `"Sunni"', add
label define religiond_lbl 5007 `"Shiek"', add
label define religiond_lbl 5008 `"Other Muslim"', add
label define religiond_lbl 6000 `"Christian"', add
label define religiond_lbl 6001 `"Catholic (Roman or unspecified)"', add
label define religiond_lbl 6002 `"Orthodox"', add
label define religiond_lbl 6003 `"Protestant"', add
label define religiond_lbl 6004 `"Evangelical protestant"', add
label define religiond_lbl 6005 `"Pentacostal"', add
label define religiond_lbl 6006 `"Adventist / Seventh-day adventist"', add
label define religiond_lbl 6007 `"Anglican"', add
label define religiond_lbl 6008 `"Assembly of God"', add
label define religiond_lbl 6009 `"Baptist"', add
label define religiond_lbl 6010 `"Church of the Nazarene"', add
label define religiond_lbl 6011 `"Congregational"', add
label define religiond_lbl 6012 `"Dutch Reformed"', add
label define religiond_lbl 6013 `"Episcopalian"', add
label define religiond_lbl 6014 `"Jehovah's Witnesses"', add
label define religiond_lbl 6015 `"Latter Day Saints (Mormon)"', add
label define religiond_lbl 6016 `"Lutheran"', add
label define religiond_lbl 6017 `"Mennonite"', add
label define religiond_lbl 6018 `"Methodist"', add
label define religiond_lbl 6019 `"New Apostolic"', add
label define religiond_lbl 6020 `"Presbyterian"', add
label define religiond_lbl 6021 `"Zion Christian"', add
label define religiond_lbl 6100 `"Other Christian, Austria"', add
label define religiond_lbl 6101 `"Old Catholic"', add
label define religiond_lbl 6102 `"Protestant, Augsburg confession"', add
label define religiond_lbl 6103 `"Protestant, Westminster confession"', add
label define religiond_lbl 6104 `"Protestant, Helvetic confession"', add
label define religiond_lbl 6105 `"Greek Oriental"', add
label define religiond_lbl 6106 `"Armenian Apostolic"', add
label define religiond_lbl 6107 `"Other Protestant"', add
label define religiond_lbl 6108 `"Christian Community for renewal"', add
label define religiond_lbl 6109 `"Christian Community, not specified"', add
label define religiond_lbl 6110 `"Other Christian, Brazil"', add
label define religiond_lbl 6111 `"Christian Congregation of Brazil"', add
label define religiond_lbl 6112 `"Brazilian Catholic Apostolic"', add
label define religiond_lbl 6113 `"Brazil for Christ"', add
label define religiond_lbl 6114 `"Foursquare Gospel"', add
label define religiond_lbl 6115 `"Universal of the Kingdom of God"', add
label define religiond_lbl 6116 `"House of the Blessing"', add
label define religiond_lbl 6117 `"House of Prayer"', add
label define religiond_lbl 6118 `"God is Love"', add
label define religiond_lbl 6119 `"Maranata"', add
label define religiond_lbl 6120 `"Other Christian, Brazil 1991"', add
label define religiond_lbl 6121 `"Undetermined Protestant"', add
label define religiond_lbl 6124 `"Other traditional Protestant"', add
label define religiond_lbl 6125 `"Neo-Christian"', add
label define religiond_lbl 6126 `"Other Neo-Christian"', add
label define religiond_lbl 6127 `"Undetermined Christian"', add
label define religiond_lbl 6128 `"Other Christian, Brazil 2000"', add
label define religiond_lbl 6129 `"Other Catholic"', add
label define religiond_lbl 6130 `"Renewed Evangelical Protestant without institutional ties"', add
label define religiond_lbl 6131 `"Pentecostal Evangelical without institutional ties"', add
label define religiond_lbl 6132 `"New Life Evangelical Protestant Pentecostal"', add
label define religiond_lbl 6133 `"Evangelical Protestant Biblical Revival Pentecostal"', add
label define religiond_lbl 6134 `"Chain Of Prayer Pentecostal"', add
label define religiond_lbl 6135 `"Undetermined Evangelical Protestant"', add
label define religiond_lbl 6136 `"Religion Of God"', add
label define religiond_lbl 6137 `"Christian without institutional ties"', add
label define religiond_lbl 6138 `"Other Christian, Canada"', add
label define religiond_lbl 6139 `"Other Catholic"', add
label define religiond_lbl 6140 `"United Church"', add
label define religiond_lbl 6141 `"Protestant, not specified"', add
label define religiond_lbl 6142 `"Other Protestant"', add
label define religiond_lbl 6143 `"Other Christian, Germany"', add
label define religiond_lbl 6144 `"Oriental Christian"', add
label define religiond_lbl 6145 `"Other Christian, Ghana"', add
label define religiond_lbl 6146 `"Other Christian, Iran"', add
label define religiond_lbl 6147 `"Assyrian or Chaldean"', add
label define religiond_lbl 6148 `"Armenian"', add
label define religiond_lbl 6149 `"Other Christians"', add
label define religiond_lbl 6150 `"Other Christian, Indonesia"', add
label define religiond_lbl 6151 `"Other Christian"', add
label define religiond_lbl 6152 `"Protestant/Other Christian"', add
label define religiond_lbl 6153 `"Other Christian, Ireland"', add
label define religiond_lbl 6154 `"Quaker"', add
label define religiond_lbl 6155 `"Other Christian, Jamaica"', add
label define religiond_lbl 6156 `"Brethren"', add
label define religiond_lbl 6157 `"Church of God"', add
label define religiond_lbl 6158 `"Church of God of Prophecy"', add
label define religiond_lbl 6159 `"Other Church of God"', add
label define religiond_lbl 6160 `"Moravian"', add
label define religiond_lbl 6161 `"United Church"', add
label define religiond_lbl 6162 `"Salvation Army"', add
label define religiond_lbl 6163 `"New Testament"', add
label define religiond_lbl 6164 `"Disciples of Christ"', add
label define religiond_lbl 6165 `"Other Christian, Mexico"', add
label define religiond_lbl 6166 `"Anabaptist"', add
label define religiond_lbl 6167 `"Calvinist"', add
label define religiond_lbl 6168 `"Cuaquera"', add
label define religiond_lbl 6169 `"Disciples of Christ"', add
label define religiond_lbl 6170 `"Christian Friendship Church"', add
label define religiond_lbl 6171 `"Prayer House Church"', add
label define religiond_lbl 6172 `"Faith Center"', add
label define religiond_lbl 6173 `"Agape Force Church"', add
label define religiond_lbl 6174 `"Alpha and Omega Church"', add
label define religiond_lbl 6175 `"Living Water Church"', add
label define religiond_lbl 6176 `"Apostolic Church"', add
label define religiond_lbl 6177 `"Church of God"', add
label define religiond_lbl 6178 `"Church of God of Prophecy"', add
label define religiond_lbl 6179 `"Complete Gospel Church"', add
label define religiond_lbl 6180 `"Evangelical Siblings Church"', add
label define religiond_lbl 6181 `"Upper Room Church"', add
label define religiond_lbl 6182 `"Pentacostal Indigenous Church"', add
label define religiond_lbl 6183 `"Angular Stone Voice Church"', add
label define religiond_lbl 6184 `"Pentacostal Missionary"', add
label define religiond_lbl 6185 `"Christian"', add
label define religiond_lbl 6186 `"Christian Societies"', add
label define religiond_lbl 6187 `"Evangelical"', add
label define religiond_lbl 6188 `"Evangelical Societies"', add
label define religiond_lbl 6189 `"New Testament Evangelical"', add
label define religiond_lbl 6190 `"Pentecostal"', add
label define religiond_lbl 6191 `"Pentecostal Societies"', add
label define religiond_lbl 6192 `"Independent Pentecostal"', add
label define religiond_lbl 6193 `"Evangelical Christian Societies"', add
label define religiond_lbl 6194 `"Pentecostal Christian Societies"', add
label define religiond_lbl 6195 `"Evangelical Pentecostal Societies"', add
label define religiond_lbl 6196 `"Evangelical Pentecostal Christian Societies"', add
label define religiond_lbl 6197 `"Soldiers of Christ's Cross Church"', add
label define religiond_lbl 6198 `"Tabernacle"', add
label define religiond_lbl 6199 `"Traditionalists"', add
label define religiond_lbl 6200 `"Other Evangelical Pentecostal Societies"', add
label define religiond_lbl 6201 `"Pentecostal not clearly specified"', add
label define religiond_lbl 6202 `"Living God, Light of the World"', add
label define religiond_lbl 6203 `"Christian and Missionary Alliance"', add
label define religiond_lbl 6204 `"Non-Pentecostal Apostolic"', add
label define religiond_lbl 6205 `"Evangelical Associations"', add
label define religiond_lbl 6206 `"Biblical"', add
label define religiond_lbl 6207 `"Confraternities"', add
label define religiond_lbl 6208 `"Christ Church"', add
label define religiond_lbl 6209 `"Peace Grace and Misericordia Church"', add
label define religiond_lbl 6210 `"Open Bible Church"', add
label define religiond_lbl 6211 `"Holiness Church"', add
label define religiond_lbl 6212 `"Evangelical Salem Church"', add
label define religiond_lbl 6213 `"Beautiful Woman Dressed in the Sun"', add
label define religiond_lbl 6214 `"Messianic Church"', add
label define religiond_lbl 6215 `"Evangelical Ministers"', add
label define religiond_lbl 6216 `"Evangelical Missionaries"', add
label define religiond_lbl 6217 `"Evangelical Movements"', add
label define religiond_lbl 6218 `"New Jerusalem"', add
label define religiond_lbl 6219 `"World Vision Church"', add
label define religiond_lbl 6220 `"Evangelical not clearly specified"', add
label define religiond_lbl 6221 `"Biblical - non-evangelicals"', add
label define religiond_lbl 6222 `"Other Christians not clearly specified"', add
label define religiond_lbl 6223 `"Assumptionist"', add
label define religiond_lbl 6224 `"Carmelite"', add
label define religiond_lbl 6225 `"Claretian"', add
label define religiond_lbl 6226 `"Conception Franciscan"', add
label define religiond_lbl 6227 `"Maronite Diocese of Mexico"', add
label define religiond_lbl 6228 `"Dominican"', add
label define religiond_lbl 6229 `"Servants of Mary Immaculate"', add
label define religiond_lbl 6230 `"Franciscan"', add
label define religiond_lbl 6231 `"Guadalupan"', add
label define religiond_lbl 6232 `"Daughters of the Immaculate Conception"', add
label define religiond_lbl 6233 `"Jesuit"', add
label define religiond_lbl 6234 `"Legionaries of Christ"', add
label define religiond_lbl 6235 `"Divine Word Missionary"', add
label define religiond_lbl 6236 `"Pauline"', add
label define religiond_lbl 6237 `"Sacred Heart"', add
label define religiond_lbl 6238 `"Saint Joseph of Tarbes"', add
label define religiond_lbl 6239 `"Servant of the Lord and the Virgin"', add
label define religiond_lbl 6240 `"Servant of Jesus"', add
label define religiond_lbl 6241 `"Greek Catholic Church"', add
label define religiond_lbl 6242 `"Reformed Roman Catholic Church"', add
label define religiond_lbl 6243 `"Mexican National Catholic Church"', add
label define religiond_lbl 6244 `"Tridentine Latin Rite Catholic Church"', add
label define religiond_lbl 6245 `"Priestly Society Trento"', add
label define religiond_lbl 6246 `"Mexican Catholic Union of Trento"', add
label define religiond_lbl 6247 `"Anabaptist / Memnonite"', add
label define religiond_lbl 6248 `"Anglican / Episcopal"', add
label define religiond_lbl 6249 `"House of Prayer"', add
label define religiond_lbl 6250 `"Center of Faith, Hope and Love of the Missionary Revival Crusade"', add
label define religiond_lbl 6251 `"Center of Faith, Hope and Love Agape Force"', add
label define religiond_lbl 6252 `"Salvation Army"', add
label define religiond_lbl 6253 `"Independent Pentecostal Fellowship"', add
label define religiond_lbl 6254 `"Upper Chamber Church"', add
label define religiond_lbl 6255 `"Faith Apostolic Church of Jesus Christ"', add
label define religiond_lbl 6256 `"Spiritual Christian Church"', add
label define religiond_lbl 6257 `"Pentecostal Evangelical Christian Church"', add
label define religiond_lbl 6258 `"Interdenominational Christian Church"', add
label define religiond_lbl 6259 `"Church of God Full Gospel in Mexico"', add
label define religiond_lbl 6260 `"Church of Jesus Christ on the Rock"', add
label define religiond_lbl 6261 `"Christ Evangelical Pentecostal Church Rock of my Salvation"', add
label define religiond_lbl 6262 `"Mexican Church of Christ's Gospel Pentecost"', add
label define religiond_lbl 6263 `"United Pentecostal Church of Mexico"', add
label define religiond_lbl 6264 `"Universal Church of the Kingdom of God"', add
label define religiond_lbl 6265 `"Only Christ Savior Christian Church"', add
label define religiond_lbl 6266 `"Independent Evangelical Pentecostal Movement"', add
label define religiond_lbl 6267 `"Prince of Peace"', add
label define religiond_lbl 6268 `"National Union of Evangelical Christian Churches (UNICE)"', add
label define religiond_lbl 6269 `"Union of Independent Evangelical Churches"', add
label define religiond_lbl 6270 `"Other associations Pentecostal"', add
label define religiond_lbl 6271 `"Church of the Living God, Pillar and Support of Truth, the Light of the World"', add
label define religiond_lbl 6272 `"Bible Church"', add
label define religiond_lbl 6273 `"Interdenominational Christian Church in Mexico"', add
label define religiond_lbl 6274 `"Church of Christ"', add
label define religiond_lbl 6275 `"Honey Church of Christ"', add
label define religiond_lbl 6276 `"Independent Evangelical Church in Mexico"', add
label define religiond_lbl 6277 `"Renewed Church of Jesus Christ and the Apostles of Divine Love"', add
label define religiond_lbl 6278 `"Other Christian and Evangelical associations without Pentecostal support"', add
label define religiond_lbl 6279 `"Faith Christian Church"', add
label define religiond_lbl 6280 `"Traditional Apostolic Catholic Holy Church Mexico-USA"', add
label define religiond_lbl 6281 `"Mexican Apostolic Catholic Church"', add
label define religiond_lbl 6282 `"Elias"', add
label define religiond_lbl 6283 `"Spiritualistic"', add
label define religiond_lbl 6284 `"Spiritualist"', add
label define religiond_lbl 6285 `"Marian Trinitarian Spirituality"', add
label define religiond_lbl 6286 `"Spirituality of the Third Age"', add
label define religiond_lbl 6287 `"Christian Spiritual"', add
label define religiond_lbl 6288 `"Judiciary Society Reign of Leonardo Alcal‡ Leos"', add
label define religiond_lbl 6289 `"Spirituality for the Divine Master and the purity of Mary"', add
label define religiond_lbl 6290 `"Light and Hope"', add
label define religiond_lbl 6291 `"Holy Spirit, Purity, Love and Light"', add
label define religiond_lbl 6292 `"Christian Science"', add
label define religiond_lbl 6293 `"Other Christian, Netherlands"', add
label define religiond_lbl 6294 `"Reformed Churches in The Netherlands"', add
label define religiond_lbl 6295 `"Other Reformed"', add
label define religiond_lbl 6296 `"Other Christian, Nicaragua"', add
label define religiond_lbl 6297 `"Moravian"', add
label define religiond_lbl 6298 `"Other Christian, Philippines"', add
label define religiond_lbl 6299 `"Aglipay"', add
label define religiond_lbl 6300 `"Bible Christian Committees"', add
label define religiond_lbl 6301 `"Born-again Christian"', add
label define religiond_lbl 6302 `"Bread of Life Ministries"', add
label define religiond_lbl 6303 `"Charismatic Full Gospel Ministries"', add
label define religiond_lbl 6304 `"Christ the Living Stone Fellowship"', add
label define religiond_lbl 6305 `"Christian and Missionary Alliance"', add
label define religiond_lbl 6306 `"Christians Missions"', add
label define religiond_lbl 6307 `"Church of Christ"', add
label define religiond_lbl 6308 `"Evangelical Christian Outreach Foundation"', add
label define religiond_lbl 6309 `"Evangelical Free Church"', add
label define religiond_lbl 6310 `"Filipino Assemblies of the First Born Inc."', add
label define religiond_lbl 6311 `"Foursquare Gospel"', add
label define religiond_lbl 6312 `"Free Believers in Christ Fellowship"', add
label define religiond_lbl 6313 `"Free Mission in the Philippines Inc."', add
label define religiond_lbl 6314 `"God World Mission"', add
label define religiond_lbl 6315 `"Good News Christian Churches"', add
label define religiond_lbl 6316 `"IEMELIF Reform Movement"', add
label define religiond_lbl 6317 `"Iglesia Evangelista Methodista en Las"', add
label define religiond_lbl 6318 `"Iglesia ni Cristo"', add
label define religiond_lbl 6319 `"Jesus Christ Saves Global Outreach"', add
label define religiond_lbl 6320 `"Jesus is Lord Church"', add
label define religiond_lbl 6321 `"Jesus Reigns Ministries"', add
label define religiond_lbl 6322 `"Love of Christ International Ministries"', add
label define religiond_lbl 6323 `"Other evangelical"', add
label define religiond_lbl 6324 `"Other Evangelical Church"', add
label define religiond_lbl 6325 `"Other Protestants"', add
label define religiond_lbl 6326 `"Philippine Evangelical Mission"', add
label define religiond_lbl 6327 `"Philippine Grace Gospel Fellowship"', add
label define religiond_lbl 6328 `"Philippines Benevolent Missionaries"', add
label define religiond_lbl 6329 `"Potter's House Christian Center"', add
label define religiond_lbl 6330 `"Salvation Army Philippines"', add
label define religiond_lbl 6331 `"Take the Nation for Jesus Global Ministries (Corpus Christi)"', add
label define religiond_lbl 6332 `"UNIDA Evangelical Church"', add
label define religiond_lbl 6333 `"United Church of Christ in the Philippines"', add
label define religiond_lbl 6334 `"United Evangelical Church of the Philippines (Chinese)"', add
label define religiond_lbl 6335 `"Victory Chapel Christian Fellowship"', add
label define religiond_lbl 6336 `"Wesleyan Church"', add
label define religiond_lbl 6337 `"World Missionary Evangelism"', add
label define religiond_lbl 6338 `"Worldwide Church of God"', add
label define religiond_lbl 6339 `"Zion Christian Community Church"', add
label define religiond_lbl 6340 `"Other Christian, Portugal"', add
label define religiond_lbl 6341 `"Other Christian, Romania"', add
label define religiond_lbl 6342 `"Greek Catholic"', add
label define religiond_lbl 6343 `"Reformed Church"', add
label define religiond_lbl 6344 `"Evangelic of Augustan Confession"', add
label define religiond_lbl 6345 `"Evangelic Synodo-Presbyterian"', add
label define religiond_lbl 6346 `"Christian of Old Rite"', add
label define religiond_lbl 6347 `"Christian by Gospel"', add
label define religiond_lbl 6348 `"Evangelic"', add
label define religiond_lbl 6349 `"Other Christian, Rwanda 2002"', add
label define religiond_lbl 6350 `"Other Christian, Sierra Leone"', add
label define religiond_lbl 6351 `"Other Christian, South Africa"', add
label define religiond_lbl 6352 `"Reformed"', add
label define religiond_lbl 6353 `"International Fellowship of Christian Churches"', add
label define religiond_lbl 6354 `"Apostolic Faith Mission of SA"', add
label define religiond_lbl 6355 `"Other Apostolic Churches"', add
label define religiond_lbl 6356 `"Pinkster Protestant Church"', add
label define religiond_lbl 6357 `"Afrikaanse Protestant Church"', add
label define religiond_lbl 6358 `"Full Gospel Church of God in Southern Africa"', add
label define religiond_lbl 6359 `"Pentecostal Churches"', add
label define religiond_lbl 6360 `"Salvation Army"', add
label define religiond_lbl 6361 `"Bandla Lama Nazaretha"', add
label define religiond_lbl 6362 `"African Methodist Episcopal Church"', add
label define religiond_lbl 6363 `"St John's Apostolic Church"', add
label define religiond_lbl 6364 `"International Pentecost Church"', add
label define religiond_lbl 6365 `"Ethiopian type churches"', add
label define religiond_lbl 6366 `"Ethnic churches"', add
label define religiond_lbl 6367 `"Other African Independent Churches"', add
label define religiond_lbl 6368 `"Other Christian Churches"', add
label define religiond_lbl 6369 `"Other Catholic Churches"', add
label define religiond_lbl 6370 `"Other Pentecostal Churches"', add
label define religiond_lbl 6371 `"Other Orthodox Churches"', add
label define religiond_lbl 6372 `"Other African Apostolic churches"', add
label define religiond_lbl 6373 `"Other Assemblies"', add
label define religiond_lbl 6374 `"Christian Scientist"', add
label define religiond_lbl 6375 `"Christian Centres"', add
label define religiond_lbl 6376 `"Other Evangelical Churches"', add
label define religiond_lbl 6377 `"Other Charismatic Churches"', add
label define religiond_lbl 6378 `"Other Christian, Uganda"', add
label define religiond_lbl 6379 `"Other Christian"', add
label define religiond_lbl 6380 `"Other Christian, Saint Lucia"', add
label define religiond_lbl 6381 `"Church of God"', add
label define religiond_lbl 6382 `"Other Christian, Senegal"', add
label define religiond_lbl 6383 `"Other Christian"', add
label define religiond_lbl 6384 `"Other Christian, Switzerland"', add
label define religiond_lbl 6385 `"Other protestant churches and communities"', add
label define religiond_lbl 6386 `"Christ-Catholic church"', add
label define religiond_lbl 6387 `"Other Christian communities"', add
label define religiond_lbl 6388 `"Other Christian non-Catholic, Uruguay"', add
label define religiond_lbl 6389 `"Other Christian, Fiji"', add
label define religiond_lbl 6390 `"Christian undefined"', add
label define religiond_lbl 6391 `"Church of England"', add
label define religiond_lbl 6392 `"Gospel Hall and Brethern"', add
label define religiond_lbl 6393 `"CMF (Every Home)"', add
label define religiond_lbl 6394 `"Salvation Army"', add
label define religiond_lbl 6395 `"All Nations Christian Fellowship"', add
label define religiond_lbl 6396 `"Apostles Gospel Outreach Fellowship"', add
label define religiond_lbl 6397 `"Christian Outreach Centre"', add
label define religiond_lbl 6398 `"Other Christian, Brazil 2010"', add
label define religiond_lbl 6399 `"Salvation Army"', add
label define religiond_lbl 6400 `"Other Christian, Cameroon"', add
label define religiond_lbl 6401 `"Other Christian, Armenia"', add
label define religiond_lbl 6402 `"Armenia apostolic"', add
label define religiond_lbl 6403 `"Nestorian"', add
label define religiond_lbl 6404 `"Molokai"', add
label define religiond_lbl 6406 `"Other Christian, Paraguay"', add
label define religiond_lbl 6408 `"Christian Community"', add
label define religiond_lbl 6409 `"Free Brothers"', add
label define religiond_lbl 6410 `"Church of God"', add
label define religiond_lbl 6411 `"Church of God of Prophecy"', add
label define religiond_lbl 6412 `"New testament"', add
label define religiond_lbl 6414 `"God is love"', add
label define religiond_lbl 6415 `"Universal Church of the Kingdom of God"', add
label define religiond_lbl 6416 `"People of God"', add
label define religiond_lbl 6417 `"Family worship center"', add
label define religiond_lbl 6418 `"Pseudo-Christian groups"', add
label define religiond_lbl 6419 `"Other Christian, Paraguay"', add
label define religiond_lbl 7000 `"Other"', add
label define religiond_lbl 7001 `"Bahai"', add
label define religiond_lbl 7002 `"Sikh"', add
label define religiond_lbl 7003 `"Other, Austria"', add
label define religiond_lbl 7004 `"Unification Church, Austria"', add
label define religiond_lbl 7005 `"Other, Brazil"', add
label define religiond_lbl 7006 `"Spiritist"', add
label define religiond_lbl 7007 `"Kardecist Spiritist"', add
label define religiond_lbl 7008 `"Afro Spiritist"', add
label define religiond_lbl 7009 `"Mediumistic Spiritist"', add
label define religiond_lbl 7010 `"Umbandist Mediumistic"', add
label define religiond_lbl 7011 `"Candomblecist Mediumistic"', add
label define religiond_lbl 7012 `"Other Afro-Brazilian"', add
label define religiond_lbl 7013 `"Oriental, Brazil"', add
label define religiond_lbl 7014 `"New Oriental"', add
label define religiond_lbl 7015 `"Oriental Seicho No-le"', add
label define religiond_lbl 7016 `"Other Oriental, Brazil"', add
label define religiond_lbl 7017 `"Esoteric, Brazil"', add
label define religiond_lbl 7018 `"Indigenous, Brazil"', add
label define religiond_lbl 7019 `"Other minority groups, Brazil"', add
label define religiond_lbl 7020 `"Other, Canada"', add
label define religiond_lbl 7021 `"Eastern religions, Canada"', add
label define religiond_lbl 7022 `"Other, Chile"', add
label define religiond_lbl 7023 `"Theosophism"', add
label define religiond_lbl 7024 `"Shintoism"', add
label define religiond_lbl 7025 `"Other, Germany"', add
label define religiond_lbl 7026 `"Other, Germany"', add
label define religiond_lbl 7027 `"Other, Ghana"', add
label define religiond_lbl 7028 `"Traditional, Ghana"', add
label define religiond_lbl 7029 `"Other, Guinea"', add
label define religiond_lbl 7030 `"Animist"', add
label define religiond_lbl 7031 `"Other, Guinea"', add
label define religiond_lbl 7032 `"Other, India"', add
label define religiond_lbl 7033 `"Jainism"', add
label define religiond_lbl 7034 `"Zoroastrianism"', add
label define religiond_lbl 7035 `"Other, India"', add
label define religiond_lbl 7036 `"Other, Indonesia"', add
label define religiond_lbl 7037 `"Confucianism"', add
label define religiond_lbl 7038 `"Other, Indonesia"', add
label define religiond_lbl 7039 `"Other, Iran"', add
label define religiond_lbl 7040 `"Zoroastrian"', add
label define religiond_lbl 7041 `"Other, Iran"', add
label define religiond_lbl 7042 `"Other, Jamaica"', add
label define religiond_lbl 7043 `"Muslim/Hindu"', add
label define religiond_lbl 7044 `"Rastafarian"', add
label define religiond_lbl 7045 `"Other, Israel"', add
label define religiond_lbl 7046 `"Druse"', add
label define religiond_lbl 7047 `"Other, Israel"', add
label define religiond_lbl 7048 `"Other, Malaysia"', add
label define religiond_lbl 7049 `"Confucianism/Taoism"', add
label define religiond_lbl 7050 `"Tribal/Folk religion, Malaysia"', add
label define religiond_lbl 7051 `"Other, Mexico"', add
label define religiond_lbl 7052 `"Brahmanism"', add
label define religiond_lbl 7053 `"Hare Krishna"', add
label define religiond_lbl 7054 `"Shintoism"', add
label define religiond_lbl 7055 `"Taoism"', add
label define religiond_lbl 7056 `"Mexican Movements"', add
label define religiond_lbl 7057 `"Ananda Marga"', add
label define religiond_lbl 7058 `"Church of Scientology"', add
label define religiond_lbl 7059 `"Masons"', add
label define religiond_lbl 7060 `"Raelian Movement"', add
label define religiond_lbl 7061 `"New Age Movement"', add
label define religiond_lbl 7062 `"Neoisraelites"', add
label define religiond_lbl 7063 `"Occultists"', add
label define religiond_lbl 7064 `"Palmar of Troya"', add
label define religiond_lbl 7065 `"Rose Cross"', add
label define religiond_lbl 7066 `"Theosophism"', add
label define religiond_lbl 7067 `"Spiritualist Special Keys"', add
label define religiond_lbl 7068 `"Onkaranada Center"', add
label define religiond_lbl 7069 `"Confucianism"', add
label define religiond_lbl 7070 `"Shia"', add
label define religiond_lbl 7071 `"Universal Great Brotherhood"', add
label define religiond_lbl 7072 `"Esoteric Science"', add
label define religiond_lbl 7073 `"Gnosticism"', add
label define religiond_lbl 7074 `"Metaphysics"', add
label define religiond_lbl 7075 `"Wicca"', add
label define religiond_lbl 7076 `"Shamanism"', add
label define religiond_lbl 7077 `"The Custom"', add
label define religiond_lbl 7078 `"Mexicayotl"', add
label define religiond_lbl 7079 `"Restorative Confederate Movement of Anahuac Culture"', add
label define religiond_lbl 7080 `"African Origin"', add
label define religiond_lbl 7081 `"Rastafarians"', add
label define religiond_lbl 7082 `"Indigenous Religions"', add
label define religiond_lbl 7083 `"Growing in Grace"', add
label define religiond_lbl 7084 `"Eckankar"', add
label define religiond_lbl 7085 `"Transcendental Meditation"', add
label define religiond_lbl 7086 `"Mission Branch"', add
label define religiond_lbl 7087 `"Children of God"', add
label define religiond_lbl 7088 `"Sri Sathya Sai Baba"', add
label define religiond_lbl 7089 `"Other new religious movements"', add
label define religiond_lbl 7090 `"Other, Philippines"', add
label define religiond_lbl 7091 `"Door of Faith"', add
label define religiond_lbl 7092 `"Faith Tabernacle Church (Living Rock Ministries)"', add
label define religiond_lbl 7093 `"International One Way Outreach"', add
label define religiond_lbl 7094 `"Miracle Life Fellowship International"', add
label define religiond_lbl 7095 `"Miracle Revival Church of the Philippines"', add
label define religiond_lbl 7096 `"Philippine Good News Ministries"', add
label define religiond_lbl 7097 `"Philippine Missionary fellowship"', add
label define religiond_lbl 7098 `"Things to Come"', add
label define religiond_lbl 7099 `"Way of Salvation"', add
label define religiond_lbl 7100 `"Word of the World"', add
label define religiond_lbl 7101 `"Tribal Religions, Philippines"', add
label define religiond_lbl 7102 `"Other, Romania"', add
label define religiond_lbl 7103 `"Unitarian"', add
label define religiond_lbl 7104 `"Armenian"', add
label define religiond_lbl 7105 `"Mosaic"', add
label define religiond_lbl 7106 `"Other, Romania"', add
label define religiond_lbl 7107 `"Other, Rwanda"', add
label define religiond_lbl 7108 `"Traditional religion, Rwanda"', add
label define religiond_lbl 7109 `"Other, Rwanda"', add
label define religiond_lbl 7110 `"Other, Sierra Leone"', add
label define religiond_lbl 7111 `"Traditional religion, Sierra Leone"', add
label define religiond_lbl 7112 `"Other, South Africa"', add
label define religiond_lbl 7113 `"African traditional belief"', add
label define religiond_lbl 7114 `"Taoist"', add
label define religiond_lbl 7115 `"Confucian"', add
label define religiond_lbl 7116 `"New Age"', add
label define religiond_lbl 7117 `"Other non-Christian, S. Africa"', add
label define religiond_lbl 7118 `"Other, Uganda"', add
label define religiond_lbl 7119 `"Traditional religion"', add
label define religiond_lbl 7120 `"Other non-Christian, Uganda"', add
label define religiond_lbl 7121 `"Other, United Kindom"', add
label define religiond_lbl 7122 `"Other, Vietnam"', add
label define religiond_lbl 7123 `"Hoa Hoa"', add
label define religiond_lbl 7124 `"Cao Dai"', add
label define religiond_lbl 7125 `"Other, Nepal"', add
label define religiond_lbl 7126 `"Kirat"', add
label define religiond_lbl 7127 `"Jain"', add
label define religiond_lbl 7128 `"Garaute"', add
label define religiond_lbl 7129 `"Tap jura"', add
label define religiond_lbl 7130 `"Other, Pakistan"', add
label define religiond_lbl 7131 `"Ahmadi"', add
label define religiond_lbl 7132 `"Parsi"', add
label define religiond_lbl 7133 `"Scheduled caste"', add
label define religiond_lbl 7134 `"Other, Saint Lucia"', add
label define religiond_lbl 7135 `"Rastafarian"', add
label define religiond_lbl 7136 `"Other, Thailand"', add
label define religiond_lbl 7137 `"Confucian"', add
label define religiond_lbl 7138 `"Other, Uruguay"', add
label define religiond_lbl 7139 `"Umbanda/other Afro-American"', add
label define religiond_lbl 7140 `"Other, Uruguay"', add
label define religiond_lbl 7141 `"Other, Burkina Faso"', add
label define religiond_lbl 7142 `"Animist"', add
label define religiond_lbl 7143 `"Other, Fiji"', add
label define religiond_lbl 7144 `"Confucian"', add
label define religiond_lbl 7145 `"Kabir Panthi"', add
label define religiond_lbl 7146 `"Satya Sai Baba"', add
label define religiond_lbl 7147 `"Bahai"', add
label define religiond_lbl 7148 `"Other non-Christian, Fiji"', add
label define religiond_lbl 7149 `"Other, Haiti"', add
label define religiond_lbl 7150 `"Voodoo"', add
label define religiond_lbl 7151 `"Other, Cameroon"', add
label define religiond_lbl 7152 `"Animist"', add
label define religiond_lbl 7153 `"Other, Liberia"', add
label define religiond_lbl 7154 `"Traditional"', add
label define religiond_lbl 7155 `"Other, Mali"', add
label define religiond_lbl 7156 `"Animist"', add
label define religiond_lbl 7157 `"Other, Nigeria"', add
label define religiond_lbl 7158 `"Traditional"', add
label define religiond_lbl 7159 `"Other, Armenia"', add
label define religiond_lbl 7160 `"Pagan"', add
label define religiond_lbl 7161 `"Shar-fadinian"', add
label define religiond_lbl 7162 `"Other, Ethiopia"', add
label define religiond_lbl 7163 `"Traditional"', add
label define religiond_lbl 7164 `"Other, Ethiopia"', add
label define religiond_lbl 7165 `"Other, Paraguay"', add
label define religiond_lbl 7166 `"Philosophical revelations"', add
label define religiond_lbl 7167 `"Indigenous religion"', add
label define religiond_lbl 7168 `"Reyukai"', add
label define religiond_lbl 7169 `"Other, Paraguay"', add
label define religiond_lbl 7900 `"Other, not elsewhere classified"', add
label define religiond_lbl 9999 `"Unknown"', add
label values religiond religiond_lbl

label define langid_lbl 1 `"Indonesian"'
label define langid_lbl 2 `"Local language"', add
label define langid_lbl 3 `"Foreign"', add
label define langid_lbl 8 `"Unknown"', add
label define langid_lbl 9 `"NIU (not in universe)"', add
label values langid langid_lbl

label define lit_lbl 0 `"NIU (not in universe)"'
label define lit_lbl 1 `"No, illiterate"', add
label define lit_lbl 2 `"Yes, literate"', add
label define lit_lbl 9 `"Unknown/missing"', add
label values lit lit_lbl

label define edattain_lbl 0 `"NIU (not in universe)"'
label define edattain_lbl 1 `"Less than primary completed"', add
label define edattain_lbl 2 `"Primary completed"', add
label define edattain_lbl 3 `"Secondary completed"', add
label define edattain_lbl 4 `"University completed"', add
label define edattain_lbl 9 `"Unknown"', add
label values edattain edattain_lbl

label define edattaind_lbl 000 `"NIU (not in universe)"'
label define edattaind_lbl 100 `"Less than primary completed (n.s.)"', add
label define edattaind_lbl 110 `"No schooling"', add
label define edattaind_lbl 120 `"Some primary completed"', add
label define edattaind_lbl 130 `"Primary (4 yrs) completed"', add
label define edattaind_lbl 211 `"Primary (5 yrs) completed"', add
label define edattaind_lbl 212 `"Primary (6 yrs) completed"', add
label define edattaind_lbl 221 `"Lower secondary general completed"', add
label define edattaind_lbl 222 `"Lower secondary technical completed"', add
label define edattaind_lbl 311 `"Secondary, general track completed"', add
label define edattaind_lbl 312 `"Some college completed"', add
label define edattaind_lbl 320 `"Secondary or post-secondary technical completed"', add
label define edattaind_lbl 321 `"Secondary, technical track completed"', add
label define edattaind_lbl 322 `"Post-secondary technical education"', add
label define edattaind_lbl 400 `"University completed"', add
label define edattaind_lbl 999 `"Unknown/missing"', add
label values edattaind edattaind_lbl

label define yrschool_lbl 00 `"None or pre-school"'
label define yrschool_lbl 01 `"1 year"', add
label define yrschool_lbl 02 `"2 years"', add
label define yrschool_lbl 03 `"3 years"', add
label define yrschool_lbl 04 `"4 years"', add
label define yrschool_lbl 05 `"5 years"', add
label define yrschool_lbl 06 `"6 years"', add
label define yrschool_lbl 07 `"7 years"', add
label define yrschool_lbl 08 `"8 years"', add
label define yrschool_lbl 09 `"9 years"', add
label define yrschool_lbl 10 `"10 years"', add
label define yrschool_lbl 11 `"11 years"', add
label define yrschool_lbl 12 `"12 years"', add
label define yrschool_lbl 13 `"13 years"', add
label define yrschool_lbl 14 `"14 years"', add
label define yrschool_lbl 15 `"15 years"', add
label define yrschool_lbl 16 `"16 years"', add
label define yrschool_lbl 17 `"17 years"', add
label define yrschool_lbl 18 `"18 years or more"', add
label define yrschool_lbl 90 `"Not specified"', add
label define yrschool_lbl 91 `"Some primary"', add
label define yrschool_lbl 92 `"Some technical after primary"', add
label define yrschool_lbl 93 `"Some secondary"', add
label define yrschool_lbl 94 `"Some tertiary"', add
label define yrschool_lbl 95 `"Adult literacy"', add
label define yrschool_lbl 96 `"Special education"', add
label define yrschool_lbl 97 `"Response suppressed"', add
label define yrschool_lbl 98 `"Unknown/missing"', add
label define yrschool_lbl 99 `"NIU (not in universe)"', add
label values yrschool yrschool_lbl

label define educid_lbl 000 `"NIU (not in universe)"'
label define educid_lbl 010 `"None"', add
label define educid_lbl 011 `"No schooling or primary not completed"', add
label define educid_lbl 020 `"Preschool"', add
label define educid_lbl 021 `"Preschool, not completed"', add
label define educid_lbl 022 `"Preschool, completed"', add
label define educid_lbl 030 `"Primary education (6 years)"', add
label define educid_lbl 031 `"Primary education (6 years), grade 1"', add
label define educid_lbl 032 `"Primary education (6 years), grade 2"', add
label define educid_lbl 033 `"Primary education (6 years), grade 3"', add
label define educid_lbl 034 `"Primary education (6 years), grade 4"', add
label define educid_lbl 035 `"Primary education (6 years), grade 5"', add
label define educid_lbl 036 `"Primary education (6 years), grade 6"', add
label define educid_lbl 037 `"Primary education (6 years), grade unknown"', add
label define educid_lbl 038 `"Primary education (6 years), not completed"', add
label define educid_lbl 039 `"Primary education (6 years), completed"', add
label define educid_lbl 040 `"Primary education (3 years)"', add
label define educid_lbl 041 `"Primary education (3 years), grade 1"', add
label define educid_lbl 042 `"Primary education (3 years), grade 2"', add
label define educid_lbl 043 `"Primary education (3 years), grade 3"', add
label define educid_lbl 044 `"Primary education (3 years), completed"', add
label define educid_lbl 050 `"Junior high school"', add
label define educid_lbl 051 `"Junior high school, grade 1"', add
label define educid_lbl 052 `"Junior high school, grade 2"', add
label define educid_lbl 053 `"Junior high school, grade 3"', add
label define educid_lbl 054 `"Junior high school, grade unknown"', add
label define educid_lbl 055 `"Junior high school, completed"', add
label define educid_lbl 060 `"Junior vocational school"', add
label define educid_lbl 061 `"Junior vocational school, grade 1"', add
label define educid_lbl 062 `"Junior vocational school, grade 2"', add
label define educid_lbl 063 `"Junior vocational school, grade 3"', add
label define educid_lbl 064 `"Junior vocational school, grade unknown"', add
label define educid_lbl 065 `"Junior vocational school, completed"', add
label define educid_lbl 070 `"Senior high school"', add
label define educid_lbl 071 `"Senior high school, grade 1"', add
label define educid_lbl 072 `"Senior high school, grade 2"', add
label define educid_lbl 073 `"Senior high school, grade 3"', add
label define educid_lbl 074 `"Senior high school, grade unknown"', add
label define educid_lbl 075 `"Senior high school, completed"', add
label define educid_lbl 080 `"Senior vocational school"', add
label define educid_lbl 081 `"Senior vocational school, grade 1"', add
label define educid_lbl 082 `"Senior vocational school, grade 2"', add
label define educid_lbl 083 `"Senior vocational school, grade 3"', add
label define educid_lbl 084 `"Senior vocational school, grade unknown"', add
label define educid_lbl 086 `"Senior vocational school, completed"', add
label define educid_lbl 090 `"Diploma I/II"', add
label define educid_lbl 091 `"Diploma I/II, year 1"', add
label define educid_lbl 092 `"Diploma I/II, year 2"', add
label define educid_lbl 093 `"Diploma I/II, completed"', add
label define educid_lbl 100 `"Academy/Diploma III"', add
label define educid_lbl 101 `"Academy/Diploma III, year 1"', add
label define educid_lbl 102 `"Academy/Diploma III, year 2"', add
label define educid_lbl 103 `"Academy/Diploma III, year 3"', add
label define educid_lbl 104 `"Academy/Diploma III, year 4"', add
label define educid_lbl 105 `"Academy/Diploma III, year unknown"', add
label define educid_lbl 106 `"Academy/Diploma III, completed"', add
label define educid_lbl 110 `"University/Diploma IV"', add
label define educid_lbl 111 `"University/Diploma IV, year 1"', add
label define educid_lbl 112 `"University/Diploma IV, year 2"', add
label define educid_lbl 113 `"University/Diploma IV, year 3"', add
label define educid_lbl 114 `"University/Diploma IV, year 4"', add
label define educid_lbl 115 `"University/Diploma IV, year 5"', add
label define educid_lbl 116 `"University/Diploma IV, year 6"', add
label define educid_lbl 117 `"University/Diploma IV, year 7"', add
label define educid_lbl 118 `"University/Diploma IV, year unknown"', add
label define educid_lbl 119 `"University/Diploma IV, completed"', add
label define educid_lbl 120 `"Graduate school"', add
label define educid_lbl 121 `"Graduate school, not completed"', add
label define educid_lbl 122 `"Graduate school, completed"', add
label define educid_lbl 123 `"Masters"', add
label define educid_lbl 124 `"Doctoral program"', add
label define educid_lbl 998 `"Unknown"', add
label values educid educid_lbl

label define empstat_lbl 0 `"NIU (not in universe)"'
label define empstat_lbl 1 `"Employed"', add
label define empstat_lbl 2 `"Unemployed"', add
label define empstat_lbl 3 `"Inactive"', add
label define empstat_lbl 9 `"Unknown/missing"', add
label values empstat empstat_lbl

label define empstatd_lbl 000 `"NIU (not in universe)"'
label define empstatd_lbl 100 `"Employed, not specified"', add
label define empstatd_lbl 110 `"At work"', add
label define empstatd_lbl 111 `"At work, and 'student'"', add
label define empstatd_lbl 112 `"At work, and 'housework'"', add
label define empstatd_lbl 113 `"At work, and 'seeking work'"', add
label define empstatd_lbl 114 `"At work, and 'retired'"', add
label define empstatd_lbl 115 `"At work, and 'no work'"', add
label define empstatd_lbl 116 `"At work, and other situation"', add
label define empstatd_lbl 117 `"At work, family holding, not specified"', add
label define empstatd_lbl 118 `"At work, family holding, not agricultural"', add
label define empstatd_lbl 119 `"At work, family holding, agricultural"', add
label define empstatd_lbl 120 `"Have job, not at work in reference period"', add
label define empstatd_lbl 130 `"Armed forces"', add
label define empstatd_lbl 131 `"Armed forces, at work"', add
label define empstatd_lbl 132 `"Armed forces, not at work in reference period"', add
label define empstatd_lbl 133 `"Military trainee"', add
label define empstatd_lbl 140 `"Marginally employed"', add
label define empstatd_lbl 200 `"Unemployed, not specified"', add
label define empstatd_lbl 201 `"Unemployed 6 or more months"', add
label define empstatd_lbl 202 `"Worked fewer than 6 months, permanent job"', add
label define empstatd_lbl 203 `"Worked fewer than 6 months, temporary job"', add
label define empstatd_lbl 210 `"Unemployed, experienced worker"', add
label define empstatd_lbl 220 `"Unemployed, new worker"', add
label define empstatd_lbl 230 `"No work available"', add
label define empstatd_lbl 240 `"Inactive unemployed"', add
label define empstatd_lbl 300 `"Inactive (not in labor force)"', add
label define empstatd_lbl 310 `"Housework"', add
label define empstatd_lbl 320 `"Unable to work/disabled"', add
label define empstatd_lbl 321 `"Permanent disability"', add
label define empstatd_lbl 322 `"Temporary illness"', add
label define empstatd_lbl 323 `"Disabled or imprisoned"', add
label define empstatd_lbl 330 `"In school"', add
label define empstatd_lbl 340 `"Retirees and living on rent"', add
label define empstatd_lbl 341 `"Living on rents"', add
label define empstatd_lbl 342 `"Living on rents or pension"', add
label define empstatd_lbl 343 `"Retirees/pensioners"', add
label define empstatd_lbl 344 `"Retired"', add
label define empstatd_lbl 345 `"Pensioner"', add
label define empstatd_lbl 346 `"Non-retirement pension"', add
label define empstatd_lbl 347 `"Disability pension"', add
label define empstatd_lbl 348 `"Retired without benefits"', add
label define empstatd_lbl 350 `"Elderly"', add
label define empstatd_lbl 351 `"Elderly or disabled"', add
label define empstatd_lbl 360 `"Institutionalized"', add
label define empstatd_lbl 361 `"Prisoner"', add
label define empstatd_lbl 370 `"Intermittent worker"', add
label define empstatd_lbl 371 `"Not working, seasonal worker"', add
label define empstatd_lbl 372 `"Not working, occasional worker"', add
label define empstatd_lbl 380 `"Other income recipient"', add
label define empstatd_lbl 390 `"Inactive, other reasons"', add
label define empstatd_lbl 391 `"Too young to work"', add
label define empstatd_lbl 392 `"Dependent"', add
label define empstatd_lbl 999 `"Unknown/missing"', add
label values empstatd empstatd_lbl

label define occisco_lbl 01 `"Legislators, senior officials and managers"'
label define occisco_lbl 02 `"Professionals"', add
label define occisco_lbl 03 `"Technicians and associate professionals"', add
label define occisco_lbl 04 `"Clerks"', add
label define occisco_lbl 05 `"Service workers and shop and market sales"', add
label define occisco_lbl 06 `"Skilled agricultural and fishery workers"', add
label define occisco_lbl 07 `"Crafts and related trades workers"', add
label define occisco_lbl 08 `"Plant and machine operators and assemblers"', add
label define occisco_lbl 09 `"Elementary occupations"', add
label define occisco_lbl 10 `"Armed forces"', add
label define occisco_lbl 11 `"Other occupations, unspecified or n.e.c."', add
label define occisco_lbl 97 `"Response suppressed"', add
label define occisco_lbl 98 `"Unknown"', add
label define occisco_lbl 99 `"NIU (not in universe)"', add
label values occisco occisco_lbl

label define isco68a_lbl 011 `"Chemists"'
label define isco68a_lbl 012 `"Physicists"', add
label define isco68a_lbl 013 `"Physical scientists not elsewhere classified"', add
label define isco68a_lbl 014 `"Physical science technicians"', add
label define isco68a_lbl 021 `"Architects and town planners"', add
label define isco68a_lbl 022 `"Civil engineers"', add
label define isco68a_lbl 023 `"Electrical and electronics engineers"', add
label define isco68a_lbl 024 `"Mechanical engineers"', add
label define isco68a_lbl 025 `"Chemical engineers"', add
label define isco68a_lbl 026 `"Metallurgists"', add
label define isco68a_lbl 027 `"Mining engineers"', add
label define isco68a_lbl 028 `"Industrial engineers"', add
label define isco68a_lbl 029 `"Engineers not elsewhere classified"', add
label define isco68a_lbl 031 `"Surveyors"', add
label define isco68a_lbl 032 `"Draughtsmen"', add
label define isco68a_lbl 033 `"Civil engineering technicians"', add
label define isco68a_lbl 034 `"Electrical and electronics engineering technicians"', add
label define isco68a_lbl 035 `"Mechanical engineering technicians"', add
label define isco68a_lbl 036 `"Chemical engineering technicians"', add
label define isco68a_lbl 037 `"Metallurgical technicians"', add
label define isco68a_lbl 038 `"Mining technicians"', add
label define isco68a_lbl 039 `"Engineering technicians not elsewhere classified"', add
label define isco68a_lbl 041 `"Aircraft pilots, navigators and flight engineers"', add
label define isco68a_lbl 042 `"Ships' deck officers and pilots"', add
label define isco68a_lbl 043 `"Ships' engineers"', add
label define isco68a_lbl 049 `"Aircraft and ships officers, n.e.c."', add
label define isco68a_lbl 051 `"Biologists, zoologists and related scientists"', add
label define isco68a_lbl 052 `"Bacteriologists, pharmacologists and related scientists"', add
label define isco68a_lbl 053 `"Agronomists and related scientists"', add
label define isco68a_lbl 054 `"Life sciences technicians"', add
label define isco68a_lbl 059 `"Life sciences technicians and related technicians, n.e.c."', add
label define isco68a_lbl 061 `"Medical doctors"', add
label define isco68a_lbl 062 `"Medical assistants"', add
label define isco68a_lbl 063 `"Dentists"', add
label define isco68a_lbl 064 `"Dental assistants"', add
label define isco68a_lbl 065 `"Veterinarians"', add
label define isco68a_lbl 066 `"Veterinary assistants"', add
label define isco68a_lbl 067 `"Pharmacists"', add
label define isco68a_lbl 068 `"Pharmaceutical assistants"', add
label define isco68a_lbl 069 `"Dietitians and public health nutritionists"', add
label define isco68a_lbl 071 `"Professional nurses"', add
label define isco68a_lbl 072 `"Nursing personnel not elsewhere classified"', add
label define isco68a_lbl 073 `"Professional midwives"', add
label define isco68a_lbl 074 `"Midwifery personnel not elsewhere classified"', add
label define isco68a_lbl 075 `"Optometrists and opticians"', add
label define isco68a_lbl 076 `"Physiotherapists and occupational therapists"', add
label define isco68a_lbl 077 `"Medical Xray technicians"', add
label define isco68a_lbl 079 `"Medical, dental, veterinary and related workers not elsewhere classified"', add
label define isco68a_lbl 081 `"Statisticians"', add
label define isco68a_lbl 082 `"Mathematicians and actuaries"', add
label define isco68a_lbl 083 `"Systems Analysts"', add
label define isco68a_lbl 084 `"Statistical and mathematical technicians"', add
label define isco68a_lbl 089 `"Statisticians, mathematicians, systems analysts and related technicians, n.e.c."', add
label define isco68a_lbl 090 `"Economists"', add
label define isco68a_lbl 099 `"Other social scientists, n.e.c."', add
label define isco68a_lbl 110 `"Accountants"', add
label define isco68a_lbl 121 `"Lawyers"', add
label define isco68a_lbl 122 `"Judges"', add
label define isco68a_lbl 129 `"Jurists not elsewhere classified"', add
label define isco68a_lbl 131 `"University and higher education teachers"', add
label define isco68a_lbl 132 `"Secondary education teachers"', add
label define isco68a_lbl 133 `"Primary education teachers"', add
label define isco68a_lbl 134 `"Preprimary education teachers"', add
label define isco68a_lbl 135 `"Special education teachers"', add
label define isco68a_lbl 139 `"Teachers not elsewhere classified"', add
label define isco68a_lbl 141 `"Ministers of religion and related members of religious orders"', add
label define isco68a_lbl 149 `"Workers in religion not elsewhere classified"', add
label define isco68a_lbl 151 `"Authors and critics"', add
label define isco68a_lbl 159 `"Authors, journalists and related writers not elsewhere classified"', add
label define isco68a_lbl 161 `"Sculptors, painters and related artists"', add
label define isco68a_lbl 162 `"Commercial artists and designers"', add
label define isco68a_lbl 163 `"Photographers and cameramen"', add
label define isco68a_lbl 169 `"Sculptors, painters and related artists, n.e.c."', add
label define isco68a_lbl 171 `"Composers, musicians and singers"', add
label define isco68a_lbl 172 `"Choreographers and dancers"', add
label define isco68a_lbl 173 `"Actors and stage directors"', add
label define isco68a_lbl 174 `"Producers, performing arts"', add
label define isco68a_lbl 175 `"Circus performers"', add
label define isco68a_lbl 179 `"Performing artists not elsewhere classified"', add
label define isco68a_lbl 180 `"Athletes, sportsmen and related workers"', add
label define isco68a_lbl 191 `"Librarians, archivists and curators"', add
label define isco68a_lbl 192 `"Sociologists, anthropologists and related scientists"', add
label define isco68a_lbl 193 `"Social workers"', add
label define isco68a_lbl 194 `"Personnel and occupational specialists"', add
label define isco68a_lbl 195 `"Philologists, translators and interpreters"', add
label define isco68a_lbl 199 `"Other professional, technical and related workers"', add
label define isco68a_lbl 201 `"Legislative officials"', add
label define isco68a_lbl 202 `"Government administrators"', add
label define isco68a_lbl 211 `"General managers"', add
label define isco68a_lbl 212 `"Production managers (except farm)"', add
label define isco68a_lbl 219 `"Managers not elsewhere classified"', add
label define isco68a_lbl 299 `"Administrative and managerial, n.e.c."', add
label define isco68a_lbl 300 `"Clerical supervisors"', add
label define isco68a_lbl 310 `"Government executive officials"', add
label define isco68a_lbl 321 `"Stenographers, typists and teletypists"', add
label define isco68a_lbl 322 `"Card and tapepunching machine operators"', add
label define isco68a_lbl 323 `"Telex operators"', add
label define isco68a_lbl 329 `"Stenegraphers, typists and teletypists, n.e.d."', add
label define isco68a_lbl 331 `"Bookkeepers and cashiers"', add
label define isco68a_lbl 339 `"Bookkeepers, cashiers and related workers not elsewhere classified"', add
label define isco68a_lbl 341 `"Bookkeeping and calculating machine operators"', add
label define isco68a_lbl 342 `"Automatic dataprocessing machine operators"', add
label define isco68a_lbl 349 `"Computing machine operators, n.e.c."', add
label define isco68a_lbl 351 `"Railway station masters"', add
label define isco68a_lbl 352 `"Postmasters"', add
label define isco68a_lbl 359 `"Transport and communications supervisors not elsewhere classified"', add
label define isco68a_lbl 360 `"Transport conductors"', add
label define isco68a_lbl 370 `"Mail distribution clerks"', add
label define isco68a_lbl 380 `"Telephone and telegraph operators"', add
label define isco68a_lbl 391 `"Stock clerks"', add
label define isco68a_lbl 392 `"Material and production planning clerks"', add
label define isco68a_lbl 393 `"Correspondence and reporting clerks"', add
label define isco68a_lbl 394 `"Receptionists and travel agency clerks"', add
label define isco68a_lbl 395 `"Library and filing clerks"', add
label define isco68a_lbl 399 `"Clerks not elsewhere classified"', add
label define isco68a_lbl 400 `"Managers (wholesale and retail trade)"', add
label define isco68a_lbl 410 `"Working proprietors (wholesale and retail trade)"', add
label define isco68a_lbl 421 `"Sales supervisors"', add
label define isco68a_lbl 422 `"Buyers"', add
label define isco68a_lbl 431 `"Technical salesmen and service advisers"', add
label define isco68a_lbl 432 `"Commercial travellers and Manufacturers' agents"', add
label define isco68a_lbl 439 `"Technical salesmen, commercial travellers and manufacturers' agents, n.e.c."', add
label define isco68a_lbl 441 `"Insurance, real estate and securities salesmen"', add
label define isco68a_lbl 442 `"Business services salesmen"', add
label define isco68a_lbl 443 `"Auctioneers"', add
label define isco68a_lbl 451 `"Salesmen, shop assistants and demonstrators"', add
label define isco68a_lbl 452 `"Street vendors, canvassers and newsvendors"', add
label define isco68a_lbl 454 `"Itinerant traders"', add
label define isco68a_lbl 459 `"Salesmen, shop assistants and demonstrators, n.e.c."', add
label define isco68a_lbl 490 `"Sales workers not elsewhere classified"', add
label define isco68a_lbl 500 `"Managers (catering and lodging services)"', add
label define isco68a_lbl 510 `"Working proprietors (catering and lodging services)"', add
label define isco68a_lbl 520 `"Housekeeping and related service supervisors"', add
label define isco68a_lbl 531 `"Cooks"', add
label define isco68a_lbl 532 `"Waiters, bartenders and related workers"', add
label define isco68a_lbl 540 `"Maids and related housekeeping service workers not elsewhere classified"', add
label define isco68a_lbl 551 `"Building caretakers"', add
label define isco68a_lbl 552 `"Charworkers, cleaners and related workers"', add
label define isco68a_lbl 560 `"Launderers, drycleaners and pressers"', add
label define isco68a_lbl 570 `"Hairdressers, barbers, beauticians and related workers"', add
label define isco68a_lbl 581 `"Firefighters"', add
label define isco68a_lbl 582 `"Policemen and detectives"', add
label define isco68a_lbl 589 `"Protective service workers not elsewhere classified"', add
label define isco68a_lbl 591 `"Guides"', add
label define isco68a_lbl 592 `"Undertakers and embalmers"', add
label define isco68a_lbl 599 `"Other service workers"', add
label define isco68a_lbl 600 `"Farm managers and supervisors"', add
label define isco68a_lbl 611 `"General farmers"', add
label define isco68a_lbl 612 `"Specialised farmers"', add
label define isco68a_lbl 621 `"General farm workers"', add
label define isco68a_lbl 622 `"Field crop and vegetable farm workers"', add
label define isco68a_lbl 623 `"Orchard, vineyard and related tree and shrub crop workers"', add
label define isco68a_lbl 624 `"Livestock workers"', add
label define isco68a_lbl 625 `"Dairy farm workers"', add
label define isco68a_lbl 626 `"Poultry farm workers"', add
label define isco68a_lbl 627 `"Nursery workers and gardeners"', add
label define isco68a_lbl 628 `"Farm machinery operators"', add
label define isco68a_lbl 629 `"Agricultural and animal husbandry workers not elsewhere classified"', add
label define isco68a_lbl 631 `"Loggers"', add
label define isco68a_lbl 632 `"Forestry workers (except logging)"', add
label define isco68a_lbl 639 `"Forestry and loggers, n.e.c."', add
label define isco68a_lbl 641 `"Fishermen"', add
label define isco68a_lbl 649 `"Fishermen, hunters and related workers not elsewhere classified"', add
label define isco68a_lbl 700 `"Production supervisors and general foremen"', add
label define isco68a_lbl 711 `"Miners and quarrymen"', add
label define isco68a_lbl 712 `"Mineral and stone treaters"', add
label define isco68a_lbl 713 `"Well drillers, borers and related workers"', add
label define isco68a_lbl 721 `"Metal smelting, converting and refining furnacemen"', add
label define isco68a_lbl 722 `"Metal rollingmill workers"', add
label define isco68a_lbl 723 `"Metal melters and reheaters"', add
label define isco68a_lbl 724 `"Metal casters"', add
label define isco68a_lbl 725 `"Metal moulders and coremakers"', add
label define isco68a_lbl 726 `"Metal annealers, temperers and casehardeners"', add
label define isco68a_lbl 727 `"Metal drawers and extruders"', add
label define isco68a_lbl 728 `"Metal platers and coaters"', add
label define isco68a_lbl 729 `"Metal processers not elsewhere classified"', add
label define isco68a_lbl 731 `"Wood treaters"', add
label define isco68a_lbl 732 `"Sawyers, plywood makers and related woodprocessing workers"', add
label define isco68a_lbl 733 `"Paper pulp preparers"', add
label define isco68a_lbl 734 `"Paper makers"', add
label define isco68a_lbl 739 `"Wood preparation workers and paper makers, n.e.c."', add
label define isco68a_lbl 741 `"Crushers, grinders and mixers"', add
label define isco68a_lbl 742 `"Cookers, roasters and related heattreaters"', add
label define isco68a_lbl 743 `"Filter and separator operators"', add
label define isco68a_lbl 744 `"Still and reactor operators"', add
label define isco68a_lbl 745 `"Petroleumrefining workers"', add
label define isco68a_lbl 749 `"Chemical processers and related workers not elsewhere classified"', add
label define isco68a_lbl 751 `"Fibre preparers"', add
label define isco68a_lbl 752 `"Spinners and winders"', add
label define isco68a_lbl 753 `"Weaving and knittingmachine setters and patterncard preparers"', add
label define isco68a_lbl 754 `"Weavers and related workers"', add
label define isco68a_lbl 755 `"Knitters"', add
label define isco68a_lbl 756 `"Bleachers, dyers and textile product finishers"', add
label define isco68a_lbl 759 `"Spinners, weavers, knitters, dyers and related workers not elsewhere classified"', add
label define isco68a_lbl 761 `"Tanners and fellmongers"', add
label define isco68a_lbl 762 `"Pelt dressers"', add
label define isco68a_lbl 769 `"Tanners, fellmongers and pelt dressers, n.e.c."', add
label define isco68a_lbl 771 `"Grain millers and related workers"', add
label define isco68a_lbl 772 `"Sugar processers and refiners"', add
label define isco68a_lbl 773 `"Butchers and meat preparers"', add
label define isco68a_lbl 774 `"Food preservers"', add
label define isco68a_lbl 775 `"Dairy product processers"', add
label define isco68a_lbl 776 `"Bakers, pastrycooks and confectionery makers"', add
label define isco68a_lbl 777 `"Tea, coffee and cocoa preparers"', add
label define isco68a_lbl 778 `"Brewers, wine and beverage makers"', add
label define isco68a_lbl 779 `"Food and beverage processers not elsewhere classified"', add
label define isco68a_lbl 781 `"Tobacco preparers"', add
label define isco68a_lbl 782 `"Cigar makers"', add
label define isco68a_lbl 783 `"Cigarette makers"', add
label define isco68a_lbl 789 `"Tobacco preparers and tobacco product makers not elsewhere classified"', add
label define isco68a_lbl 791 `"Tailors and dressmakers"', add
label define isco68a_lbl 792 `"Fur tailors and related workers"', add
label define isco68a_lbl 793 `"Milliners and hatmakers"', add
label define isco68a_lbl 794 `"Patternmakers and cutters"', add
label define isco68a_lbl 795 `"Sewers and embroiderers"', add
label define isco68a_lbl 796 `"Upholsterers and related workers"', add
label define isco68a_lbl 799 `"Tailors, dressmakers, sewers, upholsterers and related workers not elsewhere classified"', add
label define isco68a_lbl 801 `"Shoemakers and shoe repairers"', add
label define isco68a_lbl 802 `"Shoe cutters, lasters, sewers and related workers"', add
label define isco68a_lbl 803 `"Leather goods makers"', add
label define isco68a_lbl 811 `"Cabinetmakers"', add
label define isco68a_lbl 812 `"Woodworkingmachine operators"', add
label define isco68a_lbl 819 `"Cabinetmakers and related woodworkers not elsewhere classified"', add
label define isco68a_lbl 820 `"Stone cutters and carvers"', add
label define isco68a_lbl 831 `"Blacksmiths, hammersmiths and forgingpress operators"', add
label define isco68a_lbl 832 `"Toolmakers, metal patternmakers and metal markers"', add
label define isco68a_lbl 833 `"Machinetool setteroperators"', add
label define isco68a_lbl 834 `"Machinetool operators"', add
label define isco68a_lbl 835 `"Metal grinders, polishers and tool sharpeners"', add
label define isco68a_lbl 839 `"Blacksmiths, toolmakers and machinetool operators not elsewhere classified"', add
label define isco68a_lbl 841 `"Machinery fitters and machine assemblers"', add
label define isco68a_lbl 842 `"Watch, clock and precision instrument makers"', add
label define isco68a_lbl 843 `"Motor vehicle mechanics"', add
label define isco68a_lbl 844 `"Aircraft engine mechanics"', add
label define isco68a_lbl 849 `"Machinery fitters, machine assemblers and precision instrument makers (except electrical) not elsewhere classified"', add
label define isco68a_lbl 851 `"Electrical fitters"', add
label define isco68a_lbl 852 `"Electronics fitters"', add
label define isco68a_lbl 853 `"Electrical and electronics equipment assemblers"', add
label define isco68a_lbl 854 `"Radio and television repairmen"', add
label define isco68a_lbl 855 `"Electrical wiremen"', add
label define isco68a_lbl 856 `"Telephone and telegraph installers"', add
label define isco68a_lbl 857 `"Electric linemen and cable jointers"', add
label define isco68a_lbl 859 `"Electrical fitters and related electrical and electronics workers not elsewhere classified"', add
label define isco68a_lbl 861 `"Broadcasting station operators"', add
label define isco68a_lbl 862 `"Sound equipment operators and cinema projectionists"', add
label define isco68a_lbl 871 `"Plumbers and pipe fitters"', add
label define isco68a_lbl 872 `"Welders and flamecutters"', add
label define isco68a_lbl 873 `"Sheetmetal workers"', add
label define isco68a_lbl 874 `"Structural metal preparers and erectors"', add
label define isco68a_lbl 880 `"Jewellery and precious metal workers"', add
label define isco68a_lbl 891 `"Glass formers, cutters, grinders and finishers"', add
label define isco68a_lbl 892 `"Potters and related clay and abrasive formers"', add
label define isco68a_lbl 893 `"Glass and ceramics kilnmen"', add
label define isco68a_lbl 894 `"Glass engravers and etchers"', add
label define isco68a_lbl 895 `"Glass and ceramics painters and decorators"', add
label define isco68a_lbl 899 `"Glass formers, potters and related workers not elsewhere classified"', add
label define isco68a_lbl 901 `"Rubber and plastics product makers (except tire makers and tire vulcanisers)"', add
label define isco68a_lbl 902 `"Tire makers and vulcanisers"', add
label define isco68a_lbl 910 `"Paper and paperboard products makers"', add
label define isco68a_lbl 921 `"Compositors and typesetters"', add
label define isco68a_lbl 922 `"Printing pressmen"', add
label define isco68a_lbl 923 `"Stereotypers and electrotypers"', add
label define isco68a_lbl 924 `"Printing engravers (except photoengravers)"', add
label define isco68a_lbl 925 `"Photoengravers"', add
label define isco68a_lbl 926 `"Bookbinders and related workers"', add
label define isco68a_lbl 927 `"Photographic darkroom workers"', add
label define isco68a_lbl 929 `"Printers and related workers not elsewhere classified"', add
label define isco68a_lbl 931 `"Painters, construction"', add
label define isco68a_lbl 939 `"Painters not elsewhere classified"', add
label define isco68a_lbl 941 `"Musical instrument makers and tuners"', add
label define isco68a_lbl 942 `"Basketry weavers and brush makers"', add
label define isco68a_lbl 943 `"Nonmetallic mineral product makers"', add
label define isco68a_lbl 949 `"Other production and related workers"', add
label define isco68a_lbl 951 `"Bricklayers, stonemasons and tile setters"', add
label define isco68a_lbl 952 `"Reinforcedconcreters, cement finishers and terrazzo workers"', add
label define isco68a_lbl 953 `"Roofers"', add
label define isco68a_lbl 954 `"Carpenters, joiners and parquetry workers"', add
label define isco68a_lbl 955 `"Plasterers"', add
label define isco68a_lbl 956 `"Insulators"', add
label define isco68a_lbl 957 `"Glaziers"', add
label define isco68a_lbl 959 `"Construction workers not elsewhere classified"', add
label define isco68a_lbl 961 `"Powergenerating machinery operators"', add
label define isco68a_lbl 969 `"Stationary engine and related equipment operators not elsewhere classified"', add
label define isco68a_lbl 971 `"Dockers and freight handlers"', add
label define isco68a_lbl 972 `"Riggers and cable splicers"', add
label define isco68a_lbl 973 `"Crane and hoist operators"', add
label define isco68a_lbl 974 `"Earthmoving and related machinery operators"', add
label define isco68a_lbl 979 `"Materialhandling equipment operators not elsewhere classified"', add
label define isco68a_lbl 981 `"Ships' deck ratings, barge crews and boatmen"', add
label define isco68a_lbl 982 `"Ships' engineroom ratings"', add
label define isco68a_lbl 983 `"Railway engine drivers and firemen"', add
label define isco68a_lbl 984 `"Railway brakemen, signalmen and shunters"', add
label define isco68a_lbl 985 `"Motor vehicle drivers"', add
label define isco68a_lbl 986 `"Animal and animaldrawn vehicle drivers"', add
label define isco68a_lbl 989 `"Transport equipment operators not elsewhere classified"', add
label define isco68a_lbl 990 `"Labourers not elsewhere classified"', add
label define isco68a_lbl 995 `"Armed forces"', add
label define isco68a_lbl 997 `"Response suppressed"', add
label define isco68a_lbl 998 `"Unknown"', add
label define isco68a_lbl 999 `"NIU (not in universe)"', add
label values isco68a isco68a_lbl

label define indgen_lbl 000 `"NIU (not in universe)"'
label define indgen_lbl 010 `"Agriculture, fishing, and forestry"', add
label define indgen_lbl 020 `"Mining"', add
label define indgen_lbl 030 `"Manufacturing"', add
label define indgen_lbl 040 `"Electricity, gas and water"', add
label define indgen_lbl 050 `"Construction"', add
label define indgen_lbl 060 `"Wholesale and retail trade"', add
label define indgen_lbl 070 `"Hotels and restaurants"', add
label define indgen_lbl 080 `"Transportation and communications"', add
label define indgen_lbl 090 `"Financial services and insurance"', add
label define indgen_lbl 100 `"Public administration and defense"', add
label define indgen_lbl 110 `"Services, not specified"', add
label define indgen_lbl 111 `"Real estate and business services"', add
label define indgen_lbl 112 `"Education"', add
label define indgen_lbl 113 `"Health and social work"', add
label define indgen_lbl 114 `"Other services"', add
label define indgen_lbl 120 `"Private household services"', add
label define indgen_lbl 130 `"Other industry, n.e.c."', add
label define indgen_lbl 998 `"Response suppressed"', add
label define indgen_lbl 999 `"Unknown"', add
label values indgen indgen_lbl

label define classwk_lbl 0 `"NIU (not in universe)"'
label define classwk_lbl 1 `"Self-employed"', add
label define classwk_lbl 2 `"Wage/salary worker"', add
label define classwk_lbl 3 `"Unpaid worker"', add
label define classwk_lbl 4 `"Other"', add
label define classwk_lbl 9 `"Unknown/missing"', add
label values classwk classwk_lbl

label define classwkd_lbl 000 `"NIU (not in universe)"'
label define classwkd_lbl 100 `"Self-employed"', add
label define classwkd_lbl 101 `"Self-employed, unincorporated"', add
label define classwkd_lbl 102 `"Self-employed, incorporated"', add
label define classwkd_lbl 110 `"Employer"', add
label define classwkd_lbl 111 `"Sharecropper, employer"', add
label define classwkd_lbl 120 `"Working on own account"', add
label define classwkd_lbl 121 `"Own account, agriculture"', add
label define classwkd_lbl 122 `"Domestic worker, self-employed"', add
label define classwkd_lbl 123 `"Subsistence worker, own consumption"', add
label define classwkd_lbl 124 `"Own account, other"', add
label define classwkd_lbl 125 `"Own account, without temporary/unpaid help"', add
label define classwkd_lbl 126 `"Own account, with temporary/unpaid help"', add
label define classwkd_lbl 130 `"Member of cooperative"', add
label define classwkd_lbl 140 `"Sharecropper"', add
label define classwkd_lbl 141 `"Sharecropper, self-employed"', add
label define classwkd_lbl 142 `"Sharecropper, employee"', add
label define classwkd_lbl 150 `"Kibbutz member"', add
label define classwkd_lbl 200 `"Wage/salary worker"', add
label define classwkd_lbl 201 `"Management"', add
label define classwkd_lbl 202 `"Non-management"', add
label define classwkd_lbl 203 `"White collar (non-manual)"', add
label define classwkd_lbl 204 `"Blue collar (manual)"', add
label define classwkd_lbl 205 `"White and blue collar"', add
label define classwkd_lbl 206 `"Day laborer"', add
label define classwkd_lbl 207 `"Employee, with a permanent job"', add
label define classwkd_lbl 208 `"Employee, occasional, temporary, contract"', add
label define classwkd_lbl 209 `"Employee without legal contract"', add
label define classwkd_lbl 210 `"Wage/salary worker, private employer"', add
label define classwkd_lbl 211 `"Apprentice"', add
label define classwkd_lbl 212 `"Religious worker"', add
label define classwkd_lbl 213 `"Wage/salary worker, non-profit, NGO"', add
label define classwkd_lbl 214 `"White collar, private"', add
label define classwkd_lbl 215 `"Blue collar, private"', add
label define classwkd_lbl 216 `"Paid family worker"', add
label define classwkd_lbl 217 `"Cooperative employee"', add
label define classwkd_lbl 220 `"Wage/salary worker, government"', add
label define classwkd_lbl 221 `"Federal, government employee"', add
label define classwkd_lbl 222 `"State government employee"', add
label define classwkd_lbl 223 `"Local government employee"', add
label define classwkd_lbl 224 `"White collar, public"', add
label define classwkd_lbl 225 `"Blue collar, public"', add
label define classwkd_lbl 226 `"Public companies"', add
label define classwkd_lbl 227 `"Civil servants, local collectives"', add
label define classwkd_lbl 230 `"Domestic worker (work for private household)"', add
label define classwkd_lbl 240 `"Seasonal migrant"', add
label define classwkd_lbl 241 `"Seasonal migrant, no broker"', add
label define classwkd_lbl 242 `"Seasonal migrant, uses broker"', add
label define classwkd_lbl 250 `"Other wage and salary"', add
label define classwkd_lbl 251 `"Canal zone/commission employee"', add
label define classwkd_lbl 252 `"Government employment/training program"', add
label define classwkd_lbl 253 `"Mixed state/private enterprise/parastatal"', add
label define classwkd_lbl 254 `"Government public work program"', add
label define classwkd_lbl 300 `"Unpaid worker"', add
label define classwkd_lbl 310 `"Unpaid family worker"', add
label define classwkd_lbl 320 `"Apprentice, unpaid or unspecified"', add
label define classwkd_lbl 330 `"Trainee"', add
label define classwkd_lbl 340 `"Apprentice or trainee"', add
label define classwkd_lbl 350 `"Works for others without wage"', add
label define classwkd_lbl 400 `"Other"', add
label define classwkd_lbl 999 `"Unknown/missing"', add
label values classwkd classwkd_lbl

label define dayswrk_lbl 0 `"Did not work"'
label define dayswrk_lbl 1 `"1 day"', add
label define dayswrk_lbl 2 `"2 days"', add
label define dayswrk_lbl 3 `"3 days"', add
label define dayswrk_lbl 4 `"4 days"', add
label define dayswrk_lbl 5 `"5 days"', add
label define dayswrk_lbl 6 `"6 days"', add
label define dayswrk_lbl 7 `"7 days"', add
label define dayswrk_lbl 8 `"Unknown"', add
label define dayswrk_lbl 9 `"NIU (not in universe)"', add
label values dayswrk dayswrk_lbl

label define hrswork1_lbl 000 `"0 hours"'
label define hrswork1_lbl 001 `"1 hour"', add
label define hrswork1_lbl 002 `"2 hours"', add
label define hrswork1_lbl 003 `"3 hours"', add
label define hrswork1_lbl 004 `"4 hours"', add
label define hrswork1_lbl 005 `"5 hours"', add
label define hrswork1_lbl 006 `"6 hours"', add
label define hrswork1_lbl 007 `"7 hours"', add
label define hrswork1_lbl 008 `"8 hours"', add
label define hrswork1_lbl 009 `"9 hours"', add
label define hrswork1_lbl 010 `"10 hours"', add
label define hrswork1_lbl 011 `"11 hours"', add
label define hrswork1_lbl 012 `"12 hours"', add
label define hrswork1_lbl 013 `"13 hours"', add
label define hrswork1_lbl 014 `"14 hours"', add
label define hrswork1_lbl 015 `"15 hours"', add
label define hrswork1_lbl 016 `"16 hours"', add
label define hrswork1_lbl 017 `"17 hours"', add
label define hrswork1_lbl 018 `"18 hours"', add
label define hrswork1_lbl 019 `"19 hours"', add
label define hrswork1_lbl 020 `"20 hours"', add
label define hrswork1_lbl 021 `"21 hours"', add
label define hrswork1_lbl 022 `"22 hours"', add
label define hrswork1_lbl 023 `"23 hours"', add
label define hrswork1_lbl 024 `"24 hours"', add
label define hrswork1_lbl 025 `"25 hours"', add
label define hrswork1_lbl 026 `"26 hours"', add
label define hrswork1_lbl 027 `"27 hours"', add
label define hrswork1_lbl 028 `"28 hours"', add
label define hrswork1_lbl 029 `"29 hours"', add
label define hrswork1_lbl 030 `"30 hours"', add
label define hrswork1_lbl 031 `"31 hours"', add
label define hrswork1_lbl 032 `"32 hours"', add
label define hrswork1_lbl 033 `"33 hours"', add
label define hrswork1_lbl 034 `"34 hours"', add
label define hrswork1_lbl 035 `"35 hours"', add
label define hrswork1_lbl 036 `"36 hours"', add
label define hrswork1_lbl 037 `"37 hours"', add
label define hrswork1_lbl 038 `"38 hours"', add
label define hrswork1_lbl 039 `"39 hours"', add
label define hrswork1_lbl 040 `"40 hours"', add
label define hrswork1_lbl 041 `"41 hours"', add
label define hrswork1_lbl 042 `"42 hours"', add
label define hrswork1_lbl 043 `"43 hours"', add
label define hrswork1_lbl 044 `"44 hours"', add
label define hrswork1_lbl 045 `"45 hours"', add
label define hrswork1_lbl 046 `"46 hours"', add
label define hrswork1_lbl 047 `"47 hours"', add
label define hrswork1_lbl 048 `"48 hours"', add
label define hrswork1_lbl 049 `"49 hours"', add
label define hrswork1_lbl 050 `"50 hours"', add
label define hrswork1_lbl 051 `"51 hours"', add
label define hrswork1_lbl 052 `"52 hours"', add
label define hrswork1_lbl 053 `"53 hours"', add
label define hrswork1_lbl 054 `"54 hours"', add
label define hrswork1_lbl 055 `"55 hours"', add
label define hrswork1_lbl 056 `"56 hours"', add
label define hrswork1_lbl 057 `"57 hours"', add
label define hrswork1_lbl 058 `"58 hours"', add
label define hrswork1_lbl 059 `"59 hours"', add
label define hrswork1_lbl 060 `"60 hours"', add
label define hrswork1_lbl 061 `"61 hours"', add
label define hrswork1_lbl 062 `"62 hours"', add
label define hrswork1_lbl 063 `"63 hours"', add
label define hrswork1_lbl 064 `"64 hours"', add
label define hrswork1_lbl 065 `"65 hours"', add
label define hrswork1_lbl 066 `"66 hours"', add
label define hrswork1_lbl 067 `"67 hours"', add
label define hrswork1_lbl 068 `"68 hours"', add
label define hrswork1_lbl 069 `"69 hours"', add
label define hrswork1_lbl 070 `"70 hours"', add
label define hrswork1_lbl 071 `"71 hours"', add
label define hrswork1_lbl 072 `"72 hours"', add
label define hrswork1_lbl 073 `"73 hours"', add
label define hrswork1_lbl 074 `"74 hours"', add
label define hrswork1_lbl 075 `"75 hours"', add
label define hrswork1_lbl 076 `"76 hours"', add
label define hrswork1_lbl 077 `"77 hours"', add
label define hrswork1_lbl 078 `"78 hours"', add
label define hrswork1_lbl 079 `"79 hours"', add
label define hrswork1_lbl 080 `"80 hours"', add
label define hrswork1_lbl 081 `"81 hours"', add
label define hrswork1_lbl 082 `"82 hours"', add
label define hrswork1_lbl 083 `"83 hours"', add
label define hrswork1_lbl 084 `"84 hours"', add
label define hrswork1_lbl 085 `"85 hours"', add
label define hrswork1_lbl 086 `"86 hours"', add
label define hrswork1_lbl 087 `"87 hours"', add
label define hrswork1_lbl 088 `"88 hours"', add
label define hrswork1_lbl 089 `"89 hours"', add
label define hrswork1_lbl 090 `"90 hours"', add
label define hrswork1_lbl 091 `"91 hours"', add
label define hrswork1_lbl 092 `"92 hours"', add
label define hrswork1_lbl 093 `"93 hours"', add
label define hrswork1_lbl 094 `"94 hours"', add
label define hrswork1_lbl 095 `"95 hours"', add
label define hrswork1_lbl 096 `"96 hours"', add
label define hrswork1_lbl 097 `"97 hours"', add
label define hrswork1_lbl 098 `"98 hours"', add
label define hrswork1_lbl 099 `"99 hours"', add
label define hrswork1_lbl 100 `"100 hours"', add
label define hrswork1_lbl 101 `"101 hours"', add
label define hrswork1_lbl 102 `"102 hours"', add
label define hrswork1_lbl 103 `"103 hours"', add
label define hrswork1_lbl 104 `"104 hours"', add
label define hrswork1_lbl 105 `"105 hours"', add
label define hrswork1_lbl 106 `"106 hours"', add
label define hrswork1_lbl 107 `"107 hours"', add
label define hrswork1_lbl 108 `"108 hours"', add
label define hrswork1_lbl 109 `"109 hours"', add
label define hrswork1_lbl 110 `"110 hours"', add
label define hrswork1_lbl 111 `"111 hours"', add
label define hrswork1_lbl 112 `"112 hours"', add
label define hrswork1_lbl 113 `"113 hours"', add
label define hrswork1_lbl 114 `"114 hours"', add
label define hrswork1_lbl 115 `"115 hours"', add
label define hrswork1_lbl 116 `"116 hours"', add
label define hrswork1_lbl 117 `"117 hours"', add
label define hrswork1_lbl 118 `"118 hours"', add
label define hrswork1_lbl 119 `"119 hours"', add
label define hrswork1_lbl 120 `"120 hours"', add
label define hrswork1_lbl 121 `"121 hours"', add
label define hrswork1_lbl 122 `"122 hours"', add
label define hrswork1_lbl 123 `"123 hours"', add
label define hrswork1_lbl 124 `"124 hours"', add
label define hrswork1_lbl 125 `"125 hours"', add
label define hrswork1_lbl 126 `"126 hours"', add
label define hrswork1_lbl 127 `"127 hours"', add
label define hrswork1_lbl 128 `"128 hours"', add
label define hrswork1_lbl 129 `"129 hours"', add
label define hrswork1_lbl 130 `"130 hours"', add
label define hrswork1_lbl 131 `"131 hours"', add
label define hrswork1_lbl 132 `"132 hours"', add
label define hrswork1_lbl 133 `"133 hours"', add
label define hrswork1_lbl 134 `"134 hours"', add
label define hrswork1_lbl 135 `"135 hours"', add
label define hrswork1_lbl 136 `"136 hours"', add
label define hrswork1_lbl 137 `"137 hours"', add
label define hrswork1_lbl 138 `"138 hours"', add
label define hrswork1_lbl 139 `"139 hours"', add
label define hrswork1_lbl 140 `"140+ hours"', add
label define hrswork1_lbl 998 `"Unknown"', add
label define hrswork1_lbl 999 `"NIU (not in universe)"', add
label values hrswork1 hrswork1_lbl

label define hrsmain_lbl 000 `"0 hours"'
label define hrsmain_lbl 001 `"1 hour"', add
label define hrsmain_lbl 002 `"2 hours"', add
label define hrsmain_lbl 003 `"3 hours"', add
label define hrsmain_lbl 004 `"4 hours"', add
label define hrsmain_lbl 005 `"5 hours"', add
label define hrsmain_lbl 006 `"6 hours"', add
label define hrsmain_lbl 007 `"7 hours"', add
label define hrsmain_lbl 008 `"8 hours"', add
label define hrsmain_lbl 009 `"9 hours"', add
label define hrsmain_lbl 010 `"10 hours"', add
label define hrsmain_lbl 011 `"11 hours"', add
label define hrsmain_lbl 012 `"12 hours"', add
label define hrsmain_lbl 013 `"13 hours"', add
label define hrsmain_lbl 014 `"14 hours"', add
label define hrsmain_lbl 015 `"15 hours"', add
label define hrsmain_lbl 016 `"16 hours"', add
label define hrsmain_lbl 017 `"17 hours"', add
label define hrsmain_lbl 018 `"18 hours"', add
label define hrsmain_lbl 019 `"19 hours"', add
label define hrsmain_lbl 020 `"20 hours"', add
label define hrsmain_lbl 021 `"21 hours"', add
label define hrsmain_lbl 022 `"22 hours"', add
label define hrsmain_lbl 023 `"23 hours"', add
label define hrsmain_lbl 024 `"24 hours"', add
label define hrsmain_lbl 025 `"25 hours"', add
label define hrsmain_lbl 026 `"26 hours"', add
label define hrsmain_lbl 027 `"27 hours"', add
label define hrsmain_lbl 028 `"28 hours"', add
label define hrsmain_lbl 029 `"29 hours"', add
label define hrsmain_lbl 030 `"30 hours"', add
label define hrsmain_lbl 031 `"31 hours"', add
label define hrsmain_lbl 032 `"32 hours"', add
label define hrsmain_lbl 033 `"33 hours"', add
label define hrsmain_lbl 034 `"34 hours"', add
label define hrsmain_lbl 035 `"35 hours"', add
label define hrsmain_lbl 036 `"36 hours"', add
label define hrsmain_lbl 037 `"37 hours"', add
label define hrsmain_lbl 038 `"38 hours"', add
label define hrsmain_lbl 039 `"39 hours"', add
label define hrsmain_lbl 040 `"40 hours"', add
label define hrsmain_lbl 041 `"41 hours"', add
label define hrsmain_lbl 042 `"42 hours"', add
label define hrsmain_lbl 043 `"43 hours"', add
label define hrsmain_lbl 044 `"44 hours"', add
label define hrsmain_lbl 045 `"45 hours"', add
label define hrsmain_lbl 046 `"46 hours"', add
label define hrsmain_lbl 047 `"47 hours"', add
label define hrsmain_lbl 048 `"48 hours"', add
label define hrsmain_lbl 049 `"49 hours"', add
label define hrsmain_lbl 050 `"50 hours"', add
label define hrsmain_lbl 051 `"51 hours"', add
label define hrsmain_lbl 052 `"52 hours"', add
label define hrsmain_lbl 053 `"53 hours"', add
label define hrsmain_lbl 054 `"54 hours"', add
label define hrsmain_lbl 055 `"55 hours"', add
label define hrsmain_lbl 056 `"56 hours"', add
label define hrsmain_lbl 057 `"57 hours"', add
label define hrsmain_lbl 058 `"58 hours"', add
label define hrsmain_lbl 059 `"59 hours"', add
label define hrsmain_lbl 060 `"60 hours"', add
label define hrsmain_lbl 061 `"61 hours"', add
label define hrsmain_lbl 062 `"62 hours"', add
label define hrsmain_lbl 063 `"63 hours"', add
label define hrsmain_lbl 064 `"64 hours"', add
label define hrsmain_lbl 065 `"65 hours"', add
label define hrsmain_lbl 066 `"66 hours"', add
label define hrsmain_lbl 067 `"67 hours"', add
label define hrsmain_lbl 068 `"68 hours"', add
label define hrsmain_lbl 069 `"69 hours"', add
label define hrsmain_lbl 070 `"70 hours"', add
label define hrsmain_lbl 071 `"71 hours"', add
label define hrsmain_lbl 072 `"72 hours"', add
label define hrsmain_lbl 073 `"73 hours"', add
label define hrsmain_lbl 074 `"74 hours"', add
label define hrsmain_lbl 075 `"75 hours"', add
label define hrsmain_lbl 076 `"76 hours"', add
label define hrsmain_lbl 077 `"77 hours"', add
label define hrsmain_lbl 078 `"78 hours"', add
label define hrsmain_lbl 079 `"79 hours"', add
label define hrsmain_lbl 080 `"80 hours"', add
label define hrsmain_lbl 081 `"81 hours"', add
label define hrsmain_lbl 082 `"82 hours"', add
label define hrsmain_lbl 083 `"83 hours"', add
label define hrsmain_lbl 084 `"84 hours"', add
label define hrsmain_lbl 085 `"85 hours"', add
label define hrsmain_lbl 086 `"86 hours"', add
label define hrsmain_lbl 087 `"87 hours"', add
label define hrsmain_lbl 088 `"88 hours"', add
label define hrsmain_lbl 089 `"89 hours"', add
label define hrsmain_lbl 090 `"90 hours"', add
label define hrsmain_lbl 091 `"91 hours"', add
label define hrsmain_lbl 092 `"92 hours"', add
label define hrsmain_lbl 093 `"93 hours"', add
label define hrsmain_lbl 094 `"94 hours"', add
label define hrsmain_lbl 095 `"95 hours"', add
label define hrsmain_lbl 096 `"96 hours"', add
label define hrsmain_lbl 097 `"97 hours"', add
label define hrsmain_lbl 098 `"98 hours"', add
label define hrsmain_lbl 099 `"99 hours"', add
label define hrsmain_lbl 100 `"100 hours"', add
label define hrsmain_lbl 101 `"101 hours"', add
label define hrsmain_lbl 102 `"102 hours"', add
label define hrsmain_lbl 103 `"103 hours"', add
label define hrsmain_lbl 104 `"104 hours"', add
label define hrsmain_lbl 105 `"105 hours"', add
label define hrsmain_lbl 106 `"106 hours"', add
label define hrsmain_lbl 107 `"107 hours"', add
label define hrsmain_lbl 108 `"108 hours"', add
label define hrsmain_lbl 109 `"109 hours"', add
label define hrsmain_lbl 110 `"110 hours"', add
label define hrsmain_lbl 111 `"111 hours"', add
label define hrsmain_lbl 112 `"112 hours"', add
label define hrsmain_lbl 113 `"113 hours"', add
label define hrsmain_lbl 114 `"114 hours"', add
label define hrsmain_lbl 115 `"115 hours"', add
label define hrsmain_lbl 116 `"116 hours"', add
label define hrsmain_lbl 117 `"117 hours"', add
label define hrsmain_lbl 118 `"118 hours"', add
label define hrsmain_lbl 119 `"119 hours"', add
label define hrsmain_lbl 120 `"120 hours"', add
label define hrsmain_lbl 121 `"121 hours"', add
label define hrsmain_lbl 122 `"122 hours"', add
label define hrsmain_lbl 123 `"123 hours"', add
label define hrsmain_lbl 124 `"124 hours"', add
label define hrsmain_lbl 125 `"125 hours"', add
label define hrsmain_lbl 126 `"126 hours"', add
label define hrsmain_lbl 127 `"127 hours"', add
label define hrsmain_lbl 128 `"128 hours"', add
label define hrsmain_lbl 129 `"129 hours"', add
label define hrsmain_lbl 130 `"130 hours"', add
label define hrsmain_lbl 131 `"131 hours"', add
label define hrsmain_lbl 132 `"132 hours"', add
label define hrsmain_lbl 133 `"133 hours"', add
label define hrsmain_lbl 134 `"134 hours"', add
label define hrsmain_lbl 135 `"135 hours"', add
label define hrsmain_lbl 136 `"136 hours"', add
label define hrsmain_lbl 137 `"137 hours"', add
label define hrsmain_lbl 138 `"138 hours"', add
label define hrsmain_lbl 139 `"139 hours"', add
label define hrsmain_lbl 140 `"140+ hours"', add
label define hrsmain_lbl 998 `"Unknown"', add
label define hrsmain_lbl 999 `"NIU (not in universe)"', add
label values hrsmain hrsmain_lbl


