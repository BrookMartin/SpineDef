*! spinedx v2.6 (ICD-9-CM and ICD-10-CM diagnoses)  Brook I. Martin  27Oct2026
*! Department of Orthopaedics, University of Utah
*!
*! Classifies spine diagnoses into clinical categories (SPINEDX1-SPINEDX16),
*! a degenerative hierarchy (DEGDX), and vertebral regions (REG_*), using the
*! external prefix library spinedx_codes.csv. ICD-9 and ICD-10 codes are mapped
*! to the same categories so trends can run across the October 2015 transition.
*!
*! Syntax
*!   spinedx [if] [in], [dx10(varlist) dx9(varlist) icdver(varname)
*!                       idvar(varname) library(filename) replace]
*!
*!   dx10()     ICD-10-CM diagnosis variables (string; dots optional, any case)
*!   dx9()      ICD-9-CM diagnosis variables (string; dots optional)
*!   icdver()   numeric variable equal to 9 or 10 on each row. When given, dx9()
*!              is read only where icdver==9 and dx10() only where
*!              icdver==10, so one set of variables holding both versions can be
*!              passed to both options: dx9(dx1-dx25) dx10(dx1-dx25) icdver(ver)
*!   idvar()    long data: flags are set to the maximum within idvar on every row
*!   library()  code library; default spinedx_codes.csv on the adopath
*!   replace    overwrite existing output variables
*!
*! Examples (NIS)
*!   2002-2014:  spinedx, dx9(DX1-DX25)
*!   2015:       spinedx, dx9(DX1-DX30) dx10(I10_DX1-I10_DX30)
*!   2016-2023:  spinedx, dx10(I10_DX1-I10_DX40)
*!   all years:  spinedx, dx9(DX1-DX30) dx10(I10_DX1-I10_DX40)
*!
*! Diagnoses only: procedure codes are deliberately not used.
*!
*! Matching rule: a cleaned code (dots and spaces removed, upper case) matches a
*! library row when it BEGINS WITH the prefix for that coding system. A prefix
*! ending in "=" (e.g. 9964=) matches only that exact code. Edit the
*! CSV to change categories; the program never needs editing.
*!
*! Requires Stata 16 or later (frames).

program define spinedx
    version 16
    syntax [if] [in] , [DX10(varlist) DX9(varlist) ///
        ICDver(varname numeric) IDvar(varname) LIBrary(string) REPLACE]

    if "`dx10'`dx9'" == "" {
        di as err "specify dx10() and/or dx9()"
        exit 198
    }
    foreach opt in dx10 dx9 {
        foreach v of local `opt' {
            capture confirm string variable `v'
            if _rc {
                di as err "`opt'() variable `v' must be a string variable"
                exit 109
            }
        }
    }

    * ---- jobs: (coding system, variables, row condition) -------------------
    local nj 0
    foreach opt in dx10 dx9 {
        if "``opt''" == "" continue
        local ++nj
        local vars`nj' ``opt''
        if "`opt'" == "dx10" local sys`nj' icd10cm
        if "`opt'" == "dx9"  local sys`nj' icd9cm
        local cond`nj' 1
        if "`icdver'" != "" & "`opt'" == "dx10" local cond`nj' `icdver' == 10
        if "`icdver'" != "" & "`opt'" == "dx9"  local cond`nj' `icdver' == 9
    }

    * ---- library location ----------------------------------------------
    if `"`library'"' == "" {
        capture findfile spinedx_codes.csv
        if _rc {
            di as err "spinedx_codes.csv not found on the adopath; use library()"
            exit 601
        }
        local library `"`r(fn)'"'
    }
    else {
        confirm file `"`library'"'
    }

    * ---- output variables -------------------------------------------------
    local sdx
    forvalues k = 1/16 {
        local sdx `sdx' SPINEDX`k'
    }
    local reg REG_A REG_C REG_CT REG_T REG_TL REG_L REG_LS REG_S REG_M
    local flags `sdx' `reg'
    local out DEGDX `flags' ANYSPINE

    foreach v of local out {
        capture confirm variable `v', exact
        if !_rc {
            if "`replace'" != "" {
                drop `v'
            }
            else {
                di as err "variable `v' already exists; specify replace"
                exit 110
            }
        }
    }

    marksample touse, novarlist

    di as txt "spinedx v2.6: library " as res `"`library'"'

    * ---- load library: one row per (system, prefix) with 0/1 indicators -----
    tempname LIB
    frame create `LIB'
    frame `LIB' {
        quietly import delimited using `"`library'"', varnames(1) ///
            stringcols(_all) clear
        confirm variable system prefix variable
        quietly {
            replace system   = lower(strtrim(system))
            replace prefix   = upper(subinstr(subinstr(strtrim(prefix), ".", "", .), " ", "", .))
            replace variable = upper(strtrim(variable))
            drop if prefix == ""
            gen byte _ok = 0
            foreach f of local flags {
                gen byte l_`f' = (variable == "`f'")
                replace _ok = 1 if l_`f' == 1
            }
            count if _ok == 0
            if r(N) > 0 {
                noisily di as txt "note: " r(N) ///
                    " library row(s) name an unknown variable and were ignored"
            }
            drop if _ok == 0
            collapse (max) l_*, by(system prefix)
            gen byte _exact = substr(prefix, -1, 1) == "="
            replace prefix = substr(prefix, 1, strlen(prefix) - 1) if _exact
            gen byte _len = strlen(prefix)
            rename prefix _p
        }
    }

    * ---- initialise outputs --------------------------------------------------
    foreach f in DEGDX `flags' {
        quietly gen byte `f' = 0 if `touse'
    }

    forvalues j = 1/`nj' {
        local sys  `sys`j''
        local vars `vars`j''
        tempvar sm
        quietly gen byte `sm' = `touse' & (`cond`j'')

        * 1. collect the distinct raw code values across all variables
        tempfile uq
        tempname T U
        local first 1
        foreach v of local vars {
            frame put `v' if `sm' & !missing(`v'), into(`T')
            frame `T' {
                rename `v' _raw
                quietly bysort _raw: keep if _n == 1
                if !`first' quietly append using `"`uq'"'
                quietly save `"`uq'"', replace
            }
            frame drop `T'
            local first 0
        }

        * 2. classify each distinct value once
        frame create `U'
        frame `U' {
            quietly use `"`uq'"', clear
            quietly bysort _raw: keep if _n == 1
            quietly gen _c = upper(subinstr(subinstr(strtrim(_raw), ".", "", .), " ", "", .))
            foreach f of local flags {
                quietly gen byte a_`f' = 0
            }
        }
        forvalues L = 3/8 {
            tempfile lf
            frame `LIB' {
                preserve
                quietly keep if system == "`sys'" & _len == `L' & !_exact
                keep _p l_*
                quietly save `"`lf'"'
                restore
            }
            frame `U' {
                quietly gen _p = substr(_c, 1, `L')
                quietly merge m:1 _p using `"`lf'"', keep(master match) nogenerate
                foreach f of local flags {
                    quietly replace a_`f' = 1 if l_`f' == 1
                }
                drop _p l_*
            }
        }
        * exact-match rows: the whole cleaned code must equal the prefix
        tempfile xf
        quietly frame `LIB': count if system == "`sys'" & _exact
        local nx = r(N)
        if `nx' > 0 {
            frame `LIB' {
                preserve
                quietly keep if system == "`sys'" & _exact
                keep _p l_*
                quietly save `"`xf'"'
                restore
            }
            frame `U' {
                quietly gen _p = _c
                quietly merge m:1 _p using `"`xf'"', keep(master match) nogenerate
                foreach f of local flags {
                    quietly replace a_`f' = 1 if l_`f' == 1
                }
                drop _p l_*
            }
        }
        frame `U' {
            * degenerative hierarchy: highest of categories 1-6
            quietly gen byte a_DEGDX = 0
            forvalues k = 1/6 {
                quietly replace a_DEGDX = `k' if a_SPINEDX`k' == 1
            }
            quietly egen byte _any = rowmax(a_*)
            quietly keep if _any > 0
            drop _any _c
        }

        * 3. map back to the data, one variable at a time
        foreach v of local vars {
            tempvar lk
            quietly frlink m:1 `v', frame(`U' _raw) generate(`lk')
            quietly frget a_*, from(`lk') prefix(_t)
            foreach f in DEGDX `flags' {
                quietly replace `f' = max(`f', _ta_`f') if `sm'
            }
            drop _ta_* `lk'
        }
        frame drop `U'
        drop `sm'
    }
    frame drop `LIB'

    * ---- aggregate within idvar (long data) ----------------------------------
    if "`idvar'" != "" {
        tempvar ord m
        quietly gen long `ord' = _n
        sort `idvar' `ord'
        foreach f in DEGDX `flags' {
            quietly by `idvar': egen byte `m' = max(`f')
            quietly replace `f' = `m' if !missing(`m')
            drop `m'
        }
        sort `ord'
    }

    * ---- derived variables ------------------------------------------------------
    quietly replace REG_M = 1 if REG_A + REG_C + REG_CT + REG_T + REG_TL + ///
        REG_L + REG_LS + REG_S > 1 & !missing(REG_A)
    quietly egen byte ANYSPINE = rowmax(`sdx') if !missing(SPINEDX1)
    foreach v in DEGDX `sdx' {
        quietly replace `v' = . if ANYSPINE == 0
    }

    * ---- labels --------------------------------------------------------------------
    label define DEGDX 0 "other spine dx" 1 "strains" 2 "disc degeneration" ///
        3 "herniated" 4 "stenosis" 5 "listhesis/instability" 6 "deformity", replace
    label values DEGDX DEGDX
    label variable DEGDX     "Spine diagnosis hierarchy (highest of 1-6)"
    label variable SPINEDX1  "Sprains/strains"
    label variable SPINEDX2  "Disc degeneration"
    label variable SPINEDX3  "Disc herniation"
    label variable SPINEDX4  "Stenosis"
    label variable SPINEDX5  "Spondylolisthesis, instability, dislocation/subluxation"
    label variable SPINEDX6  "Scoliosis/kyphosis/deformity"
    label variable SPINEDX7  "Radiculopathy"
    label variable SPINEDX8  "Vertebral fracture"
    label variable SPINEDX9  "Spinal cord injury"
    label variable SPINEDX10 "Congenital or other anomaly"
    label variable SPINEDX11 "Inflammatory spondylopathy"
    label variable SPINEDX12 "Spine osteoporotic/pathological/fatigue fracture"
    label variable SPINEDX13 "Surgical aftercare / device complication"
    label variable SPINEDX14 "Spinal infection (ICD-10 codes only)"
    label variable SPINEDX15 "Myelopathy"
    label variable SPINEDX16 "Spine-specific neoplasm"
    label variable REG_A  "Atlas/axis"
    label variable REG_C  "Cervical"
    label variable REG_CT "Cervicothoracic"
    label variable REG_T  "Thoracic"
    label variable REG_TL "Thoracolumbar"
    label variable REG_L  "Lumbar"
    label variable REG_LS "Lumbosacral"
    label variable REG_S  "Sacral/coccyx"
    label variable REG_M  "Multiple vertebral regions"
    label variable ANYSPINE "Any spine diagnosis"
    label define YESNO 0 "NO" 1 "YES", replace
    label values ANYSPINE YESNO

    quietly count if ANYSPINE == 1
    di as txt "spinedx: " as res r(N) as txt " observation(s) with a spine diagnosis"
end
