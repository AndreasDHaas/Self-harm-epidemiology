{smcl}
{* *! version 2.1  6 May 2022}{...}
{viewerdialog fhos "dialog fhos"}{...}
{vieweralsosee "[D] fhos" "mansection D fhos"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[P] display" "help display"}{...}
{vieweralsosee "[D] edit" "help edit"}{...}
{vieweralsosee "[P] tabdisp" "help tabdisp"}{...}
{vieweralsosee "[R] table" "help table"}{...}
{viewerjumpto "Syntax" "fhos##syntax"}{...}
{viewerjumpto "Menu" "fhos##menu"}{...}
{viewerjumpto "Description" "fhos##description"}{...}
{viewerjumpto "Options" "fhos##options"}{...}
{viewerjumpto "Remarks" "fhos##remarks"}{...}
{viewerjumpto "Examples" "fhos##examples"}{...}
{p2colset 1 13 15 2}{...}
{p2col:{bf:[D] fhos} }Creates newvar_d containing the date of the first hospital code meeting the if condition {p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{opt fhos} {newvar} {cmd: using} [if] [, options] 

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Options}
{synopt :{opt mindate(date):}}disregards codes before mindate {p_end}
{synopt :{opt maxdate(date):}}disregards codes after maxdate {p_end}
{synopt :{opt minage(integer):}}disregards codes before minage{p_end}
{synopt :{opt maxage(integer):}}disregards after maxage {p_end}
{synopt :{opt refdate(varname)}}specifies codes not inrange(refdate, refdate-refminus, refdate+refplus) are dropped. Refdate can't be missing if option is specified {p_end}
{synopt :{opt refminus(integer):}}refdate - refminus is lower bound of time window specified in refdate. default is 30{p_end}
{synopt :{opt refplus(integer):}}refdate + refplus is uppper bound of time window specified in refdate. default is 30{p_end}
{synopt :{opt n:}}generates newvar_n containing the number of codes in age and date range meeting the if condition and are on different dates {p_end}
{synopt :{opt y:}}generates the binary indicator newvar_y for the presence of a pharmacy claim in age and date range meeting the if condition {p_end}
{synopt :{opt label(string):}}labels value 1 of newvar_y with string{p_end}
{synopt :{opt list(N):}}lists codes meeting the if condition of a random sample of N patients. The ado file listif is required for this option. {p_end}
{synopt :{opt listpat:ient(patient)}}lists codes of specified patient id before and after applying age and date restrictions {p_end}
{synopt :{opt desc:ribe}}specifies the using dataset and coding of its variables are described {p_end}
{synopt :{opt nogen:erate}}specifies that newvar_* not be created {p_end}
{synopt :{opt censor(varname)}}specifies that codes after varname are censored {p_end}

{marker description}{...}
{title:Description}
{synoptset 24 tabbed}{...}
{synopt :{opt newvar:}}name of new variable to be generated{p_end}
{synopt :{opt using:}}filename of cleaned AfA controls HOS table {p_end}
{synopt :{opt if:}}if condition selecting relevant codes{p_end}

{marker examples}{...}
{title:Examples}

 * Explore coding of using data by specifying the describe and nogenerate options  
{phang}{cmd: fhos} revasc {cmd: using} "$clean/HOS", nogen describe {p_end} 
 * Generate variables for first hospital admission for selected revascularisation procedures between Jan 1, 2020 and Feb 12, 2020   
{phang}{cmd: fhos} revasc using "$clean/HOS" if (code_type =="CPT" & inlist(hosp_code, "33503", "33504", "33510", "33511") & inlist(code_role, 4)), minage(25)  mindate(`=d(01/01/2011)') maxdate(`=d(15/02/2020)') {p_end} 
{marker Notes}{...}
{title:Notes}
{phang}{cmd: fhos}  uses a 1:m merge. The loaded dataset has to be in a wide format.{p_end}

{title:Also See}
{phang}{cmd: fdiag}{p_end}
{phang}{cmd: flab}{p_end}
{phang}{cmd: fdrug}{p_end}
	
{marker Author}{...}
{title:Author}
{phang}Andreas Haas{p_end}
{phang}University of Bern {p_end}
{phang}Email: andreas.haas@ispm.unibe.ch{p_end}
