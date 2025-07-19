*** Self-harm
	global studyperiod "mindate(`=d(01/01/2011)') maxdate($cdate)" 
	
* Diagnoses 
	fdiag shDiag using "$source/ICD10_V00-Y99" if regexm(icd10_code, "X[6-7]") | regexm(icd10_code, "X8[0-4]"),  $studyperiod n y censor(end) minage(10) code
	fdiag shHosDiag using "$source/ICD10_V00-Y99" if (regexm(icd10_code, "X[6-7]") | regexm(icd10_code, "X8[0-4]") ) & source==3,  $studyperiod n y censor(end) minage(10)
	fdiag shOpdDiag using "$source/ICD10_V00-Y99" if (regexm(icd10_code, "X[6-7]") | regexm(icd10_code, "X8[0-4]") ) & source==2,  $studyperiod n y censor(end) minage(10)
	
* History of self-harm
	fdiag shHist using "$source/ICD10_Z" if regexm(icd10_code, "Z91.5"),  $studyperiod n y censor(end) minage(10)
	
* Event of undetermined intent   	
	fdiag eui using "$source/ICD10_V00-Y99" if regexm(icd10_code, "Y[1-2]") | regexm(icd10_code, "Y3[0-4]"),  $studyperiod n y censor(end) minage(10)
	
* Attempter (y/n)
	egen byte sh = rowmax(shDiag_y shHist_y)
	replace sh = 3 if sh ==0
	replace sh = 2 if sh ==3 & eui_y ==1
	lab define sh 1 "Intentional self-harm event" 2 "Event of undetermined intent" 3 "No event", replace
	lab val sh sh
	tab sh, mi
	
