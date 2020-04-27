#' X matrix for the simple month in sample model
#'
#' @param nmonth an integer, the number of months
#' @param nvar an integer, the number of variables
#' @param nrg an integer, the number of rotation groups
#' @param alpha=1/nrg a coefficient 
#' @return a matrix. 
#' @examples
#' CPS_X_matrix(10,3,8,1/8)
CPS_X_matrix<-function(nmonth,nvar,nrg,alpha=1){
  XX<-t(matrix(rep(diag(nvar),nrg),nvar,nvar*nrg))
  X<-alpha*as.matrix(Matrix::.bdiag(lapply(1:nmonth,function(i){XX})))}

#' Compute the Moore penrose general inverse of a the X matrix for CPS
#'
#' @param nmonth an integer, the number of months
#' @param nvar an integer, the number of variables
#' @param nrg an integer, the number of rotation groups
#' @param alpha a coefficient 
#' @return a matrix. 
#' @examples
#' CPS_Xplus_matrix(10)
CPS_Xplus_matrix<-function(X){t(X)/8}  

#' Compute X matrix for CPS, array version
#'
#' @param months a named list with one element, this element being a character string vector 
#' @param vars a named list with one element, this element being a character string vector 
#' @param rgs a named list with one element, this element being a character string vector 
#' @param alpha (default 1/length(rgs[[1]])) a numeric value 
#' @return an array. 
#' @examples
#' X<-CPS_X_array(months=list(m=paste(200501:200504)),
#'             vars=list(y=c("e","u","n")),
#'             rgs=list(hrmis=paste(1:8)))
#' dimnames(X)

CPS_X_array<-function(months,vars,rgs,alpha=1/length(rgs[[1]])){
  nmonth=length(months[[1]])
  nvar=length(vars[[1]])
  nrg=length(rgs[[1]])
A<-array(CPS_X_matrix(nmonth,nvar,nrg,alpha),c(nvar,nrg,nmonth,nvar,nmonth))
dimnames(A)<-c(vars,rgs,months,vars,months)
names(dimnames(A))[4:5]<-paste0(names(dimnames(A))[4:5],2)
A}

#' Compute the Moore penrose general inverse of a the X matrix for CPS, array version
#'
#' @param months a named list with one element, this element being a character string vector 
#' @param vars a named list with one element, this element being a character string vector 
#' @param rgs a named list with one element, this element being a character string vector 
#' @param alpha a numeric value 
#' @return an array. 
#' @examples
#' X<-CPS_X_array(months=list(m=paste(200501:200504)),
#'             vars=list(y=c("e","u","n")),
#'             rgs=list(hrmis=paste(1:8)),1/2)
#' Xplus<-CPS_Xplus_array(months=list(m=paste(200501:200504)),
#'             vars=list(y=c("e","u","n")),
#'             rgs=list(hrmis=paste(1:8)),1/2)
#' arrayproduct::"%.%"(Xplus,X,
#'  I_A=list(c=integer(0),n=c("y2","m2"),p=c("y","hrmis","m")),
#'  I_B=list(c=integer(0),p=c("y","hrmis","m"),q=c("y2","m2")))       
CPS_Xplus_array<-function(months,vars,rgs,alpha=1/length(rgs[[1]])){
    (1/((alpha^2)*length(rgs[[1]])))*aperm(CPS_X_array(months,vars,rgs,alpha),c(4:5,1:3))}




#' Compute Gauss Markov coefficient for CPS, matrix version
#'
#' @param Sigma a Variance covariance array
#' @return a matrix. 
#' @examples
#' CoeffGM(var())
CoeffGM<-function(Sigma,nmonth=dim(Sigma)[[1]]){
  Sigg<-array(aperm(Sigma,c(3,2,1,6,5,4)),rep(nmonth*8*3,2))
  X<-CPS_X_matrix(nmonth)
  Xplus<-CPS_Xplus_matrix(X)
  M<-diag(nmonth*8*3)-X%*%Xplus
  gi<-MASS::ginv(M%*%Sigg%*%M)
  W<-Xplus%*%(diag(nmonth*8*3)-M)%*%(diag(nmonth*8*3)-Sigg%*%gi)
  return(W)}

#' Compute the Gauss Markov coefficients for Multivariate Blue for arrays
#' 
#' @param Sigma a p x p matrix
#' @param X an n x p  matrix
#' @param Xplus: a general inverse of X array
#' @return the coefficients matrix \eqn{W} such that \eqn{W\times Y} is the best unbiased linear estimator of \eqn{\beta} where \eqn{E[Y]=X\times\beta}
#' @examples
#' A=array(rnorm(prod(2:5)),2:5);M=a2m(A,2);dim(A);dim(M);dim(a2m(A))
CoeffGM.matrix<-function(Sigma,X,Xplus=MASS::ginv(X)){
  M<-diag(nrow(X))-X%*%Xplus
  Xplus%*%(diag(nrow(X))-M)%*%(diag(nrow(X))-Sigma%*%(MASS::ginv(M%*%Sigma%*%M)))}

#' Compute the Gauss Markov coefficients for Multivariate Blue
#' 
#' @param Sigma a (p_1x...x p_P) x (p_1x...x p_P) array
#' @param X an  (p_1x...x p_P) x (n_1 x ...x n_N) array
#' @param Xplus: a general inverse of X (if NULL, it will be computed by the program by Xplus<-MASS::ginv(X2) )
#' @return the coefficients matrix \eqn{W} such that $WY$ is the best unbiased linear estimator of \eqn{\beta} where $E[Y]=X\beta$
#' @examples
#' beta= matrix(rchisq(12,1),4,3)
#' dimnames(beta)<-list(m=paste(200501:200504),y=c("e","u","n"))
#' X<-CPS_X_array(months=list(m=paste(200501:200504)),
#'             vars=list(y=c("e","u","n")),
#'             rgs=list(hrmis=paste(1:8)))
#' Xplus<-CPS_Xplus_array(months=list(m=paste(200501:200504)),
#'             vars=list(y=c("e","u","n")),
#'             rgs=list(hrmis=paste(1:8)),1/2)
#' EY<-arrayproduct::"%.%"(
#'   X,beta,
#'   I_A=list(c=integer(0),n=c("m","y","hrmis"),p=c("m2","y2")),
#'   I_B=list(c=integer(0),p=c("m","y"),q=integer(0)))
#' set.seed(1)
#' Sigma=rWishart(1,length(EY),diag(length(EY)))
#' Y<-array(mvrnorm(n = 100,mu = c(EY),Sigma = Sigma[,,1]),c(100,dim(EY)))
#' dimnames(Y)<-c(list(rep=1:100),dimnames(EY))
#' Sigma.A<-array(Sigma,c(dim(EY),dim(EY)))
#' dimnames(Sigma.A)<-rep(dimnames(EY),2);
#' names(dimnames(Sigma.A))[4:6]<-paste0(names(dimnames(Sigma.A))[4:6],"2")
#' W<-CoeffGM.array(Sigma.A,X,Xplus)
#' WY<-arrayproduct::"%.%"(
#'    W,Y,
#'    I_A=list(c=integer(0),n=c("y2","m2"),p=c("m","y","hrmis")),
#'    I_B=list(c=integer(0),p=c("m","y","hrmis"),q=c("rep")))
#' DY<-arrayproduct::"%.%"(
#'    Xplus,Y,
#'    I_A=list(c=integer(0),n=c("y2","m2"),p=c("m","y","hrmis")),
#'    I_B=list(c=integer(0),p=c("m","y","hrmis"),q=c("rep")))
#' plot(c(beta),c(apply(DY,1:2,var)),col="red")
#' plot(c(beta),c(apply(WY,1:2,var)))

CoeffGM.array<-function(Sigma,X,Xplus=NULL){
  dS=length(dimnames(Sigma))/2
  dX=length(dimnames(X))-dS
  Sigma2<-matrix(Sigma,prod(dim(Sigma)[1:dS]),prod(dim(Sigma)[1:dS]))
  X2<-matrix(X,prod(dim(Sigma)[1:dS]),prod(dim(X)[(dS+1):(dX+dS)]))
  if(is.null(Xplus)){Xplus<-MASS::ginv(X2)}else{Xplus<-matrix(Xplus,prod(dim(X)[(dS+1):(dX+dS)]),prod(dim(Sigma)[1:dS]))}
  CC<-array(CoeffGM.matrix(Sigma2,X2,Xplus),c(dim(X)[-(1:dS)],dim(Sigma)[1:dS]))
  dimnames(CC)<-c(dimnames(X)[-(1:dS)],dimnames(Sigma)[1:dS])
  CC
  }


#' Compute the coefficients for Direct
#' 
#' @param Sigma a p x p matrix
#' @param X an n x p  matrix
#' @param Xplus: a general inverse of X
#' @return the coefficients matrix $W$ such that $WY$ is the best unbiased linear estimator of \eqn{\beta} where $E[Y]=X\beta$
#' @examples
#' A=array(rnorm(prod(2:5)),2:5);M=a2m(A,2);dim(A);dim(M);dim(a2m(A))

CoeffS2<-function(nmonth){
  XX<-t(matrix(rep(diag(3),8),3,24))
  X<-as.matrix(.bdiag(lapply(1:nmonth,function(i){XX})))
  Xplus<-t(X)/8
  W<-Xplus
  return(W)}
