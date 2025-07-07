
capture program drop normality
program define normality
* version 1.0  AH 2 May 2021 
	syntax varlist(min=1 max=1) [if] [in], [LOG SQRT EXP LOG10 GENerate(string)] 
	token `varlist' 
	marksample touse, novarlist
		preserve
		qui drop if !`touse'
		qui swilk `1'
		local p : di %5.4fc `r(p)'
		tempname untransf
		tempname h_u
		qui hist `1', name(`h_u', replace) scheme(cleanplots) title("Untransformed") nodraw normal
		qnorm `1', name(`untransf', replace) title("Untransformed") subtitle("Shapiro-Wilks test p=`p'") nodraw scheme(cleanplots) ytitle(`1')
		if "`log'" != "" {
			local tempname log
			qui gen `log' = log(`1')
			qui swilk `log'
			local p : di %5.4fc `r(p)'
			qnorm `log', name(log, replace) title("Log-transformed") subtitle("Shapiro-Wilks test p=`p'") nodraw scheme(cleanplots)	ytitle("log `1'")		
			tempname h_log
			qui hist `log', name(`h_log', replace) scheme(cleanplots) title("Log-transformed") nodraw normal
		}
		if "`sqrt'" != "" {
			local tempname sqrt
			qui gen `sqrt' = sqrt(`1')
			qui swilk `sqrt'
			local p : di %5.4fc `r(p)'
			qnorm `sqrt', name(sqrt, replace) title("Square root transformed") subtitle("Shapiro-Wilks test p=`p'") nodraw scheme(cleanplots) ytitle("sqrt `1'")	
			tempname h_sqrt
			qui hist `sqrt', name(`h_sqrt', replace) scheme(cleanplots) title("Square root transformed") nodraw normal
		}
		if "`exp'" != "" {
			local tempname exp
			qui gen `exp' = exp(`1')
			qui swilk `exp'
			local p : di %5.4fc `r(p)'
			qnorm `exp', name(exp, replace) title("Exponentially transformed") subtitle("Shapiro-Wilks test p=`p'") nodraw scheme(cleanplots) ytitle("exp `1'")	
			tempname h_exp
			qui hist `exp', name(`h_exp', replace) scheme(cleanplots) title("Exponentially transformed") nodraw normal
		}
		if "`log10'" != "" {
			local tempname log10
			qui gen `log10' = log10(`1')
			qui swilk `log10'
			local p : di %5.4fc `r(p)'
			qnorm `log10', name(log10, replace) title("Log10-transformed") subtitle("Shapiro-Wilks test p=`p'") nodraw scheme(cleanplots) ytitle("log10 `1'")			
			tempname h_log10
			qui hist `log10', name(`h_log10', replace) scheme(cleanplots) title("Log10-transformed") nodraw normal
		}
		local j = wordcount("`h_u' `untransf' `h_log' `log' `h_sqrt' `sqrt' `h_exp' `exp' `h_log10' `log10'")
		local y = `j'/2*3.5
		graph combine `h_u' `untransf' `h_log' `log' `h_sqrt' `sqrt' `h_exp' `exp' `h_log10' `log10', scheme(cleanplots) col(2) ysize(`y')
		restore
		if "`generate'" == "sqrt" qui gen sqrt_`1' = sqrt(`1')
		if "`generate'" == "log" qui gen log_`1' = log(`1')
		if "`generate'" == "log10" qui gen log10_`1' = log10(`1')
		if "`generate'" == "exp" qui gen exp_`1' = exp(`1')
	end 

