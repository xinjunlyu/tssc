*! version 1.2.0 23oct2019 daniel klein
program elabel_cmd_load
    version 11.2
    
    if (_caller() >= 16) local f f
    elabel parse [ anything ] [ if`f' ] [ using ]    ///
    [ , Add MODIFY REPLACE noFIX AS(string asis) ] : `0'
    
    if ("`add'`modify'" != "") {
        if ("`replace'" != "") {
            display as err "option replace may not " ///
            "be combined with option add or option modify"
            exit 198
        }
        if ("`modify'"!="") local add // void
    }
    local option `add' `modify' `replace'
    if ("`option'" == "") local option none
    
    if ("`fix'" != "") display as txt "note: option nofix ignored"
    
    if (`"`as'"' != "") {
        gettoken suffix void : as , quotes
        if ((`"`void'"' != "") | (!inlist(`"`suffix'"', "dta", "do"))) {
            display as err "option as() invalid"
            exit 198
        }
        local suffix .`suffix'
    }
    
    if mi(`"`using'"') {
        gettoken using anything : anything
        if (`"`anything'"' != "") {
            mata : errprintf("invalid '%'\n", st_local("anything"))
            exit 198
        }
    }
    else {
        gettoken usingword using : using
        gettoken using           : using
    }
    
    elabel protectr
    
    preserve
    
    clear
    
    if ( mi("`suffix'") )    load_suffix    using `"`using'"'
    if ("`suffix'" == ".do") load_labelsave using `"`using'"'
    else                     load_uselabel  using `"`using'"'
    
    tempfile tmp
    quietly elabel save `anything' `if`f'' using "`tmp'" , option(`option')
    
    restore
    
    preserve
    
    run "`tmp'"
    
    restore , not
end

program load_suffix
    syntax using/
    mata : st_local("suffix", pathsuffix(st_local("using")))
    if (!inlist("`suffix'", "", ".dta", ".do")) {
        capture describe using `"`using'"'
        local suffix = cond(_rc, ".do", ".dta")
    }
    c_local suffix : copy local suffix
end

program load_labelsave
    syntax using/
    run `"`using'"'
    quietly label dir
    if ("`r(names)'" != "") exit
    display as txt `"file "`using'""' ///
    " conatins no value label information"
end

program load_uselabel
    syntax using/
    quietly describe using `"`using'"' , varlist
    if ("`r(varlist)'" == "lname value label trunc") {
        local sortlist `r(sortlist)'
        quietly use `"`using'"'
        capture confirm string variable lname label
        if (!_rc) {
            capture confirm numeric variable value
            if (!_rc) {
                if ("`sortlist'" != "lname value") sort lname value
                mata : load_uselabel()
                drop _all
                exit
            }
            // NotReached
        }
    }
    display as err `"file "`using'" not created by {bf:uselabel}"'
    exit 698
end

version 11.2

mata :

mata set matastrict on

void load_uselabel()
{
    string       colvector lname, label
    real         colvector value
    real         matrix    info
    transmorphic scalar    v
    real         scalar    i
    
    pragma unset lname
    pragma unset label
    pragma unset value
    
    st_sview(lname, ., "lname")
    st_sview(label, ., "label")
    st_view( value, ., "value")
    info = panelsetup(lname, 1)
    
    for (i=1; i<=rows(info); ++i) {
        v = elabel_vlinit(panelsubmatrix(lname, i, info)[1], 
                          panelsubmatrix(value, i, info),
                          panelsubmatrix(label, i, info)   )
        elabel_vldefine(v)
    }
}

end
exit

/* ---------------------------------------
1.2.0 23oct2019 option nofix ignored; no longer documented
1.1.1 15jul2019 set matastrict on
1.1.0 03jun2019 use -iff- in place of -if-
1.0.0 02apr2019 first version
