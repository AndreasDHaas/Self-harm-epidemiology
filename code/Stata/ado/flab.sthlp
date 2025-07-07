{smcl}
{* *! version 2.1  6 May 2022}{...}
{viewerdialog flab "dialog flab"}{...}
{vieweralsosee "[D] flab" "mansection D flab"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[P] display" "help display"}{...}
{vieweralsosee "[D] edit" "help edit"}{...}
{vieweralsosee "[P] tabdisp" "help tabdisp"}{...}
{vieweralsosee "[R] table" "help table"}{...}
{viewerjumpto "Syntax" "flab##syntax"}{...}
{viewerjumpto "Menu" "flab##menu"}{...}
{viewerjumpto "Description" "flab##description"}{...}
{viewerjumpto "Options" "flab##options"}{...}
{viewerjumpto "Remarks" "flab##remarks"}{...}
{viewerjumpto "Examples" "flab##examples"}{...}
{p2colset 1 13 15 2}{...}
{p2col:{bf:[D] flab} }Creates newvar_d containing the date of the first lab value meeting the if condition {p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{opt flab} {newvar} {cmd: using} [if] [, options] 

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Options}
{synopt :{opt mindate(date):}}disregards lab values before mindate {p_end}
{synopt :{opt maxdate(date):}}disregards lab values after maxdate {p_end}
{synopt :{opt minage(integer):}}disregards lab values before minage{p_end}
{synopt :{opt maxage(integer):}}disregards after maxage {p_end}
{synopt :{opt n:}}generates newvar_n containing the number of lab values in age and date range meeting the if condition and are on different dates {p_end}
{synopt :{opt y:}}generates the binary indicator newvar_y for the presence of a diagnosis in age and date range meeting the if condition {p_end}
{synopt :{opt label(string):}}labels value 1 of newvar_y with string{p_end}
{synopt :{opt list(#):}}lists lab values meeting the if condition of a random sample of # patients. The ado file listif is required for this option. {p_end}
{synopt :{opt listpat:ient(patient)}}lists lab values of specified patient id before and after applying age and date restrictions {p_end}
{synopt :{opt desc:ribe}}specifies the using dataset and coding of its variables are described {p_end}
{synopt :{opt nogen:erate}}specifies that newvar_* not be created {p_end}
{synopt :{opt censor(varname)}}specifies that lab values after varname are censored {p_end}

{marker description}{...}
{title:Description}
{synoptset 24 tabbed}{...}
{synopt :{opt newvar:}}name of new variable to be generated{p_end}
{synopt :{opt using:}}filename of cleaned AfA controls ICD10_X table{p_end}
{synopt :{opt if:}}if condition selecting relevant lab values{p_end}

{marker examples}{...}
{title:Examples}

 * Generate variables for first RNA measurement between Jan 1, 2011 & Jul 1, 2020, number of RNA measurements in time period, and binary indicator
{phang}{cmd: flab} rna using "$clean/HIV_RNA" if lab_id =="HIV_RNA" & lab_v !=., mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') n y listpat("B007169875") {p_end}

{marker Notes}{...}
{title:Notes}
{phang}{cmd: flab}  uses a 1:m merge. The loaded dataset has to be in a wide format.{p_end}

{title:Also See}
{phang}{cmd: fdrug}{p_end}
{phang}{cmd: fdiag}{p_end}
{phang}{cmd: fhos}{p_end}
	
{marker Author}{...}
{title:Author}
{phang}Andreas Haas{p_end}
{phang}University of Bern {p_end}
{phang}Email: andreas.haas@ispm.unibe.ch{p_end}

