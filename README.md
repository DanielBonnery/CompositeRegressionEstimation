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

```
FALSE 
FALSE MR> MR(list.tables<-plyr::dlply(CRE_data,.variables=~time),w="Sampling.weight",list.xMR="Status",id="Identifier",list.y=c("Hobby","Status","State"))<img src="/tex/949496cd4c9f01debd33e14f4f312a48.svg?invert_in_darkmode&sanitize=true" align=middle width=2289.913725pt height=3984.657534pt/>m\in\{1,\ldots,M\}<img src="/tex/849a8c8887f089028bf4f44ea1727484.svg?invert_in_darkmode&sanitize=true" align=middle width=202.16999055pt height=22.831056599999986pt/>S_m<img src="/tex/c12167e326e469693f4bdc61edde8f6f.svg?invert_in_darkmode&sanitize=true" align=middle width=232.03233569999998pt height=22.831056599999986pt/>m<img src="/tex/f8c1356074afd454dadab69fb8da0f21.svg?invert_in_darkmode&sanitize=true" align=middle width=93.26705024999998pt height=22.831056599999986pt/>S_m<img src="/tex/cddd273c92b413ac38a21f760836701a.svg?invert_in_darkmode&sanitize=true" align=middle width=226.8817188pt height=22.831056599999986pt/>U<img src="/tex/3b15d6ee4aea1e500b618658a256e694.svg?invert_in_darkmode&sanitize=true" align=middle width=87.48879974999998pt height=39.45205439999997pt/>k<img src="/tex/55f30cd7ff5056c4745de798b7563930.svg?invert_in_darkmode&sanitize=true" align=middle width=15.53010359999999pt height=21.68300969999999pt/>S_m<img src="/tex/8771b34e27563783f96876aaa2058260.svg?invert_in_darkmode&sanitize=true" align=middle width=284.6689592999999pt height=22.831056599999986pt/>Y_{m,k}<img src="/tex/5a3e92e00c81ccc691f59450d511513b.svg?invert_in_darkmode&sanitize=true" align=middle width=161.95870019999998pt height=22.831056599999986pt/>Y<img src="/tex/95fc7fa3bcc68d70ec7f81ba19435cbb.svg?invert_in_darkmode&sanitize=true" align=middle width=56.53489214999998pt height=22.831056599999986pt/>k<img src="/tex/3ecd60585fa9138a08fa59dd38e91bb6.svg?invert_in_darkmode&sanitize=true" align=middle width=96.15824459999997pt height=22.831056599999986pt/>m<img src="/tex/f5dad70db672105de9b102a2b04bcd5d.svg?invert_in_darkmode&sanitize=true" align=middle width=111.41888175pt height=22.831056599999986pt/>w_{m,k}<img src="/tex/47e96e910fadc5c64d16122a49b0f942.svg?invert_in_darkmode&sanitize=true" align=middle width=701.5531149pt height=276.1643841pt/>\sum_{k\in S_m} w_{k,m} Y_{k,m}$.


```r
period<-200501:200512
Direct.est<-CompositeRegressionEstimation::WS(lapply(data(list=paste0("cps",period),package="dataCPS"),get),weight="pwsswgt",list.y = "pemlr")
Direct.emp.rate<-with(as.data.frame(Direct.est),(pemlr_n1 +pemlr_n2)/(pemlr_n1 +pemlr_n2+ pemlr_n3 +pemlr_n4))
library(ggplot2);ggplot(data=data.frame(period=period,E=emp.rate),aes(x=period,y=E))+geom_line()
```

```
## Error in data.frame(period = period, E = emp.rate): object 'emp.rate' not found
```

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


