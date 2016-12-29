\name{factorisedf}
\alias{factorisedf}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Transform character or factor variables into indicator variables}
\description{
For every variable named in list.y, indicators variables are created for all the values of list.y.
}
\usage{
factorisedf(df, list.y)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{df}{
a dataframe.
}
  \item{list.y}{
\code{list.y} a character vector of column names.}
}
\details{
Transform character and factor variables into indicator variables.
}
\value{
A list, containing
\item{fdf}{A dataframe with numerical variables.}
\item{nfdf}{Names of \code{fdf} columns}
%% ...
}
