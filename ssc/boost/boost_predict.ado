capture program drop boost_predict
program define boost_predict
*! version 1.1.0  Feb, 2019  Matthias Schonlau

	version 15.0

	syntax anything(name = predict) [if][in]
	
	marksample touse, novarlist

	matrix pmatrix = e(predmat)
	local names : colnames pmatrix
	local predictlabels = e(predictlabels)
	local L = wordcount("`predictlabels'")
	
	tokenize `predict', parse(*)
	local predictname = "`1'"
	if "`L'" == "1" {
		matrix colnames pmatrix = `predict'
		svmat pmatrix, names(col)
		label var `predictname' "`predictlabels'"
		replace `predictname'=. if !`touse'
	}
	else {
		svmat pmatrix, names("`1'")
		tokenize "`predictlabels'"
		foreach i of numlist 1/`L' {
			label var `predictname'`i' "``i''"
			replace `predictname'`i' =. if !`touse'
		}
	}
	
	// decided not to remove the matrix predmat to allow multiple predict statements	
end
	
/*
Revision history
Version date 
1.1.0   Feb 18, 2019  Predict allows [if][in] option. Useful for crossvalidation.
original version   July 4, 2018
*/