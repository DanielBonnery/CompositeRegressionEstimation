#' Empirical variance of a collection of arrays.
#' 
#' @param A An array of dimension d_1 x ... d_p
#' @param MARGIN a vector of integers
#' @param n the array of dimension a_1 x ... x a_n Y[i_1,...,i_n]=sum(W[i_1,...,i_n,,...,] )
#' @return 
#' @examples
#' empirical.var()
empirical.var<-function(A,MARGIN,n){
  plyr::aaply(A,MARGIN,function(A.){arrayproduct::m2a(var(arrayproduct::a2m(A.,n)),dim(A.)[-(0:n)])})
}

#' general AK weights as a function of a and k parameters.
#' 
#' @param months an integer, indicating number of months
#' @param nmonth an integer, indicating number of months
#' @param ngroup  a vector of character strings or numeric string
#' @param groups  a vector of character strings or numeric string
#' @param a a numeric value
#' @param k a numeric value
#' @param S a vector of integers indicating the indices of the rotation group in the sample that overlap with the previous sample: groups[S] are the overlapping rotation groups
#' @param S_1 a vector of integers indicating the indices of the corresponding rotation group of S in the previous month
#' @param rescaled a boolean (default FALSE) indicating whether these AK coefficient are to be applied to rescaled or not rescaled month in sample weighted sums 
#' @return an array of AK coefficients  W[m2,m1,mis1] such that Ak estimate for month m2  is sum(W[y2,,])*Y) where Y[m1,mis1] is direct estimate on mis mis1 for emp stat y1 at month m1.
#' @examples
#' library(dataCPS)
#' period=200501:200512
#' list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);
#' W<-W.ak(months=1:3,groups=1:8,a=.2,k=.5);dimnames(W) 
#' W<-W.ak(months=2:4,groups=letters[1:8],a=.2,k=.5);dimnames(W);
#' Y<-WSrg(list.tables,weight="pwsswgt",list.y="pemlr",rg="hrmis")
#' dimnames(Y);month="m";group="hrmis";variable="y";
#' months = dimnames(Y)[[month]]
#' W<-W.ak(months = months,
#'      groups = dimnames(Y)[[group]],
#'      S=c(2:4,6:8),
#'      a=.5,k=.3)
#' a=.5;k=.3
#' dimnames(W)
#' W[1,1,]  #should be all 1s   
#' m<-sample(2:length(months),1)
#' m.<-sample(2:(m-1),1)
#' if(all(abs(W[m,m,c(1,5)]-(1-k+a))<1e-10)){"this part is fine"}else{"there is a problem"}    
#' if(all(abs(W[m,m,c(2:4,6:8)]-(1-k+4*k/3-a/3))<1e-10)){"this part is fine"}else{"there is a problem"}    
#' if(all(abs(W[m,m-1,c(1:3,5:7)]-(k*W[m-1,m-1,c(1:3,5:7)]-4*k/3))<1e-10)){"this part is fine"}else{"there is a problem"}    
#' if(all(abs(W[m,m-1,c(4,8)]-(k*W[m-1,m-1,c(4,8)]))<1e-10)){"this part is fine"}else{"there is a problem"}    
#' if(all(abs(W[m,m.,]-(k*W[m-1,m.,]))<1e-10)){"this part is fine"}else{"there is a problem"}    


W.ak<-function(months,
               groups=1:8,
               S=c(2:4,6:8),
               S_1=S-1,
               a,k,
               eta0=length(groups)/length(S),
               eta1=eta0-1,
               rescaled=F){
  k<-unname(k)
  a<-unname(a)
  W<-W.rec(months,
                  groups,
                  S,
                  S_1,
                  Coef=c(alpha_1 = k,
                         alpha0 = 1-k,
                         beta_1  = -k*eta0,
                         beta0  = k*eta0-a*eta1,
                         gamma0 = a))
  if(rescaled){W<-W/ngroup}
  return(W)}


#' general AK weights as a function of a and k parameters.
#' 
#' @param nmonth an integer, indicating number of months
#' @param ngroups : number of groups
#' @param S a vector of  integers indicating the indices of the rotation group in the sample
#' @param ak a list of 2-dimension vectors
#' @return an array of AK coefficients  W[m2,m1,mis1] such that Ak estimate for month m2  is sum(W[y2,,])*Y) where Y[m1,mis1] is direct estimate on mis mis1 for emp stat y1 at month m1.
#' @examples
#' W.multi.ak(months=1:3,groups=1:8,S=c(2:4,6:8),ak=list(c(a=.2,k=.5),c(a=.2,k=.4))) 
W.multi.ak<-function(months,
                     groups,
                     S,
                     S_1=S-1,
                     ak,eta0=length(groups)/length(S),eta1=eta0-1,
                     rescaled=F){
  
  W<-plyr::laply(ak,function(AK){
    W.ak(months=months,
         groups=groups,
         S=S,
         a=AK["a"],
         k=AK["k"],
         eta0=eta0,
         eta1=eta1,
         rescaled=rescaled)
  })
names(dimnames(W))[1]<-"ak"
dimnames(W)[[1]]<-if(is.null(names(ak))){1:length(ak)}else{names(ak)}
Hmisc::label(W)<-"Coefficient matrix W[ak,m2,m1,mis1] such that AK estimate for value of AK choice number ak, month m2  is sum(W[ak,y2,,])*Y) where Y[m1,mis1] is direct estimate on mis mis1 for emp stat y1 at month m1"
W}

#' AK estimation on array of month in sample estimates
#' 
#' @param Y an array of named dimensions with 3 dimensions: 1 for the month, 1 for the month in sample, 1 for the variable name 
#' @param month : name of the month dimension (by default the name of the first dimension of Y names(dimnames(dim(Y)))[1])
#' @param group : name of the group dimenstion of Y (by default the name of the second dimension of Y names(dimnames(dim(Y)))[2]) 
#' @param S a vector of integers, subvector of 1:ngroup, to be passed to W.ak, indicating the rotation group numbers this month that were present the previous months (for CPS, c(2:4,6:8))
#' @param a a numeric value
#' @param k a numeric value
#' @param eta0 a  numeric value to be passed to W.ak
#' @param eta1 a  numeric value to be passed to W.ak
#' @return an array
#' @examples
#' library(dataCPS)
#' period=200501:200512
#' list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);
#' names(list.tables)<-period
#' Y<-WSrg(list.tables,weight="pwsswgt",list.y="pemlr",rg="hrmis")
#' dimnames(Y);
#' month="m";
#' group="mis";
#' variable="y";
#' A=W.ak(months = dimnames(Y)[[month]],
#'        groups = dimnames(Y)[[group]],
#'        S=c(2:4,6:8),
#'        a=.5,
#'        k=.5,
#'        eta0=4/3,
#'        eta1=1/3)
#' ngroup=dim(Y)[group];
#' eta1=eta0-1;
#' eta0=ngroup/length(S)
#' AK_est(Y=Y,
#'        month="m",
#'        group="mis",
#'        S=c(2:4,6:8),
#'        a=.5,
#'        k=.6,
#'        eta0=eta0,
#'        eta1=eta0-1) 

AK_est<-function(Y,
                 month=names(dimnames(Y))[1],
                 group=names(dimnames(Y))[2],
                 variable=names(dimnames(Y))[3],
                 S,
                 S_1=S-1,
                 a,
                 k,
                 groups=dimnames(Y)[[group]],
                 eta0=length(groups)/length(S),
                 eta1=eta0-1){
  arrayproduct::"%.%"(
    A=W.ak(months = dimnames(Y)[[month]],
           groups = dimnames(Y)[[group]],
           S,a,k,eta0,eta1),
    B=Y,
    I_A=list(c=integer(0),n="m2",p=c("m1","rg1")),
    I_B=list(c=integer(0),p=c(month,group),q=variable),requiresameindices=F)}



#' Gives K coefficient for unemployed used by the Census
#' 
#' @return .4
CPS_K_u<-function(){.4}
#' Gives K coefficient for unemployed used by the Census
#' 
#' @return .7
CPS_K_e<-function(){.7}

#' Gives K coefficient for unemployed used by the Census
#' 
#' @return .3
CPS_A_u<-function(){.3}

#' Gives K coefficient for unemployed used by the Census
#' 
#' @return .4
CPS_A_e<-function(){.4}

#' Gives A,K coefficient for unemployed used by the Census
#' 
#' @return The vector c(a1=CPS_A_u(),a2=CPS_A_e(),a3=0,k1=CPS_K_u(),k2=CPS_K_e(),k3=0)
CPS_AK<-function(){c(a1=CPS_A_u(),a2=CPS_A_e(),a3=0,k1=CPS_K_u(),k2=CPS_K_e(),k3=0)}



#' Gives the variance of the AK estimators from the A,K coefficients and the variance covariance matrix of the month in sample estimates
#' 
#' @param Y A named array of dimension  nmonth x 3 x 8. mistotals[m,e,g] is the month in sample direct estimate for month m, month in sample  rotation group g, and variable e. \code{dimnames(y)[[month]]} must necessarily be equal to \code{dimnames(W)["ak"]} ("u","e","n" by default)
#' @param ak: an ak coefficients vector or a  list of ak coefficients.
#' @param W (optional) if already computed, the array \code{W} of coefficients W[ak,y2,m2,y1,mis1,m1] such that AK estimate for coefficients ak, month m2 and employment status y2 is sum(W[ak,y2,m2,,,])*Y[,,]) where mistotals[y1,mis1,m1] is direct estimate on mis mis1 for emp stat y1 at month m1.
#' @return The variance of the AK estimators from the A,K coefficients and the variance covariance matrix .
#' @examples
#' library(dataCPS)
#' period=200501:200512
#' list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);
#' names(list.tables)<-period
#' Y<-WSrg(list.tables,weight="pwsswgt",list.y="pemlr",rg="hrmis")
#' dimnames(Y);
#' Y<-plyr::aaply(Y,1:2,function(x){c(n=sum(x[c(1,6:8)]),u=sum(x[4:5]),e=sum(x[2:3]))})
#' names(dimnames(Y))[3]<-"y";
#' dimnames(Y)
#' month="m";
#' mis="hrmis";
#' y="y";
#' CPS_AK_est(Y,y=y,mis=mis) 
CPS_AK_est <-
  function(Y,
           month="m",
           mis="hrmis",
           y="employmentstatus",
           W=W.multi.ak(months=dimnames(Y)[[month]],
                        groups =dimnames(Y)[[mis]],
                        S = c(2:4,6:8),
                        S_1=c(1:3,5:7),
                        ak=list(u=c(a=CPS_A_u(),k=CPS_K_u()),
                                e=c(a=CPS_A_e(),k=CPS_K_e()),
                                n=c(a=0,        k=0)))){
    Y_census_AK<-arrayproduct::"%.%"(
      W,
      Y,
      I_A=list(c="ak",n=c("m2"),p=c("m1","rg1")),
      I_B=list(c=y,p=c(month,mis),q=integer(0)))
    Hmisc::label(Y_census_AK)<-"AK estimates for coeffs ak, employment status y2, month m2." 
    return(Y_census_AK)}

#' Empirical variance of a collection of arrays.
#' 
#' @param nmonth a strictly positive integer
#' @param ak, a list of numeric vectors of length 6.
#' @param simplify a boolean
#' @param statuslabel : a character vector of dimension 3 indicating the label for unemployed, employed, not in the labor force. 
#' @return 
#' @examples
#' CPS_AK_coeff.array.fl()
CPS_AK_coeff.array.fl<-function(nmonth,ak=list(c(a_1=0,a_2=0,a_3=0,k_1=0,k_2=0,k_3=0)),simplify=TRUE,
                                statuslabel=c("0","1","_1")){
  coeff<-plyr::laply(ak,function(x){CPS_AK_coeff.array.f(nmonth=nmonth,x,simplify=simplify,statuslabel=statuslabel)},.drop=FALSE)
  names(dimnames(coeff))[1]<-c("ak")
  if(!is.null(names(ak))){dimnames(coeff)[[1]]<-names(ak)}
  Hmisc::label(coeff)<-"Coefficient matrix W[ak,y2,m2,y1,mis1,m1] such that AK estimate for coefficients ak, month m2 and employment status y2 is sum(W[ak,y2,m2,,,])*Y[,,]) where Y[y1,mis1,m1] is direct estimate on mis mis1 for emp stat y1 at month m1"
return(coeff)    }
#ak: a  vector of size 6.

CPS_AK_coeff.array.f<-function(nmonth,ak,simplify=TRUE,statuslabel=c("0","1","_1")){
  coeff<-array(0,c(3,nmonth,3,8,nmonth))
  dimnames(coeff)[[1]]<-statuslabel
  dimnames(coeff)[[3]]<-statuslabel
  S<-c(2:4,6:8)
  Sbar<-c(1,5)
  for (u in 1:3){
    coeff[u,1,u,,1]<-1
    a=ak[u];k=ak[3+u];
    for(i in 2:nmonth){
      coeff[u,i,u,,]<-coeff[u,(i-1),u,,]*k
      coeff[u,i,u,,i]<-(1-k)
      coeff[u,i,u,S-1,i-1]<-coeff[u,i,u,S-1,i-1]-k*4/3
      coeff[u,i,u,S,i]<-coeff[u,i,u,S,i]+k*4/3-8*a/3
      coeff[u,i,u,Sbar,i]<-coeff[u,i,u,Sbar,i]+8*a} }
  coeff<-coeff/8
  names(dimnames(coeff))<-c("y2","m2","y1","h1","m1")
  Hmisc::label(coeff)<-"Coefficient matrix W[y2,m2,y1,h1,m1] such that Ak estimate for month m2 and employment status y2 is sum(W[y2,m2,,,])*Y[,,]) where Y[y1,mis1,m1] is direct estimate on mis mis1 for emp stat y1 at month m1"
  if(simplify){  
    coeff=array(coeff,c(nmonth*3,nmonth*8*3))
  }
  return(coeff)}




CPS_AK_diff_coeff.array.f<-function(nmonth,ak,simplify=TRUE){
  coeff<-CPS_AK_coeff.array.f(nmonth,ak,simplify=FALSE)
  coeff[,2:nmonth,,,]<-coeff[,2:nmonth,,,,drop=FALSE]-coeff[,1:(nmonth-1),,,,drop=FALSE]
  coeff<-coeff[,-1,,,,drop=FALSE]
  if(simplify){
    coeff=array(coeff,c(length(ak),(nmonth-1)*3,(nmonth-1)*8*3))
    dimnames(coeff)[1]<-list(names(ak))}
  coeff
}


#' Gives the variance of the AK estimators from the A,K coefficients and the variance covariance matrix of the month in sample estimates
#' 
#' @param ak A set of 3 A, K coefficients, of the form c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0).
#' @param Sigma An array of dimension 3 x 8 (number of rotation groups) x number of months x 3 x 8 (number of rotation groups) x number of months.
#' @return The variance of the AK estimators from the A,K coefficients and the variance covariance matrix .
#' @examples
#' varAK3(ak=c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0), Sigma=array(drop(stats::rWishart(1,df=3*10*8,diag(3*10*8))),rep(c(10,8,3),2)))
varAK3<-function(ak,Sigma){
  nmonth<-dim(Sigma)[1]
  coeff<-CPS_AK_coeff.array.f(nmonth,ak)
  XX=array(coeff%*%(array(aperm(Sigma,c(3:1,6:4)),rep(c(nmonth*8*3),2)))%*%t(coeff),rep(c(3,nmonth),2))
  dimnames(XX)<-rep(dimnames(Sigma)[c(3,1)],2)
  aperm(XX,c(2,4,1,3))}

#' Gives the variance of an array Y that is a linear transformation AX  of an array X from the coefficients of A  and Sigma=Var[X]
#' 
#' @param coeff An array of dimension a_1 x ... x a_n x b_1 x ... x b_p
#' @param Sigma An array of dimension b_1 x ... x b_p x b_1 x ... x b_p
#' @return The variance of the AK estimators from the A,K coefficients and the variance covariance matrix .
#' @examples
#'  a=c(2,4);b=c(3,10,8);A<-array(rnorm(prod(a)*prod(b)),c(a,b));
#'  dimnames(A)[1:2]<-lapply(a,function(x){letters[1:x]});names(dimnames(A))[1:2]<-c("d1","d2"); 
#'  Sigma=array(drop(stats::rWishart(1,df=prod(b),diag(prod(b)))),rep(b,2));
#'  var_lin(A,Sigma)
var_lin<-function(A,Sigma){
  p=length(dim(Sigma))/2
  n=length(dim(A))-p
  b=dim(Sigma)[1:p]
  a=dim(A)[1:n]
  V=array(array(A,c(prod(a),prod(b)))%*%array(Sigma,rep(prod(b),2))%*%t(array(A,c(prod(a),prod(b)))),c(a,a))
  dimnames(V)<-rep(dimnames(A)[1:n],2)}

#' Gives the variance of the consecutive differences of AK estimators from the A,K coefficients and the variance covariance matrix of the month in sample estimates
#' 
#' @param ak A set of 3 A, K coefficients, of the form c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0).
#' @param Sigma An array of dimension 3 x 8 (number of rotation groups) x number of months x 3 x 8 (number of rotation groups) x number of months.
#' @return The variance of the consecutive differences of the AK estimators from the A,K coefficients and the variance covariance matrix .
#' @examples
#' varAK3diff(ak=c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0), Sigma=array(drop(stats::rWishart(1,df=3*10*8,diag(3*10*8))),rep(c(10,8,3),2)))
#' add(10, 1)
varAK3diff<-function(ak,Sigma){
  nmonth<-dim(Sigma)[[1]]
  coeff<-CPS_AK_diff_coeff.array.f(nmonth,list(ak))[,,1]
  XX=array(coeff%*%(array(aperm(Sigma,c(3:1,6:4)),rep(c(nmonth*8*3),2)))%*%t(coeff),rep(c(3,nmonth),2))
  dimnames(XX)<-rep(dimnames(Sigma)[c(3,1)],2)
  aperm(XX,c(2,4,1,3))}


#' Gives the variance of the unemployment rate estimates derived from  AK estimators from the A,K coefficients and the variance covariance matrix of the month in sample estimates
#' 
#' @param ak A set of 3 A, K coefficients, of the form c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0).
#' @param Scomppop An array of dimension number of months x 3.
#' @param Sigma An array of dimension 3 x 8 (number of rotation groups) x number of months x 3 x 8 (number of rotation groups) x number of months.
#' @return The variance of the the unemployment rate estimates derived from the AK estimators from the A,K coefficients and the variance covariance matrix .
#' @examples
#' varAK3rat(ak=c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0), 
#'          Sigma=array(drop(stats::rWishart(1,df=3*10*8,diag(3*10*8))),rep(c(10,8,3),2)))

varAK3rat<-function(ak,Sigma,Scomppop,what=c(unemployed="0",employed="1")){
  nmonth<-dim(Sigma)[1]
  mati<-matrix(c(1,1,0,1),2,2)
  SM<-Scomppop[,what]
  X<-SM[,what["unemployed"]];Y<-apply(SM,1,sum)
  V<-rbind(1,-X/Y)
  sigma<-varAK3(ak,Sigma)
  VV<-sapply(1:nmonth,function(i){V[,i]%*%mati%*%sigma[i,i,what,what]%*%t(V[,i]%*%mati)})/(Y^2)
}

#' Gives the variance of the unemployment rate estimates derived from  AK estimators from the A,K coefficients and the variance covariance matrix of the month in sample estimates
#' 
#' @param ak A set of 3 A, K coefficients, of the form c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0).
#' @param Scomppop An array of dimension number of months x 3.
#' @param Sigma An array of dimension 3 x 8 (number of rotation groups) x number of months x 3 x 8 (number of rotation groups) x number of months.
#' @return The variance of the the unemployment rate estimates derived from the AK estimators from the A,K coefficients and the variance covariance matrix .
#' @examples
#' varAK3diffrat(ak=c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0), Sigma=array(drop(stats::rWishart(1,df=3*10*8,diag(3*10*8))),rep(c(10,8,3),2)))
varAK3diffrat<-function(ak,Sigma,Scomppop,what=c(unemployed="0",employed="1")){
  nmonth<-dim(Sigma)[1]
  mati<-matrix(c(1,1,0,0,0,1,0,0,0,0,1,1,0,0,0,1),4,4)
  X<-Scomppop[,what["unemployed"]];Y<-apply(Scomppop[,what],1,sum)
  V<-t(sapply(1:(nmonth-1),function(i){c(-1/Y[i],1/Y[i+1],X[i]/(Y[i]^2),-X[i+1]/(Y[i+1]^2))}))
  sigma<-aperm(varAK3(ak,Sigma)[,,what,what],c(1,3,2,4))
  VV<-sapply(1:(nmonth-1),function(i){V[i,]%*%mati%*%array(sigma[i:(i+1),,i:(i+1),],rep(4,2))%*%t(V[i,]%*%mati)})
  names(VV)<-dimnames(Sigma)[[1]][-1]
  VV
}

varAK3ratmean<-function(ak,Sigma,Scomppop){mean(varAK3rat(ak,Sigma,Scomppop))}
varAK3diffratmean<-function(ak,Sigma,Scomppop){mean(varAK3diffrat(ak,Sigma,Scomppop))}
varAK3compratmean<-function(ak,Sigma,Scomppop){varAK3diffratmean(ak,Sigma,Scomppop)+varAK3ratmean(ak,Sigma,Scomppop)}

varAK3_n0<-function(ak,Sigma){varAK3(ak,Sigma)[,,"pumlrR_n0","pumlrR_n0"]}
varAK3_n1<-function(ak,Sigma){varAK3(ak,Sigma)[,,"pumlrR_n1","pumlrR_n1"]}

varAK3diff_n0<-function(ak,Sigma){varAK3diff(ak,Sigma)[,,"pumlrR_n0","pumlrR_n0"]}

varAK3_n0mean       <-function(ak,Sigma){mean(varAK3_n0(ak,Sigma))}
varAK3_n1mean       <-function(ak,Sigma){mean(varAK3_n1(ak,Sigma))}
varAK3diff_n0mean   <-function(ak,Sigma){mean(varAK3diff_n0(ak,Sigma))}

varAK3_n0mean2    <-function(ak,Sigma){varAK3_n0mean(ak2_n0to6(ak),Sigma)}
varAK3diff_n0mean2<-function(ak,Sigma){varAK3diff_n0mean(ak2_n0to6(ak),Sigma)}
varAK3_n1mean2    <-function(ak,Sigma){varAK3_n1mean(ak2_n1to6(ak),Sigma)}
varAK3_n0mean2comp    <-function(ak,Sigma){varAK3_n0mean(ak2_n0to6(ak),Sigma)+varAK3diff_n0mean(ak2_n0to6(ak),Sigma)}


#
ak2_n0to6<-function(ak){c(ak[1],0,0,ak[2],0,0)}
ak2_n1to6<-function(ak){c(0,ak[1],0,0,ak[2],0)}

#from a vector (a1,a2,k1,k2), returns (a1,a2,0,k1,k2,0) 
ak4to6<-function(ak){c(ak[1:2],0,ak[3:4],0)}
ak6to4<-function(ak){ak[c(1,2,4,5)]}

varAK3ratmean4<-function(ak,Sigma,Scomppop){varAK3ratmean(ak4to6(ak),Sigma,Scomppop)}
varAK3diffratmean4<-function(ak,Sigma,Scomppop){varAK3diffratmean(ak4to6(ak),Sigma,Scomppop)}
varAK3compratmean4<-function(ak,Sigma,Scomppop){varAK3compratmean(ak4to6(ak),Sigma,Scomppop)}

pen<-function(x){1000000000000000*(exp(100*(x))-100*x-5000*x^2-1)}
contraint<-function(ak){sum(pen((ak-1)*(ak>1)-ak*(ak<0)))}
varAK3ratmean4contraint<-function(ak,Sigma,Scomppop){varAK3ratmean4(ak,Sigma,Scomppop)+contraint(ak)}
varAK3diffratmean4contraint<-function(ak,Sigma,Scomppop){varAK3diffratmean4(ak,Sigma,Scomppop)+contraint(ak)}
varAK3compratmean4contraint<-function(ak,Sigma,Scomppop){varAK3compratmean4(ak,Sigma,Scomppop)+contraint(ak)}


bestAK3<-function(Sigma,Scomppop,
                  startval=c(0,0,0,0),
                  itnmax=100,
                  what=list(level=varAK3ratmean4,change=varAK3diffratmean4,compromise=varAK3compratmean4)){
  lapply(what,function(fn){
    oo<-optimx::optimx(startval,
                       fn=fn,itnmax=itnmax,method="Nelder-Mead",
                       Sigma=Sigma,Scomppop=Scomppop);
    ak4to6(c(oo$p1,oo$p2,oo$p3,oo$p4))})}


bestAK3grille<-function(Sigma,Scomppop,
                        itnmax=100,
                        what=list(level=varAK3ratmean4,change=varAK3diffratmean4,compromise=varAK3compratmean4)){
  n=4
  X=seq(0,1,length=10^n+1)
  ak3all<-lapply(X,function(x){y<-floor(x*10^(1:n));y<-(y-10*c(0,y[1:(n-1)]))/10;c(y[1:2],0,y[3:4],1,0)})
  lapply(ak3all,function(ak){})
  
  lapply(what,function(fn){
    oo<-optimx::optimx(startval,
               fn=fn,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma,Scomppop=Scomppop);
    ak4to6(c(oo$p1,oo$p2,oo$p3,oo$p4))})}




bestAK3sep<-function(Sigma,
                     startval=c(0.3,0.4,0.4,0.7),
                     itnmax=100){
  oo0 <-optimx::optimx(startval[c(1,3)],fn=varAK3_n0mean2    ,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo0d<-optimx::optimx(startval[c(1,3)],fn=varAK3diff_n0mean2,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo1 <-optimx::optimx(startval[c(1,3)],fn=varAK3_n1mean2    ,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo0c<-optimx::optimx(startval[c(1,3)],
               fn=varAK3_n0mean2comp,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma);
  list(levelsep     =c(oo0$p1 ,oo1$p1,0,oo0$p2 ,oo1$p2,0),
       changesep    =c(oo0d$p1,oo1$p1,0,oo0d$p2,oo1$p2,0),
       compromisesep=c(oo0c$p1,oo1$p1,0,oo0c$p2,oo1$p2,0))
  
}


bestAK3contraint<-function(Sigma,Scomppop,
                           startval=c(0.3,0.4,0.4,0.7),
                           itnmax=100,
                           what=list(levelc=varAK3ratmean4contraint,
                                     changec=varAK3diffratmean4contraint,
                                     compromisec=varAK3compratmean4contraint)){
  lapply(what,function(fn){
    oo<-optimx::optimx(startval,
               fn=fn,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma,Scomppop=Scomppop);
    ak4to6(c(oo$p1,oo$p2,oo$p3,oo$p4))})}


