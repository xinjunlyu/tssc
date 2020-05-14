{smcl}


{title:edm Description}

{p 4 4 2} The command edm implements a series of tools that can be used for empirical dynamic
modeling in Stata. The command keyword is {bf:edm}, and should be immediately followed by the
subcommand explore, xmap or update. A dataset must be declared as time-series or panel data by the
tsset or xtset command prior to using the edm command, and time-series operators including l., f.,
d., and s. can be used (the last for seasonal differencing). A special feature of the command is
the auto-normalization with the z. prefix for variables (e.g. z.age).


{title:Syntax}

{p 4 4 2} The {bf:explore} subcommand follows the syntax below and supports either one or two
variables for exploration using simplex projection or S-mapping.

{p 4 4 2} {bf:edm} explore {bf:variables} [if {bf:exp}], [e({it:_numlist} ascending)]
[tau(integer)] [theta(numlist ascending)] [k(integer)] [algorithm(string)] [replicate(integer)]
[seed(integer)] [full] [predict] [copredict(variable)] [copredictvar(variables)]
[crossfold(integer)] [ci(integer)] [details]

{p 4 4 2} The second subcommand {bf:xmap} performs convergent cross-mapping (CCM). The subcommand
follows the syntax below and requires two variables to follow immediately after xmap. It shares
many of the same options of the explore subcommand although there are some differences given the
different purpose of the analysis.

{p 4 4 2} {bf:edm} xmap {bf:variables} [if {bf:exp}], [e(integer)] [tau(integer)] [theta(real)]
[library(numlist ascending)] [k(integer)] [algorithm(string)] [replicate(integer)]
[direction(string)] [seed(integer)] [predict] [copredict(variable)] [copredictvar(variables)]
[ci(integer)] [details] [savesmap(string)]

{p 4 4 2} The third subcommand {bf:update} updates the command to its latest version

{p 4 4 2} {bf:edm} update, [develop] [replace]

{title:Options}

{p 4 4 2} Both explore and xmap subcommands share the following options:

{p 4 4 2} {bf:e(numlist ascending)}: This option specifies the number of dimensions E used in the
manifold construction. If a list of numbers is provided, the command will compute results for all
numbers specified. The xmap subcommand only supports a single integer as the option whereas the
explore subcommand supports the option as a numlist. The default value for E is 2 (or 3 if simplex
projection or S-maps are done in a multivariate fashion), but in theory E can range from 2 to
almost half of the total sample size. For a value smaller than the minimum or larger than the
maximum, an error message is provided. Missing data will limit the maximum E under the current
deletion method.

{p 4 4 2} {bf:tau(integer)}: The tau (or τ) option allows researchers to specify the ‘time delay’,
which essentially arranges the data by the multiple τ. This is done by specifying lagged embeddings
that take the form: t,t-1τ,…,t-(E-1)τ, where the default is tau(1) (i.e., typical lags). However,
if tau(2) is set then every-other t is used to reconstruct the attractor and make predictions—this
does not halve the observed sample size because both odd and even t would be used to construct a
single set of emdedding vectors for analysis. This option is helpful when data are oversampled
(i.e., space too closely in time) and therefore very little new information about a dynamic system
is added at each occasion. However, the tau() setting is also useful if different dynamics occur at
different times scales, and can be chosen to reflect a researcher’s theory-driven interest in a
specific time-scale (e.g., daily instead of hourly). Researchers can evaluate whether τ>1 is
required by checking for large autocorrelations in the observed data (e.g., using Stata’s corrgram
function). Of course, such a linear measure of association may not work well in nonlinear systems
and thus researchers can also check performance by examining ρ and MAE at different values of τ.

{p 4 4 2} {bf:theta(numlist ascending)}: Theta is the distance weighting parameter for the local
neighbours in the manifold. It is used to detect the nonlinearity of the system in the explore
subcommand for S-mapping. Of course, as noted above, for simplex projection and CCM a differential
weight of theta(1) is applied to neighbours based on their distance, which is reflected in the fact
that the default value of θ is 1. However, this can be altered even for simplex projection or CCM
(two cases that we do not cover here). Particularly, values for S-mapping to test for improved
predictions as they become more local may include the following command: theta(0 .00001 .0001 .001
.005 .01 .05 .1 .5 1 1.5 2 3 4 6 8 10).

{p 4 4 2} {bf:k(integer)}: This option specifies the number of neighbours used for prediction. When
set to 1, only the nearest neighbour is used, but as k increases the next-closest nearest
neighbours are included for making predictions. In the case that k is set 0, the number of
neighbours used is calculated automatically (typically as k = E + 1 to form a simplex around a
target), which is the default value. When k < 0 (e.g., k(-1)), all possible points in the
prediction set are used (i.e., all points in the library are used to reconstruct the manifold).
This latter setting is useful and typically recommended for S-mapping because it allows all points
in the library to be used for predictions with the weightings in theta. However, with large
datasets this may be computationally burdensome and therefore k(100) or perhaps k(500) may be
preferred if T or NT is large.

{p 4 4 2} {bf:algorithm(string)}: This option specifies the algorithm used for prediction. If not
specified, simplex projection (a locally weighted average) is used. Valid options include simplex
and smap, the latter of which is a sequential locally weighted global linear mapping (or S-map as
noted previously). In the case of the xmap subcommand, the algorithm(smap) invokes something
analogous to a distributed lag model with E + 1 predictors (including a constant term c) and, thus,
E + 1 locally-weighted coefficients for each predicted observation—because each predicted
observation has its own type of regression done with k neighbours as rows and E + 1 coefficients as
columns. As noted below, in this case special options are available to save these coefficients for
post-processing and, again, it is not actually a regression model and instead should be seen as a
manifold.

{p 4 4 2} {bf:replicate(integer)}: The explore subcommand uses a random 50/50 split for simplex
projection and S-maps, whereas the xmap subcommand selects the observations randomly for library
construction if the size of the library L is smaller than the size of all available observations.
In these cases, results may be different in each run because the embedding vectors (i.e., the
E-dimensional points) used to reconstruct a manifold are chosen at random. The replicate command
takes advantages of this to allow repeating the randomization process and calculating results each
time. This is akin to a nonparametric bootstrap without replacement, and is commonly used for
inference using confidence intervals in EDM (Tsonis et al., 2015; van Nes et al., 2015; Ye et al.,
2015b). When replicate is specified, mean values and the standard deviations of the results are
reported by default. As we note below, it is possible to save all estimates for post-processing
using typical Stata commands such as svmat, allowing the graphing of results or finding
percentile-based confidence intervals with the pctile command.

{p 4 4 2} {bf:predict(variable)}: This option allows you to save the internal prediction result of
the edm as a variable, which could be useful for plotting and diagnosis.

{p 4 4 2} {bf:copredict(variable)}: This option allows you to save the coprediction result as a
variable. You must specify the copredictvar(variables) options for this to work.

{p 4 4 2} {bf:copredictvar(variables)}: This option is used together with copredict option and
specify the variables used for coprediction. The number of variables must match the main variables
specified.

{p 4 4 2} {bf:tp(integer)}: tp() option adjusts the default forward prediction period. By default,
the explore mode uses tp(1) and the xmap mode uses tp(0).

{p 4 4 2} {bf:details}: By default, only mean values and standard deviations are reported when the
replicate option is specified. The details option overrides this behaviour by providing results for
each individual run. Irrespective of using this option, all results can be saved for
post-processing.

{p 4 4 2} {bf:ci(integer)}: When replicate() option is specified, this option reports the
confidence interval of the estimates, and the selected percentile values. ci(95) indicates 95%
confidence interval.

{p 4 4 2} {bf:seed(integer)}: This option specifies the seed used for the random number. In some
special cases users may wish to use this in order to keep library and prediction sets the same
across simplex projection and S-mapping with a single variable, or across multiple CCM runs with
different variables.


{p 4 4 2} Besides the shared parameters, edm explore supports the following extra options:

{p 4 4 2} {bf:crossfold(integer)}: This option asks the program to run a cross-fold validation of
the predicted variables. crossfold(5) indicates a 5-fold cross validation. Note that this cannot be
used together with replicate.

{p 4 4 2} {bf:full}: When this option is specified, the explore command will use all possible
observations in the manifold construction instead of the random 50/50 split by default. This is
effectively the same as leave-one-out cross-validation as the observation itself is not used for
the prediction.

{p 4 4 2} Besides the shared parameters, edm xmap supports the following extra options:

{p 4 4 2} {bf:library(numlist ascending)}: 	This option specifies the total library size L used for
the manifold reconstruction. Varying the library size is used to estimate the convergence property
of the cross-mapping, with a minimum value Lmin = E + 2 and the maximum equal to the total number
of observations minus sufficient lags (e.g., in the time-series case without missing data this is
Lmax = T + 1 – E). An error message is given if the L value is beyond the allowed range. To assess
the rate of convergence (i.e., the rate at which ρ increases as L grows), the full range of library
sizes at small values of L can be used, such as if E = 2 and T = 100, with the setting then perhaps
being library(4(1)25 30(5)50 54(15)99). 

{p 4 4 2} {bf:savesmap(string)}: This option allows smap coefficients to be stored in variables
with a specified prefix. For example, specifying “edm xmap x y, algorithm(smap) savesmap(beta)
k(-1)” will create a set of new variables such as beta1_l0_rep1. The string prefix (e.g., ‘beta’)
must not be shared with any variables in the dataset, and the option is only valid if the
algorithm(smap) is specified. In terms of the saved variables such as beta1_l0_rep1, the first
number immediately after the prefix ‘beta’ is 1 or 2 and indicates which of the two listed
variables is treated as the dependent variable in the cross-mapping (i.e., the direction of the
mapping). For the “edm xmap x y” case, variables starting with beta1_ contain coefficients derived
from the manifold M_X created using the lags of the first variable ‘x’ to predict Y, or Y|M_X. This
set of variables therefore store the coefficients related to ‘x’ as an outcome rather than a
predictor in CCM. Keep in mind that any Y→X effect associated with the beta1_ prefix is shown as
Y|M_X, because the outcome is used to cross-map the predictor, and thus the reported coefficients
will be scaled in the opposite direction that is typical for regression (because in CCM the outcome
variable predicts the cause). To get more familiar regression coefficients (which will be locally
weighted), variables starting with beta2_ store the coefficients estimated in the other direction,
where the second listed variable ‘y’ is used for the manifold reconstruction M_Y for the mapping
X|M_Y in the “edm xmap x y”case, testing the opposite X→Y effect in CCM, but with reported S-map
coefficients that map to a Y→X regression. We appreciate that this may be unintuitive, but because
CCM causation is tested by predicting the causal variable with the outcome, to get more familiar
regression coefficients requires reversing CCM’s causal direction to a more typical
predictoroutcome regression logic. This can be clarified by reverting to the conditional notation
such as X|M_Y, which in CCM implies a left-to-right X→Y effect, but for the S-map coefficients will
be scaled as a locally-weighted regression in the opposite direction Y→X. Moving on, following the
1 and 2 is the letter l and a number ranging from 0 to E – 1, which indicates the embedding lag on
the predictor associated with the coefficient. The numerical labeling scheme is consistent with the
lagged embeddings in the neighbouring library vectors used for prediction—recall that for S-maps, a
k×E matrix of library vectors is used to predict each target, with k neighbours and E lagged
embedding elements in each as predictors at their occasions t,t-1τ,…,t-(E-1)τ. The numeric
representation after the letter l is similar to a distributed lag model with an array of lags
associated with each neighbor used for prediction. Thus, l0 means no lag (i.e., predictions using
the first column in the k neighbouring library vectors), l1 means one lag (i.e., predictions using
the second column in the neighbouring library vectors), and so forth. A special case c is the
constant term in the regression. The final term rep1 indicates the coefficients are from the first
round of replication (if the replicate() option is not used then there is only one). Finally, the
coefficients are saved to match the observation t in the dataset that is being predicted, which as
we note later allows plotting each of the E estimated coefficients against time and/or the values
of the variable being predicted. The variables are also automatically labelled for clarity.

{p 4 4 2} {bf:direction(string)}: This option allows users to control whether the cross mapping is
calculated bidirectionally or unidirectionally, the latter of which reduces computation times if
bidirectional mappings are not required. Valid options include “oneway” and “both”, the latter of
which is the default and computes both possible cross-mappings. When oneway is chosen, the first
variable listed after the xmap subcommand is treated as the potential dependent variable following
the conventions in the regression syntax of Stata such as the‘reg’ command, so “edm xmap x y,
direction(oneway)” produces the cross-mapping Y|M_X, which pertains to a Y→X effect. This is
consistent with the beta1_ coefficients from the previous savesmap(beta) option. On this point, the
direction(oneway) option may be especially useful when an initial “edm xmap x y”procedure shows
convergence only for a cross-mapping Y|M_X, which pertains to a Y→X effect. To save time with large
datasets, any follow-up analyses with the algorithm(smap) option can then be conducted with “edm
xmap x y, algorithm(smap) savesmap(beta) direction(oneway)”.



{p 4 4 2} The update subcommand supports the following options:


{p 4 4 2} {bf:develop}: This option updates the command to its latest development version. The development version usually contains more features but may be less tested compared with the older version distributed on SSC.

{p 4 4 2} {bf:replace}: This option specifies whether you allow the update to override your local ado files.


{title:Examples}

{p 4 4 4}
     
     // Chicago crime dataset example (included in the auxiliary file) {cmd: use chicago,clear}
     
     {cmd: edm explore temp, e(2/30)} {cmd: edm xmap temp crime} {cmd: edm xmap temp crime,
     alg(smap) savesmap(beta) e(6) k(-1)}
     



{title:Updates}

{p 4 4 2} To install the stable version or upgrade directly through Stata:

{p 4 4 2} {cmd:ssc install edm, replace}

{p 4 4 2} To install the development version directly through Stata:

{p 4 4 2} {cmd: net install edm, from("https://jinjingli.github.io/edm/") replace}


{title:Suggested Citation}

{p 4 4 2} Li, J, Zyphur, M & Sugihara, G (under review). Beyond linearity, stability, and
equilibrium: The edm package for empirical dynamic modeling and convergent cross-mapping, Stata
Journal


{title:Contact}

{p 4 4 2} Jinjing Li, National Centre for Social and Economic Modelling, University of Canberra,
Australia {browse "mailto:jinjing.li@canberra.edu.au":jinjing.li@canberra.edu.au}




