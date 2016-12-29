\name{AK}
\alias{AK}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{AK composite estimator
%%  ~~function to do ... ~~
}
\description{Compute AK composite estimator (see \cite{})}
\usage{AK(list.tables,
w,
list.y,
id=NULL,
groupvar=NULL,
groups_1=NULL,
groups_0=NULL,
A = 0,
K = 0,
dft0.y = NULL,
timee=NULL)}
\arguments{
  \item{list.tables}{
dataframes. Those dataframes must contain the variables named by the values of  \code{list.y} and \code{w}. A table whose name is given in \code{list.tables} is supposed to correspond to one sample, and 
\code{list.tables} is supposed to be ordered "chronologically".
}
  \item{w}{The name of the weight variable to be used.}
  \item{list.y}{A character vector of variable names present in every
	table whose name is contained in \code{list.tables}} 
  \item{id}{
 \code{id} a character vector that indicates the names of the variables that constitute the primary key common to all the dataframes of \code{...}.
}
\item{groupvar}{A character string, which indicates the name of a variable in all
  dataframes that allow to identify the birth sample (the individuals
  not selected in the previous sample, the intersection sample, and the
  sample of person that will not be selected next month.}
  \item{groups_0}{a modality or a vector of modalities of groupvar that
	correspond to the person who will be in the sample next month}
  \item{groups_1}{a modality or a vector of modalities of groupvar that
	correspond to the person who were in the sample the former month.}
  \item{A}{ is the $A$ coefficient. It is a real number.}
  \item{K}{is the $K$ coefficient. It is a real number.}
  \item{dft0.y}{is a dataframe that gives the initial values for the "initial" estimates of list.y.
  The column names of \code{dft0.y} are the variable names of liste when quantitative, and the variable name plus the different values when qualitative.}
  \item{timee}{A character vector whose length equals the number of elements of \code{...}. It will be used in the output to identify the different dataframes of \code{...}}}

\details{
%%  ~~ If necessary, more details than the description above ~~
If \code{dft0.y=NULL}, then \code{dft0.y} as a weighted sum with the function \code{WS}.

If groupvar is not null, then groups_1 and groups_0 must be given.

At least one variable between id and groupvar must not be null.
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
A dataframe.
Rows correspond to different timee. The "T" variable corresponds to the element of \code{list.tables}.
The column names are the names of the variables for which AK estimates are computed. The values in the table correspond to the AK estimators.
}
\references{

Gurney, M, \& Daly, JF. 1965.
A multivariate approach to estimation in periodic sample surveys.
{ Page  257 of:} { Proceedings of the Social Statistics
  Section, American Statistical Association},  vol. 242.
}
\author{
Daniel Bonnéry
}
%\note{
%%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%}
\examples{
##Build dataframes
Pop<-data.frame(
			id1=rep(1:5,each=30),
			id2=rep(1:30,5),
			weight=1/rep(c(.5,.3,.4),each=50),
			status=as.factor(rbinom(150,1,.5)),
			city=(letters[1:5])[ceiling(runif(150,0,5))],
			income=((1:150)/159)^(1/2))

	samplei=sapply(1:8,function(i){rep((0:2)*50,each=3)+rep(i+(0:2),3)})
   for (i in 1:3){
    sample=union(samplei[,i],samplei[,i+1])
	assign(paste("DFs",i,sep=""),	
		data.frame(Pop[sample,-6],income=Pop[sample,6]/(1+(i-1)/10),
        groupvar=(is.element(sample,samplei[,max(i,i-1)]))+2*(is.element(sample,samplei[,i+1]))))}
## Arguments values
timee<-NULL
w="weight";id=c("id1","id2");list.y=c("income","status","city")
dft0.y=WS(list(Pop),list.y=list.y)
A=.5;K=.5
groupvar<-"groupvar"
groups_1=c(1,3)
groups_0=c(2,3)
list.tables<-lapply(paste("DFs",1:3, sep=""),get)

#argss=c(list.tables,			list( w=w, id=id, list.y=list.y, A=A, K=K,dft0.y=dft0.y));
## Computation of AK estimators.
AK(list.tables, w=w, id=id, list.y=list.y, A=A, K=K,dft0.y=dft0.y)
AK(list(DFs1,DFs2),w= w,id= id,list.y= list.y,A= A,K= K,dft0.y=dft0.y)
}



