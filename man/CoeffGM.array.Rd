% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/YF.R
\name{CoeffGM.array}
\alias{CoeffGM.array}
\title{Compute the Gauss Markov coefficients for Multivariate Blue}
\usage{
CoeffGM.array(Sigma, X, Xplus = NULL)
}
\arguments{
\item{Sigma}{a (p_1x...x p_P) x (p_1x...x p_P) array}

\item{X}{an  (p_1x...x p_P) x (n_1 x ...x n_N) array}

\item{Xplus:}{a general inverse of X (if NULL, it will be computed by the program by Xplus<-MASS::ginv(X2) )}
}
\value{
the coefficients matrix \eqn{W} such that $WY$ is the best unbiased linear estimator of \eqn{\beta} where \eqn{E[Y]=X\beta}
}
\description{
Compute the Gauss Markov coefficients for Multivariate Blue
}
\examples{
beta= matrix(rchisq(12,1),4,3)
dimnames(beta)<-list(m=paste(200501:200504),y=c("e","u","n"))
X<-CPS_X_array(months=list(m=paste(200501:200504)),
            vars=list(y=c("e","u","n")),
            rgs=list(hrmis=paste(1:8)))
Xplus<-CPS_Xplus_array(months=list(m=paste(200501:200504)),
            vars=list(y=c("e","u","n")),
            rgs=list(hrmis=paste(1:8)),1/2)
EY<-arrayproduct::"\%.\%"(
  X,beta,
  I_A=list(c=integer(0),n=c("m","y","hrmis"),p=c("m2","y2")),
  I_B=list(c=integer(0),p=c("m","y"),q=integer(0)))
set.seed(1)
Sigma=rWishart(1,length(EY),diag(length(EY)))
Y<-array(mvrnorm(n = 100,mu = c(EY),Sigma = Sigma[,,1]),c(100,dim(EY)))
dimnames(Y)<-c(list(rep=1:100),dimnames(EY))
Sigma.A<-array(Sigma,c(dim(EY),dim(EY)))
dimnames(Sigma.A)<-rep(dimnames(EY),2);
names(dimnames(Sigma.A))[4:6]<-paste0(names(dimnames(Sigma.A))[4:6],"2")
W<-CoeffGM.array(Sigma.A,X,Xplus)
WY<-arrayproduct::"\%.\%"(
   W,Y,
   I_A=list(c=integer(0),n=c("y2","m2"),p=c("m","y","hrmis")),
   I_B=list(c=integer(0),p=c("m","y","hrmis"),q=c("rep")))
DY<-arrayproduct::"\%.\%"(
   Xplus,Y,
   I_A=list(c=integer(0),n=c("y2","m2"),p=c("m","y","hrmis")),
   I_B=list(c=integer(0),p=c("m","y","hrmis"),q=c("rep")))
plot(c(beta),c(apply(DY,1:2,var)),col="red")
plot(c(beta),c(apply(WY,1:2,var)))
}
