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
Let $m\in\{1,\ldots,M\}$ be an index of the time, and let $S_m$ be the set of sampling units at time $m$. The samples $S_m$ are subsets of a larger population $U$.

Some repeated surveys use rotation groups and a rotation pattern.
For the CPS, each sampled household will be selected to be surveyed during 4 consecutive months,  then left alone 8 months, then
surveyed again 4 consecutive months. As a consequence, for a given month, a sampled units that month will be surveyed for the first, second, ..., or 8th and last time. This induces a partition of the sample into month-in-sample groups:
$S_m=S_{m,1}\cup S_{m,2}\cup \ldots\cup  S_{m,8}$. 


For each unit $k$ in $S_m$, usually the dataset contains:
the values $y_{m,k}$ of a variable of interest $y$ for unit $k$ and the period $m$. In particular we are interested in the case where $y_{m,k}$ is a vector of indicator values, $y_{m,k}=(y_{m,k,e})_{e\in\{"employed","unemployed","nilf"\}}$:
$y_{m,k}=(0,0,1)$ means that individual $k$ was not in the labor force at time $k$.

It also contains $w_{m,k}$ a sampling weight.



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

The direct estimator of the total is $\sum_{k\in S_m} w_{k,m} y_{k,m}$. The function `CompositeRegressionEstimation::WS` will produce
the weighted estimates $\hat{t}^{\mathrm{Direct}}_{y_{m}}=(\sum_{k\in S_m} w_{k,m} y_{k,m})_{m\in\{1,\ldots,M\}}$

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
$\alpha\sum_{k\in S_{m,g}} w_{m,k}y_{m,k}$, where $\alpha$ is an adjustment. In the CPS, the adjustment $\alpha= 8$ as there are $8$ rotation groups. Other adjustments are possible, as for example $(\sum_{k\in S_{m}})/\sum_{k\in S_{m,g}}$.

The following code  creates the array `Y` of dimension $M\times 8\times 3$ (M months, 8 rotation groups, 3 employment statuses.) where `Y[m,g,e]` is the month in sample estimate for month `m`, group `g` and status `e`.


```r
library(CompositeRegressionEstimation)
Y<-CompositeRegressionEstimation::WSrg2(list.tables,rg = "hrmis",weight="pwsswgt",y = "employmentstatus")
Umis<-plyr::aaply(Y[,,"e"],1:2,sum)/plyr::aaply(Y[,,c("e","u")],1:2,sum);
library(ggplot2);ggplot(data=reshape2::melt(Umis),aes(x=m,y=value,color=hrmis,group=hrmis))+geom_line()+
  scale_x_continuous(breaks=200501:200512,labels=month.abb)+xlab("")+ylab("")+ 
  labs(title = "Month-in-sample estimates", 
       subtitle = "Monthly employment rate, year 2005", 
       caption = "Computed from CPS public anonymized microdata.")
```

<img src="figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" width="100%" />

#### Linear combinaisons of the month-in-sample estimates

The month-in-sample estimates for each month and each rotation group can also be given in a data.frame with four variables: the month, the group, the employment status and the value of the estimate.
Such a dataframe can be obtained from `Y` using the function `reshape2::melt`


```r
print(reshape2::melt(Y[,,]))
```


|Row number |Month  |Month in sample group |Employment status |$Y$           |
|:----------|:------|:---------------------|:-----------------|:-------------|
|1          |200501 |1                     |n                 |17645785.4304 |
|2          |200502 |1                     |n                 |17526653.25   |
|3          |200503 |1                     |n                 |17905466.5322 |
|...        |...    |...                   |...               |...           |
|288        |200512 |8                     |u                 |846918.8885   |

Let $Y$ be the vector of values in the data.frame.
Elements of $Y$ can be refered to by the line number or by a combinaison of month, rotation group, and employment status, as for example : $Y_{200501,group 3,employed]$, or by a line number $\overrightarrow{Y}_\ell$.
We use $\overrightarrow{Y}$ to designate the vector and $Y$ to designate the array.

The values to estimate are the elements of the $M\times 3$-sized array $Y=(t_{y_{m,e}})_{m\in\{1,\ldots,M\},e\in\{"employed","unemployed","nilf"\}}=\sum_{k\in U} (y_{k,m,e}))_{m\in\{1,\ldots,M\},e\in\{"employed","unemployed","nilf"\}}$. We denote by $\overrightarrow{Y}$ the vectorisation of the array $Y$.

In R, the function to vectorize an array is the function `c`


```r
A<-array(1:12,c(3,2,2));c(A)
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12
```


We consider estimates of $\overrightarrow{\beta}$
of the form  $\widehat{\overrightarrow{\beta}} ={\overrightarrow{W}}\times \overrightarrow{Y}$, 
where ${\overrightarrow{W}}$ is a matrix of dimension $(\mathrm{dim}(\overrightarrow{\beta}),\mathrm{dim}(\overrightarrow{Y})$).

Which is equivalent to estimators of the form $W\times X$ where the $W$ is a $(\mathrm{dim}(Y))\times(\mathrm{dim}(X))$ matrix, where an element $W_{p,q}$ of $W$ is indexed by two vector $p$ and $q$ and of length the number of dimensions of the array $Y$ and the dimensions of the array $X$ respectively. 

The function `arrayproduct::"%.%"` of the 'arrayproduct' allows to perform the array multiplication as described above.
The package uses named arrays with names dimensions (`names(dimnames(A))` is not `NULL`).

### Recursive linear estimates

The function `CompositeRegressionEstimation::composite` 
allows to compute linear combinations of the month in sample groups of the form

$\hat{t}^{\text{Recursive}}_{y_{m,e}}=\left[\begin{array}{c}\alpha_{(-1)}\\\alpha_{0}\\\beta_{(-1)}\\\beta_0\\\gamma_0\end{array}\right]^{\mathrm{T}}\times \left[\begin{array}{c} \hat{t}^{\text{Recursive}}_{y_{.,m-1}}\\ \sum_{k\in S_{m}} w_{k,m} y_{k,m}\\\sum_{k\in S_{m-1}\cap      S_{m}} w_{k,m-1} y_{k,m-1}\\ \sum_{k\in S_{m-1}\cap      S_{m}} w_{k,m} y_{k,m}\\\sum_{k\in S_{m}\setminus S_{m-1}} w_{k,m} y_{k,m}\end{array}\right]$
This is a special case of a linear combination of the month-in-sample estimates.


Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates.
 
The following code computes a recursive estimator with parameters $\alpha_{(-1)}=\alpha_{0}=\frac{1}/2$, $\beta_{(-1)}=\beta_0=\gamma_0=0$.


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
any(abs(Uc-Uc2)>1e-3)
```

```
## [1] FALSE
```



#### AK estimator
The AK composite estimator is equivalently in ``CPS Technical Paper (2006). Design and Methodology of the Current Population Survey. Technical Report 66, U.S. Census Bureau. (2006), [section 10-11]'':

For ${m=1}$, ${\hat{t}_{y_{.,1}}=\sum_{k\in S_1}w_{k,m}y_{k,m}}$.
 
 For ${m\geq 2}$, 
 $${\hat{t}_{y_{.,m}}= (1-K) \times \left(\sum_{k\in S_{m}} w_{k,m} y_{k,m}\right)~+~K~\times~(\hat{t}_{y_{.,m-1}} + \Delta_m)~+~ A~\times\hat{\beta}_m}$$
 

where $${\Delta_m=\eta_0\times\sum_{k\in S_m\cap S_{m-1}}(w_{k,m} y_{k,m}-w_{k,m-1} y_{k,m-1})}$$
 and $${\hat{\beta}_m=\left(\sum_{k\notin S_m\cap S_{m-1}}w_{k,m} y_{k,m}\right)~-~\eta_1~\times~\left(\sum_{k\in S_m\cap S_{m-1}}w_{k,m} y_{k,m}\right)}$$
 
 For the CPS, ${\eta_0}$ is the ratio between the number of rotation groups in the sample and the number of overlaping rotation groups between two month, 
 which is a constant  ${\eta_0=4/3}$; ${\eta_1}$ is the ratio between the number of non overlaping rotation groups the number of overlaping rotation groups between two month, 
 which is a constant of ${1/3}$.



The AK estimator can be defined as follows:
For ${m=1}$, ${\hat{t}_{y_{.,1}}=\sum_{k\in S_1}w_{k,m}y_{k,m}}$.
 
 For ${m\geq 2}$, 
$$\hat{t}^{\text{AK}}_{y_{.,m}}= \left[\begin{array}{c}K\\(1-K)\\(-4K/3)\\(4K-A)/3 \\A\end{array}\right]^{\mathrm{T}}\times\left[\begin{array}{c} \hat{t}^{\text{AK}}_{y_{.,m-1}}\\ \sum_{k\in S_{m}} w_{k,m} y_{k,m}\\\sum_{k\in S_{m-1}\cap      S_{m}} w_{k,m-1} y_{k,m-1}\\ \sum_{k\in S_{m-1}\cap      S_{m}} w_{k,m} y_{k,m}\\\sum_{k\in S_{m}\setminus S_{m-1}} w_{k,m} y_{k,m}\end{array}\right]$$
 
 
    
  In the case of the CPS, the rotation group one sample unit  belongs to in a particular month  is a function
 of the number of times it has been selected before, including this month, and so the rotation group of an individual in a particular month is called the "month in sample" variable.
    
 For the CPS, in month ${m}$ the overlap ${S_{m-1}\cap S_{m}}$ corresponds to the individuals in the sample ${S_m}$ with a value of month in sample equal to 2,3,4, 6,7 or 8.
 The overlap ${S_{m-1}\cap S_{m}}$ corresponds to the individuals in the sample ${S_m}$ with a value of month in sample equal to 2,3,4, 6,7 or 8. as well as 
 individuals in the sample ${S_{m-1}}$ with a value of month in sample equal to 1,2,3, 5,6 or 7. 
 When parametrising the function 'AK', the choice would be `group_1=c(1:3,5:7)` and `group0=c(2:4,6:8)`.




```
CompositeRegressionEstimation::CPS_AK()
```


 The functions `AK3`, computes the linear combination directly and more efficiently. the AK estimates are linear combinations of the month in sample estimates. The function `AK3` computes the coefficient matrix $W$ from the values of $A$, $K$, $\eta_0$, $\eta_1$ and performs the matrix product $W\times X$.
The function 'coefAK' produces the coefficients.

The CPS Census Bureau uses different values of A and K for different variables.
For the employmed total, the values used are: $A=$, $K=$.
For the unemployed total, the values used are: $A=$, $K=$.
The functions `CPS_A_e`, `CPS_A_u`, `CPS_K_e`, `CPS_K_u`, `CPS_AK()` return these coefficients.


```r
CPS_AK()
```

```
##  a1  a2  a3  k1  k2  k3 
## 0.3 0.4 0.0 0.4 0.7 0.0
```




The matrix $W$ corresponding to the coefficients for the AK estimator for the total of employed can be obtained with:


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

If we want to get the whole $W$ matrix, we can use the function
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
any(abs(U_census_AK-U_census_AK)>1e-3)
```

```
## [1] FALSE
```



## Optimisation of the linear combinaisons of the month in sample estimates

In a model where $\Sigma$, the design-based covariance matrix of $X$, is known, then the optimal linear estimator could be computed.

Gauss Markov gives us the formula to compute the optimal value of $W$ as a value of $\Sigma$. It is given in 
["Bonnery Cheng Lahiri, An Evaluation of Design-based Properties of Different Composite Estimators"](https://arxiv.org/abs/1811.12249)


The model for the month in sample estimate vector $Y$ is 
$E[Y]=X\times \beta$, 
where $\beta$ is the vector indexed by $m,e$: $\beta_{m,e}=\sum_{k\in U}y_{k,m,e}$ and $X$ is the matrix with rows indexed by $m,g,e$ and columns indexed by $m,e$ such that $X_{m,g,e,m',e'}=1/8$ if $(m=m')$ and $(e=e')$, $0$ otherwise.

The best coefficient array $W^\star$ is the matrix with rows indexed by $(m',e')$ and columns indexed by $m,g,e$ given by:

$$W^\star=X  ^+ (X    X  ^+)  \left(I-\Sigma ((I-X    X  ^+)^+ \Sigma  (I-X    X  ^+))^+\right),$$


where the $^+$ operator designates the Moore Penrose pseudo inversion, $I$ is the
identity matrix. Here the minimisation is with respect to the order on symmetric positive definite matrices: $M_1\leq M_2 \Leftrightarrow M_2-M_1$ is positive. It can be shown that $X  ^+=X^\mathrm{T}$ in our case and that $X  ^+X =I$. 
The estimator $W^\starY$ is the Best Linear Unbiased Estimator under this model.


The next code provides the $X$ and $X^+$ matrices:


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


The estimator $W^\star Y$ is the Best Linear Unbiased Estimator under this model.


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
When $\Sigma$ is known, the best linear estimate of $A\times \beta$ is $A\times W^\star \beta$. What is true for the Best linear estimate is not 
true for all the best linear estimate in a subclass of the linear estimates.
For example, the best coefficients A and K for month to month change may not be the best coeeficients for level of employement.
One needs to define a compromise target to define what is the optimal $A$ and $K$ coefficients.

The following code gives the A and K coefficient as a function of $\Sigma$ that minimise ...


```r
to be done
```

When $\Sigma$ is known, 

#### Empirical best estimators and estimation of $\Sigma$

As $\Sigma$ is not known, the approach adopted by the Census has been for total of employed and total of unemployed separately to plugin an estimate of $\Sigma$, and then try values of $A$ and $K$ between
0 and 1 with one decimal value and take the ones tha minimize the estimated variance.

There are many issues with this approach:

* The optimisation method: 
- The optimal was chosen on a grid, so the optimal may have been missed.
- The optimal was chosen variable by variable, which is only optimal when estimates of different variables are uncorrelated, which is not the case: there is a negative relationship between unemployment, employment and not in the labor force: a sample with a high level of employed and unemployed will have a low level of not in the labor force.
* No robustness
- The estimation of $\Sigma$ was done with really strong variance stationarity assumption, which is unrealistic when one observes the evolution of the employment during the last decade.
- No study to my knowledge was done to show how good this estimation of $\Sigma$ was.
- the empirical best will be very sensitive to the values of $\Sigma$.

## Modified Regression Estimators (Singh) including Regression Composite Estimator, Fuller-Rao)



The `MR` function allows to compute the general class of "modified regression" estimators  proposed by Singh, see: 
* "Singh, A.~C., Kennedy, B., and Wu, S. (2001). Regression composite estimation for the Canadian Labour Force Survey: evaluation and implementation, Survey Methodology}, 27(1):33--44."
* "Singh, A.~C., Kennedy, B., Wu, S., and Brisebois, F. (1997). Composite estimation for the Canadian Labour Force Survey. Proceedings of the Survey Research Methods Section, American
  Statistical Association}, pages 300--305."
* "Singh, A.~C. and Merkouris, P. (1995). Composite estimation by modified regression for repeated surveys. Proceedings of the Survey Research Methods Section, American Statistical Association}, pages 420--425."

Modified regression is  general approach that consists in calibrating on one or more proxies for "the previous month". Singh describes what properties the proxy variable has to follow, and proposes two diferent proxy variables (proxy 1, proxy 2), as well as using the two together. The estimator obtained with proxy 1 is called "MR1", the estimator obtained with proxy 2 is called "MR2"" and the estimator obtained with both proxy 1 and proxy 2 in the model is called MR3. "Fuller, W.~A. and Rao, J. N.~K. (2001).  A regression composite estimator with application to the Canadian Labour Force Survey, Survey Methodology}, 27(1):45--51), use an estimator in the class described by Singh that with a proxy chosen to be an affine combination of proxy 1 and proxy 2. The coefficient of the combination is denoted $\alpha$ and the Modified Regression estimator obtained is called by the authors Regression Composite estimator. $\alpha=0$ gives MR1 and $\alpha=1$ gives MR2.

For  $\alpha\in[0,1]$, the  regression composite estimator of $t_{y}$  is a calibration  estimator $\left(\hat{t}^{\text{MR},\alpha}_y\right)_{m,.}$ defined as follows:
provide calibration totals $\left(t^{adj}_{x}\right)_{m,.}$ for the auxiliary variables (they can be equal to the true totals when known or estimated), then  define $ \left(\hat{t}^{\text{MR} ,\alpha}_z\right)_{1,.}=\left(\hat{t}^{\text{Direct}}_z\right)_{1,.},$  and $w_{1,{k}}^{{\text{MR}} ,\alpha}=w_{1,{k}}$ if $k\in S_1$, 0 otherwise. 
For $m \in \{2,\ldots, M\}$,  recursively define 

$$z^\star[(\alpha)]_{m,{k},.}=
  \left|\begin{array}{ll}
     \alpha\left(\tau_m^{-1}
          \left(z_{m-1,{k},.}-z_{m,{k},.}\right) +z_{m,{k},.}\right)
     +(1-\alpha)~z_{m-1,{k},.} & \text{if }k\in S_{m}\cap S_{m-1},\\
 \alpha~ z_{m,{k},.}
 +(1-\alpha)~\left(\sum_{k\in S_{m-1}}w_{m-1,{k}}^{{\text{MR}} ,\alpha}\right)^{-1}
\left(\hat{t}_y ^{\mathrm{c}}\right)_{m-1,.} & \text{if }k\in S_{m}\setminus S_{m-1},
\end{array}\right.$$
where $\tau_m=\left(\sum_{k\in S_m\cap S_{m-1}}w_{m,{k}}\right)^{-1}\sum_{k\in S_m}w_{m,{k}}$.

Then the regression composite estimator of $\left(t_{y}\right)_{m,.}$ is given by $$\left(\hat{t}^{{\text{MR}},\alpha}_y\right)_{m,.}=
\sum_{k\in S_m}w^{{\text{MR}},\alpha}_{m,{k}}y_{m,{k}},$$
where 
$$\left(w^{{\text{MR}},\alpha}_{m,.}\right)\!=\!\arg\min\left\{\sum_{k\in U}\frac{ \left(w^\star_{k}-w_{m,{k}}\right)^2}{1(k\notin S_m)+w_{m,{k}}}\left|
w^\star\in\mathbb{R}^{U},\!\!\!
\begin{array}{l}\sum_{k\in S_m} w^\star_{k}{z^\star}[(\alpha)]_{m,{k},.}\!=\!\left(\hat{t}^{{\text{MR}},\alpha}_z\right)_{m-1,.}\\
\sum_{k\in S_m} w^\star_{k}x_{m,{k},.}=\left(t^{adj}_{x}\right)_{m,.}
\end{array}
\right.\right\},$$
and $\left(\hat{t}^{{\text{MR}},\alpha}_z\right)_{m,.}= \sum_{k\in S_m}w^{{\text{MR}},\alpha}_{m,{k}}{z^\star}[(\alpha)]_{m,{k}},$ where $1(k\notin S_m)=1$ if $k\notin S_m$ and $0$ otherwise.

The following code allows to compute the Regression composite estimation (MR1 corresponds to $\alpha=0$, MR2 corresponds to $\alpha=1$, and MR3 to 'Singh=TRUE') In this example we compute MR1, MR2, MR3 and regression composite for $\alpha=.5,.75,$ and  $.95$.


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
   ggplot(data=reshape2::melt(cbind(diffUMR)),aes(x=as.Date(paste0(Var1,"01"),"%Y%m%d"),y=value,group=Var2,color=Var2))+geom_line()+xlab("")+ylab("")+ggtitle("Direct and MOdified REgression estimates for month to month change")
```

<img src="figure/unnamed-chunk-21-2.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" width="100%" />
