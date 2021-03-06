% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/YF.R
\name{CPS_X_array}
\alias{CPS_X_array}
\title{Compute X matrix for CPS, array version}
\usage{
CPS_X_array(months, vars, rgs, alpha = 1/length(rgs[[1]]))
}
\arguments{
\item{months}{a named list with one element, this element being a character string vector}

\item{vars}{a named list with one element, this element being a character string vector}

\item{rgs}{a named list with one element, this element being a character string vector}

\item{alpha}{(default 1/length(rgs[[1]])) a numeric value}
}
\value{
an array.
}
\description{
Compute X matrix for CPS, array version
}
\examples{
X<-CPS_X_array(months=list(m=paste(200501:200504)),
            vars=list(y=c("e","u","n")),
            rgs=list(hrmis=paste(1:8)))
dimnames(X)
}
