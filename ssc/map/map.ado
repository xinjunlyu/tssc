capture: program drop map
program define map
  syntax varname using/, Values(string) [na(string) replace]

  version 16

  capture: confirm string variable `varlist'
  if (_rc != 0) display "variable `varlist' must be string"

  tempname tempFrame
  frame create `tempFrame'
  frame `tempFrame'{
    capture: confirm file `using'
    if(_rc != 0){
      display as error "file `using' not found"
      exit
    }

    local fileCheck = 0
    if (substr("`using'",-4,.) == ".csv"){
      quietly: import delimited `using', varnames(1) encoding("utf-8")
      local fileCheck = 1
    }
    if (substr("`using'",-4,.) == ".dta"){
      quietly: use `using'
      local fileCheck = 1
    }
    if (`fileCheck' == 0){
      display as error "only .dta and .csv files are supported."
      exit
    }

    capture: confirm variable `varlist'
    if (_rc != 0){
      display as error "variable `varlist' does not exist in using dataset"
      exit
    }
    capture: confirm variable `values'
    if (_rc != 0){
      display as error "variable `values' does not exist in using dataset"
      exit
    }

    quietly: duplicates report `varlist'
    local unique = r(unique_value)
    local all = r(N)
    if `unique' != `all'{
      display as text "the variable `varlist' contains repeated keys"
      display as test "assigned the last available value for these keys"
    }

    local keysN = `=_N'
    forvalues i = 1/`keysN'{
      local key`i' = `varlist'[`i']
      local value`i' = `values'[`i']
    }
  }

  quietly{
    tempvar `values'
    gen ``values'' = "", after(`varlist')
    forvalues i = 1/`keysN'{
      replace ``values'' = "`value`i''" if (`varlist' == "`key`i''")
    }
    if ("`na'" != ""){
      replace ``values'' = "`na'" if(``values'' == "")
    }

    if ("`replace'" == ""){
      gen `values' = ``values'', after(``values'')
      label variable `values' "(mapped) `varlist'"
    }
    if ("`replace'" == "replace"){
      drop `varlist'
      gen `varlist' = ``values'', after(``values'')
      label variable `varlist' "(mapped) `varlist'"
    }
  }
end
