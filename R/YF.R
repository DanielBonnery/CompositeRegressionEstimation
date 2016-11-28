#Sigma: an array  

CPS_X_matrix<-function(nmonth){XX<-t(matrix(rep(diag(3),8),3,24))
  X<-as.matrix(Matrix::.bdiag(lapply(1:nmonth,function(i){XX})))}
CPS_Xplus_matrix<-function(X){t(X)/8}  

CPS_X_array<-function(nmonth){
array(CPS_X_matrix(nmonth),c(nmonth,3,nmonth,8,3))}
CPS_Xplus_array<-function(X){t(X)/8}  




  
CoeffYF<-function(Sigma,nmonth=dim(Sigma)[[1]]){
  Sigg<-array(aperm(Sigma,c(3,2,1,6,5,4)),rep(nmonth*8*3,2))
  X<-CPS_X_matrix(nmonth)
  Xplus<-CPS_Xplus_matrix(X)
  M<-diag(nmonth*8*3)-X%*%Xplus
  gi<-MASS::ginv(M%*%Sigg%*%M)
  W<-Xplus%*%(diag(nmonth*8*3)-M)%*%(diag(nmonth*8*3)-Sigg%*%gi)
  return(W)}

#' Compute the coefficients for Multivariate Blue
#' 
#' @param Sigma a p x p matrix
#' @param X an n x p  matrix
#' @param Xplus: a general inverse of X
#' @return the coefficients matrix $W$ such that $WY$ is the best unbiased linear estimator of $\beta$ where $E[Y]=X\beta$
#' @examples
#' A=array(rnorm(prod(2:5)),2:5);M=a2m(A,2);dim(A);dim(M);dim(a2m(A))

CoeffYF.matrix<-function(Sigma,X,Xplus=MASS::ginv(X)){
  M<-diag(nrow(X))-X%*%Xplus
  Xplus%*%(diag(nrow(X))-M)%*%(diag(nrow(X))-Sigma%*%(MASS::ginv(M%*%Sigma%*%M)))}


CoeffYF.array<-function(Sigma,X,Xplus=NULL){
  dS=length(dimnames(Sigma))/2
  dX=length(dimnames(X))-dS
  Sigma2<-matrix(Sigma,prod(dim(Sigma)[1:dS]),prod(dim(Sigma)[1:dS]))
  X2<-matrix(X,prod(dim(Sigma)[1:dS]),prod(dim(X)[(dS+1):(dX+dS)]))
  if(is.null(Xplus)){Xplus<-MASS::ginv(X2)}
  CC<-array(CoeffYF.matrix(Sigma2,X2,Xplus),c(dim(X)[-(1:dS)],dim(Sigma)[1:dS]))
  dimnames(CC)[(dX+1):(dS+dX)]<-dimnames(Sigma)[1:dS]
  dimnames(CC)[1:dX]<-dimnames(X)[-(1:dS)]
  CC
  }

CoeffYF.tensor<-function(Sigma,X,Xplus=ginv(t2m(X))){
  CC<-array(CoeffYF.matrix(t2m(Sigma),t2m(X),Xplus))
  CC<-
  as.tensor(CC,alongA=)
  }


CoeffS2<-function(nmonth){
  XX<-t(matrix(rep(diag(3),8),3,24))
  X<-as.matrix(.bdiag(lapply(1:nmonth,function(i){XX})))
  Xplus<-t(X)/8
  W<-Xplus
  return(W)}
