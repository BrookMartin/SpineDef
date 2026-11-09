# spinesx v2.2: CPT-based spine procedure classification

## Files
- `spinesx.ado`: the program (Stata 16+). Keep it with `spinesx_codes.csv` in a folder on your adopath.
- `spinesx_codes.csv`: the code library. Columns `code`, `variable`, `value`, `label`. One row per code x output. `value` is 1 for flags and add-on codes, the segment count for `TIERED`, and the levels contributed for the level-count rows (`FUS_*`, `DEC_*`). Labels are short paraphrases, not AMA descriptors.
- `spinesx_changes.csv`: every code whose group, region, add-on or tiered value differs from the original program, with the reason for each removal. Level-count values are new and are only in the library.
- `spinesx_test.do`: regression test with expected values from an independent implementation.

## Usage
```stata
* NASS: CPT codes in CPT1-CPT30 (check with: describe CPT*)
spinesx, cpt(CPT1-CPT30)
* long data
spinesx, cpt(cpt) idvar(key)
```
Codes are cleaned (spaces removed, upper case) and the **first 5 characters** are matched exactly, so modifiers appended to a code are ignored.

## Outputs
| Variable | Meaning |
|---|---|
| SPINESX1-18 | Procedure groups (not mutually exclusive). Missing when ANYSX = 0. 18 = spinal instrumentation (not interbody). SI joint procedures are in Fusion (9), Injection (11) and Ablation (1). |
| REGSX_A ... REGSX_S | Region flags. REGSX_S includes the sacroiliac joint. CT = "cervical or thoracic" or cervicothoracic; TL = "thoracic or lumbar" or thoracolumbar; LS = "lumbar or sacral" or lumbosacral. Many CPT codes name a range, not a region. |
| REGSX_M | Codes that cannot all fall within one broad region: cervical (A, C, CT), thoracic (CT, T, TL) or lumbosacral (TL, L, LS, S). A lumbar fusion with pelvic fixation (L + LS) or a thoracic fusion with a cervical/thoracic injection (T + CT) is **not** multiple; cervical + lumbar is. |
| ADDLEV | Number of CPT fields holding an add-on (additional level/segment) code. Interbody device add-ons (22853, 22854, 22859) are excluded, because they duplicate the arthrodesis level count. |
| TIERED | Largest "minimum additional segments" implied by a tiered code (e.g. 22842, 3-6 segments = 2). The original took the last code processed, not the largest. |
| NFUSLEV_MIN, NFUSLEV_MAX | Fewest and most levels fused consistent with the codes. Missing unless SPINESX9 = 1. |
| NDECLEV_MIN, NDECLEV_MAX | Fewest and most levels decompressed consistent with the codes. Missing unless SPINESX6 = 1. |
| ANYSX | Any procedure group, including SI joint procedures. |

## Review findings

### 1. Non-spine codes removed (most important)
In NASS, which covers all ambulatory surgery, these would have flagged ordinary non-spine cases as spine procedures:
- **Generic wound/soft-tissue procedures at any body site:** 10121, 10140, 10180, 11012, 11042-11044 (debridement, I&D, foreign body removal); 11981-11983 (drug-delivery implants such as contraceptive implants); 20900 (bone graft, any donor site).
- **Not spinal:** 21899 (unlisted neck/thorax), 21920-21931 (back/flank soft-tissue biopsy and tumor excision), 49215 (presacral/sacrococcygeal tumor, mostly infant teratoma), 64520 (sympathetic block), 64708 and 64712-64714 (peripheral nerve and plexus neuroplasty).
- **0135T** is percutaneous cryoablation of a renal tumor. You probably meant 0165T (lumbar disc arthroplasty revision, each additional), which is now in Removal/revision.
- **62367-62370** are pump analysis, reprogramming and refill visits, not procedures.

### 2. Codes in the wrong group
| Code(s) | Was | Now | Why |
|---|---|---|---|
| 22818, 22819 | Augmentation | Corpectomy/osteotomy | Kyphectomy, not vertebroplasty/kyphoplasty |
| 63081-63091 | Decompression | Corpectomy/osteotomy | Corpectomies |
| 64491 | Ablation | Injection | Facet injection, second level |
| 62287 | Injection | Decompression | Percutaneous discectomy |
| 62263, 62264 | Ablation | Injection | Epidural adhesiolysis |
| 22859 | ADR | Instrumentation | Interbody/corpectomy device without arthrodesis, not an arthroplasty |
| 0164T | ADR | Removal/revision | Removal of lumbar disc arthroplasty (0163T is the insertion code) |
| 22849, 22850 | Fusion | Removal/revision | Reinsertion; removal of instrumentation |
| 20660 | Removal | Brace | Application of cranial tongs |
| 22100-22102 | Decompression | Excision | Excision of bony lesion of posterior elements |
| 63172, 63173 | Decompression | Excision/intradural | Syrinx drainage |
| 63200 | Rhizotomy | Excision/intradural | Tethered cord release |
| 20250, 20251 | Injection | Excision/biopsy | Open vertebral biopsy |
| 63740-63746 | Pump | Meningocele/dural/CSF | Lumbar CSF shunts |
| 22867, 22868 | Distraction | Distraction **and** Decompression | Device placement with open decompression |

### 3. Common outpatient codes added
- **Facet radiofrequency ablation** 64633-64636, the most common outpatient spine ablation, was missing. Also basivertebral nerve ablation 64628/64629 and SI joint nerve ablation 64625.
- **Interlaminar epidurals** 62320-62327, plus their pre-2017 versions 62310, 62311, 62318, 62319 (in your 2016 NASS data). Also facet injections 64490, 64492, 64495; ultrasound-guided facet injections 0213T-0218T; cervical/thoracic discography 62291.
- **Vertebroplasty/kyphoplasty** 22510-22515 (only 22511 was present) and sacroplasty 0200T/0201T.
- **SI joint fusion** 27279, 27280 (you had 0775T and 0809T).
- **Percutaneous decompression (MILD)** 0274T, 0275T.
- **Missing levels and add-ons:** osteotomy 22207, 22208, 22226; vertebral body excision 22116, 22103; fracture repair 22328; cordotomy 63194-63199; dentate ligament section 63180/63182; intrafacet implants 0219T-0222T; vertebral body tethering 22836-22838; facet arthroplasty 0202T; bone marrow aspiration for graft 20939; IDET additional level 22527; lumbar disc arthroplasty 0163T.

### 4. Regions corrected
- **Region removed** where the code covers more than one region: 63035 (cervical **or** lumbar), 22216 and 22840 (any region), 62329 (spinal puncture, no fixed level).
- **Region corrected:** 63200 (tethered cord release) from cervical to lumbar.
- **Region added** for codes that had none: 22633/22634, 62290, 62380 (all lumbar).
- 62282 moved from sacral to lumbosacral ("lumbar or sacral"), matching the other lumbar/sacral injection codes.

### 5. Add-on and tiered
- **Removed from ADDLEV:** 22819 (kyphectomy, not an add-on) and 63295 (osteoplastic reconstruction, not an additional level).
- **Added to ADDLEV:** 22614, 22632, 64480, 64484, 64492, 64495, 22216, 22226, 63057, 63066, 22512, 22515, 22868 and others; see the change log.
- **TIERED:** 22847 (8+ segments) changed from 6 to 7 to match 22812; added 63016, 22819, 22837. Now takes the maximum across codes.

## Decisions applied (v2.1-v2.2)
- **Fusion (SPINESX9)** = arthrodesis codes, interbody devices placed with arthrodesis (22853, 22854) and SI joint fusion (27279, 27280, 0775T, 0809T).
- **Instrumentation (SPINESX18)** = rods, plates, screws, wiring and pelvic fixation (22840-22848), plus 22859 (interbody or corpectomy device placed *without* arthrodesis). It is set whether or not a fusion code is present; instrumentation alone does not set Fusion.
- **SI joint procedures are in the existing groups:** fusion in SPINESX9, injections (27096, G0260, 64451) in SPINESX11, ablation (64625) in SPINESX1. G0260 is the HCPCS code Medicare requires in ASCs for SI injection, and NASS CPT fields carry HCPCS codes, so it is needed for 2016-2023 counts.
- **Identifying SI procedures with REGSX_S:** within Fusion, Injection and Ablation, the only codes that set REGSX_S are SI codes, so e.g. `SPINESX9 == 1 & REGSX_S == 1` means an SI fusion was coded. REGSX_S is encounter-level, though: it is also set by sacral laminectomy (63011), sacral intraspinal lesions and sacroplasty, and an encounter with a lumbar fusion plus an SI injection also has `SPINESX9 == 1 & REGSX_S == 1`. Both combinations should be rare.
- **Spinal punctures removed** (62270, 62272, 62328, 62329). Epidural blood patch (62273) is still in the injection group; it usually treats post-puncture headache, so you may want it out too.
- **0165T** (lumbar disc arthroplasty revision, each additional) is in Removal/revision.
- **22800 TIERED = 0.**
- **Corpectomies** are only in Corpectomy/osteotomy.

## Estimating levels
**A level is a motion segment (interspace), not a vertebra: a 1-level fusion joins 2 vertebrae.** CPT arthrodesis codes are billed per interspace, so they count levels directly. Tiered instrumentation and deformity codes count *vertebral segments* (vertebrae), so they are converted: levels = vertebrae - 1 (22842, 3-6 vertebrae = 2-5 levels). Decompression codes are mixed: laminotomy and discectomy codes count interspaces, while laminectomy codes count vertebral segments, so decompression counts are approximate.

NASS has no units-of-service variable ([HCUP NASS data elements](https://hcup-us.ahrq.gov/db/nation/nass/nassdde.jsp)), so an add-on code billed for two levels may appear only once. Check whether add-on codes ever repeat across fields:

```stata
gen byte n22552 = 0
foreach v of varlist CPT1-CPT30 {
    replace n22552 = n22552 + (`v' == "22552")
}
tab n22552 if n22552 > 0
```

If they never repeat, both MIN and MAX can understate cases with 3 or more levels.

### Fusion levels
Each field contributes to an approach family:

| Family | Codes (levels per field) |
|---|---|
| Anterior interbody | 22551, 22552, 22554, 22556, 22558, 22585, 22586 (1 each); 22548 clivus-C2 (2) |
| Posterior/posterolateral | 22595, 22600, 22610, 22612, 22614, 22633, 22634, 0219T-0222T (1 each); 22590 occiput-C2 (2) |
| Posterior interbody | 22630, 22632, 22633, 22634 (1 each) |
| Lateral extracavitary | 22532, 22533, 22534 (1 each) |
| Interbody device | 22853 (1 each; used for the minimum only, since the device sits at a level already counted) |

Tiered codes give a range of levels (vertebrae - 1):

| Code | Levels | | Code | Levels |
|---|---|---|---|---|
| 22845, 22808 | 1-2 | | 22800 | 1-5 |
| 22842 | 2-5 | | 22846, 22810 | 3-6 |
| 22843, 22802 | 6-11 | | 22847, 22812 | 7+ |
| 22844, 22804 | 12+ | | | |

- **NFUSLEV_MIN** = the largest family (approaches assumed to treat the same levels, so a 360 at L4-5 is 1 level), raised to the largest tier minimum.
- **NFUSLEV_MAX** = anterior + max(posterior, posterior interbody) + lateral (approaches assumed to treat different levels), or the largest tier maximum if that is higher. Open-ended tiers (7+, 12+) use their minimum, so MAX is not a true ceiling for those cases.
- Raising the minimum with instrumentation tiers assumes the instrumented levels were fused, which is usual but not universal.
- SI fusion contributes no spinal levels: an SI-only fusion has MIN = MAX = 0.

### Decompression levels
Posterior codes add 1 per field (laminotomy, laminectomy/foraminotomy, transpedicular, costovertebral, endoscopic, percutaneous). Laminectomy "1 or 2 segments" (63001-63012) counts 1 for MIN and 2 for MAX; laminoplasty "2 or more" counts 2; laminectomy "more than 2 segments" (63015-63017) counts 3. Anterior discectomy (63075-63078) adds 1 per field.

- **NDECLEV_MIN** = the larger of posterior and anterior (same levels).
- **NDECLEV_MAX** = posterior (using the larger per-code values) + anterior (different levels).
- Corpectomies are not counted.

### Reporting
MIN and MAX agree for most single-approach cases with one code per level. I'd report NFUSLEV_MIN grouped as 1, 2 and 3+ levels as the main measure, and NFUSLEV_MAX as a sensitivity analysis. `tab NFUSLEV_MIN NFUSLEV_MAX` shows how often they differ.

## Codes to verify against the CPT book
I reviewed these without access to the AMA code set. The ones I'm least sure about, mostly newer or Category III codes, are: 0809T (effective 2024, outside 2016-2023), 0775T, G0260, 64451, 0202T, 0219T-0222T, 0274T/0275T, 64625, 64628/64629, 22836-22838, 62328/62329, 22526/22527 (may have been deleted), and 29010.
