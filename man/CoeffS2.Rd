% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/YF.R
\name{CoeffS2}
\alias{CoeffS2}
\title{Compute the coefficients for Direct}
\usage{
CoeffS2(nmonth)
}
\arguments{
\item{Sigma}{a p x p matrix}

\item{X}{an n x p  matrix}

\item{Xplus:}{a general inverse of X}
}
\value{
the coefficients matrix $W$ such that $WY$ is the best unbiased linear estimator of \eqn{\beta} where \eqn{E[Y]=X\beta}
}
\description{
Compute the coefficients for Direct
}
\examples{
A=array(rnorm(prod(2:5)),2:5);M=a2m(A,2);dim(A);dim(M);dim(a2m(A))
}
