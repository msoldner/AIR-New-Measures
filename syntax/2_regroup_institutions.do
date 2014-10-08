capture log close

* These paths will need to be changed to reflect your local
* configuration.

local homepath "\\dc1fs\dc1ehd\share\Higher Education\"
local basepath "`homepath'BMGF - For Profit Study\Extant Data"
local fileout "public_working"

cd "`basepath'"

local c_date = c(current_date)
local c_time = c(current_time)
local c_time_date = "`c_date'"+"_" +"`c_time'"
local time_string = subinstr("`c_time_date'", ":", "_", .)
local time_string = subinstr("`time_string'", " ", "_", .)

log using ".\log\log_2_regroup_institutions_`time_string'.log", text replace

clear all
version 13
set seed 1025
set more off

* 
*
* 2_regroup_institutions.do
*
* Adds several variables to file that permit analysis by important
* institutional groupings
* 
* Matthew Soldner
* American Institutes for Research
*
* Changelog
* ----------------------------------------------------------------------------|
* 2014-09-25.0 | MS | Initial version completed
* ----------------------------------------------------------------------------|
*
*

* [1] Load working file -------------------------------------------------------|
cd "`basepath'"
use "`fileout'.dta", replace

* [2] DRV_GRPCORP: Identify institutions that are part of major systems -------|
* 
* Important note: this method works for major providers, but many smaller
* providers fail to answer f1systyp appropriately. This error can be detected
* by comparing EINs.
*
* Code results in distinct values:
* 0 == Not in a system
* 9999 == In a system, not separately identified
* Else == Code uniquely identifying system membership

capture drop drv_grpcorp
capture label drop drv_grpcorp
gen drv_grpcorp = 9999
label variable drv_grpcorp "Grouped by: Corporate membership"
label define drv_grpcorp 9999 "In system, total enr below 50K", add


* [2.1] Begin with key systems. We will begin by just converting each string 
* in to a labeled integer, and then start combining.

capture drop temp
encode hd_f1sysnam, generate(temp)

replace drv_grpcorp = 0 if hd_f1systyp == 2
label define drv_grpcorp 0 "Not in a system, total enr below 50K", add

* Below, we identify the 10 largest providers (by 2012 enrollment). You can
* uncomment other providers below to separately enumerate them.

replace drv_grpcorp = 1 if inlist(temp, 462) 
label define drv_grpcorp 1 "University of Phoenix", add

replace drv_grpcorp = 2 if inlist(temp, 151, 168, 169, 170, 173) 
label define drv_grpcorp 2 "Education Management Corporation", add

replace drv_grpcorp = 3 if inlist(temp, 114, 115, 116, 117, 212) 
label define drv_grpcorp 3 "Corinthian Colleges, Inc.", add

replace drv_grpcorp = 4 if inlist(temp, 78, 79) 
label define drv_grpcorp 4 "Career Education Corporation", add

replace drv_grpcorp = 5 if inlist(temp, 52) 
label define drv_grpcorp 5 "Bridgepoint Education, Inc.", add

replace drv_grpcorp = 6 if inlist(temp, 249, 250, 251, 252) 
label define drv_grpcorp 6 "Kaplan Higher Education", add

replace drv_grpcorp = 7 if inlist(temp, 132, 133) 
label define drv_grpcorp 7 "Devry Education Group", add

replace drv_grpcorp = 8 if inlist(temp, 226, 227, 228, 229) 
label define drv_grpcorp 8 "ITT Educational Services, Inc.", add

replace drv_grpcorp = 9 if inlist(temp, 28) 
label define drv_grpcorp 9 "American Public Education, Inc.", add

replace drv_grpcorp = 10 if inlist(temp, 415, 416, 417, 418, 419) 
label define drv_grpcorp 10 "Strayer Education, Inc.", add

replace drv_grpcorp = 11 if inlist(temp, 71) 
label define drv_grpcorp 11 "Capella Education Company", add

replace drv_grpcorp = 12 if unitid == 104717
label define drv_grpcorp 12 "Grand Canyon Education, Inc.", add

* replace drv_grpcorp = 13 if inlist(temp, 377) | unitid == 467605
* label define drv_grpcorp 13 "Regency Corporation", add

* replace drv_grpcorp = 14 if inlist(temp, 247, 344, 345, 346, 347, 119) | inlist(unitid, 373605, 143376, 457323, 451565, 455901, 476841, 454652, 248660, 240240, 160445, 456825, 468893, 461193, 459170)
* label define drv_grpcorp 14 "Paul Mitchell Schools", add

* replace drv_grpcorp = 15 if inlist(temp, 103) 
* label define drv_grpcorp 15 "Columbia Southern Education Group", add

replace drv_grpcorp = 16 if inlist(temp, 265, 266) 
label define drv_grpcorp 16 "Laureate Education, Inc.", add

* replace drv_grpcorp = 17 if unitid == 134237
* label define drv_grpcorp 17 "Full Sail, LLC", add

* replace drv_grpcorp = 18 if unitid == 108232
* label define drv_grpcorp 18 "Academy of Art University", add

* replace drv_grpcorp = 19 if inlist(temp, 21, 22)
* label define drv_grpcorp 19 "American Colleges of Hairstyling, Inc.", add

* replace drv_grpcorp = 20 if inlist(temp, 43, 44)
* label define drv_grpcorp 20 "Beauty Careers Institute, Inc.", add

* replace drv_grpcorp = 21 if inlist(temp, 54, 55)
* label define drv_grpcorp 21 "Broadview Institute, Inc.", add

* replace drv_grpcorp = 22 if inlist(temp, 73, 74)
* label define drv_grpcorp 22 "Capri Schools of Beauty Culture, Inc.", add

* replace drv_grpcorp = 23 if inlist(temp, 80, 81)
* label define drv_grpcorp 23 "Career Management Systems", add

* replace drv_grpcorp = 24 if inlist(temp, 96, 97)
* label define drv_grpcorp 24 "College of Business and Technology, Inc.", add

* replace drv_grpcorp = 25 if inlist(temp, 110, 111)
* label define drv_grpcorp 25 "Concorde Career Colleges, Inc.", add

* replace drv_grpcorp = 26 if inlist(temp, 124, 125)
* label define drv_grpcorp 26 "DLORAH, Inc.", add

* replace drv_grpcorp = 27 if inlist(temp, 128, 129, 130, 131)
* label define drv_grpcorp 27 "Daymar Colleges Group, Inc.", add

* replace drv_grpcorp = 28 if inlist(temp, 141, 142, 143, 144)
* label define drv_grpcorp 28 "Dorsey School of Business Holdings, Inc.", add

* replace drv_grpcorp = 29 if inlist(temp, 159, 160, 161, 162, 163, 164, 165, 444, 84)
* label define drv_grpcorp 29 "Education Affiliates, Inc.", add

* replace drv_grpcorp = 30 if inlist(temp, 178, 179)
* label define drv_grpcorp 30 "Employment Services, Inc.", add

* replace drv_grpcorp = 31 if inlist(temp, 194, 196, 297, 298)
* label define drv_grpcorp 31 "G.R.H., Inc.", add

* replace drv_grpcorp = 32 if inlist(temp, 202, 203, 204)
* label define drv_grpcorp 32 "Globe Education Network", add 

* replace drv_grpcorp = 33 if inlist(temp, 205, 206)
* label define drv_grpcorp 33 "HMR Enterprises, Inc.", add

* replace drv_grpcorp = 34 if inlist(temp, 216, 217, 218)
* label define drv_grpcorp 34 "High-Tech Institute, Inc.", add

* replace drv_grpcorp = 35 if inlist(temp, 221, 222)
* label define drv_grpcorp 35 "Houston Training Schools, Inc.", add

* replace drv_grpcorp = 36 if inlist(temp, 273, 274)
* label define drv_grpcorp 36 "Lincoln Barber College", add

* replace drv_grpcorp = 37 if inlist(temp, 276, 277)
* label define drv_grpcorp 37 "M&S Media, Inc.", add

* replace drv_grpcorp = 38 if inlist(temp, 291, 292)
* label define drv_grpcorp 38 "Med-Com Career Training, Inc.", add

* replace drv_grpcorp = 39 if inlist(temp, 300, 301, 302) | unitid == 437556
* label define drv_grpcorp 39 "Midwest Technical Institute, Inc.", add

* replace drv_grpcorp = 40 if inlist(temp, 304, 305)
* label define drv_grpcorp 40 "Milan Institute", add

* replace drv_grpcorp = 41 if inlist(temp, 307, 308)
* label define drv_grpcorp 41 "Minnesota School of Business, Inc.", add

* replace drv_grpcorp = 42 if inlist(temp, 319, 320, 321)
* label define drv_grpcorp 42 "National College, Inc.", add

* replace drv_grpcorp = 43 if inlist(temp, 326, 327, 328) | unitid==166009
* label define drv_grpcorp 43 "Newcoast College, Inc.", add

* replace drv_grpcorp = 44 if inlist(temp, 355, 356)
* label define drv_grpcorp 44 "Platt College Los Angeles, LLC", add

* replace drv_grpcorp = 45 if inlist(temp, 360, 361, 362)
* label define drv_grpcorp 45 "Premier Education Group, LP", add

* replace drv_grpcorp = 46 if inlist(temp, 381, 382)
* label define drv_grpcorp 46 "Ridley-Lowell School of Business, Inc.", add

* replace drv_grpcorp = 47 if inlist(temp, 387, 388)
* label define drv_grpcorp 47 "Ross Education, LLC", add

* replace drv_grpcorp = 48 if inlist(temp, 391, 392, 393, 394)
* label define drv_grpcorp 48 "SAE Institute Group, Inc.", add

* replace drv_grpcorp = 49 if inlist(temp, 406, 407, 118)
* label define drv_grpcorp 49 "Steiner Education Group", add

* replace drv_grpcorp = 50 if inlist(temp, 409, 410)
* label define drv_grpcorp 50 "Stenograph, LLC", add

* replace drv_grpcorp = 51 if inlist(temp, 428, 429) | unitid == 413680
* label define drv_grpcorp 51 "Technical Education Services, Inc.", add

* replace drv_grpcorp = 52 if inlist(temp, 435, 436)
* label define drv_grpcorp 52 "The Salon Professional Academy", add

* replace drv_grpcorp = 53 if inlist(temp, 447, 448)
* label define drv_grpcorp 53 "Tricoci University of Beauty Culture, LLC", add

* replace drv_grpcorp = 54 if inlist(temp, 450, 451, 452)
* label define drv_grpcorp 54 "Tulsa Welding School, Inc.", add

* replace drv_grpcorp = 55 if inlist(temp, 455, 456)
* label define drv_grpcorp 55 "Unitech Training Academy, Inc.", add

* replace drv_grpcorp = 56 if inlist(temp, 466, 467)
* label define drv_grpcorp 56 "Vatterott Educational Centers, Inc.", add

* replace drv_grpcorp = 57 if inlist(temp, 474, 475, 476)
* label define drv_grpcorp 57 "West Coast University, Inc.", add

label values drv_grpcorp drv_grpcorp

gsort -efy_totlt1

list unitid hd_instnm drv_grpcorp efy_totlt1 ///
         if efy_totlt1 > 15000, str(40)
		 
table drv_grpcorp, c(sum efy_totlt1)

drop temp

* [3] DRV_GRPCOSMO: Identify institutions that are largely cosmetology --------|
*
* Code results in 2 distinct values:
* 0 == Not mainly cosmetology
* 1 == Mainly cosmetology

capture drop drv_grpcosmo
capture label drop drv_grpcosmo
gen drv_grpcosmo = 0
label define drv_grpcosmo 0 "Not primarily cosmetology", add
label variable drv_grpcosmo "Grouped by: Primarily cosmetology"

replace drv_grpcosmo = 1 if (py_cipcode1 > 120399 & py_cipcode1 < 120500)
label define drv_grpcosmo 1 "Primarily cosmetology", add

label values drv_grpcosmo drv_grpcosmo


* [4] DRV_GRPSTD3: Create standard tripartite grouping used in project reports-|
*
* Code results in 3 distinct values:
* 0 == For-profit, Major publicly traded 
* 1 == For-profit, Not primarily cosmetology
* 2 == For-profit, Primarily cosmetology

capture drop drv_grpstd3
capture label drop drv_grpstd3
gen drv_grpstd3 = 1
label variable drv_grpstd3 "Grouped by: Major institutional category"
label define drv_grpstd3 1 "For-profit, not primarily cosmetology", add

replace drv_grpstd3 = 2 if drv_grpcosmo == 1
label define drv_grpstd3 2 "For-profit, primarily cosmetology", add

replace drv_grpstd3 = 0 if (drv_grpcorp != 0 & drv_grpcorp != 9999)
label define drv_grpstd3 0 "For-profit, major publicly traded", add

label values drv_grpstd3 drv_grpstd3


* [3] Close out --------------------------------------------------------------|

compress
save "`basepath'\`fileout'.dta", replace

log close
exit
