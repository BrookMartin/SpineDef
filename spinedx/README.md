# spinedx

**Classify spine diagnoses from ICD-9-CM and ICD-10-CM codes in Stata**

`spinedx` assigns diagnosis codes to 16 clinically meaningful spine diagnosis categories, a degenerative diagnosis hierarchy, and the vertebral regions involved. ICD-9-CM and ICD-10-CM codes map to the same categories, so trends can be followed across the October 2015 transition between the two coding systems. It was developed for administrative data such as the HCUP National Inpatient Sample, but works with any data holding diagnosis codes in string variables.

## Installation

In Stata 16 or later:

```stata
net install spinedx, from("https://raw.githubusercontent.com/GITHUB-USER/spinedx/main/") replace
```

To also download the regression test to your current folder:

```stata
net get spinedx, from("https://raw.githubusercontent.com/GITHUB-USER/spinedx/main/")
do spinedx_test.do
```

## Usage

```stata
* ICD-10-CM
spinedx, dx10(I10_DX1-I10_DX40)

* ICD-9-CM
spinedx, dx9(DX1-DX25)

* Pooled years with separate ICD-9-CM and ICD-10-CM variables
spinedx, dx9(DX1-DX30) dx10(I10_DX1-I10_DX40)

* One set of variables holding both systems, with a 9/10 indicator
spinedx, dx9(dx1-dx25) dx10(dx1-dx25) icdver(dxver)

* Long data (one row per diagnosis)
spinedx, dx10(dx) idvar(patient_id)
```

Codes may be stored with or without decimal points, in any case. See `help spinedx` for all options.

## Output

| Variable | Description |
|---|---|
| `SPINEDX1` | Sprains and strains |
| `SPINEDX2` | Disc degeneration (including spondylosis without myelopathy and nonspecific neck/back pain) |
| `SPINEDX3` | Disc herniation |
| `SPINEDX4` | Stenosis (including spondylosis with myelopathy) |
| `SPINEDX5` | Spondylolisthesis, instability, subluxation or dislocation |
| `SPINEDX6` | Scoliosis, kyphosis or other deformity |
| `SPINEDX7` | Radiculopathy |
| `SPINEDX8` | Traumatic vertebral fracture |
| `SPINEDX9` | Spinal cord injury |
| `SPINEDX10` | Congenital or other anomaly |
| `SPINEDX11` | Inflammatory spondylopathy |
| `SPINEDX12` | Spine osteoporotic, pathological or fatigue fracture |
| `SPINEDX13` | Surgical aftercare or device complication |
| `SPINEDX14` | Spinal infection (ICD-10-CM codes only) |
| `SPINEDX15` | Myelopathy |
| `SPINEDX16` | Spine-specific neoplasm |
| `DEGDX` | Highest of categories 1-6 (0 = other spine diagnosis, 1 = strain ... 6 = deformity) |
| `REG_A` ... `REG_S` | Atlas/axis, cervical, cervicothoracic, thoracic, thoracolumbar, lumbar, lumbosacral, sacral/coccyx |
| `REG_M` | More than one region |
| `ANYSPINE` | Any spine diagnosis |

Categories are not mutually exclusive; a record can have several.

## How it works

The classification is defined by a code library, `spinedx_codes.csv`, installed alongside the program. Each row gives a coding system, a code prefix and the variable it sets; a cleaned code matches when it begins with the prefix. To adapt the definitions, edit a copy of the library and pass it with `library()`. The program does not need to change.

The program classifies each distinct code once and maps the results back to the data, so it runs quickly on large files.

## Notes on comparability

ICD-9-CM and ICD-10-CM differ in detail, so some categories are not fully comparable across the transition:

- **Radiculopathy** is captured in ICD-9-CM mainly through symptom codes, because ICD-9-CM has no "disc disorder with radiculopathy" codes.
- **Spinal infection** uses ICD-10-CM codes only.
- **Vertebral dislocations** are in `SPINEDX8` for ICD-9-CM (839.x) and `SPINEDX5` for ICD-10-CM.

When studying trends, examine the period around October 2015 for coding artifacts.

## Files

| File | Purpose |
|---|---|
| `spinedx.ado` | The program |
| `spinedx.sthlp` | Stata help file |
| `spinedx_codes.csv` | Code library |
| `spinedx_test.do` | Regression test |
| `spinedx.pkg`, `stata.toc` | Package files for `net install` |

## Related programs

- [`spinesx`](https://github.com/GITHUB-USER/spinesx): classify spine procedures from CPT codes
- [`spineinv`](https://github.com/GITHUB-USER/spineinv): Surgical Invasiveness Index from CPT codes

## Citation

If you use `spinedx` in published work, please cite:

> Martin BI. spinedx: Stata program to classify spine diagnoses from ICD-9-CM and ICD-10-CM codes. Version 2.6. 2026. https://github.com/GITHUB-USER/spinedx

## Author

Brook I. Martin, PhD, MPH
Department of Orthopaedics, University of Utah
Brook.Martin@hsc.utah.edu

## License

MIT; see [LICENSE](LICENSE). ICD-9-CM and ICD-10-CM are maintained by the Centers for Medicare & Medicaid Services and the National Center for Health Statistics.
