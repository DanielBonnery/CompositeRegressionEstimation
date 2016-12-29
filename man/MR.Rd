\name{MR}
\alias{MR}
\title{Modified regression estimation}
\description{Compute Modified Regression Estimator of Singh and Composite Regression Estimator of Fuller and Rao as described in Fuller and Rao (2001) and Singh}
\usage{MR(list.tables, w,
 id,
 list.xMR,
list.x1,
list.x2,
list.y=NULL,
calibmethod="linear",
Alpha = 0.5, 
theta = 4/3,
list.dft.x2,
 dft0.xMR = NULL,
mu0 = NULL,
timee=NULL,
add.var=FALSE)}
\arguments{
  \item{list.tables}{A list of dataframes, containing variables listed in w, list.y, list.x1,list.x2.}
  \item{w}{the name of the weight variable to be used.}
  \item{id}{a character vector, that list the variables that constitute the primary key for all dataframes in \code{...}}
  \item{list.xMR}{A list of variables for which estimates of the past will be computed, according to all of the methods specified in methods.}
  \item{list.x1}{A list of variables that will be used as auxiliary variables in the modified or composite regression estimation method. For these variables, the totals used for calibration will be computed as weighted sums obtained from the former table and composite regression weights.}
  \item{list.x2}{A list of variables that will be used as auxiliary variables in the modified or composite regression estimation method. For these variables, the totals used for calibration will be given by \code{list.dft.x2}.}
  \item{list.y}{A list of variables for which total estimates will be computed.}
  \item{calibmethod}{a character string. Accepted values are: "linear", "raking", "logit", "truncated"}
  \item{Alpha}{set of alpha coefficient of Fuller and Rao (2001)}
  \item{theta}{theta coefficient of Fuller and Rao (2001)}
  \item{list.dft.x2}{List of totals used for calibration}
  \item{dft0.xMR}{if NULL, the estimates for the first dataframe are weighted sum obtained with the weight variable \code{w}.
  If not NULL, then forces the estimates for the first dataframe to be equal to the elements of dft0.xMR.}
  \item{mu0}{mu0 coefficient as described in Fuller and Rao.}
  \item{timee}{a character vector }
  \item{add.var}{a boolean, indicating if the list of tables must be
	returned after having added the weight and control variables}
}

\value{a dataframe, with all the estimators obtained for the variables of list.y, and all the dataframes given in \code{...}.
}
\author{
Daniel Bonnéry
}

\seealso{
\code{\link{ajoutevariable}}
}
\examples{
##Build dataframes
    	id1=rep(1:5,each=10)
			id2=rep(1:10,5)
			weight=1/rep(.7,50)
      group1=as.factor(rbinom(50,2,.5))
      group2=as.character(rbinom(50,2,.5))
      group3=as.factor(rbinom(50,3,.5))
      group4=as.character(rbinom(50,1,.5))
			status=as.factor(rbinom(50,1,.5))
			city=(letters[1:5])[ceiling(runif(50,0,5))]
			income=((1:50)/51)^(1/2)
      expenditure=1/3*((1:50)/51)^(1/2)+.1*rchisq(50,1)
      somevariable=rchisq(50,1)
for (i in 1:3){
	sample=rep((0:4)*10,each=7)+rep(i+(0:6),5)
  assign(paste("Pop",i,sep=""),		data.frame(id1=id1,id2=id2,weight=weight,group1=group1,group2=group2,group3=group3,group4=group4,status=status,city=city,income=income/(1+(i-1)/10),expenditure=expenditure+i,somevariable=somevariable))
	assign(paste("DFs",i,sep=""),	
		(get(paste("Pop",i,sep="")))[sample,])}
## Arguments values
w="weight";id=c("id1","id2");A=.5;K=.5;list.y=c("income","status","city")
list.x1=c("somevariable","group1","group2")
calibmethod="linear"
list.x2=c("income","group3","group4")
list.y2=setdiff(names(Pop1),c(id,w))
list.dft.x2=lapply(lapply(lapply(paste("DFs",1:3, sep=""),get),list),WS,list.y=list.x2)
list.tables=lapply(paste("DFs",1:3, sep=""),get)
argss=c(lapply(paste("DFs",1:3, sep=""),get),
			list( w=w, Alpha=c(.75,.95), id=id, list.xMR=list.y, list.x1=list.x1, list.x2=list.x2,list.y=list.y2, list.dft.x2=list.dft.x2));

## Computation of AK estimators.
MR(lapply(paste("DFs",1:3, sep=""),get),
		 w=w, Alpha=c(.75,.95),id=id, list.xMR=list.y, list.x1=list.x1, list.x2=list.x2,list.y=list.y2, list.dft.x2=list.dft.x2)
}
