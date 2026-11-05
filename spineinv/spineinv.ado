*! spineinv v5.1 (CPT)  Brook I. Martin  05Nov2026
*! Department of Orthopaedics, University of Utah
*!
*! Surgical Invasiveness Index from CPT/HCPCS codes, using the external
*! library spineinv_codes.csv.
*!
*! Syntax
*!   spineinv varlist [if] [in] [, idvar(varname) library(filename) replace]
*!
*!   varlist    string CPT variables, e.g. CPT1-CPT30. Codes are cleaned
*!              (spaces removed, upper case) and the first 5 characters are
*!              matched exactly.
*!   idvar()    pool the codes of all rows with the same idvar (long data, or
*!              several claims per patient). Results are written on every row;
*!              the data are not reshaped or collapsed.
*!   library()  code library; default spineinv_codes.csv on the adopath
*!   replace    overwrite SCORE, err1, err2, err3 if they exist
*!
*! Scoring rules (all driven by the library):
*!   - score:   points for the first occurrence of a code
*!   - repeat:  points for each further occurrence (add-on codes); 0 means a
*!              repeated code is a non-additive duplicate (flagged in err2)
*!   - tiergrp: codes in the same tier group (e.g. 22842/22843/22844) are not
*!              additive; only the highest-scoring code present counts, and
*!              the points removed are recorded in err3
*!   - primaries: an add-on code with none of its primary codes present is
*!              flagged in err1 (it is still scored)
*!
*! Outputs: SCORE (missing if all CPT fields are empty), err1, err2 (0/1),
*! err3 (points removed for co-coded tiers). Returns r(N), r(N_err1),
*! r(N_err2), r(N_err3).
*!
*! Current Procedural Terminology is copyright of the American Medical
*! Association. Requires Stata 16 or later (frames).

program define spineinv, rclass
    version 16
    syntax varlist(min=1 string) [if] [in] [, IDvar(varname) LIBrary(string) REPLACE]

    if `"`library'"' == "" {
        capture findfile spineinv_codes.csv
        if _rc {
            di as err "spineinv_codes.csv not found on the adopath; use library()"
            exit 601
        }
        local library `"`r(fn)'"'
    }
    else confirm file `"`library'"'

    foreach v in SCORE err1 err2 err3 {
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
    quietly count if `touse'
    if r(N) == 0 error 2000

    di as txt "spineinv v5.1: library " as res `"`library'"'

    * ---- grouping key: one record, or all rows of an idvar --------------------
    tempvar grp nonmiss ord
    quietly gen long `ord' = _n
    if "`idvar'" != "" quietly egen long `grp' = group(`idvar') if `touse', missing
    else quietly gen long `grp' = _n if `touse'

    * ---- library and add-on families ------------------------------------------
    tempname LIB T L P R
    tempfile libf famf longf e1f
    frame create `LIB'
    frame `LIB' {
        quietly import delimited using `"`library'"', varnames(1) stringcols(_all) clear
        confirm variable code score repeat tiergrp primaries
        quietly {
            replace code = upper(subinstr(strtrim(code), " ", "", .))
            destring score repeat tiergrp, replace
            keep code score repeat tiergrp primaries
            drop if code == ""
            save `"`libf'"'
            * family table: each add-on with itself (role 1) and its primaries (role 2)
            keep if strtrim(primaries) != ""
            gen fam = code
            split primaries, gen(_p)
            gen _p0 = code
            keep fam _p*
            reshape long _p, i(fam) j(_j)
            drop if _p == ""
            gen byte role = cond(_j == 0, 1, 2)
            rename _p code
            keep code fam role
            save `"`famf'"'
        }
    }
    frame drop `LIB'

    * ---- long file of matched codes (only codes in the library) -----------------
    local first 1
    foreach v of local varlist {
        frame put `grp' `v' if `touse' & !missing(`v'), into(`T')
        frame `T' {
            rename `grp' _grp
            rename `v' _raw
            quietly gen str5 code = substr(upper(subinstr(strtrim(_raw), " ", "", .)), 1, 5)
            drop _raw
            quietly merge m:1 code using `"`libf'"', keep(match) nogenerate
            if !`first' quietly append using `"`longf'"'
            quietly save `"`longf'"', replace
        }
        frame drop `T'
        local first 0
    }

    frame create `L'
    frame `L' {
        quietly use `"`longf'"', clear
        local nlong = _N
    }

    if `nlong' > 0 {
        frame `L' {
            quietly {
                * occurrence number of each code within the record
                bysort _grp code: gen int _k = _n
                gen double _pts = cond(_k == 1, score, repeat) if tiergrp == 0
                gen byte _dup = _k > 1 & repeat == 0
                * tiers: first occurrence only; keep the highest score per group
                gen double _e3 = score if tiergrp > 0 & _k == 1
                bysort _grp tiergrp: egen double _tmax = max(_e3) if tiergrp > 0
                egen byte _tag = tag(_grp tiergrp) if tiergrp > 0 & _k == 1
                replace _pts = _tmax if _tag == 1
                replace _e3 = _e3 - _tmax if _tag == 1
                * err1: add-on present with none of its primaries
                preserve
                keep _grp code
                duplicates drop
                joinby code using `"`famf'"'
                if _N > 0 {
                    gen byte _isadd = role == 1
                    gen byte _isprim = role == 2
                    collapse (max) _isadd _isprim, by(_grp fam)
                    gen byte err1 = _isadd & !_isprim
                    collapse (max) err1, by(_grp)
                }
                else {
                    keep _grp
                    gen byte err1 = .
                }
                save `"`e1f'"'
                restore
                collapse (sum) SCORE=_pts err3=_e3 (max) err2=_dup, by(_grp)
                merge 1:1 _grp using `"`e1f'"', nogenerate
                replace err1 = 0 if missing(err1)
            }
        }
        quietly frlink m:1 `grp', frame(`L' _grp)
        quietly frget SCORE err1 err2 err3, from(`L')
        drop `L'
    }
    else {
        quietly gen double SCORE = .
        quietly gen byte err1 = .
        quietly gen byte err2 = .
        quietly gen double err3 = .
    }
    frame drop `L'

    * ---- records with codes but no scored code get 0; all-empty records missing
    quietly egen `nonmiss' = rownonmiss(`varlist'), strok
    if "`idvar'" != "" {
        tempvar anyc
        quietly bysort `grp': egen `anyc' = max(`nonmiss')
        quietly replace `nonmiss' = `anyc'
        sort `ord'
    }
    foreach v in SCORE err1 err2 err3 {
        quietly replace `v' = 0 if `touse' & missing(`v') & `nonmiss' > 0
        quietly replace `v' = . if !`touse' | `nonmiss' == 0
    }

    label variable SCORE "Surgical invasiveness index (CPT)"
    label variable err1  "Add-on code without its primary code"
    label variable err2  "Non-additive duplicate code (counted once)"
    label variable err3  "Points removed for co-coded tiers"

    * ---- notes ---------------------------------------------------------------------
    quietly count if `touse' & !missing(SCORE)
    local N = r(N)
    quietly count if `touse' & err1 == 1
    local n1 = r(N)
    quietly count if `touse' & err2 == 1
    local n2 = r(N)
    quietly count if `touse' & err3 > 0 & !missing(err3)
    local n3 = r(N)
    summarize SCORE if `touse'
    di as txt "err1: " as res `n1' as txt " record(s) with an add-on code but none of its primary codes (scored as coded)"
    di as txt "err2: " as res `n2' as txt " record(s) with a repeated non-additive code (counted once)"
    di as txt "err3: " as res `n3' as txt " record(s) with co-coded tiers (only the highest tier counted)"
    di as txt "Current Procedural Terminology is copyright of the American Medical Association"

    return scalar N = `N'
    return scalar N_err1 = `n1'
    return scalar N_err2 = `n2'
    return scalar N_err3 = `n3'
end
