% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/WSrg.R
\name{WSrg}
\alias{WSrg}
\title{Weighted sums by rotation groups}
\usage{
WSrg(
  list.tables,
  weight = 1,
  list.y = NULL,
  rg = "hrmis",
  rescale = F,
  dimname1 = "m"
)
}
\arguments{
\item{list.tables}{a named list of data frames}

\item{weight}{a character string  indicating the variable name or a numerical value}

\item{list.y}{a vector of character strings indicating the study variables}

\item{rg}{a character string indicating the name of the rotation group.}
}
\value{
an array
}
\description{
Weighted sums by rotation groups
}
\examples{
library(dataCPS)
period<-200501:200512
list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);
names(list.tables)<-period
Y<-WSrg(list.tables,"pwsswgt",list.y="pemlr",rg="hrmis")
dimnames(Y);dim(Y)
Y<-plyr::daply(plyr::ldply(list.tables,function(L){L[c("pemlr","pwsswgt","hrmis")]},.id="m"),
~m+pemlr+hrmis,function(d){data.frame(y=sum(d$pwsswgt))})[names(list.tables),,]
dimnames(Y);dim(Y)
system.time(plyr::daply(plyr::ldply(list.tables,,function(L){L[c("pemlr","pwsswgt","hrmis")]}),
~.id+pemlr+hrmis,function(d){data.frame(y=sum(d$pwsswgt))}))
system.time(WSrg(list.tables,weight="pwsswgt",list.y="pemlr",rg="hrmis"))
}
