{smcl}
{* *! version 1.0.0  26mar2020}{...}

{title:Map}

{pstd}
  {hi:map} {hline 2} maps string variables using an external dictionary file.

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
  {cmd:map} {help varlist:{it:varname}} {bf:using} {help filename:filename}{cmd:,} 
  {ul:v}alues [other options]

{title:Description}

{p 5 5}
This command maps an existing string variable using an external dictionary file.
It accepts .csv and .dta dictionary files. The variable to map and the variable in the dictionary files containing the mapping keys should have the same name.

{synoptset 25 tabbed}{...}
{marker Options}{synopthdr:options}
{synoptline}
{syntab:values}
{synopt:{bf:{ul:v}alues}}define the column containing the mapping values in the dictionary file.{p_end}

{syntab:other options}
{synopt:{bf:na}}value to assign to the mapped variable if the string in the original variable does not match any key in the dictionary file. The default value is an empty string{p_end}
{synopt:{bf:replace}}replaces the original variable instead of creating a new variable.{it:Be aware that this option does not preserve the original data}{p_end}

{title:Author}

{it:Daniel Alves Fernandes}
European University Institute
