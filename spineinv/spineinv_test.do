* spineinv_test.do -- regression test for spineinv v5.1
* After net install spineinv: download this file with  net get spineinv, from(...)
* and run  do spineinv_test.do
* Without installing: put spineinv.ado and spineinv_codes.csv in the current folder,
* then  adopath + "."  and  do spineinv_test.do
* Expected values come from an independent Python implementation.
clear all
version 16
input long id str8(c1 c2 c3 c4)
1 "22551" "22845" "20931" ""
2 "22630" "22632" "22842" "63047"
3 "22802" "22843" "22216" "22214"
4 "22818" "" "" ""
5 "64493" "64494" "" ""
6 "22842" "22843" "22842" ""
7 "63047" "63047" "" ""
8 "22614" "" "" ""
9 "" "" "" ""
10 "99213" "J1885" "" ""
11 " 22612" "2261451" "" ""
12 "63056" "63057" "63057" ""
13 "22857" "22860" "" ""
14 "27279" "0275T" "" ""
15 "22630" "" "" ""
15 "22632" "22842" "" ""
16 "63001" "63015" "" ""
end
tempfile input
save `input'

clear
input long id e_SCORE e_err1 e_err2 e_err3
1 5 0 0 0
2 9 0 0 0
3 23 0 0 0
4 2 0 0 0
5 0 0 0 0
6 10 0 1 5
7 1 0 1 0
8 1 1 0 0
9 . . . .
10 0 0 0 0
11 3 0 0 0
12 6 0 0 0
13 2 0 0 0
14 3 0 0 0
15 8 0 0 0
16 4 0 0 2
end
tempfile expected
save `expected'

use `input', clear
gen long order = _n
spineinv c1-c4, idvar(id)
assert order == _n
merge m:1 id using `expected', assert(match) nogenerate
local fail 0
foreach v in SCORE err1 err2 err3 {
    quietly count if `v' != e_`v'
    if r(N) {
        di as err "`v': " r(N) " mismatch(es)"
        list id c1-c4 `v' e_`v' if `v' != e_`v', noobs
        local fail 1
    }
}
if `fail' exit 9

* without idvar, id 15's two rows are scored separately
use `input', clear
spineinv c1-c4
assert SCORE == 2 if id == 15 & c1 == "22630"
assert err1 == 0  if id == 15 & c1 == "22630"
assert err1 == 1  if id == 15 & c1 == "22632"
di as res "All spineinv tests passed."
