---
title: "Composite Regression for Repeated Surveys"
author: Daniel Bonnery
---

`CompositeRegressionEstimation` is an R package that allows to compute estimators for longitudinal survey:
* Composite Regression ["Fuller, Wayne A., and J. N. K. Rao. "A regression composite estimator with application to the Canadian Labour Force Survey." Survey Methodology 27.1 (2001): 45-52."](http://www.statcan.gc.ca/pub/12-001-x/2001001/article/5853-eng.pdf)

* Gauss Markov BLUE

* AK estimator

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
U<-with(as.data.frame(Direct.est),
        (employmentstatus_ne)/(employmentstatus_ne+employmentstatus_nu))
library(ggplot2);
ggplot(data=data.frame(period=period,E=U),aes(x=period,y=U))+geom_line()+
  ggtitle("Direct estimate of the monthly employment rate from the CPS public microdata in 2005")+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")
```

<img src="figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" width="100%" />

#### Month in sample estimate

An estimate can be obtained from each month-in-sample rotation group. The month-in-sample estimates are estimates of a total of a study variable of the form:
<img src="/tex/05fe3182e27f9195f836052a21bf2a55.svg?invert_in_darkmode&sanitize=true" align=middle width=145.4812623pt height=24.657735299999988pt/>, where <img src="/tex/c745b9b57c145ec5577b82542b2df546.svg?invert_in_darkmode&sanitize=true" align=middle width=10.57650494999999pt height=14.15524440000002pt/> is an adjustment. In the CPS, the adjustment <img src="/tex/a4eaf29ba18ea817aa165fcb033bc2b7.svg?invert_in_darkmode&sanitize=true" align=middle width=40.713337499999994pt height=21.18721440000001pt/> as there are <img src="/tex/005c128d6e551735fa5d938e44e7a613.svg?invert_in_darkmode&sanitize=true" align=middle width=8.219209349999991pt height=21.18721440000001pt/> rotation groups. Other adjustments are possible, as for example <img src="/tex/71997fae67898064cda8f915bdcf3a12.svg?invert_in_darkmode&sanitize=true" align=middle width=138.49146134999998pt height=24.657735299999988pt/>.

The following code  creates the array `Y` of dimension <img src="/tex/941e0906d926f039bcfada153e127a16.svg?invert_in_darkmode&sanitize=true" align=middle width=74.36051699999999pt height=22.465723500000017pt/> (M months, 8 rotation groups, 3 employment statuses.) where `Y[m,g,e]` is the month in sample estimate for month `m`, group `g` and status `e`.


```r
library(CompositeRegressionEstimation)
Y<-CompositeRegressionEstimation::WSrg2(list.tables,rg = "hrmis",weight="pwsswgt",y = "employmentstatus")
Umis<-plyr::aaply(Y[,,"e"],1:2,sum)/plyr::aaply(Y[,,c("e","u")],1:2,sum);
library(ggplot2);ggplot(data=reshape2::melt(Umis),aes(x=m,y=value,color=mis))+geom_line()+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")+ 
  labs(title = "Month-in-sample estimates", 
       subtitle = "Monthly employment rate, year 2005", 
       caption = "Computed from CPS public anonymized microdata.")
```

```
## Error in FUN(X[[i]], ...): object 'mis' not found
```

<img src="figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" width="100%" />

#### Linear combinaisons of the month-in-sample estimates

The month-in-sample estimates for each month and each rotation group can also be given in a data.frame with four variables: the month, the group, the employment status and the value of the estimate.
Such a dataframe can be obtained from `Y` using the function `reshape2::melt`


```r
print(reshape2::melt(Y[,,]))
```


|Row number |Month  |Month in sample group |Employment status |<img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/>           |
|:----------|:------|:---------------------|:-----------------|:-------------|
|1          |200501 |1                     |n                 |17645785.4304 |
|2          |200502 |1                     |n                 |17526653.25   |
|3          |200503 |1                     |n                 |17905466.5322 |
|...        |...    |...                   |...               |...           |
|288        |200512 |8                     |u                 |846918.8885   |

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

The function `TensorDB::"%.%"` of the 'TensorDB' allows to perform the array multiplication as described above.
The package uses named arrays with names dimensions (`names(dimnames(A))` is not `NULL`).

### Recursive linear estimates

The function `CompositeRegressionEstimation::composite` 
allows to compute linear combinations of the month in sample groups of the form

<img src="/tex/68def15f8ff220e879e78aa6f1df32bd.svg?invert_in_darkmode&sanitize=true" align=middle width=428.24322255000004pt height=116.71341989999999pt/>
This is a special case of a linear combination of the month-in-sample estimates.


Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates.
 
The following code computes a recursive estimator with parameters <img src="/tex/0d22c917616fe8a92c5c6813000e4783.svg?invert_in_darkmode&sanitize=true" align=middle width=119.06307104999999pt height=27.77565449999998pt/>, <img src="/tex/c07d4aad080ca920fc0e9dbe570cd021.svg?invert_in_darkmode&sanitize=true" align=middle width=143.75007074999996pt height=22.831056599999986pt/>.


```r
Yc<-CompositeRegressionEstimation::composite(list.tables,"pwsswgt","employmentstatus",groupvar="hrmis",groups0 = c(2:4,6:8),groups_1=c(1:3,5:7),Coef = c(alpha_1=.5,alpha0=.5,beta_1=0,beta0=0,gamma0=0))
Uc<-Yc[,"employmentstatus_ne"]/(Yc[,"employmentstatus_ne"]+Yc[,"employmentstatus_nu"])
ggplot(data=reshape2::melt(cbind(Direct=U,Composite=Uc)),aes(x=as.Date(paste0(Var1,"01"),"%Y%m%d"),y=value,group=Var2,color=Var2))+geom_line()+xlab("")+ylab("")+ggtitle("Direct and Composite estimates")
```

<img src="figure/unnamed-chunk-7-1.png" title="plot of chunk unnamed-chunk-7" alt="plot of chunk unnamed-chunk-7" width="100%" />



The function `CompositeRegressionEstimation::composite` computes recursively the estimates.
Another way is to compute recursively the coefficients of the resulting linear combinaison of month in sample weights.
This is performed by the function `CompositeRegressionEstimation::W.rec`


```r
Wrec<-W.rec(months=period,
            groups =paste0("",1:8),
            S = c(2:4,6:8),
            S_1=c(1:3,5:7),
            Coef = c(alpha_1=.5,alpha0=.5,beta_1=0,beta0=0,gamma0=0))
```

Then one can multiply the array 'W' and 'X':


```r
Yc2<-TensorDB::"%.%"(Wrec,X,I_A=list(c=integer(0),n="m2",p=c("m1","rg1")),I_B=list(c=integer(0),p=c("m","hrmis"),q="employmentstatus"))
```

```
## Error in aperm.default(A, c(n, p)): 'perm' is of wrong length 3 (!= 5)
```

```r
Uc2<-Yc2[,"e"]/(Yc2[,"e"]+Yc2[,"u"])
any(abs(Uc-Uc2)>1e-3)
```

```
## [1] FALSE
```



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
<p align="center"><img src="/tex/259eea5fe1348a814aaa684477f0c14c.svg?invert_in_darkmode&sanitize=true" align=middle width=444.96454035pt height=108.49422870000001pt/></p>
 
 
    
  In the case of the CPS, the rotation group one sample unit  belongs to in a particular month  is a function
 of the number of times it has been selected before, including this month, and so the rotation group of an individual in a particular month is called the "month in sample" variable.
    
 For the CPS, in month <img src="/tex/1e277ba1ce19c790851f457314abfa6b.svg?invert_in_darkmode&sanitize=true" align=middle width=14.433101099999991pt height=14.15524440000002pt/> the overlap <img src="/tex/fcb12e9a318990eacd858a01641ef580.svg?invert_in_darkmode&sanitize=true" align=middle width=79.40270249999999pt height=22.465723500000017pt/> corresponds to the individuals in the sample <img src="/tex/6a9d394a320bc4d2ceba77eb09821eb4.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> with a value of month in sample equal to 2,3,4, 6,7 or 8.
 The overlap <img src="/tex/fcb12e9a318990eacd858a01641ef580.svg?invert_in_darkmode&sanitize=true" align=middle width=79.40270249999999pt height=22.465723500000017pt/> corresponds to the individuals in the sample <img src="/tex/6a9d394a320bc4d2ceba77eb09821eb4.svg?invert_in_darkmode&sanitize=true" align=middle width=21.74477414999999pt height=22.465723500000017pt/> with a value of month in sample equal to 2,3,4, 6,7 or 8. as well as 
 individuals in the sample <img src="/tex/dcf2b9a28b9c3ca1536e4215e48a5629.svg?invert_in_darkmode&sanitize=true" align=middle width=38.57134214999999pt height=22.465723500000017pt/> with a value of month in sample equal to 1,2,3, 5,6 or 7. 
 When parametrising the function 'AK', the choice would be `group_1=c(1:3,5:7)` and `group0=c(2:4,6:8)`.




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
CPS_AK()
```

```
##  a1  a2  a3  k1  k2  k3 
## 0.3 0.4 0.0 0.4 0.7 0.0
```




The matrix <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> corresponding to the coefficients for the AK estimator for the total of employed can be obtained with:


```r
Wak.e<-W.ak(months=period,
            groups =paste0("",1:8),
            S = c(2:4,6:8),
            S_1=c(1:3,5:7),
            a=CPS_A_e(),k=CPS_K_e(),
            eta0=4/3,
            eta1=1/3,
            rescaled=F)
```

In the same way:

```r
Wak.u<-W.ak(months=period,
            groups =paste0("",1:8),
            S = c(2:4,6:8),
            S_1=c(1:3,5:7),
            a=CPS_A_u(),k=CPS_K_u(),
            eta0=4/3,
            eta1=1/3,
            rescaled=F)
```


The Census AK estimator of the total of employed and unemployed computed with the values of A and K used by the Census are:


```r
Y_census_AK.e<-TensorDB::"%.%"(Wak.e,X[,,"e"],I_A=list(c=integer(0),n="m2",p=c("m1","rg1")),I_B=list(c=integer(0),p=c("m","hrmis"),q=integer(0)))
```

```
## Error in X[, , "e"]: incorrect number of dimensions
```

```r
Y_census_AK.u<-TensorDB::"%.%"(Wak.u,X[,,"u"],I_A=list(c=integer(0),n="m2",p=c("m1","rg1")),I_B=list(c=integer(0),p=c("m","hrmis"),q=integer(0)))
```

```
## Error in X[, , "u"]: incorrect number of dimensions
```
The corresponding unemployment rate time series can be obtained by the ratio :


```r
U_census_AK<-Y_census_AK.e/(Y_census_AK.e+Y_census_AK.u)
```



We plot the Direct estimate vs the AK estimate:




```r
ggplot(data=reshape2::melt(cbind(Direct=U,Composite=U_census_AK)),aes(x=as.Date(paste0(Var1,"01"),"%Y%m%d"),y=value,group=Var2,color=Var2))+geom_line()+xlab("")+ylab("")+ggtitle("Direct and Composite estimates")
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15-1.png)

If we want to get the whole <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> matrix, we can use the function
'W.multi.ak':




```r
Wak<-W.multi.ak(months=period,
            groups =paste0("",1:8),
            S = c(2:4,6:8),
            S_1=c(1:3,5:7),
            ak=list(u=c(a=CPS_A_u(),k=CPS_K_u()),e=c(a=CPS_A_e(),k=CPS_K_e()),n=c(a=0,k=0)))
```

and the estimates total of employed, unemployed and not in the labor force are obtained with:


```r
Y_census_AK<-TensorDB::"%.%"(Wak,X,I_A=list(c=integer(0),n="m2",p=c("m1","rg1")),I_B=list(c=integer(0),p=c("m","hrmis"),q="employmentstatus"))
```

```
## Error in aperm.default(A, c(n, p)): 'perm' is of wrong length 3 (!= 6)
```

```r
U_census_AK2<-Yc2[,"e"]/(Yc2[,"e"]+Yc2[,"u"])
any(abs(U_census_AK-U_census_AK)>1e-3)
```

```
## [1] FALSE
```



## Optimisation of the linear combinaisons of the month in sample estimates

In a model where <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/>, the design-based covariance matrix of <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/>, is known, then the optimal linear estimator could be computed.

Gauss Markov gives us the formula to compute the optimal value of <img src="/tex/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> as a value of <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/>. It is given in 
["Bonnery Cheng Lahiri, An Evaluation of Design-based Properties of Different Composite Estimators"](https://arxiv.org/abs/1811.12249)


The model for the month in sample estimate vector <img src="/tex/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode&sanitize=true" align=middle width=13.19638649999999pt height=22.465723500000017pt/> is 
<img src="/tex/671b47a51c4700e988e220049f5f5a3e.svg?invert_in_darkmode&sanitize=true" align=middle width=102.49404494999997pt height=24.65753399999998pt/>, 
where <img src="/tex/8217ed3c32a785f0b5aad4055f432ad8.svg?invert_in_darkmode&sanitize=true" align=middle width=10.16555099999999pt height=22.831056599999986pt/> is the vector indexed by <img src="/tex/d0e755a01a41c87a5166af852bf75a2d.svg?invert_in_darkmode&sanitize=true" align=middle width=29.39312144999999pt height=14.15524440000002pt/>: <img src="/tex/11f58870370728d1afbde825a0a4dfa7.svg?invert_in_darkmode&sanitize=true" align=middle width=142.10540024999997pt height=24.657735299999988pt/> and <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> is the matrix with rows indexed by <img src="/tex/6b53aba94c06975e932f98405e00fd53.svg?invert_in_darkmode&sanitize=true" align=middle width=45.129362849999985pt height=14.15524440000002pt/> and columns indexed by <img src="/tex/d0e755a01a41c87a5166af852bf75a2d.svg?invert_in_darkmode&sanitize=true" align=middle width=29.39312144999999pt height=14.15524440000002pt/> such that <img src="/tex/e4a077e059953faf6081dd6ba33ead56.svg?invert_in_darkmode&sanitize=true" align=middle width=128.15455784999997pt height=24.65753399999998pt/> if <img src="/tex/1a75153b75c9963c45b6885e90d2decf.svg?invert_in_darkmode&sanitize=true" align=middle width=68.18113994999999pt height=24.7161288pt/> and <img src="/tex/6b275a9cd6e1268e4e95549ffa1b19cd.svg?invert_in_darkmode&sanitize=true" align=middle width=54.62321534999999pt height=24.7161288pt/>, <img src="/tex/29632a9bf827ce0200454dd32fc3be82.svg?invert_in_darkmode&sanitize=true" align=middle width=8.219209349999991pt height=21.18721440000001pt/> otherwise.

The best coefficient array <img src="/tex/5bfad3945951b5bc8adc29e86180bc7b.svg?invert_in_darkmode&sanitize=true" align=middle width=24.543452999999992pt height=22.63846199999998pt/> is the matrix with rows indexed by <img src="/tex/d04446fc222321b6fe818ef6636afd2e.svg?invert_in_darkmode&sanitize=true" align=middle width=51.40230479999999pt height=24.7161288pt/> and columns indexed by <img src="/tex/6b53aba94c06975e932f98405e00fd53.svg?invert_in_darkmode&sanitize=true" align=middle width=45.129362849999985pt height=14.15524440000002pt/> given by:

<p align="center"><img src="/tex/4895e9a155618f0b4607a650b7786ac5.svg?invert_in_darkmode&sanitize=true" align=middle width=402.9448698pt height=19.726228499999998pt/></p>


where the <img src="/tex/580c42d204dc080d3bd5938b427c5db9.svg?invert_in_darkmode&sanitize=true" align=middle width=10.09137359999999pt height=26.17730939999998pt/> operator designates the Moore Penrose pseudo inversion, <img src="/tex/21fd4e8eecd6bdf1a4d3d6bd1fb8d733.svg?invert_in_darkmode&sanitize=true" align=middle width=8.515988249999989pt height=22.465723500000017pt/> is the
identity matrix. Here the minimisation is with respect to the order on symmetric positive definite matrices: <img src="/tex/654cec854951c205ce77578b67684e93.svg?invert_in_darkmode&sanitize=true" align=middle width=160.0454064pt height=22.465723500000017pt/> is positive. It can be shown that <img src="/tex/d223e53348ca685134544c60e4d8b904.svg?invert_in_darkmode&sanitize=true" align=middle width=72.0318588pt height=27.6567522pt/> in our case and that <img src="/tex/2edcd8fc671b418f91c163a1cc3064bb.svg?invert_in_darkmode&sanitize=true" align=middle width=71.16423764999999pt height=26.17730939999998pt/>. 
The estimator <img src="/tex/03830e6740cae4428e61a5d02614198d.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> is the Best Linear Unbiased Estimator under this model.


The next code provides the <img src="/tex/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode&sanitize=true" align=middle width=14.908688849999992pt height=22.465723500000017pt/> and <img src="/tex/84259d0b51812feb7c1a7fd2da2722d7.svg?invert_in_darkmode&sanitize=true" align=middle width=25.00004099999999pt height=26.17730939999998pt/> matrices:


```r
 X<-CPS_X_array(months=list(m=paste(200501:200504)),
             vars=list(y=c("e","u","n")),
             rgs=list(hrmis=paste(1:8)),1/2)
 Xplus<-CPS_Xplus_array(months=list(m=paste(200501:200504)),
             vars=list(y=c("e","u","n")),
             rgs=list(hrmis=paste(1:8)),1/2)
 TensorDB::"%.%"(Xplus,X,
  I_A=list(c=integer(0),n=c("y2","m2"),p=c("y","hrmis","m")),
  I_B=list(c=integer(0),p=c("y","hrmis","m"),q=c("y2","m2")))
```

```
## , , y2 = e, m2 = 200501
## 
##    m2
## y2  200501 200502 200503 200504
##   e      1      0      0      0
##   u      0      0      0      0
##   n      0      0      0      0
## 
## , , y2 = u, m2 = 200501
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      0
##   u      1      0      0      0
##   n      0      0      0      0
## 
## , , y2 = n, m2 = 200501
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      0
##   u      0      0      0      0
##   n      1      0      0      0
## 
## , , y2 = e, m2 = 200502
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      1      0      0
##   u      0      0      0      0
##   n      0      0      0      0
## 
## , , y2 = u, m2 = 200502
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      0
##   u      0      1      0      0
##   n      0      0      0      0
## 
## , , y2 = n, m2 = 200502
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      0
##   u      0      0      0      0
##   n      0      1      0      0
## 
## , , y2 = e, m2 = 200503
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      1      0
##   u      0      0      0      0
##   n      0      0      0      0
## 
## , , y2 = u, m2 = 200503
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      0
##   u      0      0      1      0
##   n      0      0      0      0
## 
## , , y2 = n, m2 = 200503
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      0
##   u      0      0      0      0
##   n      0      0      1      0
## 
## , , y2 = e, m2 = 200504
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      1
##   u      0      0      0      0
##   n      0      0      0      0
## 
## , , y2 = u, m2 = 200504
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      0
##   u      0      0      0      1
##   n      0      0      0      0
## 
## , , y2 = n, m2 = 200504
## 
##    m2
## y2  200501 200502 200503 200504
##   e      0      0      0      0
##   u      0      0      0      0
##   n      0      0      0      1
```


The estimator <img src="/tex/03830e6740cae4428e61a5d02614198d.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80826024999999pt height=22.465723500000017pt/> is the Best Linear Unbiased Estimator under this model.


```r
beta= matrix(rchisq(12,1),4,3)
dimnames(beta)<-list(m=paste(200501:200504),y=c("e","u","n"))
 X<-CPS_X_array(months=list(m=paste(200501:200504)),
             vars=list(y=c("e","u","n")),
             rgs=list(hrmis=paste(1:8)))
 Xplus<-CPS_Xplus_array(months=list(m=paste(200501:200504)),
             vars=list(y=c("e","u","n")),
             rgs=list(hrmis=paste(1:8)),1/2)
 EY<-TensorDB::"%.%"(X,beta,I_A=list(c=integer(0),n=c("m","y","hrmis"),p=c("m2","y2")),I_B=list(c=integer(0),p=c("m","y"),q=integer(0)))
 set.seed(1)
 Sigma=rWishart(1,length(EY),diag(length(EY)))
 Y<-array(mvrnorm(n = 100,mu = c(EY),Sigma = Sigma[,,1]),c(100,dim(EY)))
 dimnames(Y)<-c(list(rep=1:100),dimnames(EY))
 Sigma.A<-array(Sigma,c(dim(EY),dim(EY)))
 dimnames(Sigma.A)<-rep(dimnames(EY),2);names(dimnames(Sigma.A))[4:6]<-paste0(names(dimnames(Sigma.A))[4:6],"2")
 W<-CoeffGM.array(Sigma.A,X,Xplus)
 WY<-TensorDB::"%.%"(W,Y,I_A=list(c=integer(0),n=c("y2","m2"),p=c("m","y","hrmis")),I_B=list(c=integer(0),p=c("m","y","hrmis"),q=c("rep")))
 DY<-TensorDB::"%.%"(Xplus,Y,I_A=list(c=integer(0),n=c("y2","m2"),p=c("m","y","hrmis")),I_B=list(c=integer(0),p=c("m","y","hrmis"),q=c("rep")))
 plot(c(beta),c(apply(DY,1:2,var)),col="red")
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19-1.png)

```r
 plot(c(beta),c(apply(WY,1:2,var)))
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19-2.png)


#### Best AK estimator for level, change and compromise
When <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/> is known, the best linear estimate of <img src="/tex/82d4821940bb3683b4917f439e512b9d.svg?invert_in_darkmode&sanitize=true" align=middle width=42.58554134999999pt height=22.831056599999986pt/> is <img src="/tex/20ef8e6105aacc4a9df9bc1ae34b4fa9.svg?invert_in_darkmode&sanitize=true" align=middle width=67.95088739999998pt height=22.831056599999986pt/>. What is true for the Best linear estimate is not 
true for all the best linear estimate in a subclass of the linear estimates.
For example, the best coefficients A and K for month to month change may not be the best coeeficients for level of employement.
One needs to define a compromise target to define what is the optimal <img src="/tex/53d147e7f3fe6e47ee05b88b166bd3f6.svg?invert_in_darkmode&sanitize=true" align=middle width=12.32879834999999pt height=22.465723500000017pt/> and <img src="/tex/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode&sanitize=true" align=middle width=15.13700594999999pt height=22.465723500000017pt/> coefficients.

The following code gives the A and K coefficient as a function of <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/> that minimise ...


```r
to be done
```

When <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/> is known, 

#### Empirical best estimators and estimation of <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/>

As <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/> is not known, the approach adopted by the Census has been for total of employed and total of unemployed separately to plugin an estimate of <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/>, and then try values of <img src="/tex/53d147e7f3fe6e47ee05b88b166bd3f6.svg?invert_in_darkmode&sanitize=true" align=middle width=12.32879834999999pt height=22.465723500000017pt/> and <img src="/tex/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode&sanitize=true" align=middle width=15.13700594999999pt height=22.465723500000017pt/> between
0 and 1 with one decimal value and take the ones tha minimize the estimated variance.

There are many issues with this approach:

* The optimisation method: 
- The optimal was chosen on a grid, so the optimal may have been missed.
- The optimal was chosen variable by variable, which is only optimal when estimates of different variables are uncorrelated, which is not the case: there is a negative relationship between unemployment, employment and not in the labor force: a sample with a high level of employed and unemployed will have a low level of not in the labor force.
* No robustness
- The estimation of <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/> was done with really strong variance stationarity assumption, which is unrealistic when one observes the evolution of the employment during the last decade.
- No study to my knowledge was done to show how good this estimation of <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/> was.
- the empirical best will be very sensitive to the values of <img src="/tex/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode&sanitize=true" align=middle width=11.87217899999999pt height=22.465723500000017pt/>.

## Modified regression (Singh, Fuller-Rao)


