*! orthopsi v2.1 (ICD-9-CM and ICD-10-CM)  Brook I. Martin  06Nov2026
*! Department of Orthopaedics, University of Utah
*!
*! Flags 15 categories of post-procedure complications ("patient safety
*! indicators") after orthopaedic surgery, plus device-related infection, from
*! ICD-9-CM and ICD-10-CM diagnosis codes, using the external prefix library
*! orthopsi_codes.csv.
*!
*! Syntax
*!   orthopsi [if] [in], [dx10(varlist) dx9(varlist) icdver(varname)
*!                        procedure(string) sequela idvar(varname)
*!                        library(filename) replace]
*!
*!   dx10()       ICD-10-CM diagnosis variables (string; dots optional, any case)
*!   dx9()        ICD-9-CM diagnosis variables (string; dots optional)
*!   icdver()     numeric variable equal to 9 or 10; when given, dx9() is read
*!                only where icdver==9 and dx10() only where icdver==10
*!   procedure()  procedure type(s) whose site-specific codes apply, any of:
*!                spine hip knee upper lower foot hand, or all
*!   sequela      also count ICD-10-CM sequela codes (7th character S);
*!                by default they are not counted
*!   idvar()      long data: flags are set to the maximum within idvar and
*!                written on every row (the data are not collapsed)
*!   library()    code library; default orthopsi_codes.csv on the adopath
*!   replace      overwrite output variables that already exist
*!
*! dx() is accepted as a synonym for dx10(), and sp hp kn upx lox ft hnd as
*! synonyms for procedure(spine), procedure(hip), etc.
*!
*! Matching: a cleaned code (dots and spaces removed, upper case) matches a
*! library row when it BEGINS WITH the row's prefix for its coding system. A
*! prefix ending in "=" matches only that exact code.
*!
*! Requires Stata 16 or later (frames).

program define orthopsi
    version 16
    syntax [if] [in] , [DX10(varlist) DX9(varlist) DX(varlist) ///
        ICDver(varname numeric) PROCedure(string) SEQuela IDvar(varname) ///
        LIBrary(string) REPLACE SP HP KN UPX LOX FT HND]

    local dx10 `dx10' `dx'
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

    * ---- procedure types -----------------------------------------------------
    local valid spine hip knee upper lower foot hand
    local procs = lower(`"`procedure'"')
    if "`sp'"  != "" local procs `procs' spine
    if "`hp'"  != "" local procs `procs' hip
    if "`kn'"  != "" local procs `procs' knee
    if "`upx'" != "" local procs `procs' upper
    if "`lox'" != "" local procs `procs' lower
    if "`ft'"  != "" local procs `procs' foot
    if "`hnd'" != "" local procs `procs' hand
    local procs : list uniq procs
    local hasall : list posof "all" in procs
    if `hasall' local procs `valid'
    local bad : list procs - valid
    if "`bad'" != "" {
        di as err "procedure(): `bad' not recognized; use spine hip knee upper lower foot hand or all"
        exit 198
    }

    * ---- library and outputs -------------------------------------------------
    if `"`library'"' == "" {
        capture findfile orthopsi_codes.csv
        if _rc {
            di as err "orthopsi_codes.csv not found on the adopath; use library()"
            exit 601
        }
        local library `"`r(fn)'"'
    }
    else confirm file `"`library'"'

    local cats
    forvalues k = 1/15 {
        local cats `cats' PSI`k'
    }
    local flags `cats' DEVINF
    foreach v in `flags' ANYPSI {
        capture confirm variable `v', exact
        if !_rc {
            if "`replace'" != "" drop `v'
            else {
                di as err "variable `v' already exists; specify replace"
                exit 110
            }
        }
    }

    marksample touse, novarlist
    di as txt "orthopsi v2.1: library " as res `"`library'"'
    if "`procs'" == "" di as txt "procedure-specific codes: none (use procedure() to include them)"
    else di as txt "procedure-specific codes: " as res "`procs'"
    if "`sequela'" == "" di as txt "ICD-10-CM sequela codes (7th character S): not counted"

    * ---- jobs: (coding system, variables, row condition) ----------------------
    local nj 0
    foreach opt in dx10 dx9 {
        if "``opt''" == "" continue
        local ++nj
        local vars`nj' ``opt''
        local sys`nj' = cond("`opt'" == "dx10", "icd10cm", "icd9cm")
        local cond`nj' 1
        if "`icdver'" != "" local cond`nj' `icdver' == `= cond("`opt'" == "dx10", 10, 9)'
    }

    tempname LIB
    frame create `LIB'
    frame `LIB' {
        quietly import delimited using `"`library'"', varnames(1) stringcols(_all) clear
        confirm variable system prefix variable procedure
        quietly {
            replace system    = lower(strtrim(system))
            replace prefix    = upper(subinstr(subinstr(strtrim(prefix), ".", "", .), " ", "", .))
            replace variable  = upper(strtrim(variable))
            replace procedure = lower(strtrim(procedure))
            drop if prefix == ""
            gen byte _use = procedure == "all" | procedure == ""
            foreach p of local procs {
                replace _use = 1 if procedure == "`p'"
            }
            keep if _use
            gen byte _ok = 0
            foreach f of local flags {
                gen byte l_`f' = (variable == "`f'")
                replace _ok = 1 if l_`f' == 1
            }
            count if _ok == 0
            if r(N) noisily di as txt "note: " r(N) " library row(s) name an unknown variable and were ignored"
            drop if _ok == 0
            collapse (max) l_*, by(system prefix)
            gen byte _exact = substr(prefix, -1, 1) == "="
            replace prefix = substr(prefix, 1, strlen(prefix) - 1) if _exact
            gen byte _len = strlen(prefix)
            rename prefix _p
        }
    }

    foreach f of local flags {
        quietly gen byte `f' = 0 if `touse'
    }

    forvalues j = 1/`nj' {
        local sys  `sys`j''
        local vars `vars`j''
        tempvar sm
        tempfile uq
        tempname T U
        quietly gen byte `sm' = `touse' & (`cond`j'')

        * distinct code values across the variables
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

        * classify each distinct value once
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
        quietly frame `LIB': count if system == "`sys'" & _exact
        if r(N) > 0 {
            tempfile xf
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
            * sequela: 7-character ICD-10-CM codes ending in S
            if "`sys'" == "icd10cm" & "`sequela'" == "" {
                foreach f of local flags {
                    quietly replace a_`f' = 0 if strlen(_c) == 7 & substr(_c, 7, 1) == "S"
                }
            }
            quietly egen byte _any = rowmax(a_*)
            quietly keep if _any > 0
            drop _any _c
        }

        * map back to the data
        foreach v of local vars {
            tempvar lk
            quietly frlink m:1 `v', frame(`U' _raw) generate(`lk')
            quietly frget a_*, from(`lk') prefix(_t)
            foreach f of local flags {
                quietly replace `f' = max(`f', _ta_`f') if `sm'
            }
            drop _ta_* `lk'
        }
        frame drop `U'
        drop `sm'
    }
    frame drop `LIB'

    * ---- long data -------------------------------------------------------------------
    if "`idvar'" != "" {
        tempvar ord m
        quietly gen long `ord' = _n
        sort `idvar' `ord'
        foreach f of local flags {
            quietly by `idvar': egen byte `m' = max(`f')
            quietly replace `f' = `m' if `touse' & !missing(`m')
            drop `m'
        }
        sort `ord'
    }

    quietly egen byte ANYPSI = rowmax(`cats') if `touse'

    label variable PSI1  "Skin"
    label variable PSI2  "Nervous system or musculoskeletal"
    label variable PSI3  "Gastrointestinal"
    label variable PSI4  "Respiratory"
    label variable PSI5  "Cardiac"
    label variable PSI6  "Genitourinary"
    label variable PSI7  "Other, including foreign body"
    label variable PSI8  "Infection or wound disruption"
    label variable PSI9  "Vascular"
    label variable PSI10 "Pulmonary embolism"
    label variable PSI11 "Deep vein thrombosis"
    label variable PSI12 "Abscess"
    label variable PSI13 "Cerebrovascular"
    label variable PSI14 "Device problem"
    label variable PSI15 "Anesthesia or medication"
    label variable DEVINF "Device-related infection (subset of PSI8)"
    label variable ANYPSI "Any complication"
    label define YESNO 0 "NO" 1 "YES", replace
    label values ANYPSI YESNO

    quietly count if ANYPSI == 1
    di as txt "orthopsi: " as res r(N) as txt " observation(s) with a complication"
end
