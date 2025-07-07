{smcl}
{* *! version 1.0  AH 28 May 2022 }{...}
{viewerdialog regtable "dialog regtable"}{...}
{viewerjumpto "Syntax" "regtable##syntax"}{...}
{viewerjumpto "Description" "regtable##description"}{...}
{viewerjumpto "Options" "regtable##options"}{...}
{viewerjumpto "Examples" "regtable##examples"}{...}
{p2colset 1 20 20 2}{...}
{p2col:{bf:[T] regtable} {hline 2}}Saves labeled and formatted estimates stored in `r(table)' {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmdab:regtable} varlist 
[{cmd:,}
{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}
{synopt:{opt save(filepath)}}saves table {p_end}
{synopt:{opt append(filepath)}}appends table {p_end}
{synopt:{opt merge(filepath)}}merges table based on var {p_end}
{synopt:{opt mergeid(varlist)}}merges table based on mergid if merge is specified {p_end}
{synopt:{opt sort(varlist)}} sorts by varlist {p_end}
{synopt:{opt eform}} Exponentiates coefficients {p_end}
{synopt:{opt drop(varlist)}} drops variables specified in varlist {p_end}
{synopt:{opt keep(varlist)}} keeps variables specified in varlist {p_end}
{synopt:{opt baselabel(string)}}labels estimate with string (default 1.00) {p_end}
{synopt:{opt heading}}adds row with variable label for categorial variables in varlist {p_end}
{synopt:{opt dropcoef:ficient(string)}} loops over word in string and drops coefficients matching regular expression {p_end}
{synopt:{opt name(string)}} adds variable name set to string {p_end}
{synopt:{opt number(integer)}} adds variable number set to integer {p_end}
{synopt:{opt collab(string)}} adds column lab {p_end}
{synopt:{opt estlab(string)}} adds estimate label {p_end}
{synopt:{opt clean}} list clean table {p_end}

{syntab:Format}
{synopt:{opt format(string)}}Formats estimates according to Stata format specified in string{p_end}
{synopt:{opt labelf:ormat(string)}}format label column according to Stata format specified in string{p_end}
{synopt:{opt cisep:arator(string)}}string separating lower and upper bound of confidence interval, (default="-"){p_end}
{synopt:{opt brackets}}replaces parentheses with brackets{p_end}
{synopt:{opt midpoint}}use midpoint as decimal point separator{p_end}
{synopt:{opt ind:ent(integer)}}indent labels by the number of blanks specified, (default=2){p_end}

{syntab:Advanced}
{synopt:{opt varsu:ffix(string)}}rename all variables in table except label and var with suffix{p_end}

{marker description}{...}
{title:Description}

{pstd}
{opt regtable} list, saves and appends labeled and formatted estimates stored in `r(table)' 

{marker examples}{...}
{title:Examples}

    Setup	
{phang}{cmd:. webuse} drugtr2{p_end}
{phang}{cmd:. stset} time, failure(cured){p_end}

{phang}{cmd:. recode} age (14/29=1) (30/39=2) (40/max=3) , gen(age_cat){p_end}
{phang}{cmd:. label} define age_cat 1 "14-29" 2 "30-39"3 "40+", replace{p_end}
{phang}{cmd:. label} val age_cat age_cat{p_end}
{phang}{cmd:. label} var age_cat "Age group, years"{p_end}
{phang}{cmd:. describe} age_cat{p_end}

{phang}{cmd:. stcox} ib2.age_cat drug1 drug2{p_end}

    List formatted regression output 
{phang}{cmd:. regtable age_cat, ciseparator(" to ") heading clean }{p_end}
  		 
{marker author}{...}
{title:Author}
{pstd}
Andreas Haas, Email: andreas.haas@ispm.unibe.ch
