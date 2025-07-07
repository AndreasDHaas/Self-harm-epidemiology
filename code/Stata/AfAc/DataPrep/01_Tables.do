	
* Combine tables with HIV diagnoses 
	use "$source/ICD10_AB", clear
	append using "$source/ICD10_Z"
	append using "$source/ICD10_R"
	append using "$source/ICD10_O"
	append using "$source/ICD10_C00-D49"
	save "$source/ICD10_HIV", replace
		
* Combine self-harm tables 
	use "$source/ICD10_Z", clear
	append using "$source/ICD10_V00-Y99"
	save "$source/ICD10_V00-Y99_Z", replace	