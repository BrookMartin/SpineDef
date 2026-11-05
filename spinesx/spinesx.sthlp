{smcl}
{* *! version 2.2  05nov2026}{...}
{viewerjumpto "Syntax" "spinesx##syntax"}{...}
{viewerjumpto "Description" "spinesx##description"}{...}
{viewerjumpto "Options" "spinesx##options"}{...}
{viewerjumpto "Variables created" "spinesx##created"}{...}
{viewerjumpto "Remarks" "spinesx##remarks"}{...}
{viewerjumpto "Examples" "spinesx##examples"}{...}
{viewerjumpto "Author" "spinesx##author"}{...}
{title:Title}

{phang}
{bf:spinesx} {hline 2} Classify spine procedures from CPT/HCPCS codes


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:spinesx} {ifin}{cmd:,} {opt cpt(varlist)} [{it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt cpt(varlist)}}string variables holding CPT/HCPCS codes{p_end}

{syntab:Options}
{synopt:{opt id:var(varname)}}pool all rows with the same {it:varname} (long data){p_end}
{synopt:{opt lib:rary(filename)}}code library to use; default {cmd:spinesx_codes.csv} on the adopath{p_end}
{synopt:{opt replace}}replace output variables that already exist{p_end}
{synoptline}
{p 4 6 2}
Requires Stata 16 or later.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:spinesx} classifies CPT and HCPCS procedure codes into 18 spine procedure
groups and the vertebral regions involved. It also counts add-on (additional
level) codes and estimates the minimum and maximum number of levels fused and
decompressed. It was designed for outpatient surgery data such as the HCUP
Nationwide Ambulatory Surgery Sample (NASS), but works with any data holding CPT
codes in string variables.

{pstd}
Each code is cleaned (spaces removed, upper case) and its first five characters
are matched exactly against the library, so modifiers appended to a code are
ignored.

{pstd}
The classification is defined entirely by the code library,
{cmd:spinesx_codes.csv}, which is installed with the program. To change a group,
edit a copy of the library and point to it with {opt library()}.


{marker options}{...}
{title:Options}

{phang}
{opt cpt(varlist)} specifies the string variables holding CPT/HCPCS codes, for
example {cmd:cpt(CPT1-CPT30)}.

{phang}
{opt idvar(varname)} pools the codes of all rows sharing a value of {it:varname}.
Flags take their maximum and counts their sum within {it:varname}; results are
written on every row and the data are not collapsed.

{phang}
{opt library(filename)} specifies the code library. By default,
{cmd:spinesx_codes.csv} is found on the adopath.

{phang}
{opt replace} drops and re-creates output variables that already exist.


{marker created}{...}
{title:Variables created}

{pstd}
Procedure groups (0/1; missing when {cmd:ANYSX} = 0). Groups are not mutually
exclusive.

{synoptset 13}{...}
{synopt:{cmd:SPINESX1}}ablation, neurolysis or radiosurgery (includes facet and sacroiliac joint nerve ablation){p_end}
{synopt:{cmd:SPINESX2}}disc arthroplasty{p_end}
{synopt:{cmd:SPINESX3}}vertebral augmentation (vertebroplasty, kyphoplasty, sacroplasty){p_end}
{synopt:{cmd:SPINESX4}}brace, halo or closed fracture treatment{p_end}
{synopt:{cmd:SPINESX5}}corpectomy or osteotomy{p_end}
{synopt:{cmd:SPINESX6}}decompression (laminectomy, laminotomy, discectomy, percutaneous and endoscopic decompression){p_end}
{synopt:{cmd:SPINESX7}}distraction or non-fusion stabilization (interspinous devices, tethering, facet arthroplasty){p_end}
{synopt:{cmd:SPINESX8}}excision, biopsy or intradural procedure{p_end}
{synopt:{cmd:SPINESX9}}fusion (arthrodesis or interbody device; includes sacroiliac joint fusion){p_end}
{synopt:{cmd:SPINESX10}}bone graft for spine surgery{p_end}
{synopt:{cmd:SPINESX11}}injection, drainage or aspiration (includes sacroiliac joint injection){p_end}
{synopt:{cmd:SPINESX12}}meningocele or dural repair, or CSF shunt{p_end}
{synopt:{cmd:SPINESX13}}spinal neurostimulator{p_end}
{synopt:{cmd:SPINESX14}}open fracture repair{p_end}
{synopt:{cmd:SPINESX15}}intrathecal or epidural pump or catheter{p_end}
{synopt:{cmd:SPINESX16}}removal, revision or reinsertion{p_end}
{synopt:{cmd:SPINESX17}}rhizotomy or cordotomy{p_end}
{synopt:{cmd:SPINESX18}}spinal instrumentation (rods, plates, screws, pelvic fixation; not interbody){p_end}
{synopt:{cmd:ANYSX}}any spine or sacroiliac joint procedure (0/1){p_end}

{pstd}
Vertebral regions (0/1). Many CPT codes name a range rather than one region:

{synopt:{cmd:REGSX_A}}atlas/axis{p_end}
{synopt:{cmd:REGSX_C}}cervical{p_end}
{synopt:{cmd:REGSX_CT}}"cervical or thoracic", or cervicothoracic{p_end}
{synopt:{cmd:REGSX_T}}thoracic{p_end}
{synopt:{cmd:REGSX_TL}}"thoracic or lumbar", or thoracolumbar{p_end}
{synopt:{cmd:REGSX_L}}lumbar{p_end}
{synopt:{cmd:REGSX_LS}}"lumbar or sacral", or lumbosacral{p_end}
{synopt:{cmd:REGSX_S}}sacral, coccyx or sacroiliac joint{p_end}
{synopt:{cmd:REGSX_M}}codes that cannot all fall within one broad region (see {help spinesx##remarks:Remarks}){p_end}

{pstd}
Levels and counts:

{synopt:{cmd:NFUSLEV_MIN}}fewest levels fused consistent with the codes (missing unless {cmd:SPINESX9} = 1){p_end}
{synopt:{cmd:NFUSLEV_MAX}}most levels fused consistent with the codes{p_end}
{synopt:{cmd:NDECLEV_MIN}}fewest levels decompressed (missing unless {cmd:SPINESX6} = 1){p_end}
{synopt:{cmd:NDECLEV_MAX}}most levels decompressed{p_end}
{synopt:{cmd:ADDLEV}}number of CPT fields holding an add-on (additional level) code{p_end}
{synopt:{cmd:TIERED}}largest number of additional segments implied by a tiered code (e.g. instrumentation of 3-6 segments){p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:Levels.} A level is a motion segment (interspace), not a vertebra: a 1-level
fusion joins 2 vertebrae. Arthrodesis codes are counted by approach (anterior
interbody, posterior or posterolateral, posterior interbody, lateral
extracavitary). {cmd:NFUSLEV_MIN} assumes different approaches treated the same
levels and takes the largest; {cmd:NFUSLEV_MAX} assumes they treated different
levels and adds them. Both use the range implied by tiered instrumentation and
deformity codes (vertebral segments - 1). Open-ended tiers (8+ or 13+ segments)
contribute their minimum, so {cmd:NFUSLEV_MAX} is not a true ceiling for those
cases. Decompression codes mix interspaces (laminotomy, discectomy) and vertebral
segments (laminectomy), so decompression counts are approximate. Sacroiliac
joint fusion contributes no spinal levels.

{pstd}
{bf:Units of service.} Some data sets, including NASS, have no units variable, so
an add-on code billed for several levels may appear once. Level counts are then
lower bounds for cases with three or more levels.

{pstd}
{bf:Multiple regions.} {cmd:REGSX_M} is set only when the codes cannot all fall
within one broad region: cervical (A, C, CT), thoracic (CT, T, TL) or lumbosacral
(TL, L, LS, S). A lumbar fusion with pelvic fixation (L and LS) is not multiple;
a cervical and a lumbar procedure are.

{pstd}
{bf:Sacroiliac joint procedures} are in the fusion, injection and ablation groups.
Within those groups, only sacroiliac joint codes set {cmd:REGSX_S}, so, for
example, {cmd:SPINESX9 == 1 & REGSX_S == 1} identifies a coded sacroiliac joint
fusion. Region flags describe the whole record, so a record with a lumbar fusion
and a sacroiliac joint injection would also meet that condition.

{pstd}
{bf:Library format.} {cmd:spinesx_codes.csv} has the columns {cmd:code},
{cmd:variable} (the output it contributes to), {cmd:value} and {cmd:label} (a
short description). Rows for {cmd:FUS_*}, {cmd:DEC_*}, {cmd:ADDLEV} and
{cmd:TIERED} hold the level values used for the counts.

{pstd}
{bf:Testing.} {cmd:spinesx_test.do}, an ancillary file, runs a regression test.
Obtain it with {cmd:net get spinesx}, then {cmd:do spinesx_test.do}.

{pstd}
Current Procedural Terminology (CPT) is copyright of the American Medical
Association. The library lists CPT code numbers with short descriptions written
for this program; it does not reproduce AMA descriptors.


{marker examples}{...}
{title:Examples}

{pstd}HCUP NASS{p_end}
{phang2}{cmd:. spinesx, cpt(CPT1-CPT30)}{p_end}

{pstd}Outpatient lumbar fusions{p_end}
{phang2}{cmd:. tab NFUSLEV_MIN if SPINESX9 == 1 & (REGSX_L | REGSX_LS)}{p_end}

{pstd}Long data, one row per procedure{p_end}
{phang2}{cmd:. spinesx, cpt(cpt) idvar(encounter_id)}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Brook I. Martin, PhD, MPH{break}
Department of Orthopaedics, University of Utah{break}
{browse "mailto:Brook.Martin@hsc.utah.edu":Brook.Martin@hsc.utah.edu}

{title:Also see}

{psee}
{help spinedx}, {help spineinv} (if installed)
{p_end}
