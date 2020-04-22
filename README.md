---
title: "Composite Regression for Repeated Surveys"
output: html_document
editor_options: 
  chunk_output_type: console
---

`CompositeRegressionEstimation` is an R package that allows to compute estimators for longitudinal survey:
* Composite Regression ["Fuller, Wayne A., and J. N. K. Rao. "A regression composite estimator with application to the Canadian Labour Force Survey." Survey Methodology 27.1 (2001): 45-52."](http://www.statcan.gc.ca/pub/12-001-x/2001001/article/5853-eng.pdf)
* Yansaneh Fuller
* AK estimator

#  General usage
## Install package

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

# Repeated surveys

### An example: the US Census Burea CPS survey.
The R package `dataCPS` available there: ["github.com/DanielBonnery/dataCPS"](github.com/DanielBonnery/dataCPS) contains functions to download the CPS anonymised micro data from the Census Website.

The output of a repeated survey is in general a sequence of datasets, 
one dataset for each iteration of the survey. Each dataset may contain variables that can be described by the same dictionnary, or there may be changes. The sampling units also usually differ from one dataset to the other, due to non response or due to a deliberate choice not to sample the same units.
Some repeated surveys use rotation groups and a rotation patterns.

Let <img src="/tex/2c70fa955a339de8af08310418c6eed8.svg?invert_in_darkmode&sanitize=true" align=middle width=113.45099864999999pt height=24.65753399999998pt/> be an index of the time, and let <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> be the set of sampling units at time <img src="/tex/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/>. The samples <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> are subsets of a larger population <img src="/tex/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode&sanitize=true" align=middle width=13.01596064999999pt height=22.465723500000017pt/>.

For each unit <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/> in <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/>, usually the dataset contains:
the values <img src="/tex/3e1f9049f99eb672a49fe1d55167afd2.svg?invert_in_darkmode&sanitize=true" align=middle width=32.37841364999999pt height=22.465723500000017pt/> of a variable of interest <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> for unit <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/> and the period <img src="/tex/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/>.
It also contains <img src="/tex/498af25a5ecc1ca5ac220f89ab585e76.svg?invert_in_darkmode&sanitize=true" align=middle width=34.60352114999999pt height=14.15524440000002pt/> a sampling weight.


## Estimation 

The output of a survey are often used to produce estimators of totals over the population of certain characteritics, or function of this same totals, in a fixed population model for design-based inference.  



### Linear estimates

####  Month in sample estimates
Consider a sequence of monthly samples <img src="/tex/1f16910a8f500187ed9170ab67731097.svg?invert_in_darkmode&sanitize=true" align=middle width=109.18842989999997pt height=24.65753399999998pt/>. 
In the CPS, a sample <img src="/tex/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> is the union of 8 rotation groups: 
<img src="/tex/fb4bb229339c41b7015ccf42d60b3b82.svg?invert_in_darkmode&sanitize=true" align=middle width=435.7020492pt height=22.465723500000017pt/>,
where two consecutive samples are always such that 
<img src="/tex/9cb01f6db43a156c1ac73d83db1ee04c.svg?invert_in_darkmode&sanitize=true" align=middle width=109.35707639999998pt height=22.465723500000017pt/>S_{m,3}=S_{m-1,2}},
<img src="/tex/19242b4d007c17724a8d04c1166ab5e6.svg?invert_in_darkmode&sanitize=true" align=middle width=109.35707639999998pt height=22.465723500000017pt/>S_{m,6}=S_{m-1,5}},
<img src="/tex/fc09132d2f7a2d59315bdd14a77e5a81.svg?invert_in_darkmode&sanitize=true" align=middle width=109.35707639999998pt height=22.465723500000017pt/>S_{m,8}=S_{m-1,7}}, and one year appart samples are always such that
<img src="/tex/9fbcc6afaf9bc3ae1f1dbf47321b7225.svg?invert_in_darkmode&sanitize=true" align=middle width=115.90961909999997pt height=22.465723500000017pt/>S_{m,6}=S_{m-12,2}},
<img src="/tex/da34f73f9a0dab4e35622885957ca0c3.svg?invert_in_darkmode&sanitize=true" align=middle width=115.90961909999997pt height=22.465723500000017pt/>S_{m,8}=S_{m-12,4}}.

The subsamples <img src="/tex/0ef6bbee51704588af38b8dafffbafa3.svg?invert_in_darkmode&sanitize=true" align=middle width=732.6012341999999pt height=39.45205440000001pt/>k} of the sample <img src="/tex/d245353930b948e2c2cb336699ed2acd.svg?invert_in_darkmode&sanitize=true" align=middle width=267.93847739999995pt height=22.831056599999986pt/>Y_{k,m}} (A binary variable) of individual <img src="/tex/524db8a9ab9e794ba22683e395d92bb9.svg?invert_in_darkmode&sanitize=true" align=middle width=57.387176549999985pt height=22.831056599999986pt/>m}, and 
the survey weight <img src="/tex/30f5847eb2fd11e812605b4ae45ec4bd.svg?invert_in_darkmode&sanitize=true" align=middle width=640.18434645pt height=78.90410880000002pt/>m=1}, <img src="/tex/55455906cd92857bf132e6803df68677.svg?invert_in_darkmode&sanitize=true" align=middle width=175.07001764999998pt height=39.45205440000001pt/>m\geq 2}, 
<p align="center"><img src="/tex/69a6794cdf4ff62302e08a433c217913.svg?invert_in_darkmode&sanitize=true" align=middle width=595.10106645pt height=74.74916459999999pt/></p>\Delta_m=\eta_0\times\sum_{k\in S_m\cap S_{m-1}}(w_{k,m} Y_{k,m}-w_{k,m-1} Y_{k,m-1})}
and $<img src="/tex/fcfc4b0383dab1a740cf55f4022eb543.svg?invert_in_darkmode&sanitize=true" align=middle width=500.07653684999997pt height=53.88158159999998pt/>\eta_0} is the ratio between the number of rotation groups in the sample and the number of overlaping rotation groups between two month, 
which is a constant  <img src="/tex/1ad24dd9300ef7c6bad265ca1fd626d1.svg?invert_in_darkmode&sanitize=true" align=middle width=66.67810379999999pt height=24.65753399999998pt/>\eta_1} is the ratio between the number of non overlaping rotation groups the number of overlaping rotation groups between two month, 
which is a constant of <img src="/tex/a2926f674b32148082f049829ceceb74.svg?invert_in_darkmode&sanitize=true" align=middle width=700.27451835pt height=164.20092150000002pt/>m} the overlap <img src="/tex/3b0a106a9ae3a261fbae454617522e55.svg?invert_in_darkmode&sanitize=true" align=middle width=372.170766pt height=22.831056599999986pt/>S_m} with a value of month in sample equal to 2,3,4, 6,7 or 8.
The overlap <img src="/tex/3b0a106a9ae3a261fbae454617522e55.svg?invert_in_darkmode&sanitize=true" align=middle width=372.170766pt height=22.831056599999986pt/>S_m} with a value of month in sample equal to 2,3,4, 6,7 or 8. as well as 
individuals in the sample $S_{m-1}} with a value of month in sample equal to 1,2,3, 5,6 or 7. 
When parametrising the function, the choice would be \code{group_1=c(1:3,5:7)} and \code{group0=c(2:4,6:8)}.

Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates
The functions \code{AK3}, and \code{WSrg} computes the linear combination directly and more efficiently.








