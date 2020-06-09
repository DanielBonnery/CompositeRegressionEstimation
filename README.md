---
title: "Composite Regression for Repeated Surveys"
author: Daniel Bonnery
---

`CompositeRegressionEstimation` is an R package that allows to compute estimators for longitudinal survey:

* Modified Regression : "Singh, A.~C., Kennedy, B., and Wu, S. (2001). Regression composite estimation for the Canadian Labour Force Survey: evaluation and implementation, Survey Methodology}, 27(1):33--44.", "Singh, A.~C., Kennedy, B., Wu, S., and Brisebois, F. (1997). Composite estimation for the Canadian Labour Force Survey. Proceedings of the Survey Research Methods Section, American Statistical Association}, pages 300--305."  "Singh, A.~C. and Merkouris, P. (1995).  Composite estimation by modified regression for repeated surveys. Proceedings of the Survey Research Methods Section, American Statistical Association}, pages 420--425."



* Composite Regression ["Fuller, Wayne A., and J. N. K. Rao. "A regression composite estimator with application to the Canadian Labour Force Survey." Survey Methodology 27.1 (2001): 45-52."](http://www.statcan.gc.ca/pub/12-001-x/2001001/article/5853-eng.pdf)

* Gauss Markov Best Linear Unbiased Estimator as a linear combinaison of Month in sample estimates.

* AK estimator, Gurney, M. and Daly, J.~F. (1965). A multivariate approach to estimation in periodic sample surveys}.  In Proceedings of the Social Statistics Section, American
  Statistical Association, volume 242, page 257."


This package contains the generic functions that were developped for the journal article ["Bonnery Cheng Lahiri, An Evaluation of Design-based Properties of Different Composite Estimators"](https://arxiv.org/abs/1811.12249).
The demonstration code on this page  uses the `dataCPS` package that allows to download public anonymised CPS micro data from the US Census Bureau website.


#  General usage

## Install


```r
devtools::install_github("DanielBonnery/CompositeRegressionEstimation")
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
list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),function(x){get(x)[c("hrmis","hrhhid","pulineno","pwsswgt","pemlr","hrintsta")]});names(list.tables)<-period
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

### Linear combinations of month in sample estimates

#### Direct estimate

The direct estimator of the total is <img src="/tex/1be0457898a13c5f4f4a4c95d22b17ae.svg?invert_in_darkmode&sanitize=true" align=middle width=122.34483359999999pt height=24.657735299999988pt/>. The function `CompositeRegressionEstimation::WS` will produce
the weighted estimates <img src="/tex/7629247eccd6f3f305aaec4a62d5e015.svg?invert_in_darkmode&sanitize=true" align=middle width=274.0464474pt height=28.89761819999999pt/>

In the following code, we compute the direct estimates of the counts in each employment status category from the CPS public anonymised micro data in the year 2005, compute the corresponding unemployment rate time series and plot the result.

```r
Direct.est<-CompositeRegressionEstimation::WS(list.tables,weight="pwsswgt",list.y = "employmentstatus")
```

```
## Warning in get0(oNam, envir = ns): internal error -3 in R_decompress1
```

```
## Error in get0(oNam, envir = ns): lazy-load database '/home/daniel/R/x86_64-pc-linux-gnu-library/3.6/CompositeRegressionEstimation/R/CompositeRegressionEstimation.rdb' is corrupt
```

```r
U<-with(as.data.frame(Direct.est),
        (employmentstatus_ne)/(employmentstatus_ne+employmentstatus_nu))
```

```
## Error in as.data.frame(Direct.est): object 'Direct.est' not found
```

```r
library(ggplot2);
ggplot(data=data.frame(period=period,E=U),aes(x=period,y=U))+geom_line()+
  ggtitle("Direct estimate of the monthly employment rate from the CPS public microdata in 2005")+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")
```

```
## Error in data.frame(period = period, E = U): object 'U' not found
```

#### Month in sample estimate

An estimate can be obtained from each month-in-sample rotation group. The month-in-sample estimates are estimates of a total of a study variable of the form:
<img src="/tex/05fe3182e27f9195f836052a21bf2a55.svg?invert_in_darkmode&sanitize=true" align=middle width=145.4812623pt height=24.657735299999988pt/>, where <img src="/tex/c745b9b57c145ec5577b82542b2df546.svg?invert_in_darkmode&sanitize=true" align=middle width=10.57650494999999pt height=14.15524440000002pt/> is an adjustment. In the CPS, the adjustment <img src="/tex/a4eaf29ba18ea817aa165fcb033bc2b7.svg?invert_in_darkmode&sanitize=true" align=middle width=40.713337499999994pt height=21.18721440000001pt/> as there are <img src="/tex/005c128d6e551735fa5d938e44e7a613.svg?invert_in_darkmode&sanitize=true" align=middle width=8.219209349999991pt height=21.18721440000001pt/> rotation groups. Other adjustments are possible, as for example <img src="/tex/71997fae67898064cda8f915bdcf3a12.svg?invert_in_darkmode&sanitize=true" align=middle width=138.49146134999998pt height=24.657735299999988pt/>.

The following code  creates the array `Y` of dimension <img src="/tex/941e0906d926f039bcfada153e127a16.svg?invert_in_darkmode&sanitize=true" align=middle width=74.36051699999999pt height=22.465723500000017pt/> (M months, 8 rotation groups, 3 employment statuses.) where `Y[m,g,e]` is the month in sample estimate for month `m`, group `g` and status `e`.


```r
library(CompositeRegressionEstimation)
Y<-CompositeRegressionEstimation::WSrg2(list.tables,rg = "hrmis",weight="pwsswgt",y = "employmentstatus")
```

```
## Warning in get0(oNam, envir = ns): internal error -3 in R_decompress1
```

```
## Error in get0(oNam, envir = ns): lazy-load database '/home/daniel/R/x86_64-pc-linux-gnu-library/3.6/CompositeRegressionEstimation/R/CompositeRegressionEstimation.rdb' is corrupt
```

```r
Umis<-plyr::aaply(Y[,,"e"],1:2,sum)/plyr::aaply(Y[,,c("e","u")],1:2,sum);
```

```
## Error in amv_dim(x): object 'Y' not found
```

```r
library(ggplot2);ggplot(data=reshape2::melt(Umis),aes(x=m,y=value,color=hrmis,group=hrmis))+geom_line()+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")+ 
  labs(title = "Month-in-sample estimates", 
       subtitle = "Monthly employment rate, year 2005", 
       caption = "Computed from CPS public anonymized microdata.")
```

```
## Error in reshape2::melt(Umis): object 'Umis' not found
```

#### Linear combinaisons of the month-in-sample estimates

The month-in-sample estimates for each month and each rotation group can also be given in a data.frame with four variables: the month, the group, the employment status and the value of the estimate.
Such a dataframe can be obtained from `Y` using the function `reshape2::melt`


```r
print(reshape2::melt(Y[,,]))
```


```
## Error in reshape2::melt(Y): object 'Y' not found
```

```
## Error in eval(expr, envir, enclos): object 'tt' not found
```

```
## Error in nrow(tt): object 'tt' not found
```

```
## Error in lapply(toto, as.character): object 'toto' not found
```

```
## Error in ncol(toto): object 'toto' not found
```

```
## Error in eval(expr, envir, enclos): object 'toto' not found
```

```
## Error in names(toto) <- c("Row number", "Month", "Month in sample group", : object 'toto' not found
```

```
## Error in knitr::kable(toto): object 'toto' not found
```

Let <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> be the vector of values in the data.frame.
Elements of <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> can be refered to by the line number or by a combinaison of month, rotation group, and employment status, as for example : <img src="/tex/fb0a7c5c30dbaeff34cd1afcac885a47.svg?invert_in_darkmode&sanitize=true" align=middle width=156.81184199999998pt height=22.465723500000017pt/>, or by a line number <img src="/tex/8fb799df5f9c1f6f7fdaa744372bd533.svg?invert_in_darkmode&sanitize=true" align=middle width=21.941076299999988pt height=41.64378900000001pt/>.
We use <img src="/tex/9f7c9b1c4f87b770604d8d1c7e206d53.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=41.64378900000001pt/> to designate the vector and <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> to designate the array.

The values to estimate are the elements of the <img src="/tex/7c674d837975ddc779079888281b9cff.svg?invert_in_darkmode&sanitize=true" align=middle width=46.050115649999995pt height=22.465723500000017pt/>-sized array <img src="/tex/6113a4c2abf45f7818f3d5e58b17b6ca.svg?invert_in_darkmode&sanitize=true" align=middle width=820.0904612999999pt height=24.657735299999988pt/>. We denote by <img src="/tex/9f7c9b1c4f87b770604d8d1c7e206d53.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=41.64378900000001pt/> the vectorisation of the array <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/>.

In R, the function to vectorize an array is the function `c`


```r
A<-array(1:12,c(3,2,2));c(A)
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12
```


We consider estimates of <img src="/tex/4c69ba23ad577f87c4f6c53a06302d4d.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=42.00914850000001pt/>
of the form  <img src="/tex/357107fe199aa73bc3adf22491a43690.svg?invert_in_darkmode&sanitize=true" align=middle width=92.69454479999999pt height=45.3950046pt/>, 
where <img src="/tex/b44848922a59328b4ef74c94bdf966a0.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=41.64378900000001pt/> is a matrix of dimension <img src="/tex/f865697b01f0a6fca85b0727701e6693.svg?invert_in_darkmode&sanitize=true" align=middle width=126.94161974999999pt height=42.00914850000001pt/>).

Which is equivalent to estimators of the form <img src="/tex/5097776bc1f30a7da974ffb5596313f6.svg?invert_in_darkmode&sanitize=true" align=middle width=52.80813779999999pt height=22.465723500000017pt/> where the <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> is a <img src="/tex/9204b1b54cbff660169ee2b1f9b3ba8d.svg?invert_in_darkmode&sanitize=true" align=middle width=154.13265944999998pt height=24.65753399999998pt/> matrix, where an element <img src="/tex/0915cde0aa1d2e0f9dd73778329423e3.svg?invert_in_darkmode&sanitize=true" align=middle width=32.64358184999999pt height=22.465723500000017pt/> of <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> is indexed by two vector <img src="/tex/2ec6e630f199f589a2402fdf3e0289d5.svg?invert_in_darkmode&sanitize=true" align=middle width=8.270567249999992pt height=14.15524440000002pt/> and <img src="/tex/d5c18a8ca1894fd3a7d25f242cbe8890.svg?invert_in_darkmode&sanitize=true" align=middle width=7.928106449999989pt height=14.15524440000002pt/> and of length the number of dimensions of the array <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> and the dimensions of the array <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> respectively. 

The function `arrayproduct::"%.%"` of the 'arrayproduct' allows to perform the array multiplication as described above.
The package uses named arrays with names dimensions (`names(dimnames(A))` is not `NULL`).

### Recursive linear estimates

The function `CompositeRegressionEstimation::composite` 
allows to compute linear combinations of the month in sample groups of the form

<img src="/tex/68def15f8ff220e879e78aa6f1df32bd.svg?invert_in_darkmode&sanitize=true" align=middle width=428.24322255000004pt height=116.71341989999999pt/>
This is a special case of a linear combination of the month-in-sample estimates.


Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates.
 
The following code computes a recursive estimator with parameters <img src="/tex/0d22c917616fe8a92c5c6813000e4783.svg?invert_in_darkmode&sanitize=true" align=middle width=119.06307104999999pt height=27.77565449999998pt/>, <img src="/tex/c07d4aad080ca920fc0e9dbe570cd021.svg?invert_in_darkmode&sanitize=true" align=middle width=143.75007074999996pt height=22.831056599999986pt/>.






























