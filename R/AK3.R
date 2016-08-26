#' Convert an array to an array of dimension 2 or 1
#' 
#' @param A An array of dimensions (a_1 x ... x a_{dim(A)})
#' @param n An integer between 0 and length(dim(A))
#' @return M the matrix of dimension (a_1 x ... x a_n) x (a_{n+1} x ... x a_{dim(A)})
#' @examples
#' A=array(rnorm(prod(2:5)),2:5);M=a2m(A,2);dim(A);dim(M);dim(a2m(A))
a2m<-function(A,n=length(dim(A))){
  p=length(dim(A))-n
  array(A,c(if(n==0){numeric(0)}else{prod(dim(A)[1:n])},if(p==0){numeric(0)}else{prod(dim(A)[(n+1):(n+p)])}))}

#' Convert  a matrix to an array 
#' 
#' @param M A matrix of dimensions (a_1 x ... x a_{dim(A)})
#' @param a A vector of integers (numeric(0) is accepted)
#' @return b A vector of integers (numeric(0) is accepted), such that prod(a)*prod(b)=prod(dim(M))
#' @examples
#' M<-matrix(1:(prod(2:5)),prod(2:3),prod(4:5));m2a(M,2:3,4:5);identical(m2a(M),M)
m2a<-function(M,a=dim(M),b=numeric(0)){
  if(prod(a)*prod(b)!=prod(dim(M))){stop("m2a: prod(a)*prod(b)!=prod(dim(M))")}
  array(M,c(a,b))}

#' Computes a matrix that is a linear combinaison of the rotation group mis estimates
#' 
#' @param X An array of dimension b_1 x ... x b_p
#' @param W An array of dimension a_1 x ... x a_n x b_1 x ... x b_p
#' @return Y the array of dimension a_1 x ... x a_n Y[i_1,...,i_n]=sum(W[i_1,...,i_n,,...,] )
#' @examples
#' W=array(1:(prod(2:5)),2:5);X=array(1:(prod(4:5)),4:5); W%.%.;try(W[,,,-1]%.%.);X%.%X; sum(X*X);X%.%t(X);sum(c(X)*c(t(X)))
#' X=array(1:(prod(4:6)),4:6); "%.%"(W,X,j=2);
#' W%.%.%.%t(X);

"%.%" <-
  function(W,X,j=NULL,k=0){
    p<-dim(X)[0:j]
    if(is.null(j)&is.null(k)){k=0;j=length(dim(X))}
    if(is.null(j)){j<-length(dim(X))-k}
    q<-dim(X)[-(0:j)]
    i<-length(dim(W))-j
    if(i<0|k<0|j<0){stop(paste0("non-conformable arguments"))}
    n<-dim(W)[0:i]
    if(prod(dim(W))!=prod(n)*prod(p)){stop(paste0("non-conformable arguments"))}
    Y<-m2a(a2m(W,i)%*%a2m(X,j),c(n,q))
    dimnames(Y)<-c(dimnames(W)[1:i],dimnames(X)[-(0:j)])
    names(dimnames(Y))<-names(dimnames(W)[1:i])
    return(Y)}


#' Computes a matrix that is a linear combinaison of the rotation group mis estimates
#' 
#' @param X An array of dimension b_1 x ... x b_p
#' @param W An array of dimension a_1 x ... x a_n x b_1 x ... x b_p
#' @return Y the array of dimension a_1 x ... x a_n Y[i_1,...,i_n]=sum(W[i_1,...,i_n,,...,] )
#' @examples
#' W=array(1:(prod(2:5)),2:5);X=array(1:(prod(4:5)),4:5); W%.%.;try(W[,,,-1]%.%.);X%.%.; sum(X*X);X%.%t(X);sum(c(X)*c(t(X)))
#' X=array(1:(prod(4:6)),4:6); "%.%"(W,X,j=2);
#' W%.%.%.%t(X);

array.prod<-function(...,j=NULL,k=0){
  "%.k%"<-function(W,X){"%.%"(W,X,j=j)}
  apply(..., 1, function(x) Reduce("%.k%", x,accumulate = FALSE))
}

"%.k1%"<-function(W,X){"%.%"(W,X,k=1)}
"%.k2%"<-function(W,X){"%.%"(W,X,k=2)}
"%.k3%"<-function(W,X){"%.%"(W,X,k=3)}

#' Computes a matrix that is a linear combinaison of the rotation group mis estimates
#' 
#' @param X An array of dimension b_1 x ... x b_p
#' @param W An array of dimension a_1 x ... x a_n x b_1 x ... x b_p
#' @return Y the array of dimension a_1 x ... x a_n Y[i_1,...,i_n]=sum(W[i_1,...,i_n,,...,] )
#' @examples
#' W=array(1:(prod(2:5)),2:5);X=array(1:(prod(4:5)),4:5); W%.%.;try(W[,,,-1]%.%.);X%.%.; sum(X*X);X%.%t(X);sum(c(X)*c(t(X)))
#' X=array(1:(prod(4:6)),4:6); "%.%"(W,X,j=2);
#' W%.%.%.%t(X);

empirical.var<-function(A,MARGIN,n){
  plyr::aaply(A,MARGIN,function(A.){m2a(var(a2m(A.,n)),dim(A.)[-(0:n)])})
}

#W %.k2% X


W.ak<-function(nmonths,ngroups,S,a,k){
  W<-array(0,c(nmonth,nmonth,ngroups))
  Sbar<-setdiff(1:ngroups,S)
  wS<-length(S)/ngroups
  wSbar<-length(Sbar)=length(S)/length(Sbar)
  w(Sbar)<-length(Sbar)
    W[1,,1]<-1
    for(i in 2:nmonth){
      W[i,,]<-W[(i-1),,]*k
      W[i,i,]<-(1-k)
      W[i,i-1,S-1]<-W[i,i-1,S-1]-k/wS
      W[i,i,S]<-W[i,i,S]+k/wS-ngroups*a/wsbar
      W[i,i,Sbar]<-W[i,i,Sbar]+ngroups*a} 
  W<-W/ngroups
  names(dimnames(W))<-c("m2","m1","mis1")
  Hmisc::label(W)<-"Coefficient matrix W[m2,m1,mis1] such that Ak estimate for month m2  is sum(W[i2,,])*Y) where Y[m1,mis1] is direct estimate on mis mis1 for emp stat i1 at month m1"
  return(W)}

W.multi.ak<-function(nmonths,ngroups,S,ak){
  n<-length(ak)
  W<-array(0,c(nmonth,n,nmonth,ngroups,n))
  for(i in 1:n){
    W[,i,,,,i]<-W.ak(nmonths,ngroups,S,ak[[i]]["a"],ak[[i]]["k"])
  }
W}

AK_est<-function(Y,S,a,k){
  Y<-as.array(Y)
  W.ak(dim(Y)[1],S,a,k) %.k2% Y}



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

#' Gives K coefficient for unemployed used by the Census
#' 
#' @return The vector c(a1=CPS_A_u(),a2=CPS_A_e(),a3=0,k1=CPS_K_u(),k2=CPS_K_e(),k3=0)
CPS_AK<-function(){c(a1=CPS_A_u(),a2=CPS_A_e(),a3=0,k1=CPS_K_u(),k2=CPS_K_e(),k3=0)}



#' Gives the variance of the AK estimators from the A,K coefficients and the variance covariance matrix of the month in sample estimates
#' 
#' @param mistotals An array of dimension  nmonth x 8 x 3. mistotals[i,j,k] is the month in sample direct estimate for month i, month in sample j rotation group, and variable k.
#' @param coeff An array of coefficients W[ak,i2,m2,i1,mis1,m1] such that AK estimate for coefficients ak, month m2 and employment status i2 is sum(W[ak,i2,m2,,,])*Y[,,]) where mistotals[i1,mis1,m1] is direct estimate on mis mis1 for emp stat i1 at month m1.
#' @param ak: an ak coefficients vector or a  list of ak coefficients.
#' @return The variance of the AK estimators from the A,K coefficients and the variance covariance matrix .
#' @examples
#' varAK3(ak=c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0), Sigma=array(drop(stats::rWishart(1,df=3*10*8,diag(3*10*8))),rep(c(10,8,3),2)))
CPS_AK_est <-
  function(mistotals,
           coeff=CPS_AK_coeff.array.fl(dim(mistotals)[1],ak,simplify=FALSE),
           ak=CPS_AK()){
    #mistotals<-WSrg(list.tables,weight="pwsswgt",list.y="pumlr")
      if(!is.list(ak)){ak<-list(ak)}
    Estimates_AK = abind::adrop(plyr::aaply(coeff, 1:3, function(m2) {sum(aperm(mistotals,3:1) * m2)},.drop=FALSE),drop=4)
    #
    dimnames(Estimates_AK)[[1]]<-if(is.null(names(ak))){sapply(ak,function(x){paste0("AK3","-",paste(x[c(1:2,4:5)],collapse=","))})}else{names(ak)}
    Hmisc::label(Estimates_AK)<-"AK estimates for coeffs ak, employment status i2, month m2." 
    return(aperm(Estimates_AK,c(1,3,2)))}

#ak: a list of vectors of size 6.
CPS_AK_coeff.array.fl<-function(nmonth,ak,simplify=TRUE,statuslabel=c("0","1","_1")){
  coeff<-plyr::laply(ak,function(x){CPS_AK_coeff.array.f(nmonth=nmonth,x,simplify=simplify,statuslabel=statuslabel)},.drop=FALSE)
  names(dimnames(coeff))[1]<-c("ak")
  if(!is.null(names(ak))){dimnames(coeff)[[1]]<-names(ak)}
  Hmisc::label(coeff)<-"Coefficient matrix W[ak,i2,m2,i1,mis1,m1] such that AK estimate for coefficients ak, month m2 and employment status i2 is sum(W[ak,i2,m2,,,])*Y[,,]) where Y[i1,mis1,m1] is direct estimate on mis mis1 for emp stat i1 at month m1"
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
  names(dimnames(coeff))<-c("i2","m2","i1","mis1","m1")
  Hmisc::label(coeff)<-"Coefficient matrix W[i2,m2,i1,mis1,m1] such that Ak estimate for month m2 and employment status i2 is sum(W[i2,m2,,,])*Y[,,]) where Y[i1,mis1,m1] is direct estimate on mis mis1 for emp stat i1 at month m1"
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
#' varAK3rat(ak=c(a1=.3,a2=.4,a3=0,k1=.4,k2=.7,k3=0), Sigma=array(drop(stats::rWishart(1,df=3*10*8,diag(3*10*8))),rep(c(10,8,3),2)))

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
    oo<-optimx(startval,
               fn=fn,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma,Scomppop=Scomppop);
    ak4to6(c(oo$p1,oo$p2,oo$p3,oo$p4))})}




bestAK3sep<-function(Sigma,
                     startval=c(0.3,0.4,0.4,0.7),
                     itnmax=100){
  oo0 <-optimx(startval[c(1,3)],fn=varAK3_n0mean2    ,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo0d<-optimx(startval[c(1,3)],fn=varAK3diff_n0mean2,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo1 <-optimx(startval[c(1,3)],fn=varAK3_n1mean2    ,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo0c<-optimx(startval[c(1,3)],
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
    oo<-optimx(startval,
               fn=fn,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma,Scomppop=Scomppop);
    ak4to6(c(oo$p1,oo$p2,oo$p3,oo$p4))})}


