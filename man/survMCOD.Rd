% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/survMCOD.r
\name{survMCOD}
\alias{survMCOD}
\title{Fit Cox regression models for multiple cause-of-death data}
\usage{
survMCOD(formula, formOther = formula[-2], data, UC_indicator, Iter = 4)
}
\arguments{
\item{formula}{A formula object with the response on the left of the ~ operator being an object as returned by the \code{SurvM} function
(see \strong{Examples} section below). The terms on the right are the regressors to include in the the model for the pure hazard of the
disease of interest.}

\item{formOther}{A formula object with empty response, i.e. nothing on the left of the ~ operator (if a response is given it is ignored).
The terms on the right are the regressors to include in the the model for the pure hazard of other diseases. If unspecified, this model will
include the same regressors as the model for the disease of interest as specified in \code{formula} above.}

\item{data}{A data.frame in which to interpret the variables named in \code{formula} and \code{formOther} above.
Specifically, the dataset must contain one row per individual and the following variables:
- The time-to-event (for type="right") or the entry and exit times (for type="counting")
- A status variable indicating whether the individual died (=1) or is censored (=0)
- A weight variable which is missing ("NA") if the individual is censored, and a proportion between 0 and 1 if the individual died.
The weight corresponds to the proportion of that death that is attributed to the disease of interest according to the chosen weight
attribution strategy (see \strong{Details} section below).
- All the regressors named in \code{formula} and \code{formOther}.
- The Underlying Cause Indicator, specified in \code{UC_indicator}, which is 1 if the individual died and the disease of interest was selected as
underlying cause of death and 0 otherwise (i.e. 0 if individual censored or if individual died but the disease of interest
was not selected as underlying cause of death).}

\item{UC_indicator}{Name of the Underlying Cause Indicator variable in the dataset.}

\item{Iter}{Number of iterations for iteration procedure. Default is 4 which is generally enough to achieve convergence. See \strong{Value} below
for more details.}
}
\value{
This development version returns a list with three components. First, a list with the results of the multiple-cause analysis.
These are estimates of log hazard ratios for the models for the disease of interest and other diseases, and
estimates of the piecewise constant log ratio of the baseline pure hazards. Second, a list with the single-cause analysis
log hazard ratio estimates for the disease of interest and other diseases. All estimates are accompanied with their corresponding
standard errors, 95\%  confidence intervals and p-values. This will change in future versions when a proper class of objects and
summary and other such methods are developed. Third, a data.frame with Iter+2 estimates of each parameter, the first two corresponding
to a starting value and an improved starting value (see Moreno-Betancur et al. 2017 for details). This data.frame is used by function
\code{check.survMCOD}, which enables the user to check convergence (type ?check.survMCOD for details).
}
\description{
\code{survMCOD} fits Cox regression models for the pure hazard of death due to a disease of interest based on multiple
cause-of-death data ("Multiple-cause analysis"), thus acknowledging that death may be caused by several disease processes acting
concurrently. The pure hazard is the rate of deaths caused exclusively by the disease of interest, and is thus a quantity that
is conceptually closer to the marginal "causal" hazard than the cause-specific hazard. The latter is the quantity modeled
when using competing risks Cox regression based on the so-called "underlying cause of death" and ignoring all other diseases
mentioned on the death certificate ("Single-cause analysis").
}
\details{
The \code{survMCOD} function can be used to fit Cox regression models
for the pure hazard of death due to a disease of interest based on multiple
cause-of-death data. In addition to results from the multiple-cause analysis,
the function also provides the results from the single-cause analysis (i.e. from a
competing risks Cox regression based on the so-called "underlying cause of death").

The key preliminary step to using this function to perform the multiple-cause analysis
is to assign a weight to each death that represents the proportion of the death
attributed to the disease of interest. The user is referred to Moreno-Betancur et al. (2017),
Piffaretti et al. (2016) and Rey et al. (2017) for descriptions and discussions of various
weight-attribution strategies.

The assumptions of the multiple-cause model and details of the estimation procedure are provided in
Moreno-Betancur et al. (2017). A key feature of the model is that regression coefficients
need to be estimated simultaneaously for a Cox model for the disease of interest and a
Cox model for other causes, and deaths with a weight between 0 and 1 will contribute to both.
This is why the user needs to specify regressors for each of these models using the two
arguments \code{formula} and \code{formOther}.

Another aspect of the multiple-cause model is that a fully parametric model for the log ratio of the
baseline pure hazards needs to be posited. The current default is to parametrise this
a piecewise constant function with cut-offs at the 25th, 50th and 75th percentile of the
the user control over this.

Convergence of the multiple-cause model fitting procedure should be checked
using \code{check.survMCOD}.
}
\examples{

  ## Example ##

  # First we simulate data using the simMCOD function:
  datEx<-simMCOD(n=1000,xi=-1,rho=-2,phi=0,
         pgen=c(1,0,0.75,0.25,0.125,0.083),
         lambda=0.001,v=2,pUC=c(1,0.75))

  # Run analysis

  fitMCOD<-survMCOD(SurvM(time=TimeEntry,time2=TimeExit,status=Status,
                          weight=Pi)~X1,
                   formOther=~Z1,data=datEx,UC_indicator="UC")

  # Multiple-cause analysis results
   fitMCOD[[1]]

  # Single-cause analysis results
   fitMCOD[[2]]

  # Check convergence of multiple-cause analysis
    check.survMCOD(fitMCOD)

}
\references{
Moreno-Betancur M, Sadaoui H, Piffaretti C, Rey G. Survival analysis with multiple causes of death:
Extending the competing risks model. Epidemiology 2017; 28(1): 12-19.

Piffaretti C, Moreno-Betancur M, Lamarche-Vadel A, Rey G. Quantifying cause-related mortality by
weighting multiple causes of death. Bulletin of the World Health Organization 2016; 94:870-879B.

Rey G, Piffaretti C, Rondet C, Lamarche-Vadel A, Moreno-Betancur M. Analyse de la mortalite par cause :
ponderation des causes multiples. Bulletin Epidemiologique Hebdomadaire, 2017; (1): 13-9.
}
