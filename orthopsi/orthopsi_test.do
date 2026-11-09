* orthopsi_test.do -- regression test for orthopsi
* After net install orthopsi: download this file with  net get orthopsi, from(...)
* and run  do orthopsi_test.do
* Without installing: put orthopsi.ado and orthopsi_codes.csv in the current folder,
* then  adopath + "."  and  do orthopsi_test.do
* Expected values come from an independent Python implementation.
clear all
version 16
input long id byte ver str10(d1 d2)
1 10 "T84.51XA" ""
2 10 "T84.51XS" ""
3 10 "T84.020A" "M96.0"
4 10 "I82.611" "I82.401"
5 10 "E89.0" "I26.99"
6 10 "G97.41" "M96.840"
7 10 "T83.511A" "J95.851"
8 10 "T81.12XA" ""
9 10 "t8140xa" ""
10 9 "998.59" "996.66"
11 9 "9980" "99801"
12 9 "4538" "45381"
13 9 "722.83" "349.31"
14 9 "E9383" "410.71"
15 9 "V45.4" "401.9"
16 10 "" ""
17 10 "T84.216A" ""
17 9 "99649" ""
end
tempfile input
save `input'

clear
input long id e_PSI1 e_PSI2 e_PSI3 e_PSI4 e_PSI5 e_PSI6 e_PSI7 e_PSI8 e_PSI9 e_PSI10 e_PSI11 e_PSI12 e_PSI13 e_PSI14 e_PSI15 e_DEVINF e_ANYPSI
1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 1
2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
3 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1
4 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1
5 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1
6 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
7 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 1 1
8 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1
9 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1
10 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 1
11 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1
12 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1
13 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
14 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 1
15 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
17 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1
end
tempfile expected
save `expected'

use `input', clear
gen long order = _n
orthopsi, dx10(d1 d2) dx9(d1 d2) icdver(ver) idvar(id) procedure(spine hip)
assert order == _n
merge m:1 id using `expected', assert(match) nogenerate
local fail 0
foreach v in PSI1 PSI2 PSI3 PSI4 PSI5 PSI6 PSI7 PSI8 PSI9 PSI10 PSI11 PSI12 PSI13 PSI14 PSI15 DEVINF ANYPSI {
    quietly count if `v' != e_`v'
    if r(N) {
        di as err "spine + hip: `v': " r(N) " mismatch(es)"
        list id ver d1 d2 `v' e_`v' if `v' != e_`v', noobs
        local fail 1
    }
}
if `fail' exit 9
di as res "spine + hip: passed"

clear
input long id e_PSI1 e_PSI2 e_PSI3 e_PSI4 e_PSI5 e_PSI6 e_PSI7 e_PSI8 e_PSI9 e_PSI10 e_PSI11 e_PSI12 e_PSI13 e_PSI14 e_PSI15 e_DEVINF e_ANYPSI
1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 1
2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
4 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1
5 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1
6 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
7 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 1 1
8 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1
9 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1
10 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 1
11 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1
12 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1
13 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
14 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 1
15 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
17 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1
end
tempfile expected
save `expected'

use `input', clear
gen long order = _n
orthopsi, dx10(d1 d2) dx9(d1 d2) icdver(ver) idvar(id) 
assert order == _n
merge m:1 id using `expected', assert(match) nogenerate
local fail 0
foreach v in PSI1 PSI2 PSI3 PSI4 PSI5 PSI6 PSI7 PSI8 PSI9 PSI10 PSI11 PSI12 PSI13 PSI14 PSI15 DEVINF ANYPSI {
    quietly count if `v' != e_`v'
    if r(N) {
        di as err "no procedure: `v': " r(N) " mismatch(es)"
        list id ver d1 d2 `v' e_`v' if `v' != e_`v', noobs
        local fail 1
    }
}
if `fail' exit 9
di as res "no procedure: passed"

clear
input long id e_PSI1 e_PSI2 e_PSI3 e_PSI4 e_PSI5 e_PSI6 e_PSI7 e_PSI8 e_PSI9 e_PSI10 e_PSI11 e_PSI12 e_PSI13 e_PSI14 e_PSI15 e_DEVINF e_ANYPSI
1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 1
2 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 1
3 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1
4 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1
5 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1
6 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
7 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 1 1
8 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1
9 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1
10 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 1
11 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1
12 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1
13 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
14 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 1
15 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
17 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1
end
tempfile expected
save `expected'

use `input', clear
gen long order = _n
orthopsi, dx10(d1 d2) dx9(d1 d2) icdver(ver) idvar(id) procedure(all) sequela
assert order == _n
merge m:1 id using `expected', assert(match) nogenerate
local fail 0
foreach v in PSI1 PSI2 PSI3 PSI4 PSI5 PSI6 PSI7 PSI8 PSI9 PSI10 PSI11 PSI12 PSI13 PSI14 PSI15 DEVINF ANYPSI {
    quietly count if `v' != e_`v'
    if r(N) {
        di as err "all procedures + sequela: `v': " r(N) " mismatch(es)"
        list id ver d1 d2 `v' e_`v' if `v' != e_`v', noobs
        local fail 1
    }
}
if `fail' exit 9
di as res "all procedures + sequela: passed"

* synonyms: dx() for dx10(), sp hp for procedure(spine hip)
use `input', clear
keep if ver == 10
orthopsi, dx(d1 d2) sp hp
rename (PSI* DEVINF ANYPSI) (a_=)
orthopsi, dx10(d1 d2) procedure(spine hip)
foreach v of varlist PSI* DEVINF ANYPSI {
    assert `v' == a_`v'
}
di as res "All orthopsi tests passed."
