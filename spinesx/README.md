# spinesx

**Classify spine procedures from CPT/HCPCS codes in Stata**

`spinesx` assigns CPT and HCPCS procedure codes to 18 spine procedure groups and the vertebral regions involved, and estimates the minimum and maximum number of levels fused and decompressed. It was designed for outpatient surgery data such as the HCUP Nationwide Ambulatory Surgery Sample (NASS), but works with any data holding CPT codes in string variables.

## Installation

In Stata 16 or later:

```stata
net install spinesx, from("https://raw.githubusercontent.com/GITHUB-USER/spine-stata/main/spinesx/") replace
```

To also download the regression test to your current folder:

```stata
net get spinesx, from("https://raw.githubusercontent.com/GITHUB-USER/spine-stata/main/spinesx/")
do spinesx_test.do
```

## Usage

```stata
* One record per encounter (e.g. HCUP NASS)
spinesx, cpt(CPT1-CPT30)

* Long data (one row per procedure)
spinesx, cpt(cpt) idvar(encounter_id)
```

The first five characters of each code are matched, so appended modifiers are ignored. See `help spinesx` for all options.

## Output

**Procedure groups** (not mutually exclusive)

| Variable | Description |
|---|---|
| `SPINESX1` | Ablation, neurolysis or radiosurgery |
| `SPINESX2` | Disc arthroplasty |
| `SPINESX3` | Vertebral augmentation (vertebroplasty, kyphoplasty, sacroplasty) |
| `SPINESX4` | Brace, halo or closed fracture treatment |
| `SPINESX5` | Corpectomy or osteotomy |
| `SPINESX6` | Decompression (laminectomy, laminotomy, discectomy) |
| `SPINESX7` | Distraction or non-fusion stabilization |
| `SPINESX8` | Excision, biopsy or intradural procedure |
| `SPINESX9` | Fusion (arthrodesis or interbody device) |
| `SPINESX10` | Bone graft for spine surgery |
| `SPINESX11` | Injection, drainage or aspiration |
| `SPINESX12` | Meningocele or dural repair, or CSF shunt |
| `SPINESX13` | Spinal neurostimulator |
| `SPINESX14` | Open fracture repair |
| `SPINESX15` | Intrathecal or epidural pump or catheter |
| `SPINESX16` | Removal, revision or reinsertion |
| `SPINESX17` | Rhizotomy or cordotomy |
| `SPINESX18` | Spinal instrumentation (rods, plates, screws; not interbody) |
| `ANYSX` | Any spine or sacroiliac joint procedure |

Sacroiliac joint fusion, injection and ablation are included in the fusion, injection and ablation groups and set the sacral region flag.

**Regions:** `REGSX_A`, `REGSX_C`, `REGSX_CT`, `REGSX_T`, `REGSX_TL`, `REGSX_L`, `REGSX_LS`, `REGSX_S` (atlas/axis through sacral/sacroiliac) and `REGSX_M` (codes spanning more than one broad region). Many CPT codes name a range, such as "cervical or thoracic"; these set the CT, TL or LS flag.

**Levels:**

| Variable | Description |
|---|---|
| `NFUSLEV_MIN`, `NFUSLEV_MAX` | Fewest and most levels fused consistent with the codes |
| `NDECLEV_MIN`, `NDECLEV_MAX` | Fewest and most levels decompressed consistent with the codes |
| `ADDLEV` | Number of add-on (additional level) codes |
| `TIERED` | Additional segments implied by tiered instrumentation or deformity codes |

A level is a motion segment: a 1-level fusion joins two vertebrae. Where data have no units-of-service variable (as in NASS), an add-on code billed for several levels may appear once, so counts are lower bounds for cases with three or more levels. See `help spinesx` for how levels are estimated.

## How it works

The classification is defined by a code library, `spinesx_codes.csv`, installed alongside the program. Each row gives a code, the output it contributes to, and a value. To adapt the definitions, edit a copy of the library and pass it with `library()`. The program classifies each distinct code once and maps the results back to the data, so it runs quickly on large files.

## Files

| File | Purpose |
|---|---|
| `spinesx.ado` | The program |
| `spinesx.sthlp` | Stata help file |
| `spinesx_codes.csv` | Code library |
| `spinesx_test.do` | Regression test |
| `spinesx.pkg`, `stata.toc` | Package files for `net install` |

## Related programs

- [`spinedx`](../spinedx): classify spine diagnoses from ICD-9-CM and ICD-10-CM codes
- [`spineinv`](../spineinv): Surgical Invasiveness Index from CPT codes

## Citation

> Martin BI. spinesx: Stata program to classify spine procedures from CPT codes. Version 2.2. 2026. https://github.com/GITHUB-USER/spine-stata

## Author

Brook I. Martin, PhD, MPH
Department of Orthopaedics, University of Utah
Brook.Martin@hsc.utah.edu

## License

MIT; see [LICENSE](../LICENSE).

CPT (Current Procedural Terminology) is copyright of the American Medical Association. The code library lists CPT code numbers with short descriptions written for this program; it does not reproduce AMA descriptors. Users are responsible for their own CPT licensing where required.
