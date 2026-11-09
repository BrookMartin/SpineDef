# spineinv v5.1: Surgical Invasiveness Index from CPT codes

## Files
- `spineinv.ado`: the program (Stata 16+). Keep it with `spineinv_codes.csv` in a folder on your adopath.
- `spineinv_codes.csv`: the code library. Columns:
  - `code`: CPT/HCPCS code
  - `score`: points for the first occurrence in a record
  - `repeat`: points for each further occurrence (add-on codes); 0 = a repeat is a non-additive duplicate (err2)
  - `tiergrp`: codes in the same group are not additive; only the highest score counts (err3 = points removed)
  - `primaries`: for add-on codes, the primary codes; an add-on with none of them present sets err1
  - `status`: `original` (as in v4), `corrected` (bug fix), `changed (decision)` (score value changed), `added` (new code)
  - `note`: reason for any change
- `spineinv_removed.csv`: codes dropped from the original lists, with reasons.
- `spineinv_test.do`: regression test with expected values from an independent implementation.

## Usage
The call is unchanged:
```stata
spineinv CPT1-CPT30
spineinv cpt, idvar(key)        // pool all rows of the same key
```
**Two behavior changes:**
- With `idvar()`, results are written on every row instead of reshaping and collapsing the data (v4 dropped all other variables). For one row per id: `bysort key: keep if _n == 1`.
- `err1` and `err2` are 0/1 for scored records (v4: 1 or missing).

Returns `r(N)`, `r(N_err1)`, `r(N_err2)`, `r(N_err3)`.

## (1) Does v4 work properly?
**Speed.** v4 loops over every code x every record x every field with interpreted macro tests (about 238 x 30 = 7,000 statements per record). On NASS (millions of records per year) that would take days. v5 builds a file of only the matched codes, then scores it with a few vectorized steps.

**Bugs that change scores:**

| Problem | Effect | Fix |
|---|---|---|
| 22632, 22216, 22868, 64484 were in **both** the base and add-on lists | Scored twice: one 22632 = 4 + 4 = 8; 22216 = 3; 22868 = 2 | Add-on list only |
| 63057, 63066 (each additional segment) were in the base list | Counted once however many segments | Scored per occurrence |
| 22818/22819 (kyphectomy) are in the tier adjustment and the comments (scores 2 and 3) but **missing from the code list** | Kyphectomy scored 0; with both coded, 2 points were subtracted from other procedures | Added with scores 2 and 3 |
| Tier adjustment subtracted per occurrence, but base codes are added once | A repeated lower-tier code drove the score down too far | Each code counted once |
| 64484, 64491, 64494 (injection add-ons) scored 1 while injections score 0 | 2-level facet injection = 1 | Removed |
| Non-spine codes with points: 49215 = 4 (presacral tumor), 0135T = 1 (renal cryoablation), 64708/64712/64713 = 1 (peripheral nerve) | Non-spine cases scored | Removed |

**Bugs in the flags:**
- `local err2 = ... in obsno` puts an `in` qualifier inside a macro expression. I'd expect Stata to stop with a syntax error the first time a listed code is found; I can't run Stata here to confirm, but either way err2 couldn't be trusted.
- err1 primaries were wrong for 22860 (listed 22859, an interbody device; the primary is lumbar disc arthroplasty 22857) and 64491 (listed transforaminal 64479/64480; the primary is facet injection 64490). 22216 lacked 22210, and 63295 listed only 63290.
- err1 relied on quote characters embedded in a macro (`22532","22533`) being parsed as separate words, which depends on Stata's tokenizer.
- `noMERGE` was declared but never used; `rclass` returned nothing.

**Example scores, v4 vs v5.1** (bug fixes plus the score changes below):

| Case | v4 | v5.1 |
|---|---|---|
| 1-level ACDF + plate (22551 22845) | 4 | 5 |
| 2-level ACDF + plate + 2 cages (22551 22552 22845 22853 22853) | 7 | 10 |
| 1-level TLIF (22630 22842 63047 22853) | 10 | 10 |
| 2-level TLIF, cages in 2 fields (22630 22632 22842 63047 63048 22853 22853) | 19 | 13 |
| 2-level combined (22633 22634 22842 63047) | 11 | 12 |
| 2-level PLF (22612 22614 22842) | 9 | 8 |
| Cervical laminoplasty (63050) | 1 | 2 |
| Deformity with osteotomy (22802 22843 22216 22214) | 25 | 23 |
| Kyphectomy (22818) | 0 | 2 |
| 2-level facet injection (64493 64494) | 1 | 0 |

## (2) Is it comprehensive?
Codes that score 0 don't change the index, so for completeness only codes that should score points matter. v4 listed 95 codes with 0 points (injections, pumps, stimulators, wound care and others); they are removed from the library and listed in `spineinv_removed.csv` with the other removals.

Missing codes with points, now **added** (status `added`):

| Code(s) | Description | Score | Basis |
|---|---|---|---|
| 22208, 22226 | Osteotomy, each additional | 1 per occurrence | 22216 |
| 22103, 22116 | Vertebral excision, each additional | 1 per occurrence | 22100-22114 |
| 22328 | Open fracture treatment, each additional | 1 per occurrence | |
| 0163T | Lumbar disc arthroplasty, each additional | 1 per occurrence | 22860 |
| 27279, 27280 | SI joint fusion | 2 | 0775T |
| 0219T-0221T, 0222T | Intrafacet implant (facet fusion); each additional | 2; 1 | 22600-22612; 22614 |
| 0274T, 0275T | Percutaneous laminotomy/laminectomy (MILD) | 1 | 63020/63030 |
| 0202T | Facet arthroplasty with laminectomy and fixation | 2 | |
| 22836, 22837 | Vertebral body tethering (tier group 9) | 5; 10 | Anterior instrumentation 22846, 22847 |

## Score changes applied (status `changed (decision)`)
The index counts **vertebrae** treated (Mirza's convention: a 1-level fusion fuses 2 vertebrae). These values were changed to follow that convention consistently:

| Code(s) | v4 | v5.1 | Why |
|---|---|---|---|
| 22614 / 22634 | 2 / 1 | 1 / 2 | Were swapped. 22633 (4) = 22612 (2) + 22630 (2), so 22634 = 22614 + 22632 |
| 22632 | 4 per level | 1 per level | Each additional PLIF level adds 1 vertebra |
| 22551 / 22552 | 2 / 1 | 3 / 2 | 22551 replaced 22554 (2) + 63075 (1) in 2011; 22552 replaced 22585 (1) + 63076 (1) |
| 63050 | 1 | 2 | Laminoplasty covers 2 or more segments |
| 62380 | 2 | 1 | Single-interspace endoscopic decompression, as open 63030 |
| 63101, 63102 | 1 | 2 | As the other corpectomies |
| 22548 | 2 | 3 | Clivus-C1-C2 spans 3 vertebrae, as 22590 |
| 22808 | 3 | 2 | Made equal to 22845 (both 2-3 segments). I chose 2 rather than 3 because a 2-3 segment construct usually spans 2 vertebrae (1 level) |
| 0809T | 1 | 2 | SI joint fusion, as 0775T |
| 63012 | 1 | 2 | 1-2 segment laminectomy, as 63001-63011 |
| 63185 | 0 | 1 | Laminectomy with rhizotomy, as 63190 |
| 22851, 22853, 22854 | 2, once | 2 first, +1 each further | Interbody devices are reported per interspace. Like the other add-ons, the first level covers 2 vertebrae and each further level adds 1 |

**Interbody devices and NASS:** NASS has no units variable, so per-level counting of 22853 works only when the code is repeated across CPT fields. If a 2-level case lists 22853 once (billed with units of 2), it still scores 2.

## Not tested here
Stata isn't available in this environment. The scoring rules were implemented independently in Python, and `spineinv_test.do` checks the Stata program against them (duplicates, tiers, add-ons without primaries, empty records, pooled ids and row order). Please run it once before production use.
