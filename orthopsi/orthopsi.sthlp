{smcl}
{* *! version 2.1  06nov2026}{...}
{viewerjumpto "Syntax" "orthopsi##syntax"}{...}
{viewerjumpto "Description" "orthopsi##description"}{...}
{viewerjumpto "Options" "orthopsi##options"}{...}
{viewerjumpto "Variables created" "orthopsi##created"}{...}
{viewerjumpto "Remarks" "orthopsi##remarks"}{...}
{viewerjumpto "Examples" "orthopsi##examples"}{...}
{viewerjumpto "Author" "orthopsi##author"}{...}
{title:Title}

{phang}
{bf:orthopsi} {hline 2} Post-procedure complications after orthopaedic surgery from ICD-9-CM and ICD-10-CM codes


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:orthopsi} {ifin}{cmd:,} {opt dx10(varlist)} [{it:options}]

{p 8 16 2}
{cmd:orthopsi} {ifin}{cmd:,} {opt dx9(varlist)} [{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Codes (at least one required)}
{synopt:{opt dx10(varlist)}}string variables holding ICD-10-CM diagnosis codes{p_end}
{synopt:{opt dx9(varlist)}}string variables holding ICD-9-CM diagnosis codes{p_end}

{syntab:Options}
{synopt:{opt icd:ver(varname)}}numeric variable equal to 9 or 10 identifying the coding system of each row{p_end}
{synopt:{opt proc:edure(types)}}procedure type(s) whose site-specific codes apply: any of {cmd:spine} {cmd:hip} {cmd:knee} {cmd:upper} {cmd:lower} {cmd:foot} {cmd:hand}, or {cmd:all}{p_end}
{synopt:{opt seq:uela}}also count ICD-10-CM sequela codes (7th character S){p_end}
{synopt:{opt id:var(varname)}}pool all rows with the same {it:varname} (long data){p_end}
{synopt:{opt lib:rary(filename)}}code library to use; default {cmd:orthopsi_codes.csv} on the adopath{p_end}
{synopt:{opt replace}}replace output variables that already exist{p_end}
{synoptline}
{p 4 6 2}
Requires Stata 16 or later.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:orthopsi} flags 15 categories of complications ("patient safety
indicators") after orthopaedic procedures, and device-related infections, from
ICD-9-CM and ICD-10-CM diagnosis codes. The definitions are designed for
orthopaedic surgery: for example, cardiac and respiratory complications use the
codes for complications {it:following other} ({it:non-cardiac}, {it:nonthoracic})
procedures.

{pstd}
Some ICD-10-CM codes apply only to particular procedures, for example dislocation
of a hip prosthesis after hip arthroplasty, or pseudarthrosis after spinal fusion.
These site-specific codes are used only for the procedure types named in
{opt procedure()}; all other codes always apply.

{pstd}
Codes may be stored with or without decimal points, in any case. A cleaned code
matches a library row when it {it:begins with} that row's prefix for its coding
system; a prefix ending in {cmd:=} matches only that exact code. The definitions
are held in the code library {cmd:orthopsi_codes.csv}, installed with the
program; to adapt them, edit a copy and point to it with {opt library()}.


{marker options}{...}
{title:Options}

{phang}
{opt dx10(varlist)} and {opt dx9(varlist)} specify the string variables holding
ICD-10-CM and ICD-9-CM diagnosis codes. Both may be given, for example for data
pooled across the October 2015 transition. {opt dx()} is accepted as a synonym
for {opt dx10()}.

{phang}
{opt icdver(varname)} is needed only when the same variables hold ICD-9-CM codes
on some rows and ICD-10-CM codes on others. {it:varname} must equal 9 or 10.

{phang}
{opt procedure(types)} names the procedure types whose site-specific codes are
used, for example {cmd:procedure(hip)} for hip arthroplasty or
{cmd:procedure(spine)} for spine surgery. {cmd:procedure(all)} uses every
site-specific code. Without {opt procedure()}, only codes that are not
site-specific are used. The options {cmd:sp}, {cmd:hp}, {cmd:kn}, {cmd:upx},
{cmd:lox}, {cmd:ft} and {cmd:hnd} are accepted as synonyms.

{phang}
{opt sequela} also counts ICD-10-CM sequela codes (7th character S). By default
they are not counted, because they describe late effects rather than new
complications.

{phang}
{opt idvar(varname)} pools the codes of all rows sharing a value of {it:varname}.
Flags are set to their maximum within {it:varname} and written on every row; the
data are not collapsed. For one row per id, follow with {cmd:bysort}
{it:varname}{cmd:: keep if _n == 1}.

{phang}
{opt library(filename)} specifies the code library. By default,
{cmd:orthopsi_codes.csv} is found on the adopath.

{phang}
{opt replace} drops and re-creates output variables that already exist.


{marker created}{...}
{title:Variables created}

{pstd}All are 0/1. Categories are not mutually exclusive.{p_end}

{synoptset 10}{...}
{synopt:{cmd:PSI1}}skin{p_end}
{synopt:{cmd:PSI2}}nervous system or musculoskeletal (including dural tear and periprosthetic fracture){p_end}
{synopt:{cmd:PSI3}}gastrointestinal{p_end}
{synopt:{cmd:PSI4}}respiratory{p_end}
{synopt:{cmd:PSI5}}cardiac{p_end}
{synopt:{cmd:PSI6}}genitourinary{p_end}
{synopt:{cmd:PSI7}}other, including retained foreign body and postprocedural shock{p_end}
{synopt:{cmd:PSI8}}infection or wound disruption (all postprocedural and device-related infections){p_end}
{synopt:{cmd:PSI9}}vascular{p_end}
{synopt:{cmd:PSI10}}pulmonary embolism{p_end}
{synopt:{cmd:PSI11}}deep vein thrombosis (acute; excludes superficial){p_end}
{synopt:{cmd:PSI12}}abscess{p_end}
{synopt:{cmd:PSI13}}cerebrovascular{p_end}
{synopt:{cmd:PSI14}}device problem (mechanical and other non-infectious){p_end}
{synopt:{cmd:PSI15}}anesthesia or medication{p_end}
{synopt:{cmd:DEVINF}}device-related infection (a subset of {cmd:PSI8}){p_end}
{synopt:{cmd:ANYPSI}}any complication ({cmd:PSI1}-{cmd:PSI15}){p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:Comparability across coding systems.} ICD-9-CM is less detailed than
ICD-10-CM, so some categories are not fully comparable. ICD-9-CM has no
organ-specific codes for hemorrhage, hematoma, seroma or accidental laceration
complicating a procedure (998.11-998.13, 998.2); these are in {cmd:PSI7}, whereas
ICD-10-CM assigns them to the organ system. ICD-9-CM has no skin-specific
complication codes, no code for pseudarthrosis after fusion, and no
site-specific device codes, so the ICD-9-CM library has no procedure-specific
rows except the spine codes for postlaminectomy conditions. Analysts studying
trends should examine the period around October 2015 for coding artifacts.

{pstd}
{bf:Present on admission.} Data such as the National Inpatient Sample have no
present-on-admission indicator, so a flagged code may describe a condition
present before surgery. Where present-on-admission flags are available, consider
passing only diagnoses not present on admission.

{pstd}
{bf:Library format.} {cmd:orthopsi_codes.csv} has the columns {cmd:system}
({cmd:icd10cm} or {cmd:icd9cm}), {cmd:prefix}, {cmd:variable} (the output it
sets), {cmd:procedure} ({cmd:all} or a procedure type) and {cmd:description}.

{pstd}
{bf:Testing.} {cmd:orthopsi_test.do}, an ancillary file, runs a regression test.
Obtain it with {cmd:net get orthopsi}, then {cmd:do orthopsi_test.do}.


{marker examples}{...}
{title:Examples}

{pstd}Spine surgery, National Inpatient Sample 2016 onward{p_end}
{phang2}{cmd:. orthopsi, dx10(I10_DX1-I10_DX40) procedure(spine)}{p_end}

{pstd}Hip and knee arthroplasty, pooled years with separate ICD-9-CM and ICD-10-CM variables{p_end}
{phang2}{cmd:. orthopsi, dx9(DX1-DX30) dx10(I10_DX1-I10_DX40) procedure(hip knee)}{p_end}

{pstd}One set of variables holding both systems, with a 9/10 indicator{p_end}
{phang2}{cmd:. orthopsi, dx9(dx1-dx25) dx10(dx1-dx25) icdver(dxver) procedure(all)}{p_end}

{pstd}Device-related infections after spine surgery{p_end}
{phang2}{cmd:. orthopsi, dx10(I10_DX1-I10_DX40) procedure(spine)}{p_end}
{phang2}{cmd:. tab PSI8 DEVINF}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Brook I. Martin, PhD, MPH{break}
Department of Orthopaedics, University of Utah{break}
{browse "mailto:Brook.Martin@hsc.utah.edu":Brook.Martin@hsc.utah.edu}

{pstd}
ICD-9-CM and ICD-10-CM are maintained by the Centers for Medicare & Medicaid
Services and the National Center for Health Statistics.

{title:Also see}

{psee}
{help spinedx}, {help spinesx}, {help spineinv} (if installed)
{p_end}
