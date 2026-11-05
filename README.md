# spine-stata

**Stata programs for classifying spine diagnoses and procedures in administrative data**

| Program | Purpose | Input |
|---|---|---|
| [`spinedx`](spinedx) | Classifies spine diagnoses into 16 categories, a degenerative diagnosis hierarchy and vertebral regions, consistently across ICD-9-CM and ICD-10-CM | ICD-9-CM / ICD-10-CM diagnosis codes |
| [`spinesx`](spinesx) | Classifies spine procedures into 18 groups and vertebral regions, and estimates the number of levels fused and decompressed | CPT / HCPCS codes |
| [`spineinv`](spineinv) | Calculates the Surgical Invasiveness Index (Mirza et al., 2008) | CPT / HCPCS codes |

The programs were developed for HCUP databases such as the National Inpatient Sample (NIS) and the Nationwide Ambulatory Surgery Sample (NASS), but work with any data holding codes in string variables. Each is driven by a code library (a CSV file installed with the program), so definitions can be reviewed and adapted without editing the program.

## Installation

Stata 16 or later is required. Install any or all of the programs:

```stata
net install spinedx,  from("https://raw.githubusercontent.com/GITHUB-USER/spine-stata/main/spinedx/")  replace
net install spinesx,  from("https://raw.githubusercontent.com/GITHUB-USER/spine-stata/main/spinesx/")  replace
net install spineinv, from("https://raw.githubusercontent.com/GITHUB-USER/spine-stata/main/spineinv/") replace
```

Then see `help spinedx`, `help spinesx` or `help spineinv`.

Each program comes with a regression test, downloaded to the current folder with `net get` (e.g. `net get spinedx, from(...)`) and run with `do spinedx_test.do`.

## Quick example

```stata
* Outpatient spine surgery (HCUP NASS)
spinesx, cpt(CPT1-CPT30)
spineinv CPT1-CPT30
spinedx, dx10(I10_DX1-I10_DX40)

* Invasiveness of lumbar fusions for stenosis
summarize SCORE if SPINESX9 == 1 & REGSX_L == 1 & SPINEDX4 == 1, detail
```

## Repository structure

```
spine-stata/
├── LICENSE
├── README.md
├── spinedx/     stata.toc, spinedx.pkg, spinedx.ado, spinedx.sthlp,
│                spinedx_codes.csv, spinedx_test.do, README.md
├── spinesx/     (same structure)
└── spineinv/    (same structure)
```

Each subfolder is a self-contained Stata package; see its README for details.

## Citation

If you use these programs in published work, please cite the program(s) used, for example:

> Martin BI. spinedx: Stata program to classify spine diagnoses from ICD-9-CM and ICD-10-CM codes. Version 2.6. 2026. https://github.com/GITHUB-USER/spine-stata

For the invasiveness index, please also cite:

> Mirza SK, Deyo RA, Heagerty PJ, Konodi MA, Lee LA, Turner JA, Goodkin R. Development of an index to characterize the "invasiveness" of spine surgery: validation by comparison to blood loss and operative time. *Spine*. 2008;33(24):2651-2661. [doi:10.1097/BRS.0b013e31818dad07](https://doi.org/10.1097/BRS.0b013e31818dad07)

## Author

Brook I. Martin, PhD, MPH
Department of Orthopaedics, University of Utah
Brook.Martin@hsc.utah.edu

## License

MIT; see [LICENSE](LICENSE).

ICD-9-CM and ICD-10-CM are maintained by the Centers for Medicare & Medicaid Services and the National Center for Health Statistics. CPT (Current Procedural Terminology) is copyright of the American Medical Association; the `spinesx` and `spineinv` libraries list CPT code numbers with short descriptions written for these programs and do not reproduce AMA descriptors. Users are responsible for their own CPT licensing where required.
