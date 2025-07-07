* Characteristics of participants included and excluded in mortality anylysis 

	*Baseline table 
		use "$clean/analyseWide", clear
		drop if sex ==3
		tab linked, mi
		replace linked = 2 if linked ==0
		lab define linked 1 "Included" 2 "Excluded", replace
		lab val linked linked
		recode age_start (min/14 =1 "10-14") (15/24 =2 "15-24") (25/39 =3 "25-39") (40/max =4 "40+"), gen(age_start_cat4) test
		assert age_start_cat4 !=.
		lab define hiv1_y 0 "HIV-negative" 1 "HIV-positive", replace
		lab val hiv1_y hiv1_y
		
	* Table header 
		header linked, saving("$temp/chrPAT") percentformat(%3.1fc) freqlab("N=") clean freqf(%9.0fc) stddiff
		
	* Characteristics at the end of follow-up 
		percentages age_start_cat linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Characteristics at baseline") clean drop("0 1 2 3 4 5 6 7 8") 
		percentages sex linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("  Sex") clean indent(5) stddiff
		
		percentages age_start_cat4 linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("   Age, years") clean indent(5) stddiff
		sumstats age_start linked, append("$temp/chrPAT") format(%3.1fc) clean indent(5) stddiff
		
	* Characteristics at the end of follow-up 
		percentages age_start_cat linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) heading("Characteristics at the end of follow-up") clean drop("0 1 2 3 4 5 6 7 8") 
		percentages hiv1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean indent(5) stddiff heading("   HIV status")
		
		* Psychiatric comorbidity: low certainty
			percentages md1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean drop("0")	indent(3) noheading stddiff
			percentages org1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) clean drop("0")	indent(5) noheading		stddiff
			percentages su1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) noheading clean drop("0") indent(5) stddiff
			percentages psy1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) noheading clean drop("0") indent(5) stddiff	
			percentages bp1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) noheading clean drop("0") indent(5) stddiff
			percentages dep1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) noheading clean drop("0") indent(5) stddiff
			percentages anx1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) noheading clean drop("0") indent(5) stddiff	
			percentages per1_y linked, append("$temp/chrPAT") percentformat(%3.1fc) freqf(%9.0fc) noheading clean drop("0") indent(5) stddiff 

	* Follow-up time
		sumstats fup linked, append("$temp/chrPAT") format(%3.1fc) mean heading("   Follow-up time, years") clean indent(5) stddiff
		
	* Load and prepare table for export 
		tblout using "$temp/chrPAT", clear merge align format("%25s")
		replace stddiff = "" if stddiff =="."
							   
	* Create word table 
		capture putdocx clear
		putdocx begin, font("Arial", 8) landscape
		putdocx paragraph, spacing(after, 0)
		putdocx text ("Table E. Characteristics of the study population included and excluded from the mortality analysis "), font("Arial", 9, black) bold 
		putdocx table tbl1 = data(*), border(all, nil) border(top, single) border(bottom, single) layout(autofitcontent) 
		putdocx table tbl1(., .), halign(right)  font("Arial", 8)
		putdocx table tbl1(., 1), halign(left)  
		putdocx table tbl1(1, .), halign(center) bold 
		putdocx table tbl1(2, .), halign(center)  border(bottom, single)
		putdocx pagebreak
		putdocx save "$tables/Table E.docx", replace		
		