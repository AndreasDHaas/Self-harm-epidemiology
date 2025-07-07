*** Eligibility: $repo/figures/Flowchart.pptx 

	* Persons with insurance coverage between 1 Jan 2011 and 30 Jun 2020:  1,549,123
		use "$source/FUPwide", clear   
				
	* Merge baseline characteristics  
		merge 1:1 patient using "$source/BAS", keep(match) nogen keepusing(birth_d sex afa popgrp)
		assertunique patient
		count // 1,549,123
		
	* Left-trucate follow-up time at age 10
	
		* Calculate age at start of follow-up 
			gen age_start = floor((start-birth_d)/365.25)
			gen start10 = start, after(start)
			format start10 %tdD_m_CY
			list patient age_start birth_d start start10 end if inlist(patient, "B000000233", "B000000131")
			replace start10 = birth_d + 10 * 365.25 if age_start < 10
			replace age_start = floor((start10-birth_d)/365.25)
			assert age_start >=10 
			egen age_start_cat = cut(age_start), at(10,15,20,25,35,45,55,65,75,120) label
			tabstat age_start, by(age_start_cat) stats(min max)
			lab define age_start_cat 0 "10-14" 1 "15-19" 2 "20-24" 3 "25-34" 4 "35-44" 5 "45-54" 6 "55-64" 7 "65-74" 8 "75+", replace
			lab val age_start_cat age_start_cat 
			order age_start_cat, after(age_start)
		
	* Censor follow-up time at 30 June 2020  
		replace end = $close_d if end >  $close_d & end !=. 
		sum end, f
		
	* Censor at 9 years of follow-up 
		gen maxFup = start10 + 9 * 365.25
		format maxFup %tdD_m_CY
		assert end !=. 
		assert maxFup !=.
		replace end = maxFup if end > maxFup 
		
	* Excluded: 
		
		* Calculate age at end of follow-up 
			gen age_end = floor((end-birth_d)/365.25)
			egen age_end_cat = cut(age_end), at(10,15,20,25,35,45,55,65,75,120) label
			tabstat age_end, by(age_end_cat) stats(min max)
			lab define age_end_cat 0 "10-14" 1 "15-19" 2 "20-24" 3 "25-34" 4 "35-44" 5 "45-54" 6 "55-64" 7 "65-74" 8 "75+", replace
			lab val age_end_cat age_end_cat 
			
		* Unknown age: N=9,148
			drop if age_end ==. // 16,281
			di %3.1fc 16281/1549123*100 
			assert inrange(age_end, 0, 100)
			
		* Age below 10 at end of follow-up: N=263,395 + 2 age_10 ==start
			drop if age_end <10 // + 2
			di %3.1fc 263395/1549123*100 
			count 
			global N = `r(N)'
			
		* Unknown sex: N=10,004
			*drop if sex ==3 // unknown sex
			*di %3.1fc 10004/1549123*100
			
		* Merge vital status 
			merge 1:1 patient using "$source/VITAL", keep(match) keepusing(linked death_d death_y cod1 cod2) 
			count if _merge ==3
			assert $N == `r(N)'
			drop _merge 
			macro drop N
			
		* Not linked to NPR: 70,062
			*drop if linked ==0 
			*di %3.1fc 70062/1490662*100 
			*drop linked
		
		* Excluded total 
			di 263395 + 16281
			di %3.1fc 279676/1549123*100 
			count
			assert 279676+r(N)==1549123  // confirm excluded + included = total
			
	* Included: N=1,267,457
		assertunique patient
			
	* Compress
		compress
			
	* Follow-up time, years 
		gen fup = (end-start10)/365.25
		assert inrange(fup, 0, 9)
				
/*** Censor deaths after end of insurance coverage
	
	* Confirm Ns 
		tab death_y // total deaths: 62,613
		assert death_d !=. if death_y ==1 // no missing death_d
		count if death_y ==1 & death_d > end // death after end of insurance coverage: 30,480
		count if death_y ==1 & death_d <= end // death while insured: 32,133
		di 30480+ 32133 // during & after insurance coverage = total 
	
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
		
	* Checks 
		foreach var in start start10 end age_start age_start_cat age_end death_y birth_d {
			assert `var' !=. 
		}
		assertunique patient
		assert death_d !=. if death_y ==1
		assert death_d ==. if death_y ==0
		assert cod2 !=. if death_y ==1
		assert cod2 ==. if death_y ==0
		assert start1 < end
		assert inrange(age_start, 18, 100)
		
	* Confirm N 
		count 
		assert `r(N)' == 981540
		
	* Compress
		compress
		
	* Sample patients
		set seed 2412
		generate rn = runiform()

		