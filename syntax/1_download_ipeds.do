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

log using ".\log\log_1_download_ipeds_`time_string'.log", text replace

clear all
version 13
set seed 1025
set more off

* 
*
* 1_download_ipeds.do
*
* Downloads key IEPDS files and creates a single working file for analysis.
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

* [1] Download needed IPEDS files --------------------------------------------|

* [1.1] List all files to be downloaded from NCES
#delimit ;
local roster 
	"HD2012_Data_Stata
	IC2012_Data_Stata
	IC2012_AY_Data_Stata
	IC2012_PY_Data_Stata
	EFFY2012_Data_Stata
	EF2012A_DIST_Data_Stata 
	EAP2012_Data_Stata
	GR2012_Data_Stata
	SFA1112_Data_Stata
	F1112_F3_Data_Stata
	C2012_A_Data_Stata" ;
#delimit cr

* [1.2] Set refresh to 1 if you wish to redownload zip files
local refresh = 0

* [1.3] Download files as needed and unzip each
cd ".\source\"

foreach fh of local roster {
	local outfile = lower("`fh'") + ".zip" 
	if "`refresh'" == "1" {
		copy "http://nces.ed.gov/ipeds/datacenter/data/`fh'.zip" "`outfile'", replace
		unzipfile "`outfile'", replace
		}
}
	
cd "`basepath'"

* [2] Subset IPEDS HD file ---------------------------------------------------|
* Based on 2012 First Look  
* (http://nces.ed.gov/pubsearch/pubsinfo.asp?pubid=2013289rev), we expect 
* 3542 for-profit institutions in the header (HD) file. We will use HD as the
* "base" for matching

import delimited "`basepath'\source\hd2012_data_stata.csv", clear
keep if (fips < 57 & inlist(pset4flg, 1, 3) & inlist(sector, 3, 6, 9))
quietly: tab sector
assert `r(N)' == 3452

rename (*) hd_=
rename hd_unitid unitid

* Drop some low value, high storage cost variables
drop *url
drop *ialias
drop hd_addr
drop *countynm
drop *gentele

save "hd2012.dta", replace

* [3] Merge HD with IC -------------------------------------------------------|
import delimited "`basepath'\source\ic2012_data_stata.csv", clear
drop x*

rename (*) ic_=
rename ic_unitid unitid

merge 1:1 unitid using "hd2012.dta"
keep if _merge == 3
quietly: tab hd_sector
assert `r(N)' == 3452
gen zhd_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [4] Merge working file with IC charges files -------------------------------|

* [4.1] Begin with program reporters
import delimited "`basepath'\source\ic2012_py_data_stata.csv", clear
drop x*

drop cipcode2 cipcode3 cipcode4 cipcode5 cipcode6 
drop ciptuit2 ciptuit3 ciptuit4 ciptuit5 ciptuit6
drop ciplgth2 ciplgth3 ciplgth4 ciplgth5 ciplgth6
drop prgmsr2 prgmsr3 prgmsr4 prgmsr5 prgmsr6
drop mthcmp2 mthcmp3 mthcmp4 mthcmp5 mthcmp6

rename (*) py_=
rename py_unitid unitid

merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zpy_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [4.2] Then academic year reporters
import delimited "`basepath'\source\ic2012_ay_data_stata.csv", clear
drop x*

#delimit ;
keep unitid 
tuition1 fee1 hrchg1 cmpfee1 
tuition2 fee2 hrchg2 cmpfee2 
tuition3 fee3 hrchg3 cmpfee3 
tuition5 fee5 hrchg5 
tuition6 fee6 hrchg6 
tuition7 fee7 hrchg7 ;
# delimit cr

rename (*) ay_=
rename ay_unitid unitid

merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zay_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [5] Merge working file with 12-Month enrollment -----------------------------|
import delimited "`basepath'\source\effy2012_data_stata.csv", clear
drop x*

#delimit ;
keep unitid effylev
efytot* efyaiant efyasiat efybkaat efyhispt efynhpit efywhitt efy2mort 
efyunknt efynralt;
# delimit cr

reshape wide efy*, i(unitid) j(effylev)
rename efy* efy_*

merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zefy_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [6] Merge working file with distance enrollment -----------------------------|
import delimited "`basepath'\source\ef2012a_dist_data_stata.csv", clear
capture drop x*

keep if efdelev == 1
keep unitid efdetot efdeexc efdesom efdenon

rename efde* efde_*=

merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zefde_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [6] Merge working file with employees by assigned position-------------------|
* EAP is among the more complex files, given the many permutations of how
* workers are classified -- the product of role and employment arrangement.
* 
* We will take only a few of the possible categories for now, nested as:
* 10000 == All staff
* 	21000 == Instructional staff, total
* 		21100 == Instructional staff, primarily instruction, total
* 	27000 == Other teaching and instructional support, total
import delimited "`basepath'\source\eap2012_data_stata.csv", clear
capture drop x*

keep if inlist(eapcat, 10000, 21000, 21100, 27000)

capture gen denominator = .
bysort unitid (eapcat) : replace denominator = eaptot[1] 
gen eapratio = eaptot / denominator
keep unitid eapcat eaptot eapratio

reshape wide eaptot eapratio, i(unitid) j(eapcat)

rename (eaptot10000 eaptot21000 eaptot21100 eaptot27000) ///
	(eap_tot10000 eap_tot21000 eap_tot21100 eap_tot27000)
	
rename (eapratio10000 eapratio21000 eapratio21100 eapratio27000) ///
	(eap_ratio10000 eap_ratio21000 eap_ratio21100 eap_ratio27000)
	
merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zeap_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [7] Merge working file with graduation rates --------------------------------|
* Note that for now we are only dealing with gr2012. There is a separate file,
* gr2012_L2, that tracks rates for less-than-two-year institutions. 

* We will generate two rates:
* All degree/cert seekers at 4-years, 150% rate = GRTYPE == 3 / GRTYPE == 2
* All degree/cert seekers at 2-years, 150% rate = GRTYPE == 30 / GRTYPE == 29
*
* For now, we exclude: transfer out, still enrolled, and no longer enrolled.
import delimited "`basepath'\source\gr2012_data_stata.csv", clear
drop x*

keep unitid grtype grtotlt cohort
keep if inlist(grtype, 3, 2, 30, 29)

capture gen denominator = .
bysort unitid cohort : replace denominator = grtotlt[1]
capture gen gr2012 = grtotlt / denominator
keep if inlist(grtype, 3, 30)

rename (*) gr42_=
rename gr42_unitid unitid

merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zgr42_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [8] Merge working file with financial aid -----------------------------------|
import delimited "`basepath'\source\sfa1112_data_stata", clear
drop x*

rename (*) sfa_=
rename sfa_unitid unitid

merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zsfa_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [9] Merge working file with finance -----------------------------------------|
import delimited "`basepath'\source\f1112_f3_data_stata.csv", clear
drop x*

rename (*) f1112_=
rename f1112_unitid unitid

merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zf1112_merge = _merge
drop _merge

compress
save "`fileout'.dta", replace

* [10] Merge working file with completions ------------------------------------|
import delimited "`basepath'\source\c2012_a_data_stata.csv", clear
drop x*

* For now, we are:
* - going to ignore field of study (keep only summary cipcode, cipcode == 99)
* - going to ignore race/ethnicity and gender of recipients
* - sum across 'majornum'
* - create three separate variables: subbacc, bacc, and postbacc
* - verify we don't lose any completions across these manipulations

keep if cipcode == 99
total ctotalt

keep unitid cipcode majornum awlevel ctotalt
collapse (sum) ctotalt, by(unitid awlevel)

recode awlevel ///
	(1/4 = 1 "Subbacc") (5 = 2 "Bacc") (6/19 = 3 "Postbacc"), gen(awlevel2)
drop awlevel

collapse (sum) ctotalt, by(unitid awlevel2)

reshape wide ctotalt, i(unitid) j(awlevel2)	
replace ctotalt1 = 0 if ctotalt1 == .
replace ctotalt2 = 0 if ctotalt2 == .
replace ctotalt3 = 0 if ctotalt3 == .

gen grandtotal = ctotalt1 + ctotalt2 + ctotalt3 
total grandtotal

rename (*) c_=
rename c_unitid unitid

merge 1:1 unitid using "`fileout'.dta"
keep if inlist(_merge, 2, 3)
quietly: tab hd_sector
assert `r(N)' == 3452
gen zc_merge = _merge
drop _merge

compress

* [11] Close out --------------------------------------------------------------|

order *, alpha
order unitid hd_instnm hd_sector, first
save "`fileout'.dta", replace

log close
exit
