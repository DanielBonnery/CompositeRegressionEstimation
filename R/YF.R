#Sigma: an array  

CPS_X_matrix<-function(){}

CoeffYF<-function(Sigma,nmonth=dim(Sigma)[[1]]){
  Sigg<-array(aperm(Sigma,c(3,2,1,6,5,4)),rep(nmonth*8*3,2))
  XX<-t(matrix(rep(diag(3),8),3,24))
  X<-as.matrix(Matrix::.bdiag(lapply(1:nmonth,function(i){XX})))
  Xplus<-t(X)/8
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


CoeffYF.tensor<-function(Sigma,X,Xplus=MASS::ginv(X)){
  CoeffYF.matrix()}



CoeffS2<-function(nmonth){
  XX<-t(matrix(rep(diag(3),8),3,24))
  X<-as.matrix(.bdiag(lapply(1:nmonth,function(i){XX})))
  Xplus<-t(X)/8
  W<-Xplus
  return(W)}
