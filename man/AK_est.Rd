% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AK3.R
\name{AK_est}
\alias{AK_est}
\title{AK estimation on array of month in sample estimates}
\usage{
AK_est(
  Y,
  month = names(dimnames(Y))[1],
  group = names(dimnames(Y))[2],
  variable = names(dimnames(Y))[3],
  S,
  S_1 = S - 1,
  a,
  k,
  groups = dimnames(Y)[[group]],
  eta0 = length(groups)/length(S),
  eta1 = eta0 - 1
)
}
\arguments{
\item{Y}{an array of named dimensions with 3 dimensions: 1 for the month, 1 for the month in sample, 1 for the variable name}

\item{month}{: name of the month dimension (by default the name of the first dimension of Y names(dimnames(dim(Y)))[1])}

\item{group}{: name of the group dimenstion of Y (by default the name of the second dimension of Y names(dimnames(dim(Y)))[2])}

\item{S}{a vector of integers, subvector of 1:ngroup, to be passed to W.ak, indicating the rotation group numbers this month that were present the previous months (for CPS, c(2:4,6:8))}

\item{a}{a numeric value}

\item{k}{a numeric value}

\item{eta0}{a  numeric value to be passed to W.ak}

\item{eta1}{a  numeric value to be passed to W.ak}
}
\value{
an array
}
\description{
AK estimation on array of month in sample estimates
}
\examples{
library(dataCPS)
period=200501:200512
list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);
names(list.tables)<-period
Y<-WSrg(list.tables,weight="pwsswgt",list.y="pemlr",rg="hrmis")
dimnames(Y);
month="m";
group="mis";
variable="y";
A=W.ak(months = dimnames(Y)[[month]],
       groups = dimnames(Y)[[group]],
       S=c(2:4,6:8),
       a=.5,
       k=.5,
       eta0=4/3,
       eta1=1/3)
ngroup=dim(Y)[group];
eta1=eta0-1;
eta0=ngroup/length(S)
AK_est(Y=Y,
       month="m",
       group="mis",
       S=c(2:4,6:8),
       a=.5,
       k=.6,
       eta0=eta0,
       eta1=eta0-1) 
}
