# spineinv

**Surgical Invasiveness Index from CPT codes in Stata**

`spineinv` calculates the Surgical Invasiveness Index (Mirza et al., 2008) from CPT/HCPCS procedure codes. The index counts the vertebrae treated by each of six interventions: anterior decompression, fusion and instrumentation, and posterior decompression, fusion and instrumentation. Higher scores indicate more invasive surgery.

## Installation

In Stata 16 or later:

```stata
net install spineinv, from("https://raw.githubusercontent.com/GITHUB-USER/spine-stata/main/spineinv/") replace
```

To also download the regression test to your current folder:

```stata
net get spineinv, from("https://raw.githubusercontent.com/GITHUB-USER/spine-stata/main/spineinv/")
do spineinv_test.do
```

## Usage

```stata
* One record per encounter
spineinv CPT1-CPT30

* Long data (one row per procedure)
spineinv cpt, idvar(encounter_id)
```

See `help spineinv` for all options.

## Output

| Variable | Description |
|---|---|
| `SCORE` | Surgical Invasiveness Index (0 if CPT codes are present but none scores; missing if all CPT fields are empty) |
| `err1` | An add-on code is present without any of its primary codes (the add-on is still scored) |
| `err2` | A non-additive code is repeated (it is counted once) |
| `err3` | Points not counted because tiered codes in the same group were co-coded |

`r(N)`, `r(N_err1)`, `r(N_err2)` and `r(N_err3)` are returned.

## How it works

Scores are defined by a code library, `spineinv_codes.csv`, installed alongside the program:

| Column | Meaning |
|---|---|
| `code` | CPT/HCPCS code |
| `score` | Points for the first occurrence of the code |
| `repeat` | Points for each further occurrence (add-on codes such as "each additional level"); 0 means a repeat is a non-additive duplicate |
| `tiergrp` | Codes in the same group (e.g. instrumentation of 3-6, 7-12, 13+ segments) are not additive; only the highest-scoring code counts |
| `primaries` | For add-on codes, the primary codes they are reported with |
| `label` | Short description |

Points follow the index's convention of counting vertebrae: a 1-level fusion fuses two vertebrae and scores 2, and each additional level adds 1. To adapt scores, edit a copy of the library and pass it with `library()`.

Where data have no units-of-service variable (as in NASS), an add-on code billed for several levels may appear once and is scored once.

## Files

| File | Purpose |
|---|---|
| `spineinv.ado` | The program |
| `spineinv.sthlp` | Stata help file |
| `spineinv_codes.csv` | Code library |
| `spineinv_test.do` | Regression test |
| `spineinv.pkg`, `stata.toc` | Package files for `net install` |

## Reference

Mirza SK, Deyo RA, Heagerty PJ, Konodi MA, Lee LA, Turner JA, Goodkin R. Development of an index to characterize the "invasiveness" of spine surgery: validation by comparison to blood loss and operative time. *Spine*. 2008;33(24):2651-2661. [doi:10.1097/BRS.0b013e31818dad07](https://doi.org/10.1097/BRS.0b013e31818dad07)

## Related programs

- [`spinedx`](../spinedx): classify spine diagnoses from ICD-9-CM and ICD-10-CM codes
- [`spinesx`](../spinesx): classify spine procedures from CPT codes

## Citation

> Martin BI. spineinv: Stata program to calculate the Surgical Invasiveness Index from CPT codes. Version 5.1. 2026. https://github.com/GITHUB-USER/spine-stata

## Author

Brook I. Martin, PhD, MPH
Department of Orthopaedics, University of Utah
Brook.Martin@hsc.utah.edu

## License

MIT; see [LICENSE](../LICENSE).

CPT (Current Procedural Terminology) is copyright of the American Medical Association. The code library lists CPT code numbers with short descriptions written for this program; it does not reproduce AMA descriptors. Users are responsible for their own CPT licensing where required.
