*! version 0.98.2, 24oct2019, Jinjing Li, National Centre for Social and Economic Modelling, University of Canberra <jinjing.li@canberra.edu.au>
program define edm, eclass
version 14
if replay() {
if (`"`e(cmd)'"' != "edm") {
noi di as error "results for edm not found"
exit 301
}
edmDisplay `0'
exit `rc'
}
else edmParser `0'
end
program define edm_showci
syntax , matmean(name) matsd(name) buffer(name) ci(integer) [maxr(integer 2)]
quietly {
noi di as result %18s "Estimated `ci'% CI" _c
if `maxr' == 1 {
noi di as result %17s " " _c
}
forvalues j=1/`maxr' {
noi di as result " [" _c
noi di as result %9.5g `=`matmean'[1,`j']-invnormal(1-(100-`ci')/200)*`matsd'[1,`j']' _c
noi di as result ", " _c
noi di as result %9.5g `=`matmean'[1,`j']+invnormal(1-(100-`ci')/200)*`matsd'[1,`j']' _c
noi di as result " ]" _c
}
noi di ""
noi di as result %18s "`=(100-`ci')/2'/`=100 - (100-`ci')/2' Pc. tile" _c
if `maxr' == 1 {
noi di as result %17s " " _c
}
noi qui count
loc datasize = r(N)
tempname buffervar
forvalues i=1/2{
cap drop `buffervar'`i'
}
svmat `buffer',name(`buffervar')
forvalues j=1/`maxr' {
_pctile `buffervar'`j', percentile(`=(100-`ci')/2' `=100 - (100-`ci')/2' )
noi di as result " [" _c
noi di as result %9.5g `=r(r1)' _c
noi di as result ", " _c
noi di as result %9.5g `=r(r2)' _c
noi di as result " ]" _c
drop `buffervar'`j'
}
forvalues i=1/2{
cap drop `buffervar'`i'
}
noi di ""
qui keep if _n<=`datasize'
}
end
program define edmParser, eclass
loc subcommand "`1'"
if strpos("`subcommand'",",") !=0 {
loc subcommand =substr("`1'",1,strpos("`subcommand'",",")-1)
}
loc subargs = substr("`0'", strlen("`subcommand'")+1,.)
if "`subcommand'" == "update" {
edmUpdate `subargs'
}
else {
qui xtset
ereturn clear
if "`subcommand'" == "explore" {
edmExplore `subargs'
}
else if "`subcommand'" == "xmap" {
edmXmap `subargs'
}
else {
di as error `"Invalid subcommand. Use "explore" or "xmap""'
error 1
}
ereturn local cmd "edm"
ereturn local cmdline `"edm `0'"'
}
end
program define edmUpdate
syntax , [DEVELOPment] [replace]
if "`development'" == "development" {
di "Updating edm from the development channel"
net install edm, from("https://jinjingli.github.io/edm/") `replace'
}
else {
di "Updating edm from SSC"
ssc install edm, `replace'
}
end
program define edmExplore, eclass
syntax anything [if], [e(numlist ascending)] [theta(numlist ascending)] [k(integer 0)] [manifold(string)] [REPlicate(integer 1)] [seed(integer 0)] [ALGorithm(string)] [tau(integer 1)] [DETails] [Predict(name)] [CROSSfold(integer 0)] [CI(integer 0)] [tp(integer 1)] [COPredict(name)] [copredictvar(string)] [full]
if `seed' != 0 {
set seed `seed'
}
if `tp' <1 {
di as error "tp must be greater than or equal to 1"
error 9
}
if "`predict'" !="" {
confirm new variable `predict'
}
if `crossfold' >0 {
if `replicate' >1 {
di as error "Replication must be not set if crossfold validation is used."
error 119
}
if "`full'" == "full" {
di as error "option full cannot be specified in combination with crossfold."
error 119
}
}
if "`theta'" == ""{
loc theta = 1
}
qui xtset
if "`=r(panelvar)'" != "." {
loc ispanel =1
ereturn scalar panel =1
}
else {
loc ispanel =0
ereturn scalar panel =0
}
if !inlist("`algorithm'","smap","simplex","") {
di as error "Not valid algorithm specification"
error 121
}
if "`algorithm'" == "" {
loc algorithm "simplex"
}
qui xtset
loc tmax = r(tmax)
loc tmin = r(tmin)
loc tdelta = r(tdelta)
loc timevar "`=r(timevar)'"
loc total_t = int((r(tmax)-r(tmin))/r(tdelta)) + 1
tempvar x y
tokenize "`anything'"
loc ori_x "`1'"
loc ori_y "`2'"
if "`3'" != "" {
error 103
}
marksample touse
forvalues i=1/2 {
if `i' ==1 {
loc currentv = "x"
}
else {
loc currentv = "y"
}
if substr("``i''",1,2) == "z." {
qui egen double ``currentv'' = std(`=substr("``i''",3,.)') if `touse' ==1
qui replace ``currentv'' = 0 if `touse' !=1
}
else {
if "``i''" != "" {
qui gen double ``currentv'' = ``i'' if `touse' == 1
qui replace ``currentv'' = 0 if `touse' !=1
}
}
}
if "`2'" == "" {
loc univariate 1
loc y ""
}
else {
loc univariate 0
}
if "`e'" =="" {
loc e = 3 - `univariate'
}
tempvar usable
qui gen byte `usable' = `x'!=. & `touse'
loc max_e = -1
loc min_e = .
foreach i of numlist `e' {
if `i'>`max_e' {
loc max_e = `i'
}
if `i' <`min_e' {
loc min_e = `i'
}
}
if (`max_e' < 3 - `univariate') | (`min_e' < 3 - `univariate') {
di as error "Some of the proposed number of dimensions for embedding is too small."
error 121
}
loc esize = `max_e' - (1- `univariate')
loc mapping_0 "`x' `y'"
forvalues i=1/`=`esize'-1' {
tempvar x_`i'
qui gen double `x_`i'' = l`=`i'*`tau''.`x' if `usable' ==1
qui replace `usable' = 0 if `x_`i'' ==.
loc mapping_`i' "`mapping_`=`i'-1'' `x_`i''"
}
qui replace `usable' = 0 if f`future_step'.`x' ==. & `usable' ==1
if "`copredictvar'" != "" {
if "`copredict'" == "" {
di as error "The copredict() option is not specified"
error 111
}
confirm new variable `copredict'
tempvar co_train_set co_predict_set co_usable
gen byte `co_train_set' = `usable' ==1
gen byte `co_usable' = `touse' ==1
tokenize "`copredictvar'"
loc co_x "`1'"
loc co_y "`2'"
foreach v in "x" "y" {
if substr("`co_`v''",1,2) =="z." {
tempvar co_`v'_new
qui egen double `co_`v'_new' = std(`=substr("`co_`v''",3,.)') if `touse' ==1
loc co_`v' `co_`v'_new'
}
}
if (`univariate' == 1 & "`co_y'" != "") | (`univariate' == 0 & "`co_y'" == "") {
di as error "Coprediction does not match the main manifold construct"
error 111
}
loc co_mapping_0 "`co_x' `co_y'"
qui replace `co_usable' = 0 if `co_x'==.
if "`co_y'" != "" {
qui replace `co_usable' = 0 if `co_y'==.
}
forvalues i=1/`=`esize'-1' {
tempvar co_x_`i'
qui gen double `co_x_`i'' = l`=`i'*`tau''.`co_x' if `co_usable' ==1
qui replace `co_usable' = 0 if `co_x_`i'' ==.
loc co_mapping_`i' "`co_mapping_`=`i'-1'' `co_x_`i''"
loc co_mapping "`co_mapping_`i''"
}
gen byte `co_predict_set' = `co_usable' ==1
}
tempvar x_f x_p train_set predict_set
loc future_step = `tp'-1 + `tau' //predict the future value with an offset defined by tp
qui gen double `x_f' = f`future_step'.`x' if `usable' ==1
qui replace `usable' =0 if `x_f' ==.
qui gen double `x_p' = .
tempvar u mae
mat r = J(1,4,.)
loc round = max(`crossfold', `replicate')
if `crossfold' >0 {
qui count if `usable' ==1
if `crossfold' > r(N)/ `esize' {
di as error "Not enough observations for cross-validations"
error 149
}
tempvar crossfoldu crossfoldunum
qui gen `crossfoldu' = runiform() if `usable' ==1
qui egen `crossfoldunum'= rank(`crossfoldu'), unique
}
loc no_of_runs = 0
forvalues t=1/`round' {
qui {
cap drop `train_set' `predict_set'
if `crossfold' > 0 {
gen byte `train_set' = mod(`crossfoldunum',`crossfold') != (`t' -1) & `usable' ==1
gen byte `predict_set' = mod(`crossfoldunum',`crossfold') == (`t' -1) & `usable' ==1
}
else {
if "`full'" == "full" {
gen byte `train_set' = `usable' ==1
gen byte `predict_set' = `train_set'
}
else {
gen double `u' = runiform() if `usable' ==1
sum `u',d
gen byte `train_set' = `u' <r(p50) & `u' !=.
gen byte `predict_set' = `u' >=r(p50) & `u' !=.
drop `u'
}
}
tempvar overlap
gen byte `overlap' = (`train_set' ==`predict_set') & (`predict_set' ==1)
if "`full'" != "full" {
assert `overlap' == 0 if `predict_set' ==1
}
count if `train_set' ==1
loc train_size = r(N)
count if `predict_set' ==1
loc max_lib_size = min(`train_size',r(N))
if `max_lib_size' < 1 {
noi di as error "Invalid dimension or library specifications"
error 9
}
}
foreach i of numlist `e' {
loc manifold "mapping_`=`i'-2+`univariate''"
foreach j of numlist `theta' {
if `k'> 0{
loc lib_size = min(`k',`train_size')
}
else if `k' == 0{
loc lib_size = `i'+1
}
else {
loc lib_size = `max_lib_size'
}
if `lib_size' > `max_lib_size' {
loc lib_size = `max_lib_size'
}
if `k' != 0 {
loc cmdfootnote = "Note: Number of neighbours (k) is adjusted to `lib_size'" + char(10)
}
else if `k' != `lib_size' & `k' == 0 {
loc cmdfootnote = "Note: Number of neighbours (k) is set to E+1" + char(10)
}
loc vars_save ""
mata: smap_block("``manifold''", "", "`x_f'", "`x_p'","`train_set'","`predict_set'",`j',`lib_size',"`overlap'", "`algorithm'", "`vars_save'")
qui gen `mae' = abs( `x_p' - `x_f' ) if `predict_set' == 1
qui sum `mae'
loc rmae = r(mean)
drop `mae'
loc current_e =`i'
qui corr `x_f' `x_p' if `predict_set' == 1
if "`predict'" != "" {
cap gen double `predict' = `x_p'
label variable `predict' "edm prediction result"
cap replace `predict' = `x_p' if `x_p' !=.
}
mat r = (r \ `current_e', `j',`=r(rho)',`rmae')
ereturn local rho = `=r(rho)'
ereturn local mae = `rmae'
loc ++no_of_runs
}
}
}
if "`copredictvar'" !="" {
if `no_of_runs' ==1{
qui replace `overlap' = 0
qui replace `co_train_set' = 0 if `usable' ==0
tempvar co_x_p
qui gen double `co_x_p'=.
mata: smap_block("``manifold''", "`co_mapping'", "`x_f'", "`co_x_p'","`co_train_set'","`co_predict_set'",`theta',`lib_size',"`overlap'", "`algorithm'", "")
qui gen double `copredict' = `co_x_p'
label variable `copredict' "edm copredicted `copredictvar' using manifold `ori_x' `ori_y'"
}
else {
di as error "Error: coprediction can only run with one specified manifold construct (no repetition etc.)" _c
di as result ""
}
}
mat r = r[2...,.]
mat cfull = r[1,3]
loc cfullname= subinstr("`ori_x'",".","/",.)
matrix colnames cfull = `cfullname'
matrix rownames cfull = rho
qui count if `usable' ==1
scalar total_obs = r(N)
ereturn post cfull, esample(`usable')
ereturn scalar N = total_obs
ereturn local subcommand = "explore"
ereturn scalar univariate = `univariate'
ereturn local x "`ori_x'"
ereturn local y "`ori_y'"
if `crossfold' >0 {
ereturn local cmdfootnote "`cmdfootnote'Note: `crossfold'-fold cross validation results reported"
}
else {
if "`full'" == "full" {
ereturn local cmdfootnote "`cmdfootnote'Note: Full sample used for the computation"
}
else {
ereturn local cmdfootnote "`cmdfootnote'Note: Random 50/50 split for training and validation data"
}
}
ereturn matrix explore_result = r
ereturn local algorithm "`algorithm'"
ereturn local tau = `tau'
ereturn local replicate = `replicate'
ereturn local crossfold = `crossfold'
ereturn local rep_details = "`details'" == "details"
ereturn local ci = "`ci'"
ereturn local copredict ="`copredict'"
ereturn local copredictvar ="`copredictvar'"
edmDisplay
end
program define edmXmap, eclass
syntax anything [if], [e(integer 2)] [theta(real 1)] [Library(numlist)] [seed(integer 0)] [k(integer 0)] [ALGorithm(string)] [tau(integer 1)] [REPlicate(integer 1)] [SAVEsmap(string)] [DETails] [DIrection(string)] [Predict(name)] [CI(integer 0)] [tp(integer 0)] [COPredict(name)] [copredictvar(string)]
if `seed' != 0 {
set seed `seed'
}
if `tp' <0 {
di as error "tp must be greater than or equal to 0"
error 9
}
if "`predict'" !="" {
confirm new variable `predict'
if "`direction'" != "oneway" {
di as error "direction() option must be set to oneway if predicted values are to be saved."
error 197
}
}
if "`e'" =="" {
loc e = "2"
}
if "`theta'" == ""{
loc theta = 1
}
loc l_ori "`library'"
if "`library'" == "" {
loc l = 0
}
else {
loc l "`library'"
}
if !inlist("`algorithm'","smap","simplex","") {
di as error "Not valid algorithm specification"
error 121
}
if "`algorithm'" == "" {
loc algorithm "simplex"
}
else if "`algorithm'" == "smap" {
if "`savesmap'" != "" {
cap sum `savesmap'*
if _rc != 111 {
di as error "There should be no variable with existing prefix when savesmap() option is used"
error 110
}
}
}
if "`savesmap'" != "" & "`algorithm'" != "smap" {
di as error "savesmap() option should only be specified with S-map"
error 119
}
if "`direction'" == "" {
loc direction "both"
}
if !inlist("`direction'","both","oneway") {
di as error "direction() option should be either both or oneway"
error 197
}
qui xtset
if "`=r(panelvar)'" != "." {
loc ispanel =1
ereturn scalar panel =1
}
else {
loc ispanel =0
ereturn scalar panel =0
}
qui xtset
loc tmax = r(tmax)
loc tmin = r(tmin)
loc tdelta = r(tdelta)
loc timevar "`=r(timevar)'"
loc total_t = (r(tmax)-r(tmin))/r(tdelta) + 1
marksample touse
tokenize "`anything'"
loc ori_x "`1'"
loc ori_y "`2'"
if "`3'" != "" {
error 103
}
tempvar x y
forvalues i=1/2 {
if `i' ==1 {
loc currentv = "x"
}
else {
loc currentv = "y"
}
if substr("``i''",1,2) == "z." {
qui egen double ``currentv'' = std(`=substr("``i''",3,.)') if `touse' ==1
qui replace ``currentv'' = 0 if `touse' != 1
}
else {
if "``i''" != "" {
qui gen double ``currentv'' = ``i'' if `touse' == 1
qui replace ``currentv'' = 0 if `touse' != 1
}
}
}
tempvar usable
qui gen byte `usable' = `x'!=. & `touse' & f`tp'.`y' !=.
if (`e' < 2) {
di as error "Some of the proposed number of dimensions for embedding is too small."
error 121
}
loc esize = `e'
loc comap_constructed = 0
mat r1 = J(1,4,.)
mat r2 = J(1,4,.)
loc max_round = ("`direction'" == "both") + 1
forvalues round=1/`max_round'{
if `round' ==2 {
loc z "`x'"
loc x "`y'"
loc y "`z'"
qui replace `usable' = `x'!=. & `touse' & f`tp'.`y' !=.
}
loc mapping_0 "`x'"
forvalues i=1/`=`esize'-1' {
tempvar x_`i'
qui gen double `x_`i'' = l`=`i'*`tau''.`x' if `usable' ==1
qui replace `usable' = 0 if `x_`i'' ==.
loc mapping_`i' "`mapping_`=`i'-1'' `x_`i''"
}
if "`copredictvar'" != "" & `comap_constructed' ==0{
confirm new variable `copredict'
tempvar co_train_set co_predict_set co_usable
gen byte `co_train_set' = `usable' ==1
gen byte `co_usable' = `touse' ==1
tokenize "`copredictvar'"
loc co_x "`1'"
loc co_y "`2'"
foreach v in "x" "y" {
if substr("`co_`v''",1,2) =="z." {
tempvar co_`v'_new
qui egen double `co_`v'_new' = std(`=substr("`co_`v''",3,.)') if `touse' ==1
loc co_`v' `co_`v'_new'
}
}
if ("`co_y'" == "") | ("`co_x'" == "") {
di as error "Coprediction does not match the main manifold construct"
error 111
}
loc co_mapping_0 "`co_x'"
qui replace `co_usable' = 0 if `co_x'==.
forvalues i=1/`=`esize'-1' {
tempvar co_x_`i'
qui gen double `co_x_`i'' = l`=`i'*`tau''.`co_x' if `co_usable' ==1
qui replace `co_usable' = 0 if `co_x_`i'' ==.
loc co_mapping_`i' "`co_mapping_`=`i'-1'' `co_x_`i''"
loc co_mapping "`co_mapping_`i''"
}
gen byte `co_predict_set' = `co_usable' ==1
loc comap_constructed =1
}
tempvar x_f x_p train_set predict_set
qui gen double `x_f' = f`tp'.`y' if `usable' ==1
qui gen double `x_p' = .
qui gen byte `predict_set' = `usable'
qui gen byte `train_set' = . // to be decided by library length
tempvar u urank
tempvar overlap
loc no_of_runs = 0
forvalues rep =1/`replicate' {
cap drop `u' `urank'
qui gen `u' = runiform() if `usable' ==1
qui egen `urank' =rank(`u') if `usable' ==1, unique
qui count if `usable' ==1
loc urank_max = r(N)
if "`l_ori'" =="0" | "`l_ori'"=="" {
loc l = `urank_max'
}
foreach i of numlist `e' {
loc manifold "mapping_`=`i'-1'"
foreach j of numlist `theta' {
foreach lib_size of numlist `l' {
if `lib_size'>`urank_max'{
di as error "Library size exceeds the limit."
error 1
continue, break
}
else if `lib_size' <= `i' + 1 {
di as error "Cannot estimate under the current library specification"
error 1
}
qui replace `train_set' = `urank' <=`lib_size' & `usable' ==1
qui count if `train_set' ==1
loc train_size = r(N)
if `k'> 0{
loc k_size = min(`k',`train_size' -1)
}
else if `k' == 0{
loc k_size = `i'+1
}
else if `k' < 0 {
loc k_size = `train_size' -1
}
if `k' != 0 {
loc cmdfootnote = "Note: Number of neighbours (k) is adjusted to `k_size'" + char(10)
}
else if `k' != `k_size' & `k' == 0 {
}
loc vars_save ""
if "`savesmap'" != "" & "`algorithm'" =="smap" {
forvalues ii = 0/`=`i'-1' {
qui gen double `savesmap'`round'_l`ii'_rep`rep' = .
loc vars_save "`vars_save' `savesmap'`round'_l`ii'_rep`rep'"
if `round' == 1 {
label variable `savesmap'`round'_l`ii'_rep`rep' "Approximated marginal effect of l`ii'.`ori_x' on `ori_y' (rep `rep')"
}
else {
label variable `savesmap'`round'_l`ii'_rep`rep' "Approximated marginal effect of l`ii'.`ori_y' on `ori_x' (rep `rep')"
}
}
qui gen double `savesmap'`round'_c_rep`rep' = .
loc vars_save "`vars_save' `savesmap'`round'_c_rep`rep'"
}
qui gen byte `overlap' = `train_set' ==`predict_set' if `predict_set' ==1
loc last_theta = `j'
mata: smap_block("``manifold''","", "`x_f'", "`x_p'","`train_set'","`predict_set'",`j',`k_size', "`overlap'", "`algorithm'","`vars_save'")
tempvar mae
qui gen `mae' = abs( `x_p' - `x_f' ) if `predict_set' == 1
qui sum `mae'
loc rmae = r(mean)
drop `mae'
loc current_e =`i'
qui corr `x_f' `x_p' if `predict_set' == 1
if "`predict'" != "" {
cap gen double `predict' = `x_p'
label variable `predict' "edm prediction result"
cap replace `predict' = `x_p' if `x_p' !=.
}
mat r`round' = (r`round' \ `round', `lib_size',`=r(rho)',`rmae')
drop `overlap'
loc ++no_of_runs
}
}
}
}
mat r`round' = r`round'[2...,.]
}
if "`copredictvar'" !="" {
if `no_of_runs' ==1{
qui gen byte `overlap' = 0
qui replace `co_train_set' = 0 if `usable' ==0
tempvar co_x_p
qui gen double `co_x_p'=.
mata: smap_block("``manifold''","`co_mapping'", "`x_f'", "`co_x_p'","`co_train_set'","`co_predict_set'",`last_theta',`k_size', "`overlap'", "`algorithm'","")
qui gen double `copredict' = `co_x_p'
label variable `copredict' "edm copredicted `copredictvar' using manifold `ori_x' `ori_y'"
}
else {
di as error "Error: coprediction can only run with one specified manifold construct (no repetition etc.)" _c
di as result ""
}
}
mat cfull = (r1[1,3],r2[1,3])
loc name1 = subinstr("`ori_y'|M(`ori_x')",".","/",.)
loc name2 = subinstr("`ori_x'|M(`ori_y')",".","/",.)
loc shortened = 1
forvalues n =1/2 {
if strlen("`name`n''") > 32 {
loc name`n' = substr("`name`n''",1,29) + "~`shortened'"
loc ++shortened
}
}
matrix colnames cfull = `name1' `name2'
matrix rownames cfull = rho
qui count if `usable' ==1
scalar total_obs = r(N)
if "`direction'" == "oneway" {
mat cfull = cfull[1...,1]
}
ereturn post cfull, esample(`usable')
ereturn scalar N = total_obs
ereturn local subcommand = "xmap"
ereturn matrix xmap_1 = r1
if "`direction'" == "both" {
ereturn matrix xmap_2 = r2
}
ereturn scalar e = `e'
ereturn scalar theta = `theta'
ereturn local x "`ori_x'"
ereturn local y "`ori_y'"
ereturn local algorithm "`algorithm'"
ereturn local cmdfootnote "`cmdfootnote'"
ereturn local tau = `tau'
ereturn local replicate = `replicate'
ereturn local rep_details = "`details'" == "details"
ereturn local direction = "`direction'"
ereturn local ci = "`ci'"
ereturn local copredict ="`copredict'"
ereturn local copredictvar ="`copredictvar'"
edmDisplay
end
program define edmDisplay, eclass
di _n "Empirical Dynamic Modelling"
loc diopts "`options'"
loc fmt "%12.5g"
loc fmtprop "%8.3f"
if e(subcommand) =="explore" {
if e(univariate) ==1 {
di as text "Univariate mapping with `=e(x)' and its lag values"
}
else {
di as text "Multivariate mapping with `=e(x)', its lag values, and `=e(y)'"
}
if ((e(replicate) == "1" & `=e(crossfold)'<=0) | e(rep_details) == "1") {
di as txt "{hline 68}"
di as text %18s "E" _c
di as text %16s "theta" _c
di as text %16s "rho" _c
di as text %16s "MAE"
di as txt "{hline 68}"
mat r = e(explore_result)
loc nr = rowsof(r)
loc kr = colsof(r)
forvalues i = 1/ `nr' {
forvalues j=1/`kr' {
if `j'==1 {
loc dformat "%18s"
}
else {
loc dformat "%16s"
}
di as result `dformat' `"`:display `fmt' r[`i',`j'] '"' _c
}
di " "
}
di as txt "{hline 68}"
}
else {
di as txt "{hline 70}"
di as text %9s "E" _c
di as text %9s "theta" _c
di as text %13s "Mean rho" _c
di as text %13s "Std. Dev." _c
di as text %13s "Mean MAE" _c
di as text %13s "Std. Dev."
di as txt "{hline 70}"
loc dformat "%13s"
tempname reported_r r buffer summary_r
mat `r' = e(explore_result)
loc nr = rowsof(`r')
loc kr = colsof(`r')
mat `reported_r' = J(`nr',1,0)
mat `summary_r' = J(1,6,.)
forvalues i = 1/ `nr' {
mat `buffer' = J(1,2,.)
if `reported_r'[`i',1] ==1 {
continue
}
loc base_E = `r'[`i',1]
loc base_theta = `r'[`i',2]
forvalues j=1/`nr' {
if `reported_r'[`j',1] ==0 {
if `r'[`j',1] == `base_E' & `r'[`j',2] == `base_theta' {
mat `buffer' = (`buffer'\ `=`r'[`j',3]',`=`r'[`j',4]')
mat `reported_r'[`j',1] =1
}
}
}
tempname mat_mean mat_sd
mata: st_matrix("`mat_sd'", diagonal(sqrt(variance(st_matrix("`buffer'"))))')
mata: st_matrix("`mat_mean'", mean(st_matrix("`buffer'")))
di as result %9s `"`: display %9.0g `r'[`i',1] '"' _c
di as result %9s `"`: display %9.5g `r'[`i',2] '"' _c
forvalues j=1/2{
di as result `dformat' `"`:display `fmt' `mat_mean'[1,`j'] '"' _c
di as result `dformat' `"`:display `fmt' `mat_sd'[1,`j'] '"' _c
}
mat `summary_r' = (`summary_r'\ `=`r'[`i',1]',`=`r'[`i',2]', `=`mat_mean'[1,1]',`=`mat_sd'[1,1]', `=`mat_mean'[1,2]',`=`mat_sd'[1,2]')
di ""
if `=e(ci)'>0 & `=e(ci)'<100 {
edm_showci , matmean(`mat_mean') matsd(`mat_sd') buffer(`buffer') ci(`=e(ci)')
}
}
mat `summary_r'=`summary_r'[2...,.]
ereturn matrix summary = `summary_r'
di as txt "{hline 70}"
di as text "Note: Results from `=max(`=e(replicate)',`=e(crossfold)')' runs"
}
di as text ustrtrim(e(cmdfootnote))
}
else if e(subcommand) == "xmap" {
di as txt "Convergent Cross-mapping result for variables {bf:`=e(x)'} and {bf:`=e(y)'}"
loc direction1 = "`=e(y)' ~ `=e(y)'|M(`=e(x)')"
loc direction2 = "`=e(x)' ~ `=e(x)'|M(`=e(y)')"
forvalues i=1/2{
if strlen("`direction`i''")>26 {
loc direction`i' = substr("`direction`i''",1,24) + ".."
}
}
loc mapp_col_length = min(28, max(strlen("`direction1'"), strlen("`direction2'")) +3)
loc line_length = 50 + `mapp_col_length'
if (e(replicate) == "1" | e(rep_details) == "1") {
di as txt "{hline `line_length'}"
di as text %`mapp_col_length's "Mapping" _c
di as text %16s "Library size" _c
di as text %16s "rho" _c
di as text %16s "MAE"
di as txt "{hline `line_length'}"
loc max_round= 1+ (e(direction) =="both")
forvalues round=1/`max_round'{
if `round' ==1 {
mat r = e(xmap_1)
}
else {
mat r = e(xmap_2)
}
loc nr = rowsof(r)
loc kr = colsof(r)
forvalues i = 1/ `nr' {
forvalues j=1/`kr' {
if `j' == 1 {
di as result %`mapp_col_length's "`direction`=r[`i',`j']''" _c
}
else {
di as result %16s `"`:display `fmt' r[`i',`j'] '"' _c
}
}
di " "
}
}
di as txt "{hline `line_length'}"
}
else {
di as txt "{hline `line_length'}"
di as text %`mapp_col_length's "Mapping" _c
di as text %16s "Lib size" _c
di as text %16s "Mean rho" _c
di as text %16s "Std. Dev."
di as txt "{hline `line_length'}"
loc dformat "%16s"
tempname reported_r r buffer summary_r
forvalues round=1/2{
if `round' ==1 {
mat `r' = e(xmap_1)
}
else {
mat `r' = e(xmap_2)
if e(direction) =="oneway" {
continue, break
}
}
loc nr = rowsof(`r')
loc kr = colsof(`r')
mat `reported_r' = J(`nr',1,0)
mat `summary_r' = J(1,6,.)
forvalues i = 1/ `nr' {
mat `buffer' = J(1,2,.)
if `reported_r'[`i',1] ==1 {
continue
}
loc base_direction = `r'[`i',1]
loc base_L = `r'[`i',2]
forvalues j=1/`nr' {
if `reported_r'[`j',1] ==0 {
if `r'[`j',1] == `base_direction' & `r'[`j',2] == `base_L' {
mat `buffer' = (`buffer'\ `=`r'[`j',3]',`=`r'[`j',4]')
mat `reported_r'[`j',1] =1
}
}
}
tempname mat_mean mat_sd
mata: st_matrix("`mat_sd'", diagonal(sqrt(variance(st_matrix("`buffer'"))))')
mata: st_matrix("`mat_mean'", mean(st_matrix("`buffer'")))
di as result %`mapp_col_length's "`direction`base_direction''" _c
di as result `dformat' `"`: display `fmt' `r'[`i',2] '"' _c
forvalues j=1/1{
di as result `dformat' `"`:display `fmt' `mat_mean'[1,`j'] '"' _c
di as result `dformat' `"`:display `fmt' `mat_sd'[1,`j'] '"' _c
}
mat `summary_r' = (`summary_r'\ `=`r'[`i',1]',`=`r'[`i',2]', `=`mat_mean'[1,1]',`=`mat_sd'[1,1]', `=`mat_mean'[1,2]',`=`mat_sd'[1,2]')
di ""
if `=e(ci)'>0 & `=e(ci)'<100 {
edm_showci , matmean(`mat_mean') matsd(`mat_sd') buffer(`buffer') ci(`=e(ci)') maxr(1)
}
}
}
mat `summary_r'=`summary_r'[2...,.]
ereturn matrix summary = `summary_r'
di as txt "{hline `line_length'}"
di as text "Note: Results from `=e(replicate)' replications"
}
if "`=e(cmdfootnote)'" != "." {
di as text ustrtrim(e(cmdfootnote))
}
di as txt "Note: The embedding dimension E is `=e(e)'"
}
if `=e(ci)'>0 & `=e(ci)'<100 {
di as text "Note: CI is estimated based on mean +/- " _c
loc sdm:display %10.2f `=invnormal(1-(100-`=e(ci)')/200)'
di trim("`sdm'") _c
di "*std"
}
di as txt "For more information, please refer to {help edm:help file} and the article."
end
capture mata mata drop smap_block()
mata:
mata set matastrict on
void smap_block(string scalar manifold, string scalar p_manifold, string scalar prediction, string scalar result, string scalar train_use, string scalar predict_use, real scalar theta, real scalar l, string scalar skip_obs, string scalar algorithm, string scalar vars_save)
{
real matrix M, Mp, y, ystar,S
st_view(M, ., tokens(manifold), train_use) //base manifold
st_view(y, ., prediction, train_use) // known prediction of the base manifold
st_view(ystar, ., result, predict_use)
if (p_manifold != "") {
st_view(Mp, ., tokens(p_manifold), predict_use)
}
else {
st_view(Mp, ., tokens(manifold), predict_use)
}
st_view(S, ., skip_obs, predict_use)
if (l <= 0) { //default value of local library size
k = cols(M)
l = k + 1 // local library size (E+1) + itself
}
real matrix B
real scalar save_mode
if (vars_save != "") {
st_view(B, ., tokens(vars_save), predict_use)
save_mode = 1
}
else {
save_mode = 0
}
real scalar n
n = rows(Mp)
real rowvector b
for(i=1;i<=n;i++) {
b= Mp[i,.]
ystar[i] = mf_smap_single(M,b,y,l,theta,S[i],algorithm, save_mode*i, B)
}
}
end
capture mata mata drop mf_smap_single()
mata:
mata set matastrict on
real scalar mf_smap_single(real matrix M, real rowvector b, real colvector y, real scalar l, real scalar theta, real scalar skip_obs, string scalar algorithm, real scalar save_index, real matrix Beta_smap)
{
real colvector d, w, a
real colvector ind, v
real scalar j
n = rows(M)
d = J(n, 1, 0)
for(i=1;i<=n;i++) {
a= M[i,.] - b
d[i] = a*a'
}
minindex(d, l+skip_obs, ind, v)
real scalar d_base
real scalar pre_adj_skip_obs
pre_adj_skip_obs = skip_obs
for(j=1;j<=l;j++) {
if (d[ind[j+skip_obs]] == 0) {
skip_obs++
}
else {
break
}
}
if (pre_adj_skip_obs!=skip_obs) {
minindex(d, l+skip_obs, ind, v)
}
if (d[ind[1+skip_obs]] == 0) {
d= editvalue(d, 0,.)
skip_obs = 0
minindex(d, l+skip_obs, ind, v)
}
d_base = d[ind[1+skip_obs]]
w = J(l+skip_obs, 1, 0)
for(j=1+skip_obs;j<=l+skip_obs;j++) {
w[j] = exp(-theta*(d[ind[j]] / d_base)^(1/2))
}
w = w/sum(w)
r = 0
if (algorithm == "" | algorithm == "simplex") {
for(j=1+skip_obs;j<=l+skip_obs;j++) {
r = r + y[ind[j]] * w[j]
}
return(r)
}
else if (algorithm =="smap") {
real colvector y_ls
real matrix X_ls
real rowvector x_pred
y_ls = J(l+skip_obs, 1, .)
X_ls = J(l+skip_obs, cols(M), .)
for(j=1+skip_obs;j<=l+skip_obs;j++) {
y_ls[j] = y[ind[j]] * w[j]
X_ls[j,.] = M[ind[j],.] * w[j]
}
n_ls = rows(X_ls)
X_ls = X_ls,J(n_ls,1,1)
XpXi = quadcross(X_ls, X_ls)
XpXi = invsym(XpXi)
b_ls = XpXi*quadcross(X_ls, y_ls)
if (save_index>0) {
Beta_smap[save_index,.] = b_ls'
}
x_pred = b,1
r = x_pred * b_ls
return(r)
}
}
end
