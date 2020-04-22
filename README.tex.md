---
title: "Composite Regression for Repeated Surveys"
editor_options: 
  chunk_output_type: console
---

`CompositeRegressionEstimation` is an R package that allows to compute estimators for longitudinal survey:
* Composite Regression ["Fuller, Wayne A., and J. N. K. Rao. "A regression composite estimator with application to the Canadian Labour Force Survey." Survey Methodology 27.1 (2001): 45-52."](http://www.statcan.gc.ca/pub/12-001-x/2001001/article/5853-eng.pdf)
* Yansaneh Fuller
* AK estimator

#  General usage

## Install


```r
devtools::install_github("DanielBonnery/CompositeRegressionEstimation")
```
## Demonstration code
This package has been used for the paper submitted by D. Bonnery, P. Lahiri and Y. Cheng on real data (CPS data).
One can consult the pdf package documentation on the github page to see demo code.

Below is given a basic demonstration code on a simulated dataset

```r
library(CompositeRegressionEstimation)
data(CRE_data)
example(MR)
```

## Manual
R package pdf manual can be found there:
["CompositeRegressionEstimation.pdf"](https://github.com/DanielBonnery/CompositeRegressionEstimation/blob/master/CompositeRegressionEstimation.pdf)

# Repeated surveys

### An example: the US Census Burea CPS survey.
The R package `dataCPS` available there: ["github.com/DanielBonnery/dataCPS"](github.com/DanielBonnery/dataCPS) contains functions to download the CPS anonymised micro data from the Census Website.

The output of a repeated survey is in general a sequence of datasets, 
one dataset for each iteration of the survey. Each dataset may contain variables that can be described by the same dictionnary, or there may be changes. The sampling units also usually differ from one dataset to the other, due to non response or due to a deliberate choice not to sample the same units.
Some repeated surveys use rotation groups and a rotation patterns.

Let $m\in\{1,\ldots,M\}$ be an index of the time, and let $S_m$ be the set of sampling units at time $m$. The samples $S_m$ are subsets of a larger population $U$.

For each unit $k$ in $S_m$, usually the dataset contains:
the values $Y_{m,k}$ of a variable of interest $Y$ for unit $k$ and the period $m$.
It also contains $w_{m,k}$ a sampling weight.


## Estimation 

The output of a survey are often used to produce estimators of totals over the population of certain characteritics, or function of this same totals, in a fixed population model for design-based inference.  



### Linear estimates

####  Month in sample estimates
Consider a sequence of monthly samples $(S_m)_{m\in\{1,\ldots,M\}$. 
In the CPS, a sample $S_m$ is the union of 8 rotation groups: 
$S_m=S_{m,1}\cup S_{m,2}\cup S_{m,3}\cup S_{m,4}\cup S_{m,5}\cup S_{m,6}\cup S_{m,7}\cup S_{m,8}}$,
where two consecutive samples are always such that 
$S_{m,2}=S_{m-1,1}},
$S_{m,3}=S_{m-1,2}},
$S_{m,4}=S_{m-1,3}},
$S_{m,6}=S_{m-1,5}},
$S_{m,7}=S_{m-1,6}},
$S_{m,8}=S_{m-1,7}}, and one year appart samples are always such that
$S_{m,5}=S_{m-12,1}},
$S_{m,6}=S_{m-12,2}},
$S_{m,7}=S_{m-12,3}},
$S_{m,8}=S_{m-12,4}}.

The subsamples $S_{m,g}} are called rotation groups, and rotation patterns different than the CPS rotation pattern are possible.

For each individual $k} of the sample $m}, one observes the employment status $Y_{k,m}} (A binary variable) of individual $k} at time $m}, and 
the survey weight $w_{k,m}}, as well as its "rotation group".

The AK composite estimator is defined in ``CPS Technical Paper (2006), [section 10-11]'':

#'For $m=1}, $\hat{t}_{Y_{.,1}}=\sum_{k\in S_1}w_{k,m}Y_{k,m}}.

For $m\geq 2}, 
$$\hat{t}_{Y_{.,m}}= (1-K) \times \left(\sum_{k\in S_{m}} w_{k,m} Y_{k,m}\right)~+~K~\times~(\hat{t}_{Y_{.,m-1}} + \Delta_m)~+~ A~\times\hat{\beta}_m}

where $$\Delta_m=\eta_0\times\sum_{k\in S_m\cap S_{m-1}}(w_{k,m} Y_{k,m}-w_{k,m-1} Y_{k,m-1})}
and $$\hat{\beta}_m=\left(\sum_{k\notin S_m\cap S_{m-1}}w_{k,m} Y_{k,m}\right)~-~\eta_1~\times~\left(\sum_{k\in S_m\cap S_{m-1}}w_{k,m} Y_{k,m}\right)}

For the CPS, $\eta_0} is the ratio between the number of rotation groups in the sample and the number of overlaping rotation groups between two month, 
which is a constant  $\eta_0=4/3}; $\eta_1} is the ratio between the number of non overlaping rotation groups the number of overlaping rotation groups between two month, 
which is a constant of $1/3}.

   
 In the case of the CPS, the rotation group one sample unit  belongs to in a particular month  is a function
of the number of times it has been selected before, including this month, and so the rotation group of an individual in a particular month is called the "month in sample" variable.
   
For the CPS, in month $m} the overlap $S_{m-1}\cap      S_{m}} correspond to the individuals in the sample $S_m} with a value of month in sample equal to 2,3,4, 6,7 or 8.
The overlap $S_{m-1}\cap      S_{m}} correspond to the individuals in the sample $S_m} with a value of month in sample equal to 2,3,4, 6,7 or 8. as well as 
individuals in the sample $S_{m-1}} with a value of month in sample equal to 1,2,3, 5,6 or 7. 
When parametrising the function, the choice would be \code{group_1=c(1:3,5:7)} and \code{group0=c(2:4,6:8)}.

Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates
The functions \code{AK3}, and \code{WSrg} computes the linear combination directly and more efficiently.








