***Combine tables 
	
*** Analyse wide 
	use "$cleanAfA/analyseWide", clear
		
		* Exclude BON 
			drop if curScheme ==1 
			
	* Append AfAc 
		append using "$cleanAfAc/analyseWide"
		
		* enrScheme curScheme
			replace enrScheme = 1 if enrScheme ==.
			replace curScheme = 1 if curScheme ==.
			
		* Sex
			assert inlist(sex, 1, 2, 3)
			tab sex
			lab define sex 3 "Unspecified", modify
			
		* Age 
			sum age_start
			assert inrange(age_start, 10, 100)
			
		* AfA 
			replace afa = 1 if substr(patient, 1, 1) =="A"
			
		* Popgrp
			tab popgrp, mi
			replace popgrp = 9 if popgrp ==.
			lab define popgrp 9 "Unknown", modify
			
		* HIV start data for AfA data
			replace hiv1_y =1 if afa ==1
			replace hiv1_d =start10 if afa ==1
			
		* Mortality
			lab define death_y 1 "Mortality", replace 
			lab val death_y death_y
	
*** Censor deaths after end of insurance coverage
	
	* Confirm Ns 
		tab death_y // total deaths: 72,503
		assert death_d !=. if death_y ==1 // no missing death_d
		count if death_y ==1 & death_d > end // death after end of insurance coverage: 31,614
		count if death_y ==1 & death_d <= end // death while insured: 40,889
		di 31614 + 40889 // during & after insurance coverage = total 
		
	* Save old variables 
		foreach var in death_y death_d cod1 cod2 {
			gen `var'_orig = `var'
		}
		lab var cod1_orig cod1
		lab var cod2_orig cod2
		format death_d_orig %tdD_m_CY
			
	* Censor deaths after end of insurance coverage 
		gen censored = 1 if death_y ==1 & death_d > end
		
		* List censored cases  
			*listif patient death_y death_d end cod2 censored if death_y ==1 & death_d > end, id(pat) sort(pat) seed(1)
			list patient death_y death_d end cod2 censored if pat =="B011045487" // censored
		
		* List uncensored cases: plan end date was set to death date for patients who died while under insurance coverage  
			*listif patient death_y death_d end cod2 censored if death_y ==1 & death_d <= end, id(pat) sort(pat) seed(1)
			list patient death_y death_d end cod2 censored if pat =="B007826960" // not censored 
			
		* Overwrite censored death information 
			replace death_y = 0 if censored ==1
			replace death_d = . if censored ==1
			replace cod2 = . if censored ==1
			replace cod1 = . if censored ==1
			drop censored 

	* Variable labels 
		lab var patient "Patient identifier"
		lab var start "Start of insurance coverage"
		lab var start10 "Start of insurance coverage or 18th birthday, whichever occurs later"
		lab var end "End of insurance coverage or deaths, whichever occurs first"
		lab var birth_d "Month and year of birth"
		lab var age_start "Age at start10"
		lab var age_end "Age at end"
		lab var death_y "Binary indicator for death"
		lab var death_d "Date of death"
		lab var cod2 "Cause of death: natural/unnatural/unknown"
		lab var age_start_cat "Age at baseline, y" 
		lab var fup "Follow-up time, y" 
		
	* Value labels 
		lab define popgrp 9 "Unknown", modify
		lab define death_y 1 "Mortality" 0 "Alive", replace 
		lab val death_y death_y 
		lab define cod2 1 "Natural causes" 2 "Unnatural causes" 4 "Unknown", modify
		lab define cod1 1 "Natural causes" 2 "Unnatural causes" 3 "Under investigation" 4 "Unknown", modify
		
	* Drop start on end 
		drop if start10 ==end
		
	* Checks 
		foreach var in start start10 end age_start age_start_cat age_end death_y birth_d {
			assert `var' !=. 
		}
		assertunique patient
		assert death_d !=. if death_y ==1
		assert death_d ==. if death_y ==0
		assert cod2 !=. if death_y ==1
		assert cod2 ==. if death_y ==0
		assert cod1 !=. if death_y ==1
		assert cod1 ==. if death_y ==0
		assert start10 < end
		assert inrange(age_start, 10, 100)
		
	* Compress
		compress
		
	* Save combined dataset 
		saveold "$clean/analyseWide", replace version(12)
		
	* N 
		use "$clean/analyseWide", clear
		count
		drop if linked ==0
		drop if sex ==3
		
*** Self-harm long 
		use "$cleanAfA/eventsLong", clear	
		sum date, f
		use "$cleanAfAc/eventsLong", clear	
		sum date, f	
		append using "$cleanAfA/eventsLong"
		sort patient date
		merge m:1 patient using "$clean/analyseWide", keep(match) keepusing(patient) nogen
		sort patient date
		saveold "$clean/eventsLong", replace version(12)
	
* Clean eventsLong 
	use "$clean/eventsLong", clear
	listif patient date icd10_code intent event source discharge_date code_role, sepby(patient) sort(patient date) seed(2) n(20) id(patient)
	
	* Drop undetermined intent, other or unspecified event, very low specificity for self-harm, commonly used in orthopedics
		drop if event ==212 

	* Same date, same event: prioritises hospital diagnoses over outpatient
		bysort patient date event (source): keep if _n ==1 
		
	* Same date, diffrent events: prioritise intentional self-harm, lethal methods, hospital diagnoses   
		bysort patient date: gen n = _N
		bysort patient date (intent event source): keep if _n ==1
		listif patient date icd10_code intent event source discharge_date code_role n if n >2, sepby(patient date) sort(patient date intent event source) seed(2) n(20) id(patient)
		drop n
		bysort patient (date): gen N =_N
		
	* Drop individulas without intentional self-harm event
		gen i = intent ==1
		tab intent i
		bysort patient (date): egen everIntent = max(i)
		listif patient date icd10_code intent event source discharge_date code_role if everIntent ==0, sepby(patient) sort(patient date intent event source) seed(2) n(20) id(patient)
		drop if everIntent ==0
		drop everIntent 
		
	* Within x days to previous event is same episode
		foreach j in 7 14 30 90 180 365 {
			preserve 
			bysort patient (date): gen d = date-date[_n-1]
			sort patient date intent event source
			gen episode = d > `j'
			bysort patient (date): replace episode = episode + episode[_n-1] if _n !=1
			listif patient date icd10_code intent event source discharge_date code_role d episode if N>1, sepby(patient) sort(patient date intent event source) seed(2) n(120) id(patient)			
			bysort patient episode (date): egen eSdate = min(date)
			bysort patient episode (date): egen eEdate = max(date)
			bysort patient episode (date): egen eEvent = min(event)
			bysort patient episode (date): egen eIntent = min(intent)
			bysort patient episode (date): egen eSource = min(source)	
			format eSdate eEdate %tdD_m_CY 
			lab val eEvent event
			lab val eIntent intent 
			lab val eSource source
			listif patient date icd10_code intent event source discharge_date code_role d episode eSdate eEdate eIntent eEvent eSource if N>1, sepby(patient) sort(patient date intent event source) seed(2) n(20) id(patient)
			bysort patient episode: keep if _n ==1
			drop date icd10_code intent event source discharge_date code_role d
			bysort patient (eSdate): gen d = eSdate - eEdate[_n-1]
			bysort patient (eSdate): gen eN = _N
			listif patient episode eSdate eEdate eIntent eEvent eSource d if eN>1, sepby(patient) sort(patient eSdate) seed(3) n(20) id(patient)
			drop med_id pos N i
			saveold "$clean/episodesLong`j'", replace version(12)
			restore
		}
						
			use "$clean/episodesLong7", clear
			listif patient episode eSdate eEdate eIntent eEvent eSource d eN if eN>1, sepby(patient) sort(patient eSdate) seed(3) n(20) id(patient)
			sum eN if episode ==1 & everIntent ==1, de
			
	* Combine ICD tables
		use "$sourceAfA/ICD10_F.dta", clear
		append using "$sourceAfAc/ICD10_F.dta"
		save "$source/ICD10_F.dta"
		
		use "$sourceAfA/ICD10.dta", clear
		append using "$sourceAfAc/ICD10.dta"
		save "$source/ICD10.dta"
		
		use "$sourceAfA/MED_ATC_N.dta", clear
		append using "$sourceAfAc/MED_ATC_N.dta"
		save "$source/MED_ATC_N.dta"
			
	