\name{WS}
\alias{WS}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Weighted sum}
\description{Compute a weighted sum.}
\usage{WS(list.tables, weight = 1, list.y = NULL,timee=NULL)}

\arguments{
  \item{list.tables}{ a list of 
 dataframes.
}
  \item{list.y}{
\code{list.y} is a character vector, giving a list of all variables whose sum is to be computed. All the elements in list.y 
must be variable names of the data frames of \code{list.tables}.
}
  \item{weight}{a character vector, giving the name of the weight variable of \code{df} to be used, or a numeric vector whose length equals the number of observations in all tables of \code{list.tables}, or a real number.}
\item{timee}{
\code{timee} is a character vector, of the same length than \code{...}. It is used to identify what data.frame the sums are refering to in the output.
}
}
\details{
If the names in \code{list.y} do not match the names of the variable of a dataframe, then the returned weighted sum corresponding to that weight will be 0.

}
\value{\code{WS} returns a data frame. The column timee contains the vector \code{timee} or an index from 1 to the length of \code{...}. The name of the other columns of the dataframe are the elements of \code{list.y} that correspond to 
numeric variables, plus the names of the character or factor variables in list.y augmented by a '.' and the different values of the variables. The values of the data frames are the corresponding weighted sums.
}

\author{Daniel Bonnéry}
\note{This function is called in the functions \code{WS2}, \code{AK} of the same package.}


\seealso{\code{\link{AK}}}
\examples{

df<-data.frame(weight=rep(c(.5,.2),c(2,5)), 
		income=((1:7)/8)^3,
		gender=as.factor(rep(c(0,1),c(2,5))))
WS(list(df),weight="weight",list.y=c("gender","income"))		
WS(list(df),weight=1:7)		
WS(list(df,df))

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ weighted sum }
