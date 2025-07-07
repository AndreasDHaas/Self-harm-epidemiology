*** Eligibility: $repo/figures/Flowchart.pptx 

	* Fup Wide // N=235,637
		use if start < $close_d using "$source/FUPwide", clear   
		
	* Scheme at enrolment
		merge 1:1 patient start using "$source/FUP", keep(match) 
		assert _merge ==3
		drop _merge
		tab scheme, sort
		gen enrScheme = 1 if scheme ==9
		replace enrScheme = 2 if scheme ==41 
		replace enrScheme = 3 if enrScheme ==.
		tab enrScheme, mi
		drop scheme
		
	* Current scheme 
		merge 1:1 patient end using "$source/FUP", keep(match) 
		assert _merge ==3
		drop _merge
		tab scheme, sort
		gen curScheme = 1 if scheme ==9
		replace curScheme = 2 if scheme ==41 
		replace curScheme = 3 if curScheme ==.
		tab curScheme, mi
		drop scheme
								
	* Merge baseline characteristics  
		merge 1:1 patient using "$source/BAS", keep(match) nogen keepusing(birth_d sex)
		assertunique patient
		count // 
		
	* Left-trucate follow-up time at Jan 1, 2011: OPD & HOS claims availalbe 
		list if patient =="AFA0800194"
		rename start start_cover
		gen start = start_cover, after(start_cover) 
		replace start = d(01/01/2011) if start < d(01/01/2011)
		format start %tdD_m_CY
				
	* Left-trucate follow-up time at age 10 
	
		* Calculate age at start of follow-up: start 
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
		
	* Censor follow-up time at 1 Oct 2022 
		replace end = $close_d if end > $close_d & end !=. 
		sum end, f
		
	* Censor at 10 years of follow-up 
		gen maxFup = start10 + 9 * 365.25
		format maxFup %tdD_m_CY
		assert end !=. 
		assert maxFup !=.
		replace end = maxFup if end > maxFup 
	
	* Excluded: 
						
		* Unknown sex: 
			drop if sex ==3 // unknown sex
			di %3.1fc 
			
		* Calculate age at end of follow-up 
			gen age_end = floor((end-birth_d)/365.25)
			egen age_end_cat = cut(age_end), at(10,15,20,25,35,45,55,65,75,120) label
			tabstat age_end, by(age_end_cat) stats(min max)
			lab define age_end_cat 0 "10-14" 1 "15-19" 2 "20-24" 3 "25-34" 4 "35-44" 5 "45-54" 6 "55-64" 7 "65-74" 8 "75+", replace
			lab val age_end_cat age_end_cat 
			
		* Unknown age: N=28
			drop if age_end ==. // 
			di %3.1fc 28/235637*100 
			
		* Age below 18 at end of follow-up: 
			drop if age_end <10 // 
			di %3.1fc 
			count 
			global N = `r(N)'
			
		* Merge vital status 
			merge 1:1 patient using "$source/VITAL", keep(match) keepusing(linked death_d death_y cod2 cod1) 
			count if _merge ==3
			assert $N == `r(N)'
			drop _merge 
			macro drop N
			
		* Not linked to NPR
			*assert linked ==1
			tab linked
		/* Excluded total 
			di 10004 + 9148 + 262514
			di %3.1fc 281666/1549123*100 
			count
			*assert 281666+r(N)==1549123  // confirm excluded + included = total */
			
	* Included: N=1,267,457
		assertunique patient
			
	* Compress
		compress
		
	* No follow-up after 2011
		drop if end < d(01/01/2011)
			
	* Follow-up time, years 
		gen fup = (end-start10)/365.25
		assert inrange(fup, 0, 9)
		
	lab define sex 1 "Male" 2 "Female", replace
	lab val sex sex

		