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
the values <img src="/tex/5ba83d57b9bfbf937ad937b046d25c85.svg?invert_in_darkmode&sanitize=true" align=middle width=30.89444324999999pt height=14.15524440000002pt/> of a variable of interest <img src="/tex/deceeaf6940a8c7a5a02373728002b0f.svg?invert_in_darkmode&sanitize=true" align=middle width=8.649225749999989pt height=14.15524440000002pt/> for unit <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/> and the period <img src="/tex/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/>. In particular we are interested in the case where <img src="/tex/5ba83d57b9bfbf937ad937b046d25c85.svg?invert_in_darkmode&sanitize=true" align=middle width=30.89444324999999pt height=14.15524440000002pt/> is a vector of indicator values, <img src="/tex/6b03c4df1f5de6c09c79b2a37936630e.svg?invert_in_darkmode&sanitize=true" align=middle width=335.66530305pt height=24.65753399999998pt/>:
<img src="/tex/a79b0d0f9e59c6f8683ccf4431c426e6.svg?invert_in_darkmode&sanitize=true" align=middle width=105.68878979999998pt height=24.65753399999998pt/> means that individual <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/> was not in the labor force at time <img src="/tex/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode&sanitize=true" align=middle width=9.075367949999992pt height=22.831056599999986pt/>.

It also contains <img src="/tex/498af25a5ecc1ca5ac220f89ab585e76.svg?invert_in_darkmode&sanitize=true" align=middle width=34.60352114999999pt height=14.15524440000002pt/> a sampling weight.



#### Get the data
The R package `dataCPS` available there: ["github.com/DanielBonnery/dataCPS"](github.com/DanielBonnery/dataCPS) contains functions to download the CPS anonymised micro data from the U.S Census Bureau website.

The following code creates a list of dataframes for the months of 2005 that are selection of variables from the CPS public use microdata. It creates a new employment status table with only 3 levels


```r
period<-200501:200512
list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);names(list.tables)<-period
list.tables<-lapply(list.tables,function(L){
  L[["employmentstatus"]]<-forcats::fct_collapse(factor(L[["pemlr"]]),
                                            "e"=c("1","2"),
                                            "u"=c("3","4"),
                                            "n"=c("5","6","7","-1"));
  L})
```



## Estimation 

The output of a survey are often used to produce estimators of totals over the population of certain characteritics, or function of this same totals, 
in a fixed population model for design-based inference.  

### Linear estimates

#### Direct estimate

The direct estimator of the total is <img src="/tex/1be0457898a13c5f4f4a4c95d22b17ae.svg?invert_in_darkmode&sanitize=true" align=middle width=122.34483359999999pt height=24.657735299999988pt/>. The function `CompositeRegressionEstimation::WS` will produce
the weighted estimates <img src="/tex/3ce530175fe262bc233a95b0c8b47e89.svg?invert_in_darkmode&sanitize=true" align=middle width=209.78846129999997pt height=24.657735299999988pt/>

In the following code, we compute the direct estimates of the counts in each employment status category from the CPS public anonymised micro data in the year 2005, compute the corresponding unemployment rate time series and plot the result.

```r
Direct.est<-CompositeRegressionEstimation::WS(list.tables,weight="pwsswgt",list.y = "employmentstatus")
Direct.emp.rate<-with(as.data.frame(Direct.est),(employmentstatus_ne)/(employmentstatus_ne+employmentstatus_nu))
library(ggplot2);ggplot(data=data.frame(period=period,E=Direct.emp.rate),aes(x=period,y=E))+geom_line()+
  ggtitle("Direct estimate of the monthly employment rate from the CPS public microdata in 2005")+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")
```

<img src="figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" width="100%" />

#### Month in sample estimate

An estimate can be obtained from each month-in-sample rotation group. The month-in-sample estimates are estimates of a total of a study variable of the form:
<img src="/tex/794e6e1521fc2728f11f63433cf8056f.svg?invert_in_darkmode&sanitize=true" align=middle width=132.16510559999998pt height=24.657735299999988pt/>.
The following code 

```r
MIS.est<-CompositeRegressionEstimation::WSrg(list.tables,rg = "hrmis",weight="pwsswgt",list.y = "employmentstatus")
names(dimnames(MIS.est))<-c("Month","RotationGroup","EmploymentStatus")
MIS.emp.rate<-plyr::aaply(MIS.est[,,"employmentstatus_ne"],1:2,sum)/plyr::aaply(MIS.est[,,c("employmentstatus_ne","employmentstatus_nu")],1:2,sum);names(dimnames(MIS.emp.rate))<-c("Month","RotationGroup")
library(ggplot2);ggplot(data=reshape2::melt(MIS.emp.rate),aes(x=Month,y=value,color=RotationGroup))+geom_line()+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")+ 
  labs(title = "Month-in-sample estimates", 
       subtitle = "Monthly employment rate, year 2005", 
       caption = "Computed from CPS public anonymized microdata.")
```

<img src="figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" width="100%" />

#### Linear combinaisons of the month-in-sample estimates

The month-in-sample estimates for each month and each rotation group can be stored in a data.frame with four variables:
the month, the group, the employment status and the value of the estimate.


```r
print(reshape2::melt(MIS.est[,,c("employmentstatus_ne" ,"employmentstatus_nn", "employmentstatus_nu")]))
```

|Row Number |Month  |Rotation Group |Employment Status   |<img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/>           |
|:----------|:------|:--------------|:-------------------|:-------------|
|1          |200501 |hrmis1         |employmentstatus_ne |17771771.5595 |
|2          |200502 |hrmis1         |employmentstatus_ne |17501581.9912 |
|3          |200503 |hrmis1         |employmentstatus_ne |17911922.4613 |
|...        |...    |...            |...                 |...           |
|288        |200512 |hrmis8         |employmentstatus_nu |846918.8885   |

Let <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> be the vector of values in the data.frame.
Elements of <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> can be refered to by the line number or by a combinaison of month, rotation group, and employment status, as for example : <img src="/tex/3fc66a72e2d17e020e9c41a3fa79f3c9.svg?invert_in_darkmode&sanitize=true" align=middle width=160.88719184999997pt height=22.465723500000017pt/>, or by a line number <img src="/tex/aef6b18063caff2c3750441e127e3e5a.svg?invert_in_darkmode&sanitize=true" align=middle width=21.941076299999988pt height=41.64378900000001pt/>.
We use <img src="/tex/d3615153e21981003e4ebb11168a5cc7.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=41.64378900000001pt/> to designate the vector and <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> to designate the array.

The values to estimate are the elements of the <img src="/tex/d589f80ee85eb594b74fa100a4e0f23f.svg?invert_in_darkmode&sanitize=true" align=middle width=104.08773374999998pt height=22.831056599999986pt/> sized array <img src="/tex/6113a4c2abf45f7818f3d5e58b17b6ca.svg?invert_in_darkmode&sanitize=true" align=middle width=820.0904612999999pt height=24.657735299999988pt/>. We denote by <img src="/tex/9f7c9b1c4f87b770604d8d1c7e206d53.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=41.64378900000001pt/> the vectorisation of the array <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/>.

We consider estimates of <img src="/tex/9f7c9b1c4f87b770604d8d1c7e206d53.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=41.64378900000001pt/>
of the form  <img src="/tex/d516d32413c72655e7d935d133cb7a10.svg?invert_in_darkmode&sanitize=true" align=middle width=92.69456624999998pt height=45.02964839999999pt/>


### Recursive estimation

The function `CompositeRegressionEstimation::composite` 
allows to compute linear combinations of the month in sample groups of the form

$

#### AK estimator

```
CompositeRegressionEstimation::CPS_AK()
```


#### Rough estimation of the month-in-sample estimate covariance matrix

#### Empirical best AK estimator

#### Empirical best YF estimator

#### Empirical best linear estimator

### Modified regression (Singh, Fuller-Rao)


