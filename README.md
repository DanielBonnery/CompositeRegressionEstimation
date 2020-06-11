---
title: "Composite Regression for Repeated Surveys"
author: Daniel Bonnery
---

<p align="center">
  <img width="128" src="logo/logo_4.4.png" />
</p>


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
Let <img src="svgs/2c70fa955a339de8af08310418c6eed8.svg?invert_in_darkmode" align=middle width=113.45103000000002pt height=24.65759999999998pt/> be an index of the time, and let <img src="svgs/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode" align=middle width=21.744855000000005pt height=22.46574pt/> be the set of sampling units at time <img src="svgs/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode" align=middle width=14.433210000000003pt height=14.155350000000013pt/>. The samples <img src="svgs/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode" align=middle width=21.744855000000005pt height=22.46574pt/> are subsets of a larger population <img src="svgs/6bac6ec50c01592407695ef84f457232.svg?invert_in_darkmode" align=middle width=13.016025000000003pt height=22.46574pt/>.

Some repeated surveys use rotation groups and a rotation pattern.
For the CPS, each sampled household will be selected to be surveyed during 4 consecutive months,  then left alone 8 months, then
surveyed again 4 consecutive months. As a consequence, for a given month, a sampled units that month will be surveyed for the first, second, ..., or 8th and last time. This induces a partition of the sample into month-in-sample groups:
<img src="svgs/a38e6d83257e4eee7bbf7812fede4b0e.svg?invert_in_darkmode" align=middle width=216.703905pt height=22.46574pt/>. 


For each unit <img src="svgs/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode" align=middle width=9.075495000000004pt height=22.831379999999992pt/> in <img src="svgs/62ec7ed78c340ea1a37fdfba227dca78.svg?invert_in_darkmode" align=middle width=21.744855000000005pt height=22.46574pt/>, usually the dataset contains:
the values <img src="svgs/5ba83d57b9bfbf937ad937b046d25c85.svg?invert_in_darkmode" align=middle width=30.894435000000005pt height=14.155350000000013pt/> of a variable of interest <img src="svgs/deceeaf6940a8c7a5a02373728002b0f.svg?invert_in_darkmode" align=middle width=8.649300000000004pt height=14.155350000000013pt/> for unit <img src="svgs/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode" align=middle width=9.075495000000004pt height=22.831379999999992pt/> and the period <img src="svgs/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode" align=middle width=14.433210000000003pt height=14.155350000000013pt/>. In particular we are interested in the case where <img src="svgs/5ba83d57b9bfbf937ad937b046d25c85.svg?invert_in_darkmode" align=middle width=30.894435000000005pt height=14.155350000000013pt/> is a vector of indicator values, <img src="svgs/6b03c4df1f5de6c09c79b2a37936630e.svg?invert_in_darkmode" align=middle width=335.66560499999997pt height=24.65759999999998pt/>:
<img src="svgs/a79b0d0f9e59c6f8683ccf4431c426e6.svg?invert_in_darkmode" align=middle width=105.68893499999999pt height=24.65759999999998pt/> means that individual <img src="svgs/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode" align=middle width=9.075495000000004pt height=22.831379999999992pt/> was not in the labor force at time <img src="svgs/63bb9849783d01d91403bc9a5fea12a2.svg?invert_in_darkmode" align=middle width=9.075495000000004pt height=22.831379999999992pt/>.

It also contains <img src="svgs/498af25a5ecc1ca5ac220f89ab585e76.svg?invert_in_darkmode" align=middle width=34.603635000000004pt height=14.155350000000013pt/> a sampling weight.



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

The direct estimator of the total is <img src="svgs/1be0457898a13c5f4f4a4c95d22b17ae.svg?invert_in_darkmode" align=middle width=122.34486000000001pt height=24.65792999999999pt/>. The function `CompositeRegressionEstimation::WS` will produce
the weighted estimates <img src="svgs/7629247eccd6f3f305aaec4a62d5e015.svg?invert_in_darkmode" align=middle width=274.04635499999995pt height=28.897770000000005pt/>

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
<img src="svgs/05fe3182e27f9195f836052a21bf2a55.svg?invert_in_darkmode" align=middle width=145.481325pt height=24.65792999999999pt/>, where <img src="svgs/c745b9b57c145ec5577b82542b2df546.svg?invert_in_darkmode" align=middle width=10.576500000000003pt height=14.155350000000013pt/> is an adjustment. In the CPS, the adjustment <img src="svgs/a4eaf29ba18ea817aa165fcb033bc2b7.svg?invert_in_darkmode" align=middle width=40.71342pt height=21.18732pt/> as there are <img src="svgs/005c128d6e551735fa5d938e44e7a613.svg?invert_in_darkmode" align=middle width=8.219277000000005pt height=21.18732pt/> rotation groups. Other adjustments are possible, as for example <img src="svgs/71997fae67898064cda8f915bdcf3a12.svg?invert_in_darkmode" align=middle width=138.49159500000002pt height=24.65792999999999pt/>.

The following code  creates the array `Y` of dimension <img src="svgs/941e0906d926f039bcfada153e127a16.svg?invert_in_darkmode" align=middle width=74.36054999999999pt height=22.46574pt/> (M months, 8 rotation groups, 3 employment statuses.) where `Y[m,g,e]` is the month in sample estimate for month `m`, group `g` and status `e`.


```r
library(CompositeRegressionEstimation)
Y<-CompositeRegressionEstimation::WSrg2(list.tables,rg = "hrmis",weight="pwsswgt",y = "employmentstatus")
Umis<-plyr::aaply(Y[,,"e"],1:2,sum)/plyr::aaply(Y[,,c("e","u")],1:2,sum);

  mycolors <- rainbow(8) 
library(ggplot2);ggplot(data=reshape2::melt(Umis),aes(x=m,y=value,color=factor(hrmis),group=hrmis))+geom_line()+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")+ 
  labs(title = "Month-in-sample estimates", 
       subtitle = "Monthly employment rate, year 2005", 
       caption = "Computed from CPS public anonymized microdata.")+
scale_colour_manual(values = mycolors)+
guides(colour=guide_legend(title="m.i.s."))
```

<img src="figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" width="100%" />

#### Linear combinaisons of the month-in-sample estimates

The month-in-sample estimates for each month and each rotation group can also be given in a data.frame with four variables: the month, the group, the employment status and the value of the estimate.
Such a dataframe can be obtained from `Y` using the function `reshape2::melt`


```r
print(reshape2::melt(Y[,,]))
```


|Row number |Month  |Month in sample group |Employment status |<img src="svgs/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode" align=middle width=13.196370000000005pt height=22.46574pt/>           |
|:----------|:------|:---------------------|:-----------------|:-------------|
|1          |200501 |1                     |n                 |17645785.4304 |
|2          |200502 |1                     |n                 |17526653.25   |
|3          |200503 |1                     |n                 |17905466.5322 |
|...        |...    |...                   |...               |...           |
|288        |200512 |8                     |u                 |846918.8885   |

Let <img src="svgs/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode" align=middle width=13.196370000000005pt height=22.46574pt/> be the vector of values in the data.frame.
Elements of <img src="svgs/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode" align=middle width=13.196370000000005pt height=22.46574pt/> can be refered to by the line number or by a combinaison of month, rotation group, and employment status, as for example : <img src="svgs/f194d966a70e1bca28fc2062eb9e3ee7.svg?invert_in_darkmode" align=middle width=153.09046500000002pt height=22.46574pt/>, or by a line number <img src="svgs/8fb799df5f9c1f6f7fdaa744372bd533.svg?invert_in_darkmode" align=middle width=21.941205000000004pt height=41.643689999999985pt/>.
We use <img src="svgs/9f7c9b1c4f87b770604d8d1c7e206d53.svg?invert_in_darkmode" align=middle width=16.438785000000003pt height=41.643689999999985pt/> to designate the vector and <img src="svgs/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode" align=middle width=13.196370000000005pt height=22.46574pt/> to designate the array.

The values to estimate are the elements of the <img src="svgs/7c674d837975ddc779079888281b9cff.svg?invert_in_darkmode" align=middle width=46.050180000000005pt height=22.46574pt/>-sized array <img src="svgs/6113a4c2abf45f7818f3d5e58b17b6ca.svg?invert_in_darkmode" align=middle width=820.090755pt height=24.65792999999999pt/>. We denote by <img src="svgs/9f7c9b1c4f87b770604d8d1c7e206d53.svg?invert_in_darkmode" align=middle width=16.438785000000003pt height=41.643689999999985pt/> the vectorisation of the array <img src="svgs/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode" align=middle width=13.196370000000005pt height=22.46574pt/>.

In R, the function to vectorize an array is the function `c`


```r
A<-array(1:12,c(3,2,2));c(A)
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12
```


We consider estimates of <img src="svgs/4c69ba23ad577f87c4f6c53a06302d4d.svg?invert_in_darkmode" align=middle width=16.438785000000003pt height=42.008999999999986pt/>
of the form  <img src="svgs/357107fe199aa73bc3adf22491a43690.svg?invert_in_darkmode" align=middle width=92.69469pt height=45.39513000000001pt/>, 
where <img src="svgs/b44848922a59328b4ef74c94bdf966a0.svg?invert_in_darkmode" align=middle width=17.808285000000005pt height=41.643689999999985pt/> is a matrix of dimension <img src="svgs/f865697b01f0a6fca85b0727701e6693.svg?invert_in_darkmode" align=middle width=126.94176000000002pt height=42.008999999999986pt/>).

Which is equivalent to estimators of the form <img src="svgs/5097776bc1f30a7da974ffb5596313f6.svg?invert_in_darkmode" align=middle width=52.80825pt height=22.46574pt/> where the <img src="svgs/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode" align=middle width=17.808285000000005pt height=22.46574pt/> is a <img src="svgs/9204b1b54cbff660169ee2b1f9b3ba8d.svg?invert_in_darkmode" align=middle width=154.13277pt height=24.65759999999998pt/> matrix, where an element <img src="svgs/0915cde0aa1d2e0f9dd73778329423e3.svg?invert_in_darkmode" align=middle width=32.6436pt height=22.46574pt/> of <img src="svgs/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode" align=middle width=17.808285000000005pt height=22.46574pt/> is indexed by two vector <img src="svgs/2ec6e630f199f589a2402fdf3e0289d5.svg?invert_in_darkmode" align=middle width=8.270625000000004pt height=14.155350000000013pt/> and <img src="svgs/d5c18a8ca1894fd3a7d25f242cbe8890.svg?invert_in_darkmode" align=middle width=7.928167500000005pt height=14.155350000000013pt/> and of length the number of dimensions of the array <img src="svgs/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode" align=middle width=13.196370000000005pt height=22.46574pt/> and the dimensions of the array <img src="svgs/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode" align=middle width=14.908740000000003pt height=22.46574pt/> respectively. 

The function `arrayproduct::"%.%"` of the 'arrayproduct' allows to perform the array multiplication as described above.
The package uses named arrays with named dimensions (`names(dimnames(A))` is not `NULL`).

### Recursive linear estimates

The function `CompositeRegressionEstimation::composite` 
allows to compute linear combinations of the month in sample groups of the form

<img src="svgs/68def15f8ff220e879e78aa6f1df32bd.svg?invert_in_darkmode" align=middle width=428.24380500000007pt height=116.71341pt/>
This is a special case of a linear combination of the month-in-sample estimates.


Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates.
 
The following code computes a recursive estimator with parameters <img src="svgs/dd6ce82535106d87325a1d76ce58da15.svg?invert_in_darkmode" align=middle width=108.688635pt height=27.775769999999994pt/>, <img src="svgs/c07d4aad080ca920fc0e9dbe570cd021.svg?invert_in_darkmode" align=middle width=143.75014499999997pt height=22.831379999999992pt/>.


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
Yc2<-arrayproduct::"%.%"(Wrec,Y,I_A=list(c=integer(0),n="m2",p=c("m1","rg1")),I_B=list(c=integer(0),p=c("m","hrmis"),q="employmentstatus"))
Uc2<-Yc2[,"e"]/(Yc2[,"e"]+Yc2[,"u"])
paste0("The two differnt methods give ",if(all(abs(Uc-Uc2)<1e-3)){"same"}else{"different"}," results");
```

```
## [1] "The two differnt methods give same results"
```



#### AK estimator
The AK composite estimator is equivalently in ``CPS Technical Paper (2006). Design and Methodology of the Current Population Survey. Technical Report 66, U.S. Census Bureau. (2006), [section 10-11]'':

For <img src="svgs/448378a33e519f8bf89301552c0a348c.svg?invert_in_darkmode" align=middle width=44.569965pt height=21.18732pt/>, <img src="svgs/da2cc7485cb0fa1b15583647a8b5d253.svg?invert_in_darkmode" align=middle width=167.13790500000002pt height=28.897770000000005pt/>.
 
 For <img src="svgs/dfc1aff530546b0b16ab4aa699cf534f.svg?invert_in_darkmode" align=middle width=44.569965pt height=21.18732pt/>, 
 <p align="center"><img src="svgs/6518d014d587aa82df63c2831dfca370.svg?invert_in_darkmode" align=middle width=536.45955pt height=50.182935pt/></p>
 

where <p align="center"><img src="svgs/81dd682ea0449547e2543021d5275dc3.svg?invert_in_darkmode" align=middle width=362.0001pt height=40.045995pt/></p>
 and <p align="center"><img src="svgs/0c649883f5f4faec4a6a2d3814c35465.svg?invert_in_darkmode" align=middle width=479.02635pt height=59.178735pt/></p>
 
 For the CPS, <img src="svgs/b396510f188ae3cee621c2a36bcb2985.svg?invert_in_darkmode" align=middle width=14.714700000000004pt height=14.155350000000013pt/> is the ratio between the number of rotation groups in the sample and the number of overlaping rotation groups between two month, 
 which is a constant  <img src="svgs/3e0fccc50f84b4c25e62fc568fcf153e.svg?invert_in_darkmode" align=middle width=62.11194pt height=24.65759999999998pt/>; <img src="svgs/4a09d1898adc7637934a77010e40aea5.svg?invert_in_darkmode" align=middle width=14.714700000000004pt height=14.155350000000013pt/> is the ratio between the number of non overlaping rotation groups the number of overlaping rotation groups between two month, 
 which is a constant of <img src="svgs/be175353a87f6fc97908fcda28d4c44a.svg?invert_in_darkmode" align=middle width=24.657765pt height=24.65759999999998pt/>.



The AK estimator can be defined as follows:
For <img src="svgs/448378a33e519f8bf89301552c0a348c.svg?invert_in_darkmode" align=middle width=44.569965pt height=21.18732pt/>, <img src="svgs/da2cc7485cb0fa1b15583647a8b5d253.svg?invert_in_darkmode" align=middle width=167.13790500000002pt height=28.897770000000005pt/>.
 
 For <img src="svgs/dfc1aff530546b0b16ab4aa699cf534f.svg?invert_in_darkmode" align=middle width=44.569965pt height=21.18732pt/>, 
<p align="center"><img src="svgs/259eea5fe1348a814aaa684477f0c14c.svg?invert_in_darkmode" align=middle width=444.96375pt height=108.49426499999998pt/></p>
 
 
    
  In the case of the CPS, the rotation group one sample unit  belongs to in a particular month  is a function
 of the number of times it has been selected before, including this month, and so the rotation group of an individual in a particular month is called the "month in sample" variable.
    
 For the CPS, in month <img src="svgs/1e277ba1ce19c790851f457314abfa6b.svg?invert_in_darkmode" align=middle width=14.433210000000003pt height=14.155350000000013pt/> the overlap <img src="svgs/fcb12e9a318990eacd858a01641ef580.svg?invert_in_darkmode" align=middle width=79.402785pt height=22.46574pt/> corresponds to the individuals in the sample <img src="svgs/6a9d394a320bc4d2ceba77eb09821eb4.svg?invert_in_darkmode" align=middle width=21.744855000000005pt height=22.46574pt/> with a value of month in sample equal to 2,3,4, 6,7 or 8.
 The overlap <img src="svgs/fcb12e9a318990eacd858a01641ef580.svg?invert_in_darkmode" align=middle width=79.402785pt height=22.46574pt/> corresponds to the individuals in the sample <img src="svgs/6a9d394a320bc4d2ceba77eb09821eb4.svg?invert_in_darkmode" align=middle width=21.744855000000005pt height=22.46574pt/> with a value of month in sample equal to 2,3,4, 6,7 or 8. as well as 
 individuals in the sample <img src="svgs/dcf2b9a28b9c3ca1536e4215e48a5629.svg?invert_in_darkmode" align=middle width=38.57139pt height=22.46574pt/> with a value of month in sample equal to 1,2,3, 5,6 or 7. 
 When parametrising the function 'AK', the choice would be `group_1=c(1:3,5:7)` and `group0=c(2:4,6:8)`.




```
CompositeRegressionEstimation::CPS_AK()
```


 The functions `AK3`, computes the linear combination directly and more efficiently. the AK estimates are linear combinations of the month in sample estimates. The function `AK3` computes the coefficient matrix <img src="svgs/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode" align=middle width=17.808285000000005pt height=22.46574pt/> from the values of <img src="svgs/53d147e7f3fe6e47ee05b88b166bd3f6.svg?invert_in_darkmode" align=middle width=12.328800000000005pt height=22.46574pt/>, <img src="svgs/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.137100000000004pt height=22.46574pt/>, <img src="svgs/1c6008f5bc971bdde74e1a5f31c04e45.svg?invert_in_darkmode" align=middle width=14.714700000000004pt height=14.155350000000013pt/>, <img src="svgs/99540970492f8b54b28407a609d84199.svg?invert_in_darkmode" align=middle width=14.714700000000004pt height=14.155350000000013pt/> and performs the matrix product <img src="svgs/5097776bc1f30a7da974ffb5596313f6.svg?invert_in_darkmode" align=middle width=52.80825pt height=22.46574pt/>.
The function 'coefAK' produces the coefficients.

The CPS Census Bureau uses different values of A and K for different variables.
For the employmed total, the values used are: <img src="svgs/aa1f7d354b356080efa3e3bb7e56e66c.svg?invert_in_darkmode" align=middle width=29.680365000000002pt height=22.46574pt/>, <img src="svgs/7c98bb40b74dbb4486fd69f3a388ce4a.svg?invert_in_darkmode" align=middle width=32.488665pt height=22.46574pt/>.
For the unemployed total, the values used are: <img src="svgs/aa1f7d354b356080efa3e3bb7e56e66c.svg?invert_in_darkmode" align=middle width=29.680365000000002pt height=22.46574pt/>, <img src="svgs/7c98bb40b74dbb4486fd69f3a388ce4a.svg?invert_in_darkmode" align=middle width=32.488665pt height=22.46574pt/>.
The functions `CPS_A_e`, `CPS_A_u`, `CPS_K_e`, `CPS_K_u`, `CPS_AK()` return these coefficients.


```r
CPS_AK()
```

```
##  a1  a2  a3  k1  k2  k3 
## 0.3 0.4 0.0 0.4 0.7 0.0
```




The matrix <img src="svgs/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode" align=middle width=17.808285000000005pt height=22.46574pt/> corresponding to the coefficients for the AK estimator for the total of employed can be obtained with:


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
Y_census_AK.e<-arrayproduct::"%.%"(Wak.e,Y[,,"e"],
           I_A=list(c=integer(0),n=c("m2"),p=c("m1","rg1")),
           I_B=list(c=integer(0),p=c("m","hrmis"),q=integer(0)))
Y_census_AK.u<-arrayproduct::"%.%"(Wak.u,Y[,,"u"],
                                   I_A=list(c=integer(0),n="m2",p=c("m1","rg1")),
                                   I_B=list(c=integer(0),p=c("m","hrmis"),q=integer(0)))
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

If we want to get the whole <img src="svgs/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode" align=middle width=17.808285000000005pt height=22.46574pt/> matrix, we can use the function
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
Y_census_AK<-arrayproduct::"%.%"(Wak,Y,I_A=list(c="ak",n=c("m2"),p=c("m1","rg1")),I_B=list(c="employmentstatus",p=c("m","hrmis"),q=integer(0)))
U_census_AK2<-Yc2[,"e"]/(Yc2[,"e"]+Yc2[,"u"])
paste0("The two differnt methods give ",if(all(abs(U_census_AK-U_census_AK)<1e-3)){"same"}else{"different"}," results");
```

```
## [1] "The two differnt methods give same results"
```



## Optimisation of the linear combinaisons of the month in sample estimates

In a model where <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/>, the design-based covariance matrix of <img src="svgs/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode" align=middle width=14.908740000000003pt height=22.46574pt/>, is known, then the optimal linear estimator could be computed.

Gauss Markov gives us the formula to compute the optimal value of <img src="svgs/84c95f91a742c9ceb460a83f9b5090bf.svg?invert_in_darkmode" align=middle width=17.808285000000005pt height=22.46574pt/> as a value of <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/>. It is given in 
["Bonnery Cheng Lahiri, An Evaluation of Design-based Properties of Different Composite Estimators"](https://arxiv.org/abs/1811.12249)


The model for the month in sample estimate vector <img src="svgs/91aac9730317276af725abd8cef04ca9.svg?invert_in_darkmode" align=middle width=13.196370000000005pt height=22.46574pt/> is 
<img src="svgs/671b47a51c4700e988e220049f5f5a3e.svg?invert_in_darkmode" align=middle width=102.49404pt height=24.65759999999998pt/>, 
where <img src="svgs/8217ed3c32a785f0b5aad4055f432ad8.svg?invert_in_darkmode" align=middle width=10.165650000000005pt height=22.831379999999992pt/> is the vector indexed by <img src="svgs/d0e755a01a41c87a5166af852bf75a2d.svg?invert_in_darkmode" align=middle width=29.393265000000003pt height=14.155350000000013pt/>: <img src="svgs/11f58870370728d1afbde825a0a4dfa7.svg?invert_in_darkmode" align=middle width=142.10542500000003pt height=24.65792999999999pt/> and <img src="svgs/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode" align=middle width=14.908740000000003pt height=22.46574pt/> is the matrix with rows indexed by <img src="svgs/6b53aba94c06975e932f98405e00fd53.svg?invert_in_darkmode" align=middle width=45.12948000000001pt height=14.155350000000013pt/> and columns indexed by <img src="svgs/d0e755a01a41c87a5166af852bf75a2d.svg?invert_in_darkmode" align=middle width=29.393265000000003pt height=14.155350000000013pt/> such that <img src="svgs/e4a077e059953faf6081dd6ba33ead56.svg?invert_in_darkmode" align=middle width=128.154675pt height=24.65759999999998pt/> if <img src="svgs/1a75153b75c9963c45b6885e90d2decf.svg?invert_in_darkmode" align=middle width=68.181135pt height=24.716340000000006pt/> and <img src="svgs/6b275a9cd6e1268e4e95549ffa1b19cd.svg?invert_in_darkmode" align=middle width=54.623250000000006pt height=24.716340000000006pt/>, <img src="svgs/29632a9bf827ce0200454dd32fc3be82.svg?invert_in_darkmode" align=middle width=8.219277000000005pt height=21.18732pt/> otherwise.

The best coefficient array <img src="svgs/5bfad3945951b5bc8adc29e86180bc7b.svg?invert_in_darkmode" align=middle width=24.543585000000004pt height=22.638659999999973pt/> is the matrix with rows indexed by <img src="svgs/d04446fc222321b6fe818ef6636afd2e.svg?invert_in_darkmode" align=middle width=51.40245000000001pt height=24.716340000000006pt/> and columns indexed by <img src="svgs/6b53aba94c06975e932f98405e00fd53.svg?invert_in_darkmode" align=middle width=45.12948000000001pt height=14.155350000000013pt/> given by:

<p align="center"><img src="svgs/4895e9a155618f0b4607a650b7786ac5.svg?invert_in_darkmode" align=middle width=402.94485pt height=19.726245pt/></p>


where the <img src="svgs/580c42d204dc080d3bd5938b427c5db9.svg?invert_in_darkmode" align=middle width=10.091400000000005pt height=26.177579999999978pt/> operator designates the Moore Penrose pseudo inversion, <img src="svgs/21fd4e8eecd6bdf1a4d3d6bd1fb8d733.svg?invert_in_darkmode" align=middle width=8.515980000000004pt height=22.46574pt/> is the
identity matrix. Here the minimisation is with respect to the order on symmetric positive definite matrices: <img src="svgs/654cec854951c205ce77578b67684e93.svg?invert_in_darkmode" align=middle width=160.04620500000001pt height=22.46574pt/> is positive. It can be shown that <img src="svgs/d223e53348ca685134544c60e4d8b904.svg?invert_in_darkmode" align=middle width=72.031905pt height=27.656969999999987pt/> in our case and that <img src="svgs/2edcd8fc671b418f91c163a1cc3064bb.svg?invert_in_darkmode" align=middle width=71.164335pt height=26.177579999999978pt/>. 
The estimator <img src="svgs/2c8919cf92358a4585c3984adc3e1a56.svg?invert_in_darkmode" align=middle width=38.561820000000004pt height=22.638659999999973pt/> is the Best Linear Unbiased Estimator under this model.


The next code provides the <img src="svgs/cbfb1b2a33b28eab8a3e59464768e810.svg?invert_in_darkmode" align=middle width=14.908740000000003pt height=22.46574pt/> and <img src="svgs/84259d0b51812feb7c1a7fd2da2722d7.svg?invert_in_darkmode" align=middle width=25.000140000000002pt height=26.177579999999978pt/> matrices:


```r
 X<-CPS_X_array(months=list(m=paste(200501:200504)),
             vars=list(y=c("e","u","n")),
             rgs=list(hrmis=paste(1:8)),1/2)
 Xplus<-CPS_Xplus_array(months=list(m=paste(200501:200504)),
             vars=list(y=c("e","u","n")),
             rgs=list(hrmis=paste(1:8)),1/2)
 arrayproduct::"%.%"(Xplus,X,
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


The estimator <img src="svgs/2c8919cf92358a4585c3984adc3e1a56.svg?invert_in_darkmode" align=middle width=38.561820000000004pt height=22.638659999999973pt/> is the Best Linear Unbiased Estimator under this model.


```r
beta= matrix(rchisq(12,1),4,3)
dimnames(beta)<-list(m=paste(200501:200504),y=c("e","u","n"))
 X<-CPS_X_array(months=list(m=paste(200501:200504)),
             vars=list(y=c("e","u","n")),
             rgs=list(hrmis=paste(1:8)))
 Xplus<-CPS_Xplus_array(months=list(m=paste(200501:200504)),
             vars=list(y=c("e","u","n")),
             rgs=list(hrmis=paste(1:8)),1/2)
 EY<-arrayproduct::"%.%"(X,beta,I_A=list(c=integer(0),n=c("m","y","hrmis"),p=c("m2","y2")),I_B=list(c=integer(0),p=c("m","y"),q=integer(0)))
 set.seed(1)
 Sigma=rWishart(1,length(EY),diag(length(EY)))
 Y<-array(mvrnorm(n = 100,mu = c(EY),Sigma = Sigma[,,1]),c(100,dim(EY)))
 dimnames(Y)<-c(list(rep=1:100),dimnames(EY))
 Sigma.A<-array(Sigma,c(dim(EY),dim(EY)))
 dimnames(Sigma.A)<-rep(dimnames(EY),2);names(dimnames(Sigma.A))[4:6]<-paste0(names(dimnames(Sigma.A))[4:6],"2")
 W<-CoeffGM.array(Sigma.A,X,Xplus)
 WY<-arrayproduct::"%.%"(W,Y,I_A=list(c=integer(0),n=c("y2","m2"),p=c("m","y","hrmis")),I_B=list(c=integer(0),p=c("m","y","hrmis"),q=c("rep")))
 DY<-arrayproduct::"%.%"(Xplus,Y,I_A=list(c=integer(0),n=c("y2","m2"),p=c("m","y","hrmis")),I_B=list(c=integer(0),p=c("m","y","hrmis"),q=c("rep")))
 plot(c(beta),c(apply(DY,1:2,var)),col="red")
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19-1.png)

```r
 plot(c(beta),c(apply(WY,1:2,var)))
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19-2.png)


#### Best AK estimator for level, change and compromise
When <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/> is known, the best linear estimate of <img src="svgs/82d4821940bb3683b4917f439e512b9d.svg?invert_in_darkmode" align=middle width=42.585675pt height=22.831379999999992pt/> is <img src="svgs/20ef8e6105aacc4a9df9bc1ae34b4fa9.svg?invert_in_darkmode" align=middle width=67.95096pt height=22.831379999999992pt/>. What is true for the Best linear estimate is not 
true for all the best linear estimate in a subclass of the linear estimates.
For example, the best coefficients A and K for month to month change may not be the best coeeficients for level of employement.
One needs to define a compromise target to define what is the optimal <img src="svgs/53d147e7f3fe6e47ee05b88b166bd3f6.svg?invert_in_darkmode" align=middle width=12.328800000000005pt height=22.46574pt/> and <img src="svgs/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.137100000000004pt height=22.46574pt/> coefficients.

The following code gives the A and K coefficient as a function of <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/> that minimise ...


```r
to be done
```

When <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/> is known, 

#### Empirical best estimators and estimation of <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/>

As <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/> is not known, the approach adopted by the Census has been for total of employed and total of unemployed separately to plugin an estimate of <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/>, and then try values of <img src="svgs/53d147e7f3fe6e47ee05b88b166bd3f6.svg?invert_in_darkmode" align=middle width=12.328800000000005pt height=22.46574pt/> and <img src="svgs/d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.137100000000004pt height=22.46574pt/> between
0 and 1 with one decimal value and take the ones tha minimize the estimated variance.

There are many issues with this approach:

* The optimisation method: 
- The optimal was chosen on a grid, so the optimal may have been missed.
- The optimal was chosen variable by variable, which is only optimal when estimates of different variables are uncorrelated, which is not the case: there is a negative relationship between unemployment, employment and not in the labor force: a sample with a high level of employed and unemployed will have a low level of not in the labor force.
* No robustness
- The estimation of <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/> was done with really strong variance stationarity assumption, which is unrealistic when one observes the evolution of the employment during the last decade.
- No study to my knowledge was done to show how good this estimation of <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/> was.
- the empirical best will be very sensitive to the values of <img src="svgs/813cd865c037c89fcdc609b25c465a05.svg?invert_in_darkmode" align=middle width=11.872245000000005pt height=22.46574pt/>.

## Modified Regression Estimators (Singh) including Regression Composite Estimator, Fuller-Rao)



The `MR` function allows to compute the general class of "modified regression" estimators  proposed by Singh, see: 
* "Singh, A.~C., Kennedy, B., and Wu, S. (2001). Regression composite estimation for the Canadian Labour Force Survey: evaluation and implementation, Survey Methodology}, 27(1):33--44."
* "Singh, A.~C., Kennedy, B., Wu, S., and Brisebois, F. (1997). Composite estimation for the Canadian Labour Force Survey. Proceedings of the Survey Research Methods Section, American
  Statistical Association}, pages 300--305."
* "Singh, A.~C. and Merkouris, P. (1995). Composite estimation by modified regression for repeated surveys. Proceedings of the Survey Research Methods Section, American Statistical Association}, pages 420--425."

Modified regression is  general approach that consists in calibrating on one or more proxies for "the previous month". Singh describes what properties the proxy variable has to follow, and proposes two diferent proxy variables (proxy 1, proxy 2), as well as using the two together. The estimator obtained with proxy 1 is called "MR1", the estimator obtained with proxy 2 is called "MR2"" and the estimator obtained with both proxy 1 and proxy 2 in the model is called MR3. "Fuller, W.~A. and Rao, J. N.~K. (2001).  A regression composite estimator with application to the Canadian Labour Force Survey, Survey Methodology}, 27(1):45--51), use an estimator in the class described by Singh that with a proxy chosen to be an affine combination of proxy 1 and proxy 2. The coefficient of the combination is denoted <img src="svgs/c745b9b57c145ec5577b82542b2df546.svg?invert_in_darkmode" align=middle width=10.576500000000003pt height=14.155350000000013pt/> and the Modified Regression estimator obtained is called by the authors Regression Composite estimator. <img src="svgs/1924b0e737a1c5c085f6e7f1b0fa4840.svg?invert_in_darkmode" align=middle width=40.71342pt height=21.18732pt/> gives MR1 and <img src="svgs/c9dbc3793c46e3142103f06476da99df.svg?invert_in_darkmode" align=middle width=40.71342pt height=21.18732pt/> gives MR2.

For  <img src="svgs/956cd791e512dfa01644376d1564b9f5.svg?invert_in_darkmode" align=middle width=63.54447pt height=24.65759999999998pt/>, the  regression composite estimator of <img src="svgs/9e4cfb65a7f38e06b6bc1ff329783f29.svg?invert_in_darkmode" align=middle width=13.015695000000004pt height=20.222069999999988pt/>  is a calibration  estimator <img src="svgs/037d128c722d5b697093ed688ba4653a.svg?invert_in_darkmode" align=middle width=75.119715pt height=28.897770000000005pt/> defined as follows:
provide calibration totals <img src="svgs/845aa45b15d6fadb66d30d7b011f0cbd.svg?invert_in_darkmode" align=middle width=59.962155pt height=27.94572000000001pt/> for the auxiliary variables (they can be equal to the true totals when known or estimated), then  define <img src="svgs/0d50084a9d74ec1dd07d1f84986a966d.svg?invert_in_darkmode" align=middle width=172.64395499999998pt height=28.897770000000005pt/>  and <img src="svgs/bcd48ccbe3dd432902443e762b7794c7.svg?invert_in_darkmode" align=middle width=98.261625pt height=31.52523pt/> if <img src="svgs/edbaa580261d974cfc9e2b536943ee21.svg?invert_in_darkmode" align=middle width=45.79905000000001pt height=22.831379999999992pt/>, 0 otherwise. 
For <img src="svgs/ddba494acdb7ba6fce5f72bfd88114c7.svg?invert_in_darkmode" align=middle width=113.45103000000002pt height=24.65759999999998pt/>,  recursively define 

<p align="center"><img src="svgs/aa7e53b4b54158a95ba8cc17a40125f8.svg?invert_in_darkmode" align=middle width=639.0879pt height=52.831515pt/></p>
where <img src="svgs/b70f471822c534fc5351f95109f16223.svg?invert_in_darkmode" align=middle width=306.03655499999996pt height=44.51171999999999pt/>.

Then the regression composite estimator of <img src="svgs/e250ee6fce46f0e5dbe7f54586d4bdf4.svg?invert_in_darkmode" align=middle width=46.096215pt height=24.65759999999998pt/> is given by <p align="center"><img src="svgs/131f25f931778b834f71e93f6ac9a675.svg?invert_in_darkmode" align=middle width=218.84609999999998pt height=38.676pt/></p>
where 
<p align="center"><img src="svgs/0ec4f7756a1f256fbac9894d09f5a967.svg?invert_in_darkmode" align=middle width=682.8145499999999pt height=49.409909999999996pt/></p>
and <img src="svgs/f2230306459e2d0fc9f23e30b1c72dea.svg?invert_in_darkmode" align=middle width=277.379355pt height=31.52523pt/> where <img src="svgs/d41cac0bf7b005c0f5503df4c721935b.svg?invert_in_darkmode" align=middle width=102.874695pt height=24.65759999999998pt/> if <img src="svgs/deced8d35d34aca6ba7d00f790906347.svg?invert_in_darkmode" align=middle width=50.911410000000004pt height=24.65759999999998pt/> and <img src="svgs/29632a9bf827ce0200454dd32fc3be82.svg?invert_in_darkmode" align=middle width=8.219277000000005pt height=21.18732pt/> otherwise.

The following code allows to compute the Regression composite estimation (MR1 corresponds to <img src="svgs/1924b0e737a1c5c085f6e7f1b0fa4840.svg?invert_in_darkmode" align=middle width=40.71342pt height=21.18732pt/>, MR2 corresponds to <img src="svgs/c9dbc3793c46e3142103f06476da99df.svg?invert_in_darkmode" align=middle width=40.71342pt height=21.18732pt/>, and MR3 to 'Singh=TRUE') In this example we compute MR1, MR2, MR3 and regression composite for <img src="svgs/81067953f2c541852133b94c7bfb1974.svg?invert_in_darkmode" align=middle width=78.156375pt height=21.18732pt/> and  <img src="svgs/6257fd1a75ed4ae92ab5e10899aa2027.svg?invert_in_darkmode" align=middle width=21.004665000000006pt height=21.18732pt/>.


```r
list.tables<-lapply(list.tables,dplyr::mutate,const=1)
YMR<-MR(list.tables,
   w="pwsswgt",
   list.xMR="employmentstatus",
   id=c("hrhhid","pulineno"),
   list.x1="const",
   Alpha=c(0,.5,.75,.95,1),
   list.y=c("employmentstatus"))$dfEst;
   UMR<-YMR[,"employmentstatus_ne",]/(YMR[,"employmentstatus_ne",]+YMR[,"employmentstatus_nu",])
   ggplot(data=reshape2::melt(cbind(Direct=U,Composite=UMR)),aes(x=as.Date(paste0(Var1,"01"),"%Y%m%d"),y=value,group=Var2,color=Var2))+geom_line()+xlab("")+ylab("")+ggtitle("Direct and Modified Regression Estimates")
```

<img src="figure/unnamed-chunk-21-1.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" width="100%" />

```r
   diffUMR<-cbind(Direct=U,Composite=UMR)[-1,]-cbind(Direct=U,Composite=UMR)[-12,]
   ggplot(data=reshape2::melt(cbind(diffUMR)),aes(x=as.Date(paste0(Var1,"01"),"%Y%m%d"),y=value,group=Var2,color=Var2))+geom_line()+xlab("")+ylab("")+ggtitle("Direct and Modified Regression estimates for month to month change")
```

<img src="figure/unnamed-chunk-21-2.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" width="100%" />
