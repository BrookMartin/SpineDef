*! spinesx v2.2 (CPT/HCPCS)  Brook I. Martin  03Nov2026
*! Department of Orthopaedics, University of Utah
*!
*! Classifies spine procedures from CPT/HCPCS codes into procedure groups
*! (SPINESX1-SPINESX18), vertebral regions (REGSX_*), the number of add-on
*! codes (ADDLEV), the minimum additional segments implied by tiered codes
*! (TIERED), and the minimum and maximum number of levels fused
*! (NFUSLEV_MIN, NFUSLEV_MAX) and decompressed (NDECLEV_MIN, NDECLEV_MAX),
*! using the external library spinesx_codes.csv. A level is a motion segment
*! (interspace): a 1-level fusion joins 2 vertebrae. Designed for HCUP NASS (2016+) but works on any data
*! with CPT codes in string variables.
*!
*! Syntax
*!   spinesx [if] [in], cpt(varlist) [idvar(varname) library(filename) replace]
*!
*!   cpt()      string CPT variables, e.g. cpt(CPT1-CPT30). Codes are cleaned
*!              (spaces removed, upper case) and the first 5 characters are
*!              matched EXACTLY against the library, so trailing modifiers
*!              are ignored.
*!   idvar()    long data: flags take the maximum and counts the sum within
*!              idvar, on every row (no collapse)
*!   library()  code library; default spinesx_codes.csv on the adopath
*!   replace    overwrite existing output variables
*!
*! Library columns: code, variable, value, label. To change a group, edit the
*! CSV; the program never needs editing.
*!
*! Requires Stata 16 or later (frames).

program define spinesx
    version 16
    syntax [if] [in] , CPT(varlist) [IDvar(varname) LIBrary(string) REPLACE]

    foreach v of local cpt {
        capture confirm string variable `v'
        if _rc {
            di as err "cpt() variable `v' must be a string variable"
            exit 109
        }
    }

    if `"`library'"' == "" {
        capture findfile spinesx_codes.csv
        if _rc {
            di as err "spinesx_codes.csv not found on the adopath; use library()"
            exit 601
        }
        local library `"`r(fn)'"'
    }
    else confirm file `"`library'"'

    local grp
    forvalues k = 1/18 {
        local grp `grp' SPINESX`k'
    }
    local reg REGSX_A REGSX_C REGSX_CT REGSX_T REGSX_TL REGSX_L REGSX_LS REGSX_S
    local flags `grp' `reg'
    local maxv  TIERED FUS_LO FUS_HI
    local sumv  ADDLEV FUS_A FUS_P FUS_I FUS_L FUS_D DEC_P DEC_PH DEC_A
    local out `flags' REGSX_M ADDLEV TIERED NFUSLEV_MIN NFUSLEV_MAX NDECLEV_MIN NDECLEV_MAX ANYSX

    foreach v in `out' `maxv' `sumv' {
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
    di as txt "spinesx v2.2: library " as res `"`library'"'

    * ---- library: one row per code, a column per output ----------------------
    tempname LIB T U
    tempfile libf uq
    frame create `LIB'
    frame `LIB' {
        quietly import delimited using `"`library'"', varnames(1) ///
            stringcols(_all) clear
        confirm variable code variable value
        quietly {
            replace code     = upper(subinstr(strtrim(code), " ", "", .))
            replace variable = upper(strtrim(variable))
            destring value, replace
            gen byte _ok = 0
            foreach f in `flags' `maxv' `sumv' {
                gen byte l_`f' = cond(variable == "`f'", value, 0)
                replace _ok = 1 if variable == "`f'"
            }
            count if _ok == 0
            if r(N) noisily di as txt "note: " r(N) ///
                " library row(s) name an unknown variable and were ignored"
            drop if _ok == 0 | code == ""
            collapse (max) l_*, by(code)
            rename code _code
            save `"`libf'"'
        }
    }
    frame drop `LIB'

    * ---- distinct code values across all CPT variables -------------------------
    local first 1
    foreach v of local cpt {
        frame put `v' if `touse' & !missing(`v'), into(`T')
        frame `T' {
            rename `v' _raw
            quietly bysort _raw: keep if _n == 1
            if !`first' quietly append using `"`uq'"'
            quietly save `"`uq'"', replace
        }
        frame drop `T'
        local first 0
    }

    * ---- classify each distinct value once --------------------------------------
    frame create `U'
    frame `U' {
        quietly use `"`uq'"', clear
        quietly bysort _raw: keep if _n == 1
        quietly gen _code = substr(upper(subinstr(strtrim(_raw), " ", "", .)), 1, 5)
        quietly merge m:1 _code using `"`libf'"', keep(match) nogenerate
        drop _code
    }

    * ---- map back: flags and TIERED by max, ADDLEV by count of fields --------
    foreach f of local flags {
        quietly gen byte `f' = 0 if `touse'
    }
    foreach f in `maxv' `sumv' {
        quietly gen int `f' = 0 if `touse'
    }
    foreach v of local cpt {
        tempvar lk
        quietly frlink m:1 `v', frame(`U' _raw) generate(`lk')
        quietly frget l_*, from(`lk') prefix(_t)
        foreach f in `flags' `maxv' {
            quietly replace `f' = max(`f', _tl_`f') if `touse' & !missing(_tl_`f')
        }
        foreach f of local sumv {
            quietly replace `f' = `f' + _tl_`f' if `touse' & !missing(_tl_`f')
        }
        drop _tl_* `lk'
    }
    frame drop `U'

    * ---- long data ------------------------------------------------------------------
    if "`idvar'" != "" {
        tempvar ord m
        quietly gen long `ord' = _n
        sort `idvar' `ord'
        foreach f in `flags' `maxv' {
            quietly by `idvar': egen int `m' = max(`f')
            quietly replace `f' = `m' if `touse'
            drop `m'
        }
        foreach f of local sumv {
            quietly by `idvar': egen int `m' = total(`f')
            quietly replace `f' = `m' if `touse'
            drop `m'
        }
        sort `ord'
    }

    * ---- multiple regions --------------------------------------------------------
    * CPT region codes are often ranges ("cervical or thoracic", "lumbar or
    * sacral"), so REGSX_M is set only when the codes cannot all fall within
    * ONE broad region: cervical (A, C, CT), thoracic (CT, T, TL) or
    * lumbosacral (TL, L, LS, S).
    tempvar fc ft fl anyr
    quietly gen byte `fc' = !(REGSX_T | REGSX_TL | REGSX_L | REGSX_LS | REGSX_S)
    quietly gen byte `ft' = !(REGSX_A | REGSX_C | REGSX_L | REGSX_LS | REGSX_S)
    quietly gen byte `fl' = !(REGSX_A | REGSX_C | REGSX_CT | REGSX_T)
    quietly egen byte `anyr' = rowmax(`reg') if `touse'
    quietly gen byte REGSX_M = (`anyr' == 1 & !(`fc' | `ft' | `fl')) if `touse'

    * ---- estimated levels (motion segments, not vertebrae) ---------------------
    * NASS has no units, so a code billed for several levels may appear once.
    * MIN assumes different approaches (anterior, posterior, posterior
    * interbody, lateral, interbody device) treat the same levels and is raised
    * to the minimum implied by any tiered code. MAX assumes anterior,
    * posterior and lateral approaches treat different levels and allows the
    * maximum implied by tiered codes (open-ended tiers use their minimum).
    quietly gen byte NFUSLEV_MIN = max(FUS_A, FUS_P, FUS_I, FUS_L, FUS_D, FUS_LO) if SPINESX9 == 1
    quietly gen byte NFUSLEV_MAX = max(FUS_A + max(FUS_P, FUS_I) + FUS_L, FUS_HI, NFUSLEV_MIN) if SPINESX9 == 1
    quietly gen byte NDECLEV_MIN = max(DEC_P, DEC_A) if SPINESX6 == 1
    quietly gen byte NDECLEV_MAX = DEC_PH + DEC_A if SPINESX6 == 1
    drop FUS_A FUS_P FUS_I FUS_L FUS_D FUS_LO FUS_HI DEC_P DEC_PH DEC_A

    quietly egen byte ANYSX = rowmax(`grp') if `touse'
    foreach v in `grp' {
        quietly replace `v' = . if ANYSX == 0
    }

    * ---- labels ------------------------------------------------------------------
    label variable SPINESX1  "Ablation / neurolysis / radiosurgery (includes SI joint)"
    label variable SPINESX2  "Disc arthroplasty (ADR)"
    label variable SPINESX3  "Vertebral augmentation (vertebroplasty, kyphoplasty, sacroplasty)"
    label variable SPINESX4  "Brace, halo or closed fracture treatment"
    label variable SPINESX5  "Corpectomy or osteotomy"
    label variable SPINESX6  "Decompression (laminectomy, laminotomy, discectomy)"
    label variable SPINESX7  "Distraction or non-fusion stabilization"
    label variable SPINESX8  "Excision, biopsy or intradural procedure"
    label variable SPINESX9  "Fusion (arthrodesis or interbody device; includes SI joint)"
    label variable SPINESX10 "Bone graft (spine)"
    label variable SPINESX11 "Injection, drainage or aspiration (includes SI joint)"
    label variable SPINESX12 "Meningocele, dural repair or CSF shunt"
    label variable SPINESX13 "Spinal neurostimulator"
    label variable SPINESX14 "Open fracture repair"
    label variable SPINESX15 "Intrathecal/epidural pump or catheter"
    label variable SPINESX16 "Removal, revision or reinsertion"
    label variable SPINESX17 "Rhizotomy or cordotomy"
    label variable SPINESX18 "Spinal instrumentation (rods, plates, screws; not interbody)"
    label variable REGSX_A  "Atlas/axis"
    label variable REGSX_C  "Cervical"
    label variable REGSX_CT "Cervical or thoracic / cervicothoracic"
    label variable REGSX_T  "Thoracic"
    label variable REGSX_TL "Thoracic or lumbar / thoracolumbar"
    label variable REGSX_L  "Lumbar"
    label variable REGSX_LS "Lumbar or sacral / lumbosacral"
    label variable REGSX_S  "Sacral/coccyx/sacroiliac joint"
    label variable REGSX_M  "Multiple broad regions"
    label variable ADDLEV   "Number of add-on (additional level) CPT codes"
    label variable TIERED   "Minimum additional segments implied by tiered codes"
    label variable NFUSLEV_MIN "Levels fused, minimum (1 level = 2 vertebrae)"
    label variable NFUSLEV_MAX "Levels fused, maximum"
    label variable NDECLEV_MIN "Levels decompressed, minimum"
    label variable NDECLEV_MAX "Levels decompressed, maximum"
    label variable ANYSX    "Any spine or SI joint procedure"
    label define YESNO 0 "NO" 1 "YES", replace
    label values ANYSX YESNO

    quietly count if ANYSX == 1
    di as txt "spinesx: " as res r(N) as txt " observation(s) with a spine procedure"
end
