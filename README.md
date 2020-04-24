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
Direct.emp.rate<-with(as.data.frame(Direct.est),(employmentstatus_ne)/(employmentstatus_ne+employmentstatus_nu))
library(ggplot2);ggplot(data=data.frame(period=period,E=Direct.emp.rate),aes(x=period,y=E))+geom_line()+
  ggtitle("Direct estimate of the monthly employment rate from the CPS public microdata in 2005")+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")
```

<img src="figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" width="100%" />

#### Month in sample estimate

An estimate can be obtained from each month-in-sample rotation group. The month-in-sample estimates are estimates of a total of a study variable of the form:
<img src="/tex/05fe3182e27f9195f836052a21bf2a55.svg?invert_in_darkmode&sanitize=true" align=middle width=145.4812623pt height=24.657735299999988pt/>, where <img src="/tex/c745b9b57c145ec5577b82542b2df546.svg?invert_in_darkmode&sanitize=true" align=middle width=10.57650494999999pt height=14.15524440000002pt/> is an adjustment. In the CPS, the adjustment <img src="/tex/a4eaf29ba18ea817aa165fcb033bc2b7.svg?invert_in_darkmode&sanitize=true" align=middle width=40.713337499999994pt height=21.18721440000001pt/> as there are <img src="/tex/005c128d6e551735fa5d938e44e7a613.svg?invert_in_darkmode&sanitize=true" align=middle width=8.219209349999991pt height=21.18721440000001pt/> rotation groups. Other adjustments are possible, as for example <img src="/tex/71997fae67898064cda8f915bdcf3a12.svg?invert_in_darkmode&sanitize=true" align=middle width=138.49146134999998pt height=24.657735299999988pt/>.

The following code 

```r
MIS.est<-CompositeRegressionEstimation::WSrg(list.tables,rg = "hrmis",weight="pwsswgt",list.y = "employmentstatus")
```

```
## Error in abind(`200501` = structure(c(0, 0, 0, 0, 0, 0, 0, 0, 17771771.5595, : could not find function "abind"
```

```r
names(dimnames(MIS.est))<-c("Month","RotationGroup","EmploymentStatus")
```

```
## Error in names(dimnames(MIS.est)) <- c("Month", "RotationGroup", "EmploymentStatus"): object 'MIS.est' not found
```

```r
MIS.emp.rate<-plyr::aaply(MIS.est[,,"employmentstatus_ne"],1:2,sum)/plyr::aaply(MIS.est[,,c("employmentstatus_ne","employmentstatus_nu")],1:2,sum);names(dimnames(MIS.emp.rate))<-c("Month","RotationGroup")
```

```
## Error in amv_dim(x): object 'MIS.est' not found
```

```
## Error in names(dimnames(MIS.emp.rate)) <- c("Month", "RotationGroup"): object 'MIS.emp.rate' not found
```

```r
library(ggplot2);ggplot(data=reshape2::melt(MIS.emp.rate),aes(x=Month,y=value,color=RotationGroup))+geom_line()+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")+ 
  labs(title = "Month-in-sample estimates", 
       subtitle = "Monthly employment rate, year 2005", 
       caption = "Computed from CPS public anonymized microdata.")
```

```
## Error in reshape2::melt(MIS.emp.rate): object 'MIS.emp.rate' not found
```

#### Linear combinaisons of the month-in-sample estimates

The month-in-sample estimates for each month and each rotation group can be stored in a data.frame with four variables:
the month, the group, the employment status and the value of the estimate.


```r
print(reshape2::melt(MIS.est[,,c("employmentstatus_ne" ,"employmentstatus_nn", "employmentstatus_nu")]))
```

```
## Error in reshape2::melt(MIS.est[, , c("employmentstatus_ne", "employmentstatus_nn", : object 'MIS.est' not found
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
## Error in names(toto) <- c("Row Number", "Month", "Rotation Group", "Employment Status", : object 'toto' not found
```

```
## Error in knitr::kable(toto): object 'toto' not found
```

Let <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> be the vector of values in the data.frame.
Elements of <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> can be refered to by the line number or by a combinaison of month, rotation group, and employment status, as for example : <img src="/tex/3fc66a72e2d17e020e9c41a3fa79f3c9.svg?invert_in_darkmode&sanitize=true" align=middle width=160.88719184999997pt height=22.465723500000017pt/>, or by a line number <img src="/tex/aef6b18063caff2c3750441e127e3e5a.svg?invert_in_darkmode&sanitize=true" align=middle width=21.941076299999988pt height=41.64378900000001pt/>.
We use <img src="/tex/d3615153e21981003e4ebb11168a5cc7.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=41.64378900000001pt/> to designate the vector and <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> to designate the array.

The values to estimate are the elements of the <img src="/tex/7c674d837975ddc779079888281b9cff.svg?invert_in_darkmode&sanitize=true" align=middle width=46.050115649999995pt height=22.465723500000017pt/>-sized array <img src="/tex/6113a4c2abf45f7818f3d5e58b17b6ca.svg?invert_in_darkmode&sanitize=true" align=middle width=820.0904612999999pt height=24.657735299999988pt/>. We denote by <img src="/tex/9f7c9b1c4f87b770604d8d1c7e206d53.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=41.64378900000001pt/> the vectorisation of the array <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/>.

In R, the function to vectorize an array is the function `c`

```r
A<-array(1:12,c(3,2,2));c(A)
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12
```


We consider estimates of <img src="/tex/9f7c9b1c4f87b770604d8d1c7e206d53.svg?invert_in_darkmode&sanitize=true" align=middle width=16.43875364999999pt height=41.64378900000001pt/>
of the form  <img src="/tex/e01e4b580defdbd55ba4c6b09b1ffb3d.svg?invert_in_darkmode&sanitize=true" align=middle width=92.69454479999999pt height=45.02964839999999pt/>, 
where <img src="/tex/b44848922a59328b4ef74c94bdf966a0.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=41.64378900000001pt/> is a matrix of dimension <img src="/tex/ae1907bd1d43388b78617cae84cfa316.svg?invert_in_darkmode&sanitize=true" align=middle width=126.94161974999999pt height=41.64378900000001pt/>).

Which is equivalent to estimators of the form <img src="/tex/5097776bc1f30a7da974ffb5596313f6.svg?invert_in_darkmode&sanitize=true" align=middle width=52.80813779999999pt height=22.465723500000017pt/> where the <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> is a <img src="/tex/9204b1b54cbff660169ee2b1f9b3ba8d.svg?invert_in_darkmode&sanitize=true" align=middle width=154.13265944999998pt height=24.65753399999998pt/> matrix, where an element <img src="/tex/0915cde0aa1d2e0f9dd73778329423e3.svg?invert_in_darkmode&sanitize=true" align=middle width=32.64358184999999pt height=22.465723500000017pt/> of <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> is indexed by two vector <img src="/tex/2ec6e630f199f589a2402fdf3e0289d5.svg?invert_in_darkmode&sanitize=true" align=middle width=8.270567249999992pt height=14.15524440000002pt/> and <img src="/tex/d5c18a8ca1894fd3a7d25f242cbe8890.svg?invert_in_darkmode&sanitize=true" align=middle width=7.928106449999989pt height=14.15524440000002pt/> and of length the number of dimensions of the array <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> and the dimensions of the array <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> respectively. 

The function `TensorDB::"%.%"` of the 'TensorDB' allows to perform the array multiplication as described above.
The package uses named arrays with names dimensions (`names(dimnames(A))` is not `NULL`).

### Recursive linear estimates

The function `CompositeRegressionEstimation::composite` 
allows to compute linear combinations of the month in sample groups of the form

<img src="/tex/68def15f8ff220e879e78aa6f1df32bd.svg?invert_in_darkmode&sanitize=true" align=middle width=428.24322255000004pt height=116.71341989999999pt/>
This is a special case of a linear combination of the month-in-sample estimates.

#### AK estimator


The AK composite estimator is equivalently in ``CPS Technical Paper (2006). Design and Methodology of the Current Population Survey. Technical Report 66, U.S. Census Bureau. (2006), [section 10-11]'':


For <img src="/tex/448378a33e519f8bf89301552c0a348c.svg?invert_in_darkmode&sanitize=true" align=middle width=44.56994024999999pt height=21.18721440000001pt/>, <img src="/tex/da2cc7485cb0fa1b15583647a8b5d253.svg?invert_in_darkmode&sanitize=true" align=middle width=167.13742815pt height=28.89761819999999pt/>.
 
 For <img src="/tex/dfc1aff530546b0b16ab4aa699cf534f.svg?invert_in_darkmode&sanitize=true" align=middle width=44.56994024999999pt height=21.18721440000001pt/>, 
 <p align="center"><img src="/tex/6518d014d587aa82df63c2831dfca370.svg?invert_in_darkmode&sanitize=true" align=middle width=536.46001035pt height=50.18295645pt/></p>
 

where <p align="center"><img src="/tex/81dd682ea0449547e2543021d5275dc3.svg?invert_in_darkmode&sanitize=true" align=middle width=361.99945814999995pt height=40.045914149999994pt/></p>
 and <p align="center"><img src="/tex/0c649883f5f4faec4a6a2d3814c35465.svg?invert_in_darkmode&sanitize=true" align=middle width=479.02636814999994pt height=59.1786591pt/></p>
 
 For the CPS, <img src="/tex/b396510f188ae3cee621c2a36bcb2985.svg?invert_in_darkmode&sanitize=true" align=middle width=14.714708249999989pt height=14.15524440000002pt/> is the ratio between the number of rotation groups in the sample and the number of overlaping rotation groups between two month, 
 which is a constant  <img src="/tex/3e0fccc50f84b4c25e62fc568fcf153e.svg?invert_in_darkmode&sanitize=true" align=middle width=62.11188059999999pt height=24.65753399999998pt/>; <img src="/tex/4a09d1898adc7637934a77010e40aea5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.714708249999989pt height=14.15524440000002pt/> is the ratio between the number of non overlaping rotation groups the number of overlaping rotation groups between two month, 
 which is a constant of <img src="/tex/be175353a87f6fc97908fcda28d4c44a.svg?invert_in_darkmode&sanitize=true" align=middle width=24.657628049999992pt height=24.65753399999998pt/>.



The AK estimator can be defined as follows:
For <img src="/tex/448378a33e519f8bf89301552c0a348c.svg?invert_in_darkmode&sanitize=true" align=middle width=44.56994024999999pt height=21.18721440000001pt/>, <img src="/tex/da2cc7485cb0fa1b15583647a8b5d253.svg?invert_in_darkmode&sanitize=true" align=middle width=167.13742815pt height=28.89761819999999pt/>.
 
 For <img src="/tex/dfc1aff530546b0b16ab4aa699cf534f.svg?invert_in_darkmode&sanitize=true" align=middle width=44.56994024999999pt height=21.18721440000001pt/>, 


<img src="/tex/0c9644ece89508a4343bb7ca720e39d2.svg?invert_in_darkmode&sanitize=true" align=middle width=446.76190844999996pt height=116.71341989999999pt/>
 
 
    
  In the case of the CPS, the rotation group one sample unit  belongs to in a particular month  is a function
 of the number of times it has been selected before, including this month, and so the rotation group of an individual in a particular month is called the "month in sample" variable.
    
 For the CPS, in month <img src="/tex/1e277ba1ce19c790851f457314abfa6b.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/> the overlap <img src="/tex/32e587e0d40e3e2ee819ca369a5ca1e9.svg?invert_in_darkmode&sanitize=true" align=middle width=79.40270249999999pt height=22.465723500000017pt/> correspond to the individuals in the sample <img src="/tex/6a9d394a320bc4d2ceba77eb09821eb4.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> with a value of month in sample equal to 2,3,4, 6,7 or 8.
 The overlap <img src="/tex/32e587e0d40e3e2ee819ca369a5ca1e9.svg?invert_in_darkmode&sanitize=true" align=middle width=79.40270249999999pt height=22.465723500000017pt/> correspond to the individuals in the sample <img src="/tex/6a9d394a320bc4d2ceba77eb09821eb4.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> with a value of month in sample equal to 2,3,4, 6,7 or 8. as well as 
 individuals in the sample <img src="/tex/dcf2b9a28b9c3ca1536e4215e48a5629.svg?invert_in_darkmode&sanitize=true" align=middle width=38.57134214999999pt height=22.465723500000017pt/> with a value of month in sample equal to 1,2,3, 5,6 or 7. 
 When parametrising the function, the choice would be `group_1=c(1:3,5:7)` and `group0=c(2:4,6:8)`.

 Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates
 

```
CompositeRegressionEstimation::CPS_AK()
```


 The functions `AK3`, computes the linear combination directly and more efficiently. the AK estimates are linear combinations of the month in sample estimates. The function `AK3` computes the coefficient matrix <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> from the values of <img src="/tex/53d147e7f3fe6e47ee05b88b166bd3f6.svg?invert_in_darkmode&sanitize=true" align=middle width=12.32879834999999pt height=22.465723500000017pt/>, <img src="/tex/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode&sanitize=true" align=middle width=15.13700594999999pt height=22.465723500000017pt/>, <img src="/tex/1c6008f5bc971bdde74e1a5f31c04e45.svg?invert_in_darkmode&sanitize=true" align=middle width=14.714708249999989pt height=14.15524440000002pt/>, <img src="/tex/99540970492f8b54b28407a609d84199.svg?invert_in_darkmode&sanitize=true" align=middle width=14.714708249999989pt height=14.15524440000002pt/> and performs the matrix product <img src="/tex/5097776bc1f30a7da974ffb5596313f6.svg?invert_in_darkmode&sanitize=true" align=middle width=52.80813779999999pt height=22.465723500000017pt/>.
The function 'coefAK' produces the coefficients.

The CPS Census Bureau uses different values of A and K for different variables.
For the employmed total, the values used are: <img src="/tex/aa1f7d354b356080efa3e3bb7e56e66c.svg?invert_in_darkmode&sanitize=true" align=middle width=29.68033034999999pt height=22.465723500000017pt/>, <img src="/tex/7c98bb40b74dbb4486fd69f3a388ce4a.svg?invert_in_darkmode&sanitize=true" align=middle width=32.48853134999999pt height=22.465723500000017pt/>.
For the unemployed total, the values used are: <img src="/tex/aa1f7d354b356080efa3e3bb7e56e66c.svg?invert_in_darkmode&sanitize=true" align=middle width=29.68033034999999pt height=22.465723500000017pt/>, <img src="/tex/7c98bb40b74dbb4486fd69f3a388ce4a.svg?invert_in_darkmode&sanitize=true" align=middle width=32.48853134999999pt height=22.465723500000017pt/>.
The functions `CPS_A_e`, `CPS_A_u`, `CPS_K_e`, `CPS_K_u`, `CPS_AK()` return these coefficients.

```r
CPS_A_e();CPS_A_u();
```

```
## Error in CPS_A_e(): could not find function "CPS_A_e"
```

```
## Error in CPS_A_u(): could not find function "CPS_A_u"
```

```r
CPS_K_e();CPS_K_u();
```

```
## Error in CPS_K_e(): could not find function "CPS_K_e"
```

```
## Error in CPS_K_u(): could not find function "CPS_K_u"
```

```r
CPS_AK()
```

```
## Error in CPS_AK(): could not find function "CPS_AK"
```

the option `W.ak` with parameters 

```r
W.ak()
```

```
## Error in W.ak(): could not find function "W.ak"
```


the function `CPS_AK_coeff.array.f` with the parameters

`simplify=FALSE` produces the array of dimension 


```r
W=CPS_AK_coeff.array.f(4,ak=CPS_AK(),simplify=FALSE)
```

```
## Error in CPS_AK_coeff.array.f(4, ak = CPS_AK(), simplify = FALSE): could not find function "CPS_AK_coeff.array.f"
```

```r
dimnames(W);dim(W)
```

```
## Error in eval(expr, envir, enclos): object 'W' not found
```

```
## Error in eval(expr, envir, enclos): object 'W' not found
```

#### Rough estimation of the month-in-sample estimate covariance matrix

#### Empirical best AK estimator

#### Empirical best YF estimator

#### Empirical best linear estimator

### Modified regression (Singh, Fuller-Rao)


