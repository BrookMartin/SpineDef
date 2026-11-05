* spinesx_test.do -- regression test for spinesx v2.2
* After net install spinesx: download this file with  net get spinesx, from(...)
* and run  do spinesx_test.do
* Without installing: put spinesx.ado and spinesx_codes.csv in the current folder,
* then  adopath + "."  and  do spinesx_test.do
* Expected values come from an independent Python implementation.
clear all
version 16
input long id str8(cpt1 cpt2 cpt3 cpt4)
1 "22551" "22552" "22845" "20930"
2 "22612" "22614" "22842" "22848"
3 "63047" "63048" "63048" "64483"
4 "22551" "63047" "" ""
5 "64479" "22610" "" ""
6 "64635" "64636" "" ""
7 "22514" "22515" "" ""
8 "11042" "10180" "20900" ""
9 "0275T" "" "" " "
10 "27279" "" "" " "
11 "22867" "" "" " "
12 "22852" "22849" "" ""
13 "63650" "63685" "" ""
14 "22802" "22843" "22847" ""
15 "63740" "" "" " "
16 "6304751" " 22612" "" ""
17 "0135T" "" "" " "
18 "22858" "22856" "" ""
19 "64483" "" "" " "
19 "22612" "" "" " "
20 "22842" "22848" "" ""
21 "27096" "G0260" "64625" ""
22 "27279" "22612" "" ""
23 "22558" "22633" "22614" "22842"
24 "22800" "22842" "" ""
25 "63017" "63030" "63035" ""
26 "62270" "62328" "" ""
27 "0165T" "" "" " "
28 "22551" "22552" "22552" "63075"
29 "22853" "" "" " "
30 "22859" "" "" " "
31 "22612" "22853" "22842" ""
32 "63005" "" "" " "
end
tempfile input
save `input'

clear
input long id e_SPINESX1 e_SPINESX2 e_SPINESX3 e_SPINESX4 e_SPINESX5 e_SPINESX6 e_SPINESX7 e_SPINESX8 e_SPINESX9 e_SPINESX10 e_SPINESX11 e_SPINESX12 e_SPINESX13 e_SPINESX14 e_SPINESX15 e_SPINESX16 e_SPINESX17 e_SPINESX18 e_REGSX_A e_REGSX_C e_REGSX_CT e_REGSX_T e_REGSX_TL e_REGSX_L e_REGSX_LS e_REGSX_S e_REGSX_M e_ADDLEV e_TIERED e_NFUSLEV_MIN e_NFUSLEV_MAX e_NDECLEV_MIN e_NDECLEV_MAX e_ANYSX
1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 1 1 2 2 . . 1
2 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 0 0 1 2 2 5 . . 1
3 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 2 0 . . 3 3 1
4 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 1 0 0 1 1 1 1 1
5 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 1 1 . . 1
6 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 . . . . 1
7 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 . . . . 1
8 . . . . . . . . . . . . . . . . . . 0 0 0 0 0 0 0 0 0 0 0 . . . . 0
9 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 . . 1 1 1
10 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 . . 1
11 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 . . 1 1 1
12 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 . . . . 1
13 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 . . . . 1
14 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 7 7 11 . . 1
15 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 . . . . 1
16 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 1 1 1
17 . . . . . . . . . . . . . . . . . . 0 0 0 0 0 0 0 0 0 0 0 . . . . 0
18 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 . . . . 1
19 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 1 1 . . 1
20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 2 . . . . 1
21 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 . . . . 1
22 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 1 1 . . 1
23 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 1 2 2 5 . . 1
24 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 2 2 5 . . 1
25 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 2 . . 5 5 1
26 . . . . . . . . . . . . . . . . . . 0 0 0 0 0 0 0 0 0 0 0 . . . . 0
27 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 1 0 . . . . 1
28 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 2 0 3 3 1 1 1
29 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 . . 1
30 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 . . . . 1
31 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 2 2 5 . . 1
32 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 . . 1 2 1
end
tempfile expected
save `expected'

use `input', clear
spinesx, cpt(cpt1-cpt4) idvar(id)
merge m:1 id using `expected', assert(match) nogenerate
local fail 0
foreach v in SPINESX1 SPINESX2 SPINESX3 SPINESX4 SPINESX5 SPINESX6 SPINESX7 SPINESX8 SPINESX9 SPINESX10 SPINESX11 SPINESX12 SPINESX13 SPINESX14 SPINESX15 SPINESX16 SPINESX17 SPINESX18 REGSX_A REGSX_C REGSX_CT REGSX_T REGSX_TL REGSX_L REGSX_LS REGSX_S REGSX_M ADDLEV TIERED NFUSLEV_MIN NFUSLEV_MAX NDECLEV_MIN NDECLEV_MAX ANYSX {
    quietly count if `v' != e_`v'
    if r(N) {
        di as err "`v': " r(N) " mismatch(es)"
        list id cpt1-cpt4 `v' e_`v' if `v' != e_`v', noobs
        local fail 1
    }
}
if `fail' exit 9
di as res "All spinesx tests passed."
