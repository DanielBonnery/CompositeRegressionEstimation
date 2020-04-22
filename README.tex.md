---
title: "Composite Regression for Repeated Surveys"
author: Daniel Bonnery
output: md_document
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
Some repeated surveys use rotation groups and a rotation pattern.

Let $m\in\{1,\ldots,M\}$ be an index of the time, and let $S_m$ be the set of sampling units at time $m$. The samples $S_m$ are subsets of a larger population $U$.

For each unit $k$ in $S_m$, usually the dataset contains:
the values $Y_{m,k}$ of a variable of interest $Y$ for unit $k$ and the period $m$.
It also contains $w_{m,k}$ a sampling weight.


## Estimation 

The output of a survey are often used to produce estimators of totals over the population of certain characteritics, or function of this same totals, 
in a fixed population model for design-based inference.  

### Linear estimates

#### Direct estimate

The direct estimator of the total is $\sum_{k\in S_m} w_{k,m} Y_{k,m}$.


```r
period<-200501:200512
Direct.est<-CompositeRegressionEstimation::WS(lapply(data(list=paste0("cps",period),package="dataCPS"),get),weight="pwsswgt",list.y = "pemlr")
Direct.emp.rate<-with(as.data.frame(Direct.est),(pemlr_n1 +pemlr_n2)/(pemlr_n1 +pemlr_n2+ pemlr_n3 +pemlr_n4))
library(ggplot2);ggplot(data=data.frame(period=period,E=emp.rate),aes(x=period,y=E))+geom_line()
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1-1.png)

#### Month in sample estimate

#### AK estimator

```
CompositeRegressionEstimation::CPS_AK()
```


#### Rough estimation of the month-in-sample estimate covariance matrix

#### Empirical best AK estimator

#### Empirical best YF estimator

#### Empirical best linear estimator

### Modified regression (Singh, Fuller-Rao)


