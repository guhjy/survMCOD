
<!-- README.md is generated from README.Rmd. Please edit that file -->
survMCOD
========

[![License](https://img.shields.io/badge/License-GPL%20%28%3E=%203%29-brightgreen.svg)](http://www.gnu.org/licenses/gpl-3.0.html)

**survMCOD** is an R package to fit Cox regression models for the hazard of death due to a disease of interest based on multiple cause-of-death data ("Multiple-cause analysis"). Such data are usually obtained by extracting all the diseases mentioned on the death certificate, not only the so-called "underlying cause of death". This multiple-cause mortality model thus acknowledges that death may be caused by several disease processes acting together. It was proposed by Moreno-Betancur et al. (2017), and it is the first formal extension of the single-cause competing risks model to that setting.

Specifically, using all deaths partially attributed to the disease of interest, we model the pure hazard rate of the disease of interest. This is the rate of deaths caused exclusively by that disease, and is thus a quantity that is conceptually closer to the marginal "causal" hazard than the cause-specific hazard. The latter is the quantity modeled when using competing risks Cox regression based on the underlying cause of death and ignoring all other diseases mentioned on the death certificate ("Single-cause analysis").

**Note:** Please note that the version available on GitHub is the most up-to-date *development* version of the package. A stable version of the package will be available from CRAN once it is released.

Getting Started
---------------

### Prerequisites

The **survMCOD** package requires the **survival** and **Matrix** packages.

### Installation

The **survMCOD** package can be installed directly from GitHub using the **devtools** package. To do this you should first check you have devtools installed by executing the following commands from within your R session:

``` r
if (!require(devtools)) {
  install.packages("devtools")
}
```

Then execute the following commands to install **survMCOD**:

``` r
library(devtools)
install_github("moreno-betancur/survMCOD")
```

Example
-------

To illustrate the use of the package, we use data simulated using the package's `simMCOD` function (use `?simMCOD` for more details):

``` r
library(survMCOD)
#> Loading required package: survival

datEx <- simMCOD(n = 4000, xi = -1, rho = -2, phi = 0, pgen = c(1, 0, 0.75, 
    0.25, 0.125, 0.083), lambda = 0.001, v = 2, pUC = c(1, 0.75))
```

The dataset is of the format required by `survMCOD`. It contains one row per invididual, and the variables consist of: \* The covariates to include as regressors in the models (X1 and Z1). \* A time of entry and a time of exit corresponding to the set-up of a time-to-event outcome with delayed entry and right censoring (TimeEntry and TimeExit). N.B. The package also handles the simple right-censoring case. \* The vital status of the indvidual at TimeExit (Status), coded 1=died and 0=alive. \* A weight indicating the proportion of the death attributed to the disease of interest (Pi) which is a number between 0 and 1 if Status=1 and missing (NA) if Status=0. \* The underlying cause indicator (UC) which is 1 if the disease of interest was selected as underlying cause using WHO rules and 0 otherwise.

When analysing your own survival data with multiple causes of death, a key preliminary step to fitting models with `survMCOD` will be to assign a weight to each death that represents the proportion of the death attributed to the disease of interest. The user is referred to Moreno-Betancur et al. (2017), Piffaretti et al. (2016) and Rey et al. (2017) for descriptions and discussions of various weight-attribution strategies.

The assumptions of the multiple-cause model and details of the estimation procedure are provided in Moreno-Betancur et al. (2017). A key feature of the model is that a Cox model for the disease of interest and a Cox model for other causes need to be fitted simultaneously, and deaths with a weight between 0 and 1 will contribute to both. This is why the user needs to specify regressors for each of these models using the two arguments `formula` and `formOther` of the function as follows (use `?survMCOD` and `?SurvM` for more details).

``` r
fitMCOD <- survMCOD(SurvM(time = TimeEntry, time2 = TimeExit, status = Status, 
    weight = Pi) ~ X1, formOther = ~Z1, data = datEx, UC_indicator = "UC")
#> [1] "Iteration 1 out of 4 completed"
#> [1] "Iteration 2 out of 4 completed"
#> [1] "Iteration 3 out of 4 completed"
#> [1] "Iteration 4 out of 4 completed"
```

One aspect of the multiple-cause model is that a fully parametric model for the log ratio of the baseline pure hazards needs to be posited. The current default is to parametrise this a piecewise constant function with cut-offs at the 25th, 50th and 75th percentile of the failure time distribution of pure events (with weight=1). Future versions will provide the user control over this. Thus the model fit provides regression coefficient estimates for the models relating to the disease of interest and other diseases (as log-hazard ratios) and also estimates of the piecewise constant estimated log ratio of the baseline hazards. These results are extracted as follows:

``` r
fitMCOD[["Multiple-cause"]]
#> $`Disease of interest`
#>        Coef        SE     CIlow     CIupp pvalue
#> X1 -2.60311 0.2899448 -3.171402 -2.034819      0
#> 
#> $`Other diseases`
#>          Coef         SE       CIlow      CIupp    pvalue
#> Z1 0.01206181 0.04419341 -0.07455727 0.09868089 0.7849052
#> 
#> $`Piecewise constant log ratio of the baseline pure hazards`
#>               Coef        SE      CIlow      CIupp       pvalue
#> xi.0    -0.8786035 0.1561839 -1.1847238 -0.5724831 1.850315e-08
#> xi.4.22 -0.7769194 0.1706753 -1.1114431 -0.4423957 5.313067e-06
#> xi.5.72 -0.5855525 0.1597737 -0.8987089 -0.2723960 2.474481e-04
#> xi.7.57 -0.8500949 0.1609934 -1.1656421 -0.5345478 1.289671e-07
```

The results from the single-cause analysis can also be extracted from the object, as follows:

``` r
fitMCOD[["Single-cause"]]
#> $`Disease of interest`
#>         Coef        SE     CIupp     CIlow pvalue
#> X1 -1.358253 0.1234843 -1.600278 -1.116229      0
#> 
#> $`Other diseases`
#>           Coef         SE      CIupp      CIlow    pvalue
#> Z1 -0.03109009 0.04252078 -0.1144293 0.05224911 0.4646729
```

The convergence of the multiple-cause analysis should be checked using (use `?check.survMCOD` for more details):

``` r
check.survMCOD(fitMCOD)
```

![](README-unnamed-chunk-7-1.png)

Healthy convergence is seen by curves showing variation in estimates across the first three points, followed by a stabilisation of the curve around the final estimate.

Future versions will define a proper class of for objects created by `survMCOD` and summary and other such methods.

Bug Reports
-----------

If you find any bugs, please report them via email to [Margarita Moreno-Betancur](mailto:margarita.moreno@mcri.edu.au).

References
----------

1.  Moreno-Betancur M, Sadaoui H, Piffaretti C, Rey G. [Survival analysis with multiple causes of death: Extending the competing risks model](http://journals.lww.com/epidem/Abstract/2017/01000/Survival_Analysis_with_Multiple_Causes_of_Death_.3.aspx). Epidemiology 2017; 28(1): 12-19.

2.  Piffaretti C, Moreno-Betancur M, Lamarche-Vadel A, Rey G. [Quantifying cause-related mortality by weighting multiple causes of death](http://cdrwww.who.int/bulletin/volumes/94/12/16-172189.pdf). Bulletin of the World Health Organization 2016; 94:870-879B.

3.  Rey G, Piffaretti C, Rondet C, Lamarche-Vadel A, Moreno-Betancur M. [Analyse de la mortalite par cause : ponderation des causes multiples](http://invs.santepubliquefrance.fr/beh/2017/1/pdf/2017_1_2.pdf). Bulletin Epidemiologique Hebdomadaire, 2017; (1): 13-9.
