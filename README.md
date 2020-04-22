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

Let <img src="/tex/2c70fa955a339de8af08310418c6eed8.svg?invert_in_darkmode&sanitize=true" align=middle width=113.45099864999999pt height=24.65753399999998pt/> be an index of the time, and let <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> be the set of sampling units at time <img src="/tex/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/>. The samples <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> are subsets of a larger population <img src="/tex/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode&sanitize=true" align=middle width=13.01596064999999pt height=22.465723500000017pt/>.

For each unit <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/> in <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/>, usually the dataset contains:
the values <img src="/tex/3e1f9049f99eb672a49fe1d55167afd2.svg?invert_in_darkmode&sanitize=true" align=middle width=32.37841364999999pt height=22.465723500000017pt/> of a variable of interest <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> for unit <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/> and the period <img src="/tex/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/>.
It also contains <img src="/tex/498af25a5ecc1ca5ac220f89ab585e76.svg?invert_in_darkmode&sanitize=true" align=middle width=34.60352114999999pt height=14.15524440000002pt/> a sampling weight.


## Estimation 

The output of a survey are often used to produce estimators of totals over the population of certain characteritics, or function of this same totals, 
in a fixed population model for design-based inference.  

### Linear estimates

#### Direct estimate

The direct estimator of the total is <img src="/tex/ad796610a1505cccc91fa1d60f0e35de.svg?invert_in_darkmode&sanitize=true" align=middle width=123.82880234999999pt height=24.657735299999988pt/>.


```r
period<-200501:200512
Direct.est<-CompositeRegressionEstimation::WS(lapply(data(list=paste0("cps",period),package="dataCPS"),get),weight="pwsswgt",list.y = "pemlr")
Direct.emp.rate<-with(as.data.frame(Direct.est),(pemlr_n1 +pemlr_n2)/(pemlr_n1 +pemlr_n2+ pemlr_n3 +pemlr_n4))
library(ggplot2);ggplot(data=data.frame(period=period,E=Direct.emp.rate),aes(x=period,y=E))+geom_line()
```

<img src="figure/unnamed-chunk-1-1.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" width="100%" />

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


