* Mental disorders 

	* Any mental disorder 
		fdiag md1 using "$source/ICD10_F" if regexm(icd10_code, "F"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Any mental disorder") censor(end) 
			
		* F0-F9
			fdiag org1 using "$source/ICD10_F" if regexm(icd10_code, "F0"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Organic mental disorder") censor(end)
			fdiag su1 using "$source/ICD10_F" if regexm(icd10_code, "F1[0-6]") | regexm(icd10_code, "F1[8-9]") , n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Substance use disorder") censor(end)
			fdiag psy1 using "$source/ICD10_F" if regexm(icd10_code, "F2"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Psychotic disorder") censor(end)
			fdiag mood1 using "$source/ICD10_F" if regexm(icd10_code, "F3"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Mood disorder") censor(end)
			fdiag anx1 using "$source/ICD10_F" if regexm(icd10_code, "F4"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Anxiety disorder") censor(end)
			fdiag bhs1 using "$source/ICD10_F" if regexm(icd10_code, "F5"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Behavioural syndromes associated with physical factors") censor(end)
			fdiag per1 using "$source/ICD10_F" if regexm(icd10_code, "F6"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Personality disorders") censor(end)
			fdiag int1 using "$source/ICD10_F" if regexm(icd10_code, "F7"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Intellectual disabilities") censor(end)
			fdiag dev1 using "$source/ICD10_F" if regexm(icd10_code, "F8"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Developmental disorders") censor(end)
			fdiag bhd1 using "$source/ICD10_F" if regexm(icd10_code, "F9[0-8]"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Behavioural disorders") censor(end)
				
		* Sub-categories 
			fdiag alc1 using "$source/ICD10_F" if regexm(icd10_code, "F10"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Alcohol use disorder") censor(end)
			fdiag drug1 using "$source/ICD10_F" if regexm(icd10_code, "F1[1-6]") | regexm(icd10_code, "F1[8-9]"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Drug use disorder") censor(end)
			fdiag bp1 using "$source/ICD10_F" if regexm(icd10_code, "F31"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Bipolar disorder") censor(end)
			fdiag dep1 using "$source/ICD10_F" if regexm(icd10_code, "F3[2-3]") | regexm(icd10_code, "F34.1"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Depression") censor(end)
			fdiag panic1 using "$source/ICD10_F" if regexm(icd10_code, "F41.0"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Panic disorder") censor(end)
			fdiag gad1 using "$source/ICD10_F" if regexm(icd10_code, "F41.1"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Generalised anxiety disorder") censor(end)
			fdiag ad1 using "$source/ICD10_F" if regexm(icd10_code, "F41.2"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Mixed anxiety and depressive disorder") censor(end) 
			fdiag ptsd1 using "$source/ICD10_F" if regexm(icd10_code, "F43.1"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Post-traumatic stress disorder") censor(end)
			fdiag ed1 using "$source/ICD10_F" if regexm(icd10_code, "F50"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Eating disorder") censor(end)
			fdiag sd1 using "$source/ICD10_F" if regexm(icd10_code, "F51"), n y mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') label("Sleep disorder") censor(end)


	* HIV 
	
		* Diagnoses 
			fdiag hivDiag using "$clean/ICD10_HIV" if regexm(icd10_code, "B2[0-4]") | regexm(icd10_code, "Z21") | regexm(icd10_code, "R75") | regexm(icd10_code, "O98.7") ///
														,  mindate(`=d(01/01/2011)') maxdate(`=d(30/06/2020)') n y censor(end)
														
		* Medication								   PIs | NNRTIs | NRTIs|                  IIs    |        ARV combinations   &  NOT     TDF/FTC  |   TAF     |   FTC   |    3TC  (used in PrEP)    
			fdrug hivMed using "$clean/MED_ATC_J" ///
										if ((regexm(med_id, "J05A[E-G]") |  regexm(med_id, "J05AJ") |  regexm(med_id, "J05AR")) & !inlist(med_id, "J05AR03", "J05AF13", "J05AF09", "J05AF05")), /// 
										mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') n y censor(end)	
										
		* Laboratory tests 
		
			* HIV viral load test 
				flab rna using "$clean/HIV_RNA" if lab_id =="HIV_RNA" & lab_v !=., mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') n y censor(end)
				
			* CD4 count or percent 
				flab cd4 using "$clean/CD4_A" if lab_v !=.,  mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') n y censor(end)
				
			* Positive HIV test: todo remove screening tests 
				flab hivPos using "$clean/HIV_TEST" if lab_id =="HIV_TEST" & lab_v ==1,  mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') n y censor(end)
				
		* HIV definitions 
		
			* Version 1: low certainty 
			
				* Generate variables 
					egen hiv1_n = rowtotal(hivDiag_n hivMed_n rna_n cd4_n hivPos_n afa) 
					egen hiv1_d = rowmin(hivDiag_d hivMed_d rna_d cd4_d hivPos_d) 
					format hiv1_d %tdD_m_CY
					egen hiv1_y = rowmax(hivDiag_y hivMed_y rna_y cd4_y hivPos_y afa)
		
				* Asserts 
					assert inrange(hiv1_d, `=d(01/01/2011)', `=d(01/07/2020)') if hiv1_d !=. 
					assert inlist(hiv1_y, 0, 1)
					assert hiv1_y == 1 if hiv1_d !=.
					count if hiv1_d ==. & hiv1_y == 1 // !!! AfA members wihtout other HIV indicator have missing hiv_d !!! 
					*replace hiv1_d = start if hiv1_d ==. & hiv1_y==1 ---> set HIV positive date to start of follow-up or impute hiv1_d dates <---
					assert hiv1_d ==. if hiv1_y == 0					
				
	
* Save 
	save "$clean/analyseWide", replace				