{smcl}
{* *! version 2.6  05nov2026}{...}
{viewerjumpto "Syntax" "spinedx##syntax"}{...}
{viewerjumpto "Description" "spinedx##description"}{...}
{viewerjumpto "Options" "spinedx##options"}{...}
{viewerjumpto "Variables created" "spinedx##created"}{...}
{viewerjumpto "Remarks" "spinedx##remarks"}{...}
{viewerjumpto "Examples" "spinedx##examples"}{...}
{viewerjumpto "Author" "spinedx##author"}{...}
{title:Title}

{phang}
{bf:spinedx} {hline 2} Classify spine diagnoses from ICD-9-CM and ICD-10-CM codes


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:spinedx} {ifin}{cmd:,} {opt dx10(varlist)} [{it:options}]

{p 8 16 2}
{cmd:spinedx} {ifin}{cmd:,} {opt dx9(varlist)} [{it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Codes (at least one required)}
{synopt:{opt dx10(varlist)}}string variables holding ICD-10-CM diagnosis codes{p_end}
{synopt:{opt dx9(varlist)}}string variables holding ICD-9-CM diagnosis codes{p_end}

{syntab:Options}
{synopt:{opt icd:ver(varname)}}numeric variable equal to 9 or 10 identifying the coding system of each row{p_end}
{synopt:{opt id:var(varname)}}pool all rows with the same {it:varname} (long data){p_end}
{synopt:{opt lib:rary(filename)}}code library to use; default {cmd:spinedx_codes.csv} on the adopath{p_end}
{synopt:{opt replace}}replace output variables that already exist{p_end}
{synoptline}
{p 4 6 2}
Requires Stata 16 or later.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:spinedx} classifies diagnosis codes into 16 spine diagnosis categories, a
degenerative diagnosis hierarchy, and the vertebral regions involved. ICD-9-CM and
ICD-10-CM codes are mapped to the same categories, so trends can be followed
across the October 1, 2015 transition from ICD-9-CM to ICD-10-CM.

{pstd}
Codes may be stored with or without decimal points and in upper or lower case.
A code is cleaned (spaces and decimal points removed, upper case) and matches a
library row when it {it:begins with} that row's prefix, for its coding system. A
prefix ending in {cmd:=} matches only that exact code.

{pstd}
The classification is defined entirely by the code library,
{cmd:spinedx_codes.csv}, which is installed with the program. To change a
category, edit a copy of the library and point to it with {opt library()}; the
program itself does not need editing.


{marker options}{...}
{title:Options}

{phang}
{opt dx10(varlist)} and {opt dx9(varlist)} specify the string variables holding
ICD-10-CM and ICD-9-CM diagnosis codes. Both may be given, for example for the
2015 National Inpatient Sample, which stores ICD-9-CM and ICD-10-CM codes in
separate variables.

{phang}
{opt icdver(varname)} is needed only when the same variables hold ICD-9-CM codes on
some rows and ICD-10-CM codes on others. {it:varname} must equal 9 or 10. When it is
given, {opt dx9()} is read only where {it:varname}==9 and {opt dx10()} only where
{it:varname}==10, so the same variables can be passed to both options. This matters
because some ICD-9-CM V and E codes begin with the same characters as ICD-10-CM
codes.

{phang}
{opt idvar(varname)} pools the codes of all rows sharing a value of {it:varname},
for data with one row per diagnosis or several records per patient. Flags are set
to their maximum within {it:varname} and written on every row; the data are not
collapsed. For one row per id, follow with {cmd:bysort} {it:varname}{cmd:: keep if _n == 1}.

{phang}
{opt library(filename)} specifies the code library. By default,
{cmd:spinedx_codes.csv} is found on the adopath. Pointing to a project copy is a
convenient way to fix the definitions used for a given analysis.

{phang}
{opt replace} drops and re-creates output variables that already exist.


{marker created}{...}
{title:Variables created}

{pstd}
Diagnosis categories (0/1; missing when {cmd:ANYSPINE} = 0). Categories are not
mutually exclusive.

{synoptset 12}{...}
{synopt:{cmd:SPINEDX1}}sprains and strains{p_end}
{synopt:{cmd:SPINEDX2}}disc degeneration (includes spondylosis without myelopathy, nonspecific neck and back pain){p_end}
{synopt:{cmd:SPINEDX3}}disc herniation{p_end}
{synopt:{cmd:SPINEDX4}}stenosis (includes spondylosis with myelopathy){p_end}
{synopt:{cmd:SPINEDX5}}spondylolisthesis, instability, subluxation or dislocation (ICD-10-CM dislocation codes){p_end}
{synopt:{cmd:SPINEDX6}}scoliosis, kyphosis or other deformity{p_end}
{synopt:{cmd:SPINEDX7}}radiculopathy{p_end}
{synopt:{cmd:SPINEDX8}}traumatic vertebral fracture (ICD-9-CM also vertebral dislocation, 839.x){p_end}
{synopt:{cmd:SPINEDX9}}spinal cord injury{p_end}
{synopt:{cmd:SPINEDX10}}congenital or other anomaly{p_end}
{synopt:{cmd:SPINEDX11}}inflammatory spondylopathy{p_end}
{synopt:{cmd:SPINEDX12}}spine osteoporotic, pathological or fatigue fracture{p_end}
{synopt:{cmd:SPINEDX13}}surgical aftercare or device complication{p_end}
{synopt:{cmd:SPINEDX14}}spinal infection (ICD-10-CM codes only){p_end}
{synopt:{cmd:SPINEDX15}}myelopathy{p_end}
{synopt:{cmd:SPINEDX16}}spine-specific neoplasm{p_end}

{pstd}
Hierarchy and summary:

{synopt:{cmd:DEGDX}}highest of categories 1-6: 0 other spine diagnosis, 1 strain, 2 disc degeneration, 3 herniation, 4 stenosis, 5 spondylolisthesis/instability, 6 deformity{p_end}
{synopt:{cmd:ANYSPINE}}any spine diagnosis (0/1){p_end}

{pstd}
Vertebral regions (0/1):

{synopt:{cmd:REG_A}}atlas/axis{p_end}
{synopt:{cmd:REG_C}}cervical{p_end}
{synopt:{cmd:REG_CT}}cervicothoracic{p_end}
{synopt:{cmd:REG_T}}thoracic{p_end}
{synopt:{cmd:REG_TL}}thoracolumbar{p_end}
{synopt:{cmd:REG_L}}lumbar{p_end}
{synopt:{cmd:REG_LS}}lumbosacral{p_end}
{synopt:{cmd:REG_S}}sacral or coccyx{p_end}
{synopt:{cmd:REG_M}}more than one region{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:Comparability across coding systems.} ICD-9-CM and ICD-10-CM differ in
detail, so a few categories cannot be fully comparable. Radiculopathy
({cmd:SPINEDX7}) is captured mainly through symptom codes in ICD-9-CM, because
ICD-9-CM has no "disc disorder with radiculopathy" codes; expect it to rise at the
transition. Spinal infection ({cmd:SPINEDX14}) uses ICD-10-CM codes only. Vertebral
dislocations are in {cmd:SPINEDX8} for ICD-9-CM (839.x) but {cmd:SPINEDX5} for
ICD-10-CM (S13.1, S23.1, S33.1). Analysts
studying trends should examine the period around October 2015 for coding
artifacts.

{pstd}
{bf:Diagnoses only.} Procedure codes are not used. Spine procedures can be
classified with {help spinesx} (if installed).

{pstd}
{bf:Library format.} {cmd:spinedx_codes.csv} has the columns {cmd:system}
({cmd:icd10cm} or {cmd:icd9cm}), {cmd:prefix}, {cmd:variable} (the output
variable the prefix sets) and {cmd:description}.

{pstd}
{bf:Testing.} {cmd:spinedx_test.do}, an ancillary file, runs a regression test.
Obtain it with {cmd:net get spinedx}, then {cmd:do spinedx_test.do}.


{marker examples}{...}
{title:Examples}

{pstd}National Inpatient Sample, 2002-2014 (ICD-9-CM){p_end}
{phang2}{cmd:. spinedx, dx9(DX1-DX25)}{p_end}

{pstd}2016 onward (ICD-10-CM){p_end}
{phang2}{cmd:. spinedx, dx10(I10_DX1-I10_DX40)}{p_end}

{pstd}Pooled years with separate ICD-9-CM and ICD-10-CM variables{p_end}
{phang2}{cmd:. spinedx, dx9(DX1-DX30) dx10(I10_DX1-I10_DX40)}{p_end}

{pstd}One set of variables holding both systems, with a 9/10 indicator{p_end}
{phang2}{cmd:. spinedx, dx9(dx1-dx25) dx10(dx1-dx25) icdver(dxver)}{p_end}

{pstd}Long data, one row per diagnosis{p_end}
{phang2}{cmd:. spinedx, dx10(dx) idvar(patient_id)}{p_end}

{pstd}A project copy of the library{p_end}
{phang2}{cmd:. spinedx, dx10(I10_DX1-I10_DX40) library("C:/project/spinedx_codes.csv") replace}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Brook I. Martin, PhD, MPH{break}
Department of Orthopaedics, University of Utah{break}
{browse "mailto:Brook.Martin@hsc.utah.edu":Brook.Martin@hsc.utah.edu}

{pstd}
ICD-9-CM and ICD-10-CM are maintained by the Centers for Medicare & Medicaid
Services and the National Center for Health Statistics.
