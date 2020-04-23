---
title: "Composite Regression for Repeated Surveys"
author: Daniel Bonnery
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



The output of a repeated survey is in general a sequence of datasets, 
one dataset for each iteration of the survey. 

## An example: the US Census Bureau CPS survey.

### Variables

The CPS provides 8 different employment categories, but we can regroup some to get 3 categories: 
employed, not employed, not in the labor force.
Each dataset may contain variables that can be described by the same dictionnary, or there may be changes. 

### Rotation group and rotation pattern

The sampling units also usually differ from one dataset to the other, due to non response or due to a deliberate choice not to sample the same units.
Let <img src="/tex/2c70fa955a339de8af08310418c6eed8.svg?invert_in_darkmode&sanitize=true" align=middle width=113.45099864999999pt height=24.65753399999998pt/> be an index of the time, and let <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> be the set of sampling units at time <img src="/tex/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/>. The samples <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> are subsets of a larger population <img src="/tex/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode&sanitize=true" align=middle width=13.01596064999999pt height=22.465723500000017pt/>.

Some repeated surveys use rotation groups and a rotation pattern.
For the CPS, each sampled household will be selected to be surveyed during 4 consecutive months,  then left alone 8 months, then
surveyed again 4 consecutive months. As a consequence, for a given month, a sampled units that month will be surveyed for the first, second, ..., or 8th and last time. This induces a partition of the sample into month-in-sample groups:
<img src="/tex/a38e6d83257e4eee7bbf7812fede4b0e.svg?invert_in_darkmode&sanitize=true" align=middle width=216.70454189999992pt height=22.465723500000017pt/>. 


For each unit <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/> in <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/>, usually the dataset contains:
the values <img src="/tex/5ba83d57b9bfbf937ad937b046d25c85.svg?invert_in_darkmode&sanitize=true" align=middle width=30.89444324999999pt height=14.15524440000002pt/> of a variable of interest <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> for unit <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/> and the period <img src="/tex/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/>.
It also contains <img src="/tex/498af25a5ecc1ca5ac220f89ab585e76.svg?invert_in_darkmode&sanitize=true" align=middle width=34.60352114999999pt height=14.15524440000002pt/> a sampling weight.



#### Get the data
The R package `dataCPS` available there: ["github.com/DanielBonnery/dataCPS"](github.com/DanielBonnery/dataCPS) contains functions to download the CPS anonymised micro data from the U.S Census Bureau website.

The following code creates a list of dataframes for the months of 2005 that are selection of variables from the CPS public use microdata. It creates a new employment status table with only 3 levels


```r
period<-200501:200512
list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);names(list.tables)<-period
list.tables<-lapply(list.tables,function(L){
  L[["employmentstatus"]]<-forcats::fct_collapse(factor(L<img src="/tex/1a857c9d51cc6cf71e349ed465ac3ea3.svg?invert_in_darkmode&sanitize=true" align=middle width=701.5531149pt height=276.1643841pt/>\sum_{k\in S_m} w_{k,m} y_{k,m}<img src="/tex/c809ea0d92a0447434ff91dc93614fc7.svg?invert_in_darkmode&sanitize=true" align=middle width=647.2427973pt height=22.831056599999986pt/>(\sum_{k\in S_m} w_{k,m} y_{k,m})_{m\in\{1,\ldots,M\}}<img src="/tex/eddd60c5ef3b135441cfa418e96aee31.svg?invert_in_darkmode&sanitize=true" align=middle width=904.7195783999999pt height=519.2694144pt/>\sum_{k\in S_{m,g}} w_{m,k}y_{m,k}<img src="/tex/6f56d2338c5fb50bb546f57aedc6e43a.svg?invert_in_darkmode&sanitize=true" align=middle width=1089.21322455pt height=637.6255776pt/>X<img src="/tex/06ad1b606a93bab03c9f1c0e5cdd9e53.svg?invert_in_darkmode&sanitize=true" align=middle width=1899.3322738499999pt height=78.90410880000002pt/>X<img src="/tex/28bdbb2566ab78529d438748f813e1b5.svg?invert_in_darkmode&sanitize=true" align=middle width=365.31071445000003pt height=22.831056599999986pt/>X<img src="/tex/4de31ac91408fd19d96ad2c01386288b.svg?invert_in_darkmode&sanitize=true" align=middle width=831.3905622pt height=22.831056599999986pt/>X_{200501,group 3,employed]<img src="/tex/8fbe9975a2120b362bd0912b701c0b44.svg?invert_in_darkmode&sanitize=true" align=middle width=132.24477089999996pt height=22.831056599999986pt/>\overrightarrow{X}_\ell<img src="/tex/bd9a15f1f1bceeab51108e1fc8c8c48e.svg?invert_in_darkmode&sanitize=true" align=middle width=54.79850969999999pt height=22.465723500000017pt/>\overrightarrow{X}<img src="/tex/0b481c97d4fca87fab91408d2de18bb1.svg?invert_in_darkmode&sanitize=true" align=middle width=179.33581049999998pt height=22.831056599999986pt/>X<img src="/tex/572053c68cb79ed88c6f480e6501262d.svg?invert_in_darkmode&sanitize=true" align=middle width=324.97798409999996pt height=39.45205440000001pt/>M\times 3-sized<img src="/tex/b84ed24dc93cedabca5f471ca723b10f.svg?invert_in_darkmode&sanitize=true" align=middle width=79.71986879999999pt height=22.831056599999986pt/>Y=(\sum_{k\in U} (y_{k,m}==e))_{m\in\{1,\ldots,M\},e\in\{"employed","unemployed","nilf"\}}<img src="/tex/df4567845e3fc9ac17ebde1c6e9dc98a.svg?invert_in_darkmode&sanitize=true" align=middle width=93.36790484999999pt height=22.831056599999986pt/>\overrightarrow{Y}<img src="/tex/ede59ae42a7b9f0b354f85485e791af8.svg?invert_in_darkmode&sanitize=true" align=middle width=202.2766053pt height=22.831056599999986pt/>Y<img src="/tex/9380e47fd6763b9786dbb1bf6d290c3e.svg?invert_in_darkmode&sanitize=true" align=middle width=171.00501989999998pt height=39.45205439999997pt/>\overrightarrow{Y}<img src="/tex/a31afbbe7ee6b60e90cde45836a00633.svg?invert_in_darkmode&sanitize=true" align=middle width=80.93833274999999pt height=22.831056599999986pt/>\widehat{\overrightarrow{Y}} =W\times \overrightarrow{X}$

#### AK estimator

```
CompositeRegressionEstimation::CPS_AK()
```


#### Rough estimation of the month-in-sample estimate covariance matrix

#### Empirical best AK estimator

#### Empirical best YF estimator

#### Empirical best linear estimator

### Modified regression (Singh, Fuller-Rao)


