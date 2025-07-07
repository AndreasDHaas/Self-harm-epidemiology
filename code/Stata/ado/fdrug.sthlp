{smcl}
{* *! version 2.1  6 May 2022}{...}
{viewerdialog fdrug "dialog fdrug"}{...}
{vieweralsosee "[D] fdrug" "mansection D fdrug"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[P] display" "help display"}{...}
{vieweralsosee "[D] edit" "help edit"}{...}
{vieweralsosee "[P] tabdisp" "help tabdisp"}{...}
{vieweralsosee "[R] table" "help table"}{...}
{viewerjumpto "Syntax" "fdrug##syntax"}{...}
{viewerjumpto "Menu" "fdrug##menu"}{...}
{viewerjumpto "Description" "fdrug##description"}{...}
{viewerjumpto "Options" "fdrug##options"}{...}
{viewerjumpto "Remarks" "fdrug##remarks"}{...}
{viewerjumpto "Examples" "fdrug##examples"}{...}
{p2colset 1 13 15 2}{...}
{p2col:{bf:[D] fdrug} }Creates newvar_d containing the date of the first pharmacy claim meeting the if condition {p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{opt fdrug} {newvar} {cmd: using} [if] [, options] 

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Options}
{synopt :{opt mindate(date):}}disregards claims before mindate {p_end}
{synopt :{opt maxdate(date):}}disregards claims after maxdate {p_end}
{synopt :{opt minage(integer):}}disregards claims before minage{p_end}
{synopt :{opt maxage(integer):}}disregards after maxage {p_end}
{synopt :{opt n:}}generates newvar_n containing the number of claims in age and date range meeting the if condition and are on different dates {p_end}
{synopt :{opt y:}}generates the binary indicator newvar_y for the presence of a pharmacy claim in age and date range meeting the if condition {p_end}
{synopt :{opt label(string):}}labels value 1 of newvar_y with string{p_end}
{synopt :{opt list(#):}}lists claims meeting the if condition of a random sample of # patients. The ado file listif is required for this option. {p_end}
{synopt :{opt listpat:ient(patient)}}lists claims of specified patient id before and after applying age and date restrictions {p_end}
{synopt :{opt refdate(varname)}}specifies medicaton not inrange(refdate, refdate-refminus, refdate+refplus) are dropped. Refdate can't be missing if option is specified {p_end}
{synopt :{opt refminus(integer):}}refdate - refminus is lower bound of time window specified in refdate. default is 30{p_end}
{synopt :{opt refplus(integer):}}refdate + refplus is uppper bound of time window specified in refdate. default is 30{p_end}
{synopt :{opt desc:ribe}}specifies the using dataset and coding of its variables are described {p_end}
{synopt :{opt nogen:erate}}specifies that newvar_* not be created {p_end}
{synopt :{opt censor(varname)}}specifies that claims after varname are censored {p_end}

{marker description}{...}
{title:Description}
{synoptset 24 tabbed}{...}
{synopt :{opt newvar:}}name of new variable to be generated{p_end}
{synopt :{opt using:}}filename of cleaned AfA controls MED_ATC_X table {p_end}
{synopt :{opt if:}}if condition selecting relevant claims{p_end}

{marker examples}{...}
{title:Examples}

 * Generate variables for first dolutegravir claim after Jan 1, 2020 and number of claims between Jan 1, 2020 & Jul 1, 2020  
{phang}{cmd: fdrug} dtg using "$clean/MED_ATC_J" if inlist(med_id, "J05AR13", "J05AR21", "J05AR25", "J05AR27", "J05AJ03"), mindate(`=d(01/01/2020)') maxdate(`=d(01/07/2020)') n listpat("B006574078"){p_end} 

{marker Notes}{...}
{title:Notes}
{phang}{cmd: fdrug}  uses a 1:m merge. The loaded dataset has to be in a wide format.{p_end}

{title:Also See}
{phang}{cmd: fdiag}{p_end}
{phang}{cmd: flab}{p_end}
{phang}{cmd: fhos}{p_end}
	
{marker Author}{...}
{title:Author}
{phang}Andreas Haas{p_end}
{phang}University of Bern {p_end}
{phang}Email: andreas.haas@ispm.unibe.ch{p_end}




				


