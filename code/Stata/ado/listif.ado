* Listif - List values of variables of all records of a random sample of patients if expression is true. 
	* syntax [varlist] [if] [in], ID(varname) SORT(varlist) [ SEPBY(varlist) N(integer) SEED(integer) ] 
	* if no varlist is specified, the values of all the variables are displayed
	* Options:  
		* id(varname); required patient identifier 
		* sort(varlist); required; determines sorting of listif
		* sepby(varlist); optional; specifies that a separator line be drawn whenever any of the variables in sepby(varlist2) change their values
		* n(integer); optional; default is 10 
		* seed(integer); optional, seed can not be set to -88888 (used as default)
	* Examples: 
		* listif patient treatment_date nappi_code icd10_code atccode if nappi_code=="800325", id(patient) sort(patient treatment_date nappi_code) sepby(patient treatment_date) n(3) seed(100)
		capture program drop listif
		program define listif
		* version 1.2  27may2022
			version 16
			syntax [varlist] [if] [in], ID(varname)  SORT(varlist) [SEPBY(varlist) N(integer 10) SEED(integer -88888) NOLABel STRING(integer 30) global(string) ]
			marksample touse, novarlist
			if `seed' != -88888 set seed `seed'
			preserve
			qui drop if !`touse'
			* sample 
			tempvar random
			qui gen `random' = runiform()
			qui bysort `id' (`random'): keep if _n ==1
			qui sample `n', count
			qui levelsof `id', clean
			* Global 
			capture confirm numeric variable `id' 
			if !_rc {
				if "`global'" != "" {
					qui levelsof `id', sep(,) clean
					global `global' "`r(levels)'"
				}
			}
			else {
				if "`global'" != "" {
					qui levelsof `id', sep(,)
					global `global' "`r(levels)'"
				}
			}			
			sort `sort'
			restore
			* List 
			capture confirm numeric variable `id' 
			if !_rc {
				foreach j in `r(levels)' {
						list `varlist' if `id' ==`j', sepby(`sepby') `nolabel' string(`string')
				}
			}
			else {
				foreach j in `r(levels)' {
						list `varlist' if `id' =="`j'", sepby(`sepby') `nolabel' string(`string')
				}	
			}			
		end