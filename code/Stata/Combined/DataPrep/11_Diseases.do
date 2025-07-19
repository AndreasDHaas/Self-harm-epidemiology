* Study period 
	global studyperiod "mindate(`=d(01/01/2011)') maxdate($cdate)" 
	
	* ISH 
		fdiag ish1 using "$source/ICD10_V00-Y99_Z" if regexm(icd10_code, "X[6-7]") | regexm(icd10_code, "X8[0-4]"), n y $studyperiod label("Intentional self-harm") minage(10) 

* Mental disorders 

	* Any mental disorder 
		fdiag md1 using "$source/ICD10_F" if regexm(icd10_code, "F"), n y $studyperiod label("Any mental disorder") censor(end) minage(10)
			
		* F0-F9
			fdiag org1 using "$source/ICD10_F" if regexm(icd10_code, "F0"), n y $studyperiod label("Organic mental disorder") censor(end) minage(10)
			fdiag su1 using "$source/ICD10_F" if regexm(icd10_code, "F1[0-6]") | regexm(icd10_code, "F1[8-9]") , n y $studyperiod label("Substance use disorder") censor(end) minage(10)
			fdiag psy1 using "$source/ICD10_F" if regexm(icd10_code, "F2"), n y $studyperiod label("Psychotic disorder") censor(end) minage(10)
			fdiag mood1 using "$source/ICD10_F" if regexm(icd10_code, "F3"), n y $studyperiod label("Mood disorder") censor(end) minage(10)
			fdiag anx1 using "$source/ICD10_F" if regexm(icd10_code, "F4"), n y $studyperiod label("Anxiety disorder") censor(end) minage(10)
			fdiag bhs1 using "$source/ICD10_F" if regexm(icd10_code, "F5"), n y $studyperiod label("Behavioural syndromes associated with physical factors") censor(end) minage(10)
			fdiag per1 using "$source/ICD10_F" if regexm(icd10_code, "F6"), n y $studyperiod label("Personality disorders") censor(end) minage(10)
			fdiag int1 using "$source/ICD10_F" if regexm(icd10_code, "F7"), n y $studyperiod label("Intellectual disabilities") censor(end) minage(10)
			fdiag dev1 using "$source/ICD10_F" if regexm(icd10_code, "F8"), n y $studyperiod label("Developmental disorders") censor(end) minage(10)
			fdiag bhd1 using "$source/ICD10_F" if regexm(icd10_code, "F9[0-8]"), n y $studyperiod label("Behavioural disorders") censor(end) minage(10)
				
		* Sub-categories 
			fdiag alc1 using "$source/ICD10_F" if regexm(icd10_code, "F10"), n y $studyperiod label("Alcohol use disorder") censor(end) minage(10)
			fdiag drug1 using "$source/ICD10_F" if regexm(icd10_code, "F1[1-6]") | regexm(icd10_code, "F1[8-9]"), n y $studyperiod label("Drug use disorder") censor(end) minage(10)
			fdiag bp1 using "$source/ICD10_F" if regexm(icd10_code, "F31"), n y $studyperiod label("Bipolar disorder") censor(end) minage(10)
			fdiag dep1 using "$source/ICD10_F" if regexm(icd10_code, "F3[2-3]") | regexm(icd10_code, "F34.1"), n y $studyperiod label("Depression") censor(end) minage(10)
			fdiag panic1 using "$source/ICD10_F" if regexm(icd10_code, "F41.0"), n y $studyperiod label("Panic disorder") censor(end) minage(10)
			fdiag gad1 using "$source/ICD10_F" if regexm(icd10_code, "F41.1"), n y $studyperiod label("Generalised anxiety disorder") censor(end) minage(10)
			fdiag ad1 using "$source/ICD10_F" if regexm(icd10_code, "F41.2"), n y $studyperiod label("Mixed anxiety and depressive disorder") censor(end) minage(10) 
			fdiag ptsd1 using "$source/ICD10_F" if regexm(icd10_code, "F43.1"), n y $studyperiod label("Post-traumatic stress disorder") censor(end) minage(10)
			fdiag ed1 using "$source/ICD10_F" if regexm(icd10_code, "F50"), n y $studyperiod label("Eating disorder") censor(end) minage(10)
			fdiag sd1 using "$source/ICD10_F" if regexm(icd10_code, "F51"), n y $studyperiod label("Sleep disorder") censor(end) minage(10)

	* History of self-harm
		fdiag shHist using "$source/ICD10_Z" if regexm(icd10_code, "Z91.5"),  $studyperiod n y censor(end) minage(10)
		

if "$cohort" == "AfAc" {
		
* HIV 
	
	* Diagnoses 
		fdiag hivDiag using "$source/ICD10_HIV" if regexm(icd10_code, "B2[0-4]") | regexm(icd10_code, "Z21") | regexm(icd10_code, "R75") | regexm(icd10_code, "O98.7"),  $studyperiod n y censor(end) minage(10)
														
	* Medication								   PIs | NNRTIs | NRTIs|                  IIs    |        ARV combinations   &  NOT     TDF/FTC  |   TAF     |   FTC   |    3TC  (used in PrEP)    
		fdrug hivMed using "$source/MED_ATC_J" ///
									if ((regexm(med_id, "J05A[E-G]") |  regexm(med_id, "J05AJ") |  regexm(med_id, "J05AR")) & !inlist(med_id, "J05AR03", "J05AF13", "J05AF09", "J05AF05")), /// 
									$studyperiod n y censor(end)	minage(10)
										
	* Laboratory tests 
	
		* HIV viral load test 
			flab rna using "$source/HIV_RNA" if lab_id =="HIV_RNA" & lab_v !=., $studyperiod n y censor(end) minage(10)
			
		* CD4 count or percent 
			flab cd4 using "$source/CD4_A" if lab_v !=.,  $studyperiod n y censor(end) minage(10)
			
		* Positive HIV test: todo remove screening tests 
			flab hivPos using "$source/HIV_TEST" if lab_id =="HIV_TEST" & lab_v ==1,  $studyperiod n y censor(end) minage(10)
			
	* HIV definitions 
	
		* Version 1: low certainty 
		
			* Generate variables 
				egen hiv1_n = rowtotal(hivDiag_n hivMed_n rna_n cd4_n hivPos_n afa) 
				egen hiv1_d = rowmin(hivDiag_d hivMed_d rna_d cd4_d hivPos_d) 
				format hiv1_d %tdD_m_CY
				egen hiv1_y = rowmax(hivDiag_y hivMed_y rna_y cd4_y hivPos_y afa)
	
			* Asserts 
				assert inrange(hiv1_d, `=d(01/01/2011)', $close_d) if hiv1_d !=. 
				assert inlist(hiv1_y, 0, 1)
				assert hiv1_y == 1 if hiv1_d !=.
				count if hiv1_d ==. & hiv1_y == 1 // !!! AfA members wihtout other HIV indicator have missing hiv_d !!! 
				assert hiv1_d ==. if hiv1_y == 0		
				lab define hiv 1 "HIV", replace
				lab val hiv1_y hiv
				
				

}
else if "$cohort" == "AfA" {
}
else {
	di in red "Cohort is neither AfA nor AfAc"
	error 614
}
				
	* Closing date 
		gen close_d = $close_d 
		format close_d %tdD_m_CY
				
* Save 
	save "$clean/analyseWide", replace				
