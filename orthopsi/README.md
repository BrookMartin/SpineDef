# orthopsi

**Post-procedure complications after orthopaedic surgery from ICD-9-CM and ICD-10-CM codes, in Stata**

`orthopsi` flags 15 categories of post-procedure complications ("patient safety indicators"), plus device-related infections, from ICD-9-CM and ICD-10-CM diagnosis codes. The definitions are designed for orthopaedic surgery: cardiac and respiratory complications, for example, use the codes for complications *following other (non-cardiac, nonthoracic) procedures*. Some codes apply only to particular procedures, such as dislocation of a hip prosthesis after hip arthroplasty or pseudarthrosis after spinal fusion; these are used only for the procedure types you specify.

## Installation

In Stata 16 or later:

```stata
net install orthopsi, from("https://raw.githubusercontent.com/BrookMartin/SpineDef/main/orthopsi/") replace
```

To also download the regression test to your current folder:

```stata
net get orthopsi, from("https://raw.githubusercontent.com/BrookMartin/SpineDef/main/orthopsi/")
do orthopsi_test.do
```

## Usage

```stata
* Spine surgery, ICD-10-CM
orthopsi, dx10(I10_DX1-I10_DX40) procedure(spine)

* Hip and knee arthroplasty, pooled years with separate ICD-9-CM and ICD-10-CM variables
orthopsi, dx9(DX1-DX30) dx10(I10_DX1-I10_DX40) procedure(hip knee)

* One set of variables holding both systems, with a 9/10 indicator
orthopsi, dx9(dx1-dx25) dx10(dx1-dx25) icdver(dxver) procedure(all)

* Long data (one row per diagnosis)
orthopsi, dx10(dx) idvar(patient_id) procedure(spine)
```

Procedure types are `spine`, `hip`, `knee`, `upper` (upper extremity), `lower` (lower extremity), `foot` and `hand`. Without `procedure()`, only codes that are not site-specific are used. ICD-10-CM sequela codes (7th character S) are not counted unless you add the `sequela` option. Codes can be stored with or without decimal points. See `help orthopsi` for all options.

With `idvar()`, results are pooled across all rows with the same id and written on every row; the data are not collapsed. For one row per id, follow with `bysort patient_id: keep if _n == 1`.

## Output

| Variable | Complication category |
|---|---|
| `PSI1` | Skin |
| `PSI2` | Nervous system or musculoskeletal (including dural tear and periprosthetic fracture) |
| `PSI3` | Gastrointestinal |
| `PSI4` | Respiratory |
| `PSI5` | Cardiac |
| `PSI6` | Genitourinary |
| `PSI7` | Other, including retained foreign body and postprocedural shock |
| `PSI8` | Infection or wound disruption (all postprocedural and device-related infections) |
| `PSI9` | Vascular |
| `PSI10` | Pulmonary embolism |
| `PSI11` | Deep vein thrombosis (acute; excludes superficial) |
| `PSI12` | Abscess |
| `PSI13` | Cerebrovascular |
| `PSI14` | Device problem (mechanical and other non-infectious) |
| `PSI15` | Anesthesia or medication |
| `DEVINF` | Device-related infection (a subset of `PSI8`) |
| `ANYPSI` | Any complication |

Categories are not mutually exclusive.

## How it works

The definitions are held in a code library, `orthopsi_codes.csv`, installed alongside the program. Each row gives a coding system (ICD-9-CM or ICD-10-CM), a code prefix, the category it sets, and the procedure type it applies to (`all` for codes that are not site-specific). A cleaned code matches when it begins with the prefix. To adapt the definitions, edit a copy of the library and pass it with `library()`. The program classifies each distinct code once and maps the results back to the data, so it runs quickly on large files.

ICD-9-CM is less detailed than ICD-10-CM, so some categories are not fully comparable across the October 2015 transition. In particular, ICD-9-CM has no organ-specific codes for hemorrhage, hematoma or accidental laceration complicating a procedure (these are in `PSI7`), and no site-specific device codes. Examine the period around the transition for coding artifacts.

Administrative data such as the National Inpatient Sample have no present-on-admission indicator, so a flagged code may describe a condition present before surgery. Where present-on-admission flags are available, consider passing only diagnoses not present on admission.

## Files

| File | Purpose |
|---|---|
| `orthopsi.ado` | The program |
| `orthopsi.sthlp` | Stata help file |
| `orthopsi_codes.csv` | Code library |
| `orthopsi_test.do` | Regression test |
| `orthopsi.pkg`, `stata.toc` | Package files for `net install` |

## Related programs

- [`spinedx`](../spinedx): classify spine diagnoses from ICD-9-CM and ICD-10-CM codes
- [`spinesx`](../spinesx): classify spine procedures from CPT codes
- [`spineinv`](../spineinv): Surgical Invasiveness Index from CPT codes

## Citation

> Martin BI. orthopsi: Stata program to identify post-procedure complications after orthopaedic surgery from ICD-9-CM and ICD-10-CM codes. Version 2.1. 2026. https://github.com/BrookMartin/SpineDef
> Engler ID, Vasavada KD, Vanneman ME, Schoenfeld AJ, Martin BI. Do Community-level Disadvantages Account for Racial Disparities in the Safety of Spine Surgery? A Large Database Study Based on Medicare Claims. Clin Orthop Relat Res. 2023 Feb 1;481(2):268-278. doi: 10.1097/CORR.0000000000002323. Epub 2022 Aug 12. PMID: 35976183; PMCID: PMC9831153.


## Author

Brook I. Martin, PhD, MPH
Department of Orthopaedics, University of Utah
Brook.Martin@hsc.utah.edu

## License

MIT; see [LICENSE](../LICENSE). ICD-9-CM and ICD-10-CM are maintained by the Centers for Medicare & Medicaid Services and the National Center for Health Statistics.
