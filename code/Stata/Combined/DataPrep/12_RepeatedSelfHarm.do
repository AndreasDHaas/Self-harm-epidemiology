*** Repeated self-harm events

* Define study period 
	global studyperiod "mindate(`=d(01/01/2011)') maxdate($cdate)" 
		
* Repeated events 

	* Diagnoses 
		use "$source/ICD10_V00-Y99_Z", clear
		keep if regexm(icd10_code, "X[6-7]") | regexm(icd10_code, "X8[0-4]") | ///
		regexm(icd10_code, "Y[1-2]") | regexm(icd10_code, "Y3[0-4]") 
		rename icd10_date date 
		
	* Select relevant diagnoses 
		drop if age < 10  // minage 
		drop if age > 100 & age !=. // maxage 
		drop if date < d(01/01/2011) // mindate
		drop if date > $close_d & date !=. // maxdate
		
	* Checks	
		assert date!=.
		assert patient !=""
		sort patient date

	* ICD10 3 digits
		gen icd10_3 = substr(icd10_code, 1, 3)
		tab icd10_3, sort
		
	* ICD10 2 digits
		gen icd10_2 = substr(icd10_code, 1, 2)
		tab icd10_2, sort
		
	* Source 
		gen temp = 4-source
		lab define source 1 "HOS" 2 "OPD" 3 "MED", replace
		lab val temp source
		drop source
		rename temp source
				
	* Intent 
		gen intent = regexm(icd10_code, "X[6-7]") | regexm(icd10_code, "X8[0-4]") | regexm(icd10_code, "Y87.0") 
		replace intent = 2 if intent ==0
		lab define intent 1 "Self-harm" 2 "Undetermined", replace  
		lab val intent intent
		
	* Discharge date 
		format discharge_date %tdCCYY-NN-DD
		
	* Type of event: 	
	
		* Event: prioritise more lethal and determined events: firearms, drowning, hanging, poison by gas, jump, other drug, cut 
		* Spicer, R.S. and Miller, T.R. Suicide acts in 8 states: incidence and case fatality rates by demographics and method. 
		* American Journal of Public Health. 2000:90(12);1885.) https://ijmhs.biomedcentral.com/articles/10.1186/1752-4458-8-54/tables/1   
		
		* Sort 
			sort patient date
			
		* Intentional self-harm by firearms or explosive
			gen event = 101 if regexm(icd10_code, "X[7][2-5]") 	
				
		* Intentional self-harm by drowning and submersion
			replace event = 102 if regexm(icd10_code, "X71") 	
			
		* Intentional self-harm by hanging, strangulation and suffocation
			replace event = 103 if regexm(icd10_code, "X70") 
			
		* Intention self-poisoning exposure to gases
			replace event = 104 if regexm(icd10_code, "X[6][7]") 
	
		*  Intentional self-harm by jumping from a high place, or before moving object
			replace event = 105 if regexm(icd10_code, "X[8][0-1]") 			
	
		* Intentional self-harm by smoke, fire and flames
			replace event = 106 if regexm(icd10_code, "X76") 	

		* Intentional self-harm by crashing of motor vehicle
			replace event = 107 if regexm(icd10_code, "X82") 	
			
		* Intentional self-harm by steam, hot vapours and hot objects
			replace event = 108 if regexm(icd10_code, "X77") 	

		* Intention self-poisoning 
			replace event = 109 if regexm(icd10_code, "X[6][0-6]")  | regexm(icd10_code, "X[6][8-9]") 
			
		* Intentional self-harm by sharp object
			replace event = 110 if regexm(icd10_code, "X78") 
			
		* Intentional self-harm by blunt object
			replace event = 111 if regexm(icd10_code, "X79")
			
 		* Intentional self-harm by other or unspecified means
			replace event = 112 if regexm(icd10_code, "X[8][3-4]") 					

		
		* Undetermined intent, firearms or explosives
			replace event = 201 if regexm(icd10_code, "Y[2][2-5]") 	
							
		* Undetermined intent, drowning and submersion
			replace event = 202 if regexm(icd10_code, "Y21") 	
			
		* Undetermined intent, hanging, strangulation and suffocation
			replace event = 203 if regexm(icd10_code, "Y20") 			
			
		* Undetermined intent, poisoning exposure to gases
			replace event = 204 if regexm(icd10_code, "Y[1][7]") 	
		
		*  Undetermined intent, jumping from a high place, or before moving object
			replace event = 205 if regexm(icd10_code, "Y[3][0-1]") 						
			
		* Undetermined intent, smoke, fire and flames
			replace event = 206 if regexm(icd10_code, "Y26") 	
					
		* Undetermined intent, crashing of motor vehicle
			replace event = 207 if regexm(icd10_code, "Y32") 
			
		* Undetermined intent, steam, hot vapours and hot objects
			replace event = 208 if regexm(icd10_code, "Y27") 	
			
		* Undetermined intent, self-poisoning  
			replace event = 209 if regexm(icd10_code, "Y[1][0-6]")  | regexm(icd10_code, "Y[1][8-9]") 
			
		* Undetermined intent, sharp object
			replace event = 210 if regexm(icd10_code, "Y28") 
			
		* Undetermined intent, blunt object
			replace event = 211 if regexm(icd10_code, "Y29") 		
			
		* Undetermined intent, other or unspecified event
			replace event = 212 if regexm(icd10_code, "Y[3][3-4]") 		
			
		* Label 
			lab define event ///
			101 "Intentional self-harm by firearms or explosives" ///
			102 "Intentional self-harm by drowning and submersion" ///
			103 "Intentional self-harm by hanging, strangulation and suffocation" ///
			104 "Intentional self-poisoning by exposure to gases" ///
			105 "Intentional self-harm by jumping from a high place, or before moving object" ///
			106 "Intentional self-harm by smoke, fire and flames" ///
			107 "Intentional self-harm by crashing of motor vehicle" ///
			108 "Intentional self-harm by steam, hot vapours and hot objects" ///
			109 "Intentional self-poisoning other than gas" ///
			110 "Intentional self-harm by sharp object" ///
			111 "Intentional self-harm by blunt object" ///
			112 "Intentional self-harm by other or unspecified means" ///
			201 "Undetermined intent, firearms or explosives" ///
			202 "Undetermined intent, drowning and submersion" ///
			203 "Undetermined intent, hanging, strangulation and suffocation" ///
			204 "Undetermined intent, poisoning by exposure to gases" ///
			205 "Undetermined intent, jumping from a high place, or before moving object" ///
			206 "Undetermined intent, smoke, fire and flames" ///
			207 "Undetermined intent, crashing of motor vehicle" ///
			208 "Undetermined intent, steam, hot vapours and hot objects" ///
			209 "Undetermined intent, poisoning other than gas" ///
			210 "Undetermined intent, sharp object" ///
			211 "Undetermined intent, blunt object" ///
			212 "Undetermined intent, other or unspecified event" ///
			, replace 
			lab val event event		
			assert event !=.
								
			listif patient date icd10_code intent event source discharge_date code_role if icd10_code =="Z91.5", sepby(patient) sort(patient date) seed(2) n(20) id(patient)
		
	* Save 
		save "$clean/eventsLong", replace

