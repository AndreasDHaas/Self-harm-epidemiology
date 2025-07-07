capture program drop fdiag
program define fdiag
* version 2.3  AH 11 July 2022 
	* assert master table is in wide format 
	qui gunique patient
	if r(maxJ) > 1 {
		display in red "Currently loaded dataset is not in wide format. The variable patient has to uniquly identify observations."
		exit 198
	}	
	* syntax checking enforces that variables specified in IF are included in master table. 
	* workaround: original dataset is preserved. Variables specified in IF and not included in master table are generate before systax checking and original dataset restored thereafter
	preserve 
	foreach var in patient icd10_code code_role icd_1 {
		qui capture gen `var' = ""
	}
	foreach var in icd10_date source discharge_date icd10_type icd_23 age {
		qui capture gen `var' = .
	}	
	* syntax 
	syntax newvarname using [if] , [ MINDATE(string) MAXDATE(string) MINAGE(integer -999) MAXAGE(integer 999) LABel(string) N Y LIST(integer 0) LISTPATient(string) DESCribe NOGENerate NOTIF(string) NOTIFBEFORE(integer 30) NOTIFAFTER(integer 30) CENSOR(varlist min==1 max==1) REFDATE(varlist min==1 max==1) REFMINUS(integer 30) REFPLUS(integer 30) Code ]  
	restore 
	* confirm newvarname does not exist 
	if "`nogenerate'" =="" { 
		capture confirm variable `varlist'_d
		if !_rc {
			display in red "`varlist' already exists"
			exit 198
		}
	}
	preserve
	* save refdate 
	if "`refdate'" !="" {
		tempfile ref 
		keep patient `refdate'
		qui save `ref'
	}
	use `using', clear
	* merge ref 
	if "`refdate'" !="" {
		qui merge m:1 patient using `ref', keep(match master)
	}
	*describe
	if "`describe'" !="" {
		describe
		lab list source 
		lab list icd10_type
		tab code_role, mi
	}
	* listpatient
	if "`listpatient'" !="" {
		di "" 
		di "" 
		di in red "listpatient: all obs in using table"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* select relevant diagnoses 
	marksample touse, novarlist
	foreach code in `notif' {
		qui replace `touse' = 1 if regexm(icd10_code, "`code'")
	}
	qui drop if !`touse'
	* list
	if "`list'" !="0" {
		di in red " --- list start ---"
		listif patient icd10_date discharge_date icd10_code source icd10_type code_role age, id(patient) sort(patient icd10_date) n(`list')  sepby(patient) 
		di in red " --- list end ---"
	}
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: obs meeting if and notif conditions"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* notif 
		* flag codes meeting notif condition 
		if "`notif'" !="" {
			qui gen notif_code = .
			foreach code in `notif' {
				qui replace notif_code = 1 if regexm(icd10_code, "`code'") 
			}
		}
		* flag codes that are not used because they are in time window around codes meeting notif condition
		if "`notif'" !="" {
			qui gen notif = 0
			qui bysort patient (notif_code icd10_date): replace notif_code = notif_code + notif_code[_n-1] if _n >1 
			qui sum notif_code 
			di in red "number of iterations: `r(max)'"
			forvalues j =`r(min)'/`r(max)' {
				di in red "iteration number: `j'"
				qui gen notif_code`j'_d = icd10_date if notif_code == `j'
				qui bysort patient (notif_code`j'_d): replace notif_code`j'_d = notif_code`j'_d[1] if notif_code`j'_d ==.
				format notif_code`j'_d % td
				qui replace notif = 1 if (icd10_date >= notif_code`j'_d - `notifbefore') & (icd10_date <= notif_code`j'_d + `notifafter') 
				drop notif_code`j'_d
			}
			sort patient icd10_date
			if "`listpatient'" !="" {
				di in red "listpatient: obs meeting if and notif conditions, obs not used because they are in time window around codes meeting notif condition flagged (notif==1)"
				list patient icd10_date discharge_date icd10_code source icd10_type code_role age notif if patient =="`listpatient'", sepby(patient)
			}
		}
		* drop notif records records and notif codes 
		if "`notif'" !="" {
			qui drop if notif ==1 
			drop notif 
			marksample touse, novarlist
			drop if !`touse'
			if "`listpatient'" !="" {
				di in red "listpatient: obs meeting if conditions, notif==1 dropped"
				list patient icd10_date discharge_date icd10_code source icd10_type code_role age notif if patient =="`listpatient'", sepby(patient)
			}
		}	
	* select age 
	if "`minage'" !="" qui drop if age < `minage' 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: obs < minage dropped"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	if "`maxage'" !="" qui drop if age > `maxage' & age !=. 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: obs > maxage dropped"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* mindate 
	if "`mindate'" != "" qui drop if icd10_date < `mindate'
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: obs < mindate dropped"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* maxdate
	if "`maxdate'" != "" qui drop if icd10_date > `maxdate' & icd10_date !=. 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: obs > maxdate dropped"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* refdate
	if "`refdate'" != "" {
		count if `refdate' ==. & _merge ==3
		if `r(N)' > 0 {
			display in red "`refdate' has missing values"
			exit 198
		}	
		gen lb = `refdate' - `refminus'
		gen ub = `refdate' + `refplus'
		qui keep if inrange(icd10_date, lb, ub)  
	}
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: not within refdate -refminus +refplus dropped"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age `refdate' lb ub if patient =="`listpatient'", sepby(patient) 
	}
	* number of diagnoses 
	qui bysort patient icd10_date: keep if _n ==1
	if "`listpatient'" !="" {
		di in red "listpatient: keep one record per date"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* n 
	if "`n'" != "" qui bysort patient (icd10_date): gen `varlist'_n =_N	
	* generate indicator variable sepcified in newvarname
	if "`y'" != "" {
		qui gen `varlist'_y = 1
		* label 
			if "`label'" != "" {
				label define  `varlist'_y 1 "`label'" , replace
				lab val `varlist'_y `varlist'_y
			}
	}
	* select first diag event 
	qui bysort patient (icd10_date): keep if _n ==1
	* event date 
	qui rename icd10_date `varlist'_d
	if "`listpatient'" !="" {
		di in red "listpatient: keep first event"
		list patient `varlist'_* if patient =="`listpatient'", sepby(patient) 
	}
	* clean
	qui keep patient icd10_code `varlist'_*
	rename icd10_code `varlist'_code
	if "`code'" !="" { 
	    drop `varlist'_code
	}
	* order and apply n and y options
	order patient `varlist'_d 
	* save events
	qui tempfile events
	qui save "`events'"
	* merge events to original dataset 
	restore 
	if "`nogenerate'" =="" { 
		qui merge 1:1 patient using "`events'", keep(match master) nogen
		if "`y'" != "" {
			qui replace `varlist'_y = 0 if `varlist'_y ==. 
			di "--- before censoring ---"
			tab `varlist'_y, mi
		}
	}
	if "`censor'" !="" {
		if "`y'" != "" {
			qui replace `varlist'_y = 0 if `varlist'_d !=. & `varlist'_d > `censor'
			qui capture replace `varlist'_n = . if `varlist'_d !=. & `varlist'_d > `censor'
			di "--- after censoring ---"
			tab `varlist'_y, mi
		}
		qui replace `varlist'_d = . if `varlist'_d !=. & `varlist'_d > `censor'
	}
end
