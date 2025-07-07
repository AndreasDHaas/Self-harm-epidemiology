	
		
* Combine self-harm tables 
	use "$source/ICD10_Z", clear
	append using "$source/ICD10_V00-Y99"
	save "$source/ICD10_V00-Y99_Z", replace	