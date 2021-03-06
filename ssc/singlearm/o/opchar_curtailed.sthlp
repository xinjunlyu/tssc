{smcl}
{* *! version 1.0 15 May 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "opchar_curtailed##syntax"}{...}
{viewerjumpto "Description" "opchar_curtailed##description"}{...}
{viewerjumpto "Options" "opchar_curtailed##options"}{...}
{viewerjumpto "Remarks" "opchar_curtailed##remarks"}{...}
{viewerjumpto "Examples" "opchar_curtailed##examples"}{...}
{title:Title}
{phang}
{bf:opchar_curtailed} {hline 2} Determine the operating characteristics of group sequential single-arm trial designs for a single binary endpoint

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:opchar_curtailed}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt j(#)}} The maximal number of stages to allow. Defaults to 2.{p_end}
{synopt:{opt pi1(#)}} The (desirable) response probability at which the trial is powered. Defaults to 0.3.{p_end}
{synopt:{opt n(numlist)}} Numlist of stage-wise sample sizes. Internally defaults to 10,19.{p_end}
{synopt:{opt a(numlist miss)}} Numlist of acceptance boundaries. Internally defaults to 1,5.{p_end}
{synopt:{opt r(numlist miss)}} Numlist of rejection boundaries. Internally defaults to .,6.{p_end}
{synopt:{opt thetaf(numlist)}} A numlist of futility curtailment probabilities. Internally defaults to 0,...,0.{p_end}
{synopt:{opt thetae(numlist)}} A numlist of efficacy curtailment probabilities. Internally defaults to 1,...,1.{p_end}
{synopt:{opt k(numlist)}} Calculations are performed conditional on the trial stopping in one of the stages listed in numlist k. Thus, k should be a numlist of integers, with elements between one and the maximum number of possible stages. If left unspecified, it will internally default to all possible stages.{p_end}
{synopt:{opt pi(numlist)}} Numlist of response probabilities to evaluate the expected performance of the point estimation procedures at. This will internally default to 0,0.01,...,1.{p_end}
{synopt:{opt sum:mary(#)}} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.{p_end}
{synopt:{opt pl:ot}} Indicates whether a plot should be produced. If set to power then the power curve will be procedured. If set to ess then the ESS curve will be produced.{p_end}
{synopt:{opt *}} Additional options to use during plotting.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

For each value of pi in the supplied numlist pi, opchar_curtailed evaluates the
power, ESS, and other key characteristics, of each of the supplied designs.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt j(#)} The maximal number of stages to allow. Defaults to 2.

{phang}
{opt n(numlist)} Numlist of stage-wise sample sizes. Internally defaults to 10,19.

{phang}
{opt a(numlist miss)} Numlist of acceptance boundaries. Internally defaults to 1,5.

{phang}
{opt r(numlist miss)} Numlist of rejection boundaries. Internally defaults to .,6.

{phang}
{opt thetaf(numlist)} A numlist of futility curtailment probabilities. Internally defaults to 0,...,0.

{phang}
{opt thetae(numlist)} A numlist of efficacy curtailment probabilities. Internally defaults to 1,...,1.

{phang}
{opt k(numlist)} Calculations are performed conditional on the trial stopping in one of the stages listed in numlist k. Thus, k should be a numlist of integers, with elements between one and the maximum number of possible stages. If left unspecified, it will internally default to all possible stages.

{phang}
{opt pi(numlist)} Numlist of response probabilities to evaluate the expected performance of the point estimation procedures at. This will internally default to 0,0.01,...,1.

{phang}
{opt sum:mary(#)} An integer indicating whether a summary of the function's progress should be printed (summary = 1) to the console. Defaults to 0.

{phang}
{opt pl:ot} Indicates whether a plot should be produced. If set to bias that the bias curve will be procedured. If set to rmse then the RMSE curve will be produced.

{phang}
{opt *} Additional options to use during plotting.

{marker examples}{...}
{title:Examples}

{phang}
{stata opchar_curtailed}

{phang}
{stata opchar_curtailed, n(15, 10) a(1, 5) r(., 6)}

{title:Author}
{p}

Michael J. Grayling, MRC Biostatistics Unit, Cambridge.

Email {browse "mjg211@cam.ac.uk":mjg211@cam.ac.uk}

{title:See Also}

Related commands:

{help des_curtailed} (if installed)
