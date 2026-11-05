{smcl}
{* *! version 5.1  05nov2026}{...}
{viewerjumpto "Syntax" "spineinv##syntax"}{...}
{viewerjumpto "Description" "spineinv##description"}{...}
{viewerjumpto "Options" "spineinv##options"}{...}
{viewerjumpto "Variables created" "spineinv##created"}{...}
{viewerjumpto "Remarks" "spineinv##remarks"}{...}
{viewerjumpto "Examples" "spineinv##examples"}{...}
{viewerjumpto "Stored results" "spineinv##results"}{...}
{viewerjumpto "References" "spineinv##references"}{...}
{viewerjumpto "Author" "spineinv##author"}{...}
{title:Title}

{phang}
{bf:spineinv} {hline 2} Surgical Invasiveness Index from CPT codes


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:spineinv} {varlist} {ifin} [{cmd:,} {it:options}]

{pstd}
{it:varlist} is the list of string variables holding CPT/HCPCS codes.

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt id:var(varname)}}pool all rows with the same {it:varname} (long data){p_end}
{synopt:{opt lib:rary(filename)}}code library to use; default {cmd:spineinv_codes.csv} on the adopath{p_end}
{synopt:{opt replace}}replace output variables that already exist{p_end}
{synoptline}
{p 4 6 2}
Requires Stata 16 or later.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:spineinv} calculates the Surgical Invasiveness Index (Mirza et al. 2008) from
CPT/HCPCS codes. The index counts the vertebrae treated by each of six
interventions: anterior decompression, fusion and instrumentation, and posterior
decompression, fusion and instrumentation. Higher scores indicate more invasive
surgery.

{pstd}
Each code is cleaned (spaces removed, upper case) and its first five characters
are matched exactly against the code library, {cmd:spineinv_codes.csv}, which is
installed with the program. The library gives each code's points and the rules
below; to change a score, edit a copy of the library and point to it with
{opt library()}.


{marker options}{...}
{title:Options}

{phang}
{opt idvar(varname)} pools the codes of all rows sharing a value of {it:varname},
for data with one row per procedure or several claims per patient. Results are
written on every row; the data are not reshaped or collapsed. For one row per id,
follow with {cmd:bysort} {it:varname}{cmd:: keep if _n == 1}.

{phang}
{opt library(filename)} specifies the code library. By default,
{cmd:spineinv_codes.csv} is found on the adopath.

{phang}
{opt replace} drops and re-creates {cmd:SCORE}, {cmd:err1}, {cmd:err2} and
{cmd:err3} if they exist.


{marker created}{...}
{title:Variables created}

{synoptset 10}{...}
{synopt:{cmd:SCORE}}Surgical Invasiveness Index; 0 if CPT codes are present but none scores; missing if all CPT variables are empty{p_end}
{synopt:{cmd:err1}}1 if an add-on code is present without any of its primary codes (the add-on is still scored){p_end}
{synopt:{cmd:err2}}1 if a non-additive code is repeated (it is counted once){p_end}
{synopt:{cmd:err3}}points not counted because tiered codes in the same group were co-coded{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:Scoring rules.} The library columns define the rules:

{phang2}{cmd:score}: points for the first occurrence of a code in a record.{p_end}
{phang2}{cmd:repeat}: points for each further occurrence. Add-on codes ("each
additional level") score per occurrence; for other codes {cmd:repeat} is 0 and a
repeat sets {cmd:err2}.{p_end}
{phang2}{cmd:tiergrp}: codes in the same tier group (for example, posterior
segmental instrumentation of 3-6, 7-12 and 13+ segments) are not additive; only the
highest-scoring code present counts, and the points removed are stored in
{cmd:err3}.{p_end}
{phang2}{cmd:primaries}: for add-on codes, the primary codes it is reported with;
used for {cmd:err1}.{p_end}
{phang2}{cmd:label}: a short description of the code.{p_end}

{pstd}
{bf:Interbody devices} are scored per level: the first device scores 2 (two
vertebrae) and each further occurrence 1.

{pstd}
{bf:Units of service.} Some data sets, including NASS, have no units variable, so
an add-on code billed for several levels may appear once and be scored once.

{pstd}
{bf:Testing.} {cmd:spineinv_test.do}, an ancillary file, runs a regression test.
Obtain it with {cmd:net get spineinv}, then {cmd:do spineinv_test.do}.

{pstd}
Current Procedural Terminology (CPT) is copyright of the American Medical
Association. The library lists CPT code numbers with short descriptions written
for this program; it does not reproduce AMA descriptors.


{marker examples}{...}
{title:Examples}

{pstd}One record per encounter{p_end}
{phang2}{cmd:. spineinv CPT1-CPT30}{p_end}

{pstd}Long data, one row per procedure{p_end}
{phang2}{cmd:. spineinv cpt, idvar(encounter_id)}{p_end}

{pstd}With {help spinesx}: invasiveness of outpatient fusions{p_end}
{phang2}{cmd:. spinesx, cpt(CPT1-CPT30)}{p_end}
{phang2}{cmd:. spineinv CPT1-CPT30}{p_end}
{phang2}{cmd:. summarize SCORE if SPINESX9 == 1, detail}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:spineinv} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{synopt:{cmd:r(N)}}number of observations scored{p_end}
{synopt:{cmd:r(N_err1)}}number of observations with {cmd:err1} = 1{p_end}
{synopt:{cmd:r(N_err2)}}number of observations with {cmd:err2} = 1{p_end}
{synopt:{cmd:r(N_err3)}}number of observations with {cmd:err3} > 0{p_end}


{marker references}{...}
{title:References}

{phang}
Mirza SK, Deyo RA, Heagerty PJ, Konodi MA, Lee LA, Turner JA, Goodkin R. 2008.
Development of an index to characterize the "invasiveness" of spine surgery:
validation by comparison to blood loss and operative time. {it:Spine} 33(24):
2651-2661. {browse "https://doi.org/10.1097/BRS.0b013e31818dad07":doi:10.1097/BRS.0b013e31818dad07}


{marker author}{...}
{title:Author}

{pstd}
Brook I. Martin, PhD, MPH{break}
Department of Orthopaedics, University of Utah{break}
{browse "mailto:Brook.Martin@hsc.utah.edu":Brook.Martin@hsc.utah.edu}

{title:Also see}

{psee}
{help spinedx}, {help spinesx} (if installed)
{p_end}
