* Healthcare encounters before ISH 

	/* Veronika's dataset 
		import excel "Y:/IeDEA/IeDEA_Science\Datasets\SH\Combined/v1.1/dd_SH.xlsx", sheet("dd_SH") firstrow clear
		rename id patient
		tab Self_harm_y
		save "$temp/analyseWide_vws", replace */

	*Baseline table 
		use "$clean/analyseWide", clear
	
	*Studyperiod 
		global studyperiod "mindate(`=d(01/01/2011)') maxdate($cdate)" 
	
	* Define ISH 
	
		* Merge long table with event episodes 
			mmerge patient using "$clean/episodesLong7", unmatched(master) uif(eEvent < 200)
		
		* Remove censored events 
			sort patient eSdate
			*listif patient start10 ish1_d linked death_y death_d maxFup close_d episode eSdate eEdate eEvent eIntent if inlist(patient, $j), id(patient) sort(patient eSdate) 
			
			*listif patient start10 age_start ish1_d linked death_y death_d maxFup close_d episode eSdate eEdate eEvent eIntent if eSdate < start10, id(patient) sort(patient eSdate) 
			replace eSdate = . if eSdate <= start10
			replace eSdate = . if eSdate > close_d
			assert end !=.
			*listif patient start10 ish1_d linked death_y death_d maxFup close_d episode eSdate eEdate end eEvent eIntent if eSdate > end & eSdate !=., id(patient) sort(patient eSdate) 
			replace eSdate = . if eSdate > end
			replace eSdate = . if eSdate > death_d
			
		* Keep first event 
			bysort patient (eSdate): keep if _n ==1
			
		* ISH event (0/1)
			gen ish = eSdate != .
			
		* Merge Veronika's dataset and confirm self-harm events and dates match   
			mmerge patient using "$temp/analyseWide_vws", ukeep(Self_harm_y eSdate_sh1)
			replace Self_harm_y = 0 if Self_harm_y ==.
			assert Self_harm_y == ish 
			tab Self_harm_y ish, mi
			assert eSdate == eSdate_sh1
			
		* Ensure everyone is there 
			count if ish != 1 & Self_harm ==1
			format eSdate_sh1 %tdD_m_CY
			*listif patient start10 end death_d cod1 eSdate ish eSdate_sh1 Self_harm close_d if ish != 1 & Self_harm ==1, id(patient) sort(patient) seed(1) n(5) global(j)
			
	* Clean 
		keep patient patient start start10 end enrScheme curScheme birth_d sex age_start age_start_cat maxFup age_end age_end_cat ///
			 linked death_y death_d cod1 cod2 fup ish1_d ish1_code ish1_n ish1_y popgrp eSdate eEdate eEvent eIntent eSource ish 
			
	* Baseline year  
		gen year = year(start10)
		recode year (2011=1 "2011") (2012/2016 =2 "2012-2016") (2017/max =3 "2017-2021"), gen(year_cat) test
		
	* Age 
		recode age_start (min/14 =1 "10-14") (15/19 =2 "15-19") (20/39 =3 "20-39") (40/59 =4 "40-59") (60/max =5 "60+"), gen(age_start_cat5) test
		assert age_start_cat5 !=.
		
	* Suicides 
		gen diff = death_d - eEdate 
		gen suicide = 1 if diff <=7 & cod2 ==2 & ish == 1 // high
		replace suicide = 0 if suicide ==.
		*replace suicide = 2 if diff <=7 & cod1 ==3 & ish == 1 // moderate
		*replace suicide = 3 if diff <=7 & inlist(cod1, 1, 4) & ish == 1 // low 
	    lab define suicide 1 "Suicide"  0 "Control", replace 
		
	* FUP cat 
     	 egen fup_cat = cut(fup), at(0, 2, 4, 6, 8, 10)
		 label define fup_cat 0 "<2" 2 "2-4" 4 "4-6" 5 "6-8" 8 ">8"
		 label values fup_cat fup_cat
		 tab fup_cat, mi
		 
	* Strata 
		 gen strata = string(age_start_cat5) + "-" + string(fup_cat) + "-" + string(sex) + "-" + string(year_cat)
		 tab strata, mi	
		 
	* Consecutive number within strata by case vs control in random order   
 		set seed 9803415
		gen random = runiform()
		bysort strata ish (random): gen n = _n
		bysort strata ish (random): gen N = _N
		list strata N if n ==1 & ish==1
		count if n ==1 & ish==1
		sort N
		list strata N if n ==1 & ish==0
				
	* Save 
		save "$temp/ISH", replace 
		
	* Cases & Controls
		use "$temp/ISH", clear
		keep if ish ==1
		gen tte = eSdate - start10 
		keep patient strata tte n N
		save "$temp/ISH_1", replace
		
		use "$temp/ISH", clear
		keep if ish ==0
		keep patient strata n N
		save "$temp/ISH_0", replace
			
	* Match controls to ISH cases 
		use "$temp/ISH_1", clear
		rename patient case_id 
		mmerge strata n using "$temp/ISH_0", unmatched(master) ukeep(patient)
		assert _merge ==3
		drop _merge
		rename patient control_1
		replace n = n + N
		mmerge strata n using "$temp/ISH_0", unmatched(master) ukeep(patient)
		assert _merge ==3
		drop _merge
		rename patient control_2
		rename case_id control_0
		drop strata
		gen i = _n
		reshape long control_, i(i) j(j)
		rename control_ patient
		rename j control
		drop i
		assertunique patient
		mmerge patient using "$temp/ISH", unmatched(master)
		assert _merge ==3
		drop _merge
		tab control
		assert tte !=.
			
	* Assign event data for controls: start10 + tte of cases 
		replace eSdate = start10 + tte if eSdate ==. 
		assert eSdate !=.
			
	* Event time under follow-up 
		gen valid = inrange(eSdate, start10, end)
		tab ish valid, mi // not valid for 201 controls 
			
	* Cases with invalid event time set it to 95th percentile of their follow-up time 
		replace eSdate = start10 + ((end - start10)*0.95) if valid ==0 & ish ==0 
		assert inrange(eSdate, start10, end)
		replace tte = (eSdate - start10)/365.25
		sum tte if ish ==1
		sum tte if ish ==0
			
		* Recode ISH: 1=ISH, 2=Control	
			replace ish = 1-ish +1 
			tab ish
			lab define ish 1 "Intentional self-harm" 2 "Control", replace 
			lab val ish ish

		* Follow-up before self-harm, days 
			gen fbs = eSdate-start10
			assert fbs !=.
			sum fbs
			foreach j in 7 30 60 90 {
				gen fbs`j' = fbs >= `j'
				tab fbs`j', mi
			}
			*listif patient start10 fbs eSdate fbs7 if fbs <7, id(patient) sort(patient eSdate) seed(1) n(1)
		
		* Mental Health 
			foreach j in 7 30 90 {
				fdiag md_any`j' using "$source/ICD10_F" if regexm(icd10_code, "F"), n y $studyperiod label("Mental health encounter") refdate(eSdate) refminus(`j') refplus(-1) 
				fdiag md_opd`j' using "$source/ICD10_F" if regexm(icd10_code, "F") & source == 2, n y $studyperiod label("OPD") refdate(eSdate) refminus(`j') refplus(-1) 
				fdiag md_hos`j' using "$source/ICD10_F" if regexm(icd10_code, "F") & source == 3, n y $studyperiod label("Hospital") refdate(eSdate) refminus(`j') refplus(-1) 
			}
			
		* Any visit  
			foreach j in 7 30 90 {
				fdiag any_any`j' using "$source/ICD10", n y $studyperiod label("Any health care encounter") refdate(eSdate) refminus(`j') refplus(-1) 
				fdiag any_opd`j' using "$source/ICD10" if source == 2, n y $studyperiod label("OPD") refdate(eSdate) refminus(`j') refplus(-1) 
				fdiag any_hos`j' using "$source/ICD10" if source == 3, n y $studyperiod label("Hospital") refdate(eSdate) refminus(`j') refplus(-1) 
			}
		
		gen med_id =""
			
		* Medication
			foreach j in 7 30 90 {
				fdrug med_psy`j' using "$source/MED_ATC_N" if regexm(med_id, "^N06A") | regexm(med_id, "^N05A") | regexm(med_id, "^N05B"), n y $studyperiod label("Psychiatric medication claim") refdate(eSdate) refminus(`j') refplus(-1) 
				fdrug med_ad`j' using "$source/MED_ATC_N" if regexm(med_id, "^N06A"), n y $studyperiod label("Antidepressants") refdate(eSdate) refminus(`j') refplus(-1) 
				fdrug med_ap`j' using "$source/MED_ATC_N" if regexm(med_id, "^N05A"), n y $studyperiod label("Antipsychotics") refdate(eSdate) refminus(`j') refplus(-1) 
				fdrug med_anx`j' using "$source/MED_ATC_N" if regexm(med_id, "^N05B"), n y $studyperiod label("Anxiolytics") refdate(eSdate) refminus(`j') refplus(-1) 
			}
			
		foreach j in 7 30 90 {
				lab define med_psy`j'_y 1 "Psychiatric medication claim", replace
			}
			
	save "$clean/hcs", replace
			
	// Table 
	
	* Data 
		 use "$clean/hcs", clear
		 drop if sex ==3
			
	* Table header 
		header ish, saving("$temp/chrPAT") percentformat(%3.1fc) freqlab("N=") clean freqf(%9.0fc) pval stddiff
		
	* Characteristics at the end of follow-up 
		percentages age_start_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Matching characteristics") clean drop("0 1 2 3 4 5 6 7 8") 
		percentages age_start_cat5 ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Age at baseline, years") clean indent(5) chi stddiff
		sumstats age_start ish, append("$temp/chrPAT") format(%3.1fc) clean indent(5) ttest
		percentages sex ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Sex") clean indent(5) chi stddiff
		percentages year_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Baseline year") clean indent(5) chi stddiff
		percentages fup_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Time from baseline to event, years") clean indent(5) chi stddiff
		sumstats tte ish, append("$temp/chrPAT") format(%3.1fc) clean indent(3) ttest 

		percentages age_start_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Health care encounters within 7 days before event") clean drop("0 1 2 3 4 5 6 7 8") 	
		percentages fbs7 ish if fbs7==1 , append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Under follow-up ≥7 days before event: denominator") clean indent(3) chi drop(0 1) columntotals
		
		percentages any_any7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages any_opd7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages any_hos7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff	
		
		percentages md_any7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages md_opd7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages md_hos7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff

		percentages med_psy7_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages med_ad7_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages med_anx7_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff	
		percentages med_ap7_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff	
		
		percentages age_start_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Health care encounters within 30 days before event") clean drop("0 1 2 3 4 5 6 7 8") 	
		percentages fbs30 ish if fbs30==1 , append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Under follow-up ≥30 days before event: denominator") clean indent(3) chi drop(0 1) columntotals
		
		percentages any_any30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages any_opd30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages any_hos30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
		percentages md_any30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages md_opd30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages md_hos30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff	
		
		percentages med_psy30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages med_ad30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages med_anx30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		percentages med_ap30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
		percentages age_start_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Health care encounters within 90 days before event") clean drop("0 1 2 3 4 5 6 7 8") 	
		percentages fbs90 ish if fbs90==1 , append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Under follow-up ≥90 days before event: denominator") clean indent(3) chi drop(0 1) columntotals
		
		percentages any_any90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages any_opd90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages any_hos90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
		percentages md_any90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages md_opd90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages md_hos90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	 stddiff
		
		percentages med_psy90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages med_ad90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages med_anx90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	 stddiff
		percentages med_ap90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
	* Encounters by type 
		gen reason1 = substr(any_any30_code, 1, 1)
		gen reason3 = substr(any_any30_code, 1, 3)
		gen reason5 = substr(any_any30_code, 1, 5)
		
		tab reason5, sort
		
	* Load and prepare table for export 
		tblout using "$temp/chrPAT", clear merge align format("%25s")
		
		drop pvalue
		replace stddiff = "" if stddiff == "."
							   
	* Create word table 
		capture putdocx clear
		putdocx begin, font("Arial", 8) 
		putdocx paragraph, spacing(after, 0)
		putdocx text ("Table SX: Health care utilization before intentional self-harm encounters compared to matched controls before hypothetical encounter dates"), font("Arial", 9, black) bold 
		putdocx table tbl1 = data(*), border(all, nil) border(top, single) border(bottom, single) layout(autofitcontent) 
		putdocx table tbl1(., .), halign(right)  font("Arial", 8)
		putdocx table tbl1(., 1), halign(left)  
		putdocx table tbl1(1, .), halign(center) bold 
		putdocx table tbl1(2, .), halign(center)  border(bottom, single)
		putdocx pagebreak
		putdocx save "$tables/SX.docx", replace
	
		
* Healthcare encounters before suicide 
		
	* Match controls to suicide cases 
		
		* Cases & Controls
		use "$temp/ISH", clear
		keep if suicide ==1
		gen tte = eSdate - start10 
		keep patient strata tte n N
		save "$temp/S_1", replace
		
		use "$temp/ISH", clear
		drop if ish ==1 | suicide ==1
		keep patient strata n N
		save "$temp/S_0", replace
			
	* Match controls to ISH cases 
		use "$temp/S_1", clear
		rename patient case_id 
		mmerge strata n using "$temp/S_0", unmatched(master) ukeep(patient)
		assert _merge ==3
		drop _merge
		rename patient control_1
		
		forvalues j = 2/20 {
			replace n = n + N
			mmerge strata n using "$temp/S_0", unmatched(master) ukeep(patient)
			assert _merge ==3
			drop _merge
			rename patient control_`j'
		}
		
		rename case_id control_0
		drop strata
		gen i = _n
		reshape long control_, i(i) j(j)
		rename control_ patient
		rename j control
		drop i
		assertunique patient
		mmerge patient using "$temp/ISH", unmatched(master)
		assert _merge ==3
		drop _merge
		tab control
		assert tte !=.
			
	* Assign event data for controls: start10 + tte of cases 
		replace eSdate = start10 + tte if eSdate ==. 
		assert eSdate !=.
			
	* Event time under follow-up 
		gen valid = inrange(eSdate, start10, end)
		tab ish valid, mi // not valid for 201 controls 
			
	* Cases with invalid event time set it to 95th percentile of their follow-up time 
		replace eSdate = start10 + ((end - start10)*0.95) if valid ==0 & ish ==0 
		assert inrange(eSdate, start10, end)
		replace tte = (eSdate - start10)/365.25
		sum tte if ish ==1
		sum tte if ish ==0
			
		* Recode ISH: 1=ISH, 2=Control	
			replace ish = 1-ish +1 
			tab ish
			lab define ish 1 "Intentional self-harm" 2 "Control", replace 
			lab val ish ish

		* Follow-up before self-harm, days 
			gen fbs = eSdate-start10
			assert fbs !=.
			sum fbs
			foreach j in 7 30 60 90 {
				gen fbs`j' = fbs >= `j'
				tab fbs`j', mi
			}
			*listif patient start10 fbs eSdate fbs7 if fbs <7, id(patient) sort(patient eSdate) seed(1) n(1)
		
		* Mental Health 
			foreach j in 7 30 90 {
				fdiag md_any`j' using "$source/ICD10_F" if regexm(icd10_code, "F"), n y $studyperiod label("Mental health encounter") refdate(eSdate) refminus(`j') refplus(-1) 
				fdiag md_opd`j' using "$source/ICD10_F" if regexm(icd10_code, "F") & source == 2, n y $studyperiod label("OPD") refdate(eSdate) refminus(`j') refplus(-1) 
				fdiag md_hos`j' using "$source/ICD10_F" if regexm(icd10_code, "F") & source == 3, n y $studyperiod label("Hospital") refdate(eSdate) refminus(`j') refplus(-1) 
			}
			
		* Any visit  
			foreach j in 7 30 90 {
				fdiag any_any`j' using "$source/ICD10", n y $studyperiod label("Any health care encounter") refdate(eSdate) refminus(`j') refplus(-1) 
				fdiag any_opd`j' using "$source/ICD10" if source == 2, n y $studyperiod label("OPD") refdate(eSdate) refminus(`j') refplus(-1) 
				fdiag any_hos`j' using "$source/ICD10" if source == 3, n y $studyperiod label("Hospital") refdate(eSdate) refminus(`j') refplus(-1) 
			}
		
		gen med_id =""
			
		* Medication
			foreach j in 7 30 90 {
				fdrug med_psy`j' using "$source/MED_ATC_N" if regexm(med_id, "^N06A") | regexm(med_id, "^N05A") | regexm(med_id, "^N05B"), n y $studyperiod label("Psychiatric medication claim") refdate(eSdate) refminus(`j') refplus(-1) 
				fdrug med_ad`j' using "$source/MED_ATC_N" if regexm(med_id, "^N06A"), n y $studyperiod label("Antidepressants") refdate(eSdate) refminus(`j') refplus(-1) 
				fdrug med_ap`j' using "$source/MED_ATC_N" if regexm(med_id, "^N05A"), n y $studyperiod label("Antipsychotics") refdate(eSdate) refminus(`j') refplus(-1) 
				fdrug med_anx`j' using "$source/MED_ATC_N" if regexm(med_id, "^N05B"), n y $studyperiod label("Anxiolytics") refdate(eSdate) refminus(`j') refplus(-1) 
			}
			
		foreach j in 7 30 90 {
				lab define med_psy`j'_y 1 "Psychiatric medication claim", replace
			}
			
	save "$clean/hcs", replace
			
	// Table 
	
	* Data 
		 use "$clean/hcs", clear
			
	* Table header 
		header ish, saving("$temp/chrPAT") percentformat(%3.1fc) freqlab("N=") clean freqf(%9.0fc) pval stddiff
		
	* Characteristics at the end of follow-up 
		percentages age_start_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Matching characteristics") drop("0 1 2 3 4 5 6 7 8") 
		percentages age_start_cat5 ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Age at baseline, years") indent(5) chi stddiff
		sumstats age_start ish, append("$temp/chrPAT") format(%3.1fc) clean indent(5) ttest 
		percentages sex ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Sex") clean indent(5) chi stddiff
		percentages year_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Baseline year") clean indent(5) chi stddiff 
		percentages fup_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Time from baseline to event, years") clean indent(5) chi stddiff
		sumstats tte ish, append("$temp/chrPAT") format(%3.1fc) clean indent(3) ttest 

		percentages age_start_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Health care encounters within 7 days before event") clean drop("0 1 2 3 4 5 6 7 8") 	
		percentages fbs7 ish if fbs7==1 , append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Under follow-up ≥7 days before event: denominator") indent(3) chi drop(0 1) columntotals clean
		
		percentages any_any7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages any_opd7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages any_hos7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		
		percentages md_any7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages md_opd7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages md_hos7_y ish if fbs7==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff	

		percentages med_psy7_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages med_ad7_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages med_anx7_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff	 
		percentages med_ap7_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff	
		
		percentages age_start_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Health care encounters within 30 days before event") clean drop("0 1 2 3 4 5 6 7 8") 	
		percentages fbs30 ish if fbs30==1 , append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Under follow-up ≥30 days before event: denominator") clean indent(3) chi drop(0 1) columntotals
		
		percentages any_any30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages any_opd30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages any_hos30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
		percentages md_any30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages md_opd30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages md_hos30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
		percentages med_psy30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages med_ad30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages med_anx30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		percentages med_ap30_y ish if fbs30==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
		percentages age_start_cat ish, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Health care encounters within 90 days before event") clean drop("0 1 2 3 4 5 6 7 8") 	
		percentages fbs90 ish if fbs90==1 , append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Under follow-up ≥90 days before event: denominator") clean indent(3) chi drop(0 1) columntotals
		
		percentages any_any90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages any_opd90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages any_hos90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
		percentages md_any90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages md_opd90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages md_hos90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
		percentages med_psy90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(3) chi noheading drop(0) plevel(1) stddiff
		percentages med_ad90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1) stddiff
		percentages med_anx90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		percentages med_ap90_y ish if fbs90==1, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) chi noheading drop(0) plevel(1)	stddiff
		
	* Encounters by type 
		gen reason1 = substr(any_any30_code, 1, 1)
		gen reason3 = substr(any_any30_code, 1, 3)
		gen reason5 = substr(any_any30_code, 1, 5)
		
		tab reason5, sort
		
	* Load and prepare table for export 
		tblout using "$temp/chrPAT", clear merge align format("%25s")
		drop pvalue
		replace stddiff = "" if stddiff == "."
							   
	* Create word table 
		capture putdocx clear
		putdocx begin, font("Arial", 8) 
		putdocx paragraph, spacing(after, 0)
		putdocx text ("Table SX: Health care utilization before intentional self-harm encounters compared to matched controls before hypothetical encounter dates"), font("Arial", 9, black) bold 
		putdocx table tbl1 = data(*), border(all, nil) border(top, single) border(bottom, single) layout(autofitcontent) 
		putdocx table tbl1(., .), halign(right)  font("Arial", 8)
		putdocx table tbl1(., 1), halign(left)  
		putdocx table tbl1(1, .), halign(center) bold 
		putdocx table tbl1(2, .), halign(center)  border(bottom, single)
		putdocx pagebreak
		putdocx save "$tables/SX.docx", replace
	