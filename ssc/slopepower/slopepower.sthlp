{smcl}
{* *! version 1.0)}
{hline}
{cmd:help slopepower}{right: ({})}
{hline}
{vieweralsosee "[R] mixed" "help mixed"}{...}
{viewerjumpto "Syntax" "slopepower##syntax"}{...}
{viewerjumpto "Menu" "slopepower##menu"}{...}
{viewerjumpto "Description" "slopepower##description"}{...}
{viewerjumpto "Options" "slopepower##options"}{...}
{viewerjumpto "Examples" "slopepower##examples"}{...}
{viewerjumpto "Stored results" "slopepower##results"}{...}
{viewerjumpto "Authors" "slopepower##authors"}{...}

{title:Title}
{p2colset 5 20 20 2}{...}
{p2col :{hi:slopepower} {hline 2}}Sample size and power calculator for 
outcomes measured using a slope (ie repeated measures at multiple timepoints). 
A linear mixed model is used on data in memory to obtain estimates for slopes 
and variances among people with (and without) the condition of interest{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:slopepower}
        {it:{help depvar}}
		{ifin}
        {cmd:,}
        {opth subj:ect(varname)}
        {opth time(varname)}
        {opth sched:ule(numlist)}
        [{it:{help slopepower##options_table:options}}]


{synoptset 29 tabbed}{...}
{marker options}
{marker options_table}{...}
{synopthdr}
{synoptline}
{syntab :Options for data in memory}
{p2coldent :* {opth subj:ect(varname)}}variable defining each subject{p_end}
{p2coldent :* {opth time(varname)}}variable defining the time of each measurement{p_end}
{synopt :{opt obs}}the data in memory are observational. One of {opt obs} and {opt rct} must be specified{p_end}
{synopt :{opt nocont:rols}}the observational data in memory contain no controls{p_end}
{synopt :{opt rct}}the data in memory are from an RCT. One of {opt obs} and {opt rct} must be specified{p_end}
{synopt :{opth case:con(varname)}}variable defining if a person is a case or control. Required if and only if observational data is used. Must be a binary variable{p_end}
{p2coldent :* {opth tr:eat(varname)}}variable defining if a person received the intervention. Required if and only if RCT data is used{p_end}

{syntab :Options for future study}
{p2coldent :* {opth sched:ule(numlist)}}the visit times for the proposed study. 
Visit times are assumed to be in the same time units as the time variable, 
unless scale is specified{p_end}
{synopt :{opth drop:outs(numlist)}}the proportion of dropouts at each visit. 
Must correspond to the schedule list{p_end}
{synopt :{opt sca:le(#)}}The ratio between the time and schedule timescales{p_end}
{synopt :{opt a:lpha(#)}}significance level; default is 0.05{p_end}
{synopt :{opt p:ower(#)}}power; default is 0.8, Required to compute sample size{p_end}
{synopt :{opt n(#)}}total sample size; required to compute power{p_end}
{synopt :{opt eff:ectiveness(#)}}the assumed effectiveness of the treatment to be trialled. Default is 0.25{p_end}
{synopt :{opt uset:rt}}use the observed effectiveness of the treatment{p_end}

{syntab :Model options}
{synopt :{opt iter:ate(#)}}the maximum number of iterations allowed in the {cmd:mixed} model{p_end}
{synopt :{opt nocontvar}}omit the variance parameter for controls in the {cmd:mixed} model{p_end}

{synoptline}
{pstd}*these options are required.
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:slopepower} performs a sample size or power calculation for a proposed two-arm
randomised clinical trial (RCT) where the outcome of interest is a slope 
measured over time, and the treatment hopes to alter this slope to be more 
similar to the slope of people without the condition. The calculations are based 
partly upon data in Stata’s memory and partly on user input.
A linear mixed model is run (using {helpb mixed}) on the 
data in memory to estimate a plausible treatment effect and its variance; the 
remaining parameters are specified by the user. The data should come from 
either an observational study or a similar clinical trial and contain repeated 
measurements of the outcome in long format (see {helpb reshape} for more 
details). The data in memory will not be altered by this command. 


{marker options}{...}
{title:Options}

{dlgtab:Options for data in memory}

{phang}
{opth subj:ect(varname)} is the unique identifier for participants in the 
observational study

{phang}
{opth time(varname)} is the time variable of visits in the observational dataset. 
This can be in any units (eg days, months, years)

{phang}
{opt obs}, {opt nocont:rols} and {opt rct} tell Stata the nature of the data in 
memory. Exactly one of {opt obs} and {opt rct} must be specified. 
{opt nocont:rols} can optionally be used with {opt obs} if all the subjects in 
your observational data have the condition of interest.

{phang}
{opt case:control} specifies the variable used to identify cases in observational
data; it can only be used with {opt obs}. It must be a binary 0/1 variable.

{dlgtab:Options for future study}

{phang}
{opth sched:ule(numlist)} specifies the visit times for the proposed trial. A baseline
 visit at time 0 is assumed; this list should describe subsequent visits, in 
 whole number units of time. The default is to use the same time unit as the 
 time variable. To use a different timescale, specify how many TIME units make 
 one SCHEDULE unit in the scale option.

{phang}
{opth drop:outs(numlist)} specifies the estimated proportion of dropouts you 
expect at each study visit. It must correspond exactly to the schedule list. 
Each number in the list is a proportion between 0 and 1; this is the fraction of
subjects (of those remaining in the study at the preceding visit) you estimate 
will fail to attend that visit.

{phang}
{opt sca:le(#)} specifies the ratio between the time and visit timescales. 
For instance, if your time variable is in days, and you wish to have visits 
annually for three years, you would specify scale(365) and schedule(1 2 3)

{phang}
{opt tre:at} specifies treatment variable when you are usign RCT data; it can 
only be specified with {opt rct}. It must be a binary 0/1 variable.

{phang}
{opt a:lpha(#)} sets the significance level to be used in the planned study. 
The default is alpha(0.05).

{phang}
{opt pow:er(#)} sets the power for the planned study. The default is power(0.8)

{phang}
{opt n(#)} specifies the total number of particpants who will be in the trial. 
If an odd number is given, (n-1) will be used to allow equal numbers per arm.
Only one of {opt pow:er} and {opt n(#)} may be specified.

{phang}
{opt eff:ectiveness(#)} and {opt uset:rt} specify the effect size you hope to 
achieve in the future trial. {opt eff:ectiveness} specifies this effect size is
a proportion of the difference between cases and controls in the observational 
data in memory (or between treated and untreated in RCT data). If observational 
data with no controls are used, {opt eff:ectiveness} is a proportion of the 
difference towards a slope of 0. This must be a number 
between 0 and 1; the default value is 0.25. {opt uset:rt} specifies that, when 
RCT data is used, the planned study is expected to achieve the same effect size. 
You can only specify one of {opt eff:ectiveness} and {opt uset:rt}.

{dlgtab:Model options}

{phang}
{opt iter:ate(#)} is used as an option in the {cmd:mixed} command; see {helpb maximize}.

{phang}
{opt noCONTVar} specifies that the mixed model should estimate a variance 
parameter for controls. This is only applicable for when you are using 
observational data. Ignoring this variance may help the model to converge.

{marker examples}{...}
{title:Examples}
    {hline}
    Setup
{phang2}{cmd:. webuse nlswork, clear}{p_end}

{pstd}Use observational data, with no controls, to calculate power of a trial 
with N=4000, with 5% loss to follow-up expected at one year and two years, and 
10% at years three and five{p_end}
{phang2}{cmd:. slopepower ln_wage , subject(id) time(year) obs nocontrols schedule(1 2 3 5) dropouts (0.05 0.05 0.1 0.1) n(4000)}{p_end}

 {hline}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:slopepower} stores the following in {cmd:r()}:

{synoptset 18 tabbed}{...}
{p2col 5 20 20 4: Scalars}{p_end}
{synopt:{cmd:r(obs_in_model)}}number of observations in memory that were used in the mixed model{p_end}
{synopt:{cmd:r(alpha)}}Type I error rate (significance level) of the planned trial{p_end}
{synopt:{cmd:r(power)}}power of the planned trial{p_end}
{synopt:{cmd:r(fupvisits)}}specified number of follow up visits{p_end}
{synopt:{cmd:r(sampsize)}}total sample size{p_end}
{synopt:{cmd:r(effectiveness)}}specified effectiveness of the proposed treatment{p_end}
{synopt:{cmd:r(te)}}estimated treatment effect found in the data in memory{p_end}
{synopt:{cmd:r(var_te)}}variance of the estimate of the treatment effect{p_end}


{synoptset 18 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(table)}}table of results{p_end}

{p2colreset}{...}

{marker references}{...}
{title:References}

{phang}
Chris Frost, Michael G. Kenward, Nick C. Fox. Optimizing the design of clinical 
trials where the outcome is a rate. Can estimating a baseline rate in a run-in 
period increase efficiency? Statist. Med. 2008; 27:3717–3731 doi: 10.1002/sim.3280


{marker Authors}{...}
{title:Authors}
Katy Morgan, Amy Mulick, Stephen Nash
London School of Hygiene and Tropical Medicine
London, UK
stephen.nash@lshtm.ac.uk



