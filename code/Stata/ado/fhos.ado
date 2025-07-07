capture program drop fhos
program define fhos
* version 2.1  AH 6 May 2022 
	* assert master table is in wide format 
	qui gunique patient
	if r(maxJ) > 1 {
		display in red "Currently loaded dataset is not in wide format. The variable patient must uniquly identify observations."
		exit 198
	}	
	* syntax checking enforces that variables specified in IF are included in master table. 
	* workaround: original dataset is preserved. Variables specified in IF and not included in master table are generate before systax checking and original dataset restored thereafter
	preserve 
	foreach var in patient code_type hosp_code code_description {
		qui capture gen `var' = ""
	}
	foreach var in adm_date dis_date duration code_role initial_los no_of_days_approved age {
		qui capture gen `var' = .
	}	
	* syntax 
	syntax newvarname using [if] , [ MINDATE(string) MAXDATE(string) MINAGE(integer -999) MAXAGE(integer 999) LABel(string) N Y LIST(integer 0) LISTPATient(string) DESCribe NOGENerate censor(varlist min==1 max==1) REFDATE(varlist min==1 max==1) REFMINUS(integer 30) REFPLUS(integer 30)]  
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
		tab code_type
		lab list code_role
	}
	* listpatient
	if "`listpatient'" !="" {
		di "" 
		di "" 
		di in red "listpatient: all"
		list patient adm_date dis_date duration code_type hosp_code code_role code_description age if patient =="`listpatient'", sepby(patient) string(20) 
	}
	* select relevant diagnoses 
	marksample touse, novarlist
	qui drop if !`touse'
	* list
	if "`list'" !="0" {
		di in red " --- list start ---"
		listif patient adm_date dis_date duration code_type hosp_code code_role code_description age, id(patient) sort(patient adm_d) n(`list')  sepby(patient) 
		di in red " --- list end ---"
	}
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: meeting if conditions"
		list patient adm_date dis_date duration code_type hosp_code code_role code_description age if patient =="`listpatient'", sepby(patient) 
	}
	* select age 
	if "`minage'" !="" qui drop if age < `minage' 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: >= minage"
		list patient adm_date dis_date duration code_type hosp_code code_role code_description age if patient =="`listpatient'", sepby(patient) 
	}
	if "`maxage'" !="" qui drop if age > `maxage' & age !=. 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: <= maxage"
		list patient adm_date dis_date duration code_type hosp_code code_role code_description age if patient =="`listpatient'", sepby(patient) 
	}
	* mindate 
	if "`mindate'" != "" qui drop if adm_date < `mindate'
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: >= mindate"
		list patient adm_date dis_date duration code_type hosp_code code_role code_description age if patient =="`listpatient'", sepby(patient) 
	}
	* maxdate
	if "`maxdate'" != "" qui drop if adm_date > `maxdate' & adm_date !=. 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: <= maxdate"
		list patient adm_date dis_date duration code_type hosp_code code_role code_description age if patient =="`listpatient'", sepby(patient) 
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
		qui keep if inrange(adm_date, lb, ub)  
	}
	* number of diagnoses 
	qui bysort patient adm_date: keep if _n ==1
	if "`listpatient'" !="" {
		di in red "listpatient: keep one record per date"
		list patient adm_date dis_date duration code_type hosp_code code_role code_description age if patient =="`listpatient'", sepby(patient) 
	}
	* n 
	if "`n'" != "" qui bysort patient (adm_date): gen `varlist'_n =_N	
	* generate indicator variable sepcified in newvarname
	if "`y'" != "" {
		qui gen `varlist'_y = 1
		* label 
			if "`label'" != "" {
				label define  `varlist'_y 1 "`label'" 
				lab val `varlist'_y `varlist'_y
			}
	}
	* select first diag event 
	qui bysort patient (adm_date): keep if _n ==1
	* event date 
	qui rename adm_date `varlist'_d
	if "`listpatient'" !="" {
		di in red "listpatient: keep first event"
		list patient `varlist'_* if patient =="`listpatient'", sepby(patient) 
	}
	* clean
	qui keep patient `varlist'_*
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