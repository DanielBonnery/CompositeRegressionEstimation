#' Composite Regression Estimation simulated data
#'
#' A simulated datasets containing survey data.
#' The primary key of the data is Identifier and time
#'\itemize{
#' \item Identifier identifier
#' \item Status Employment status
#' \item Sampling.weight Sampling weight
#' \item time date
#' \item Month.in.sample indicator of month in sample rotation group
#' \item Gender Gender
#' \item Income Income
#' \item State State
#' \item Hobby Hobby
#' }
#' @format A data frame
#' @source 
# imaginary

if(FALSE){
  set.seed(1)
  CRE_data<-
  plyr::adply(0:10,1,function(i){
  rgsize<-100
    n=8*rgsize
     X<-data.frame(Identifier=i*rgsize+c(sapply(c(0:3,12:15),function(j){(j*rgsize+1):((j+1)*rgsize)})),
                Status=sample(as.factor(c("employed","unemployed","not in the labor force")),n,replace=TRUE),
                "Sampling.weight"=1,
                time=as.Date(i,"2010-01-01"),
                "Month in sample"=rep(8:1,each=rgsize),
                Gender=sample(as.factor(c("male","female")),n,replace=TRUE),
                Income=VGAM::rpareto(n,.5,.5),
                State=sample(as.factor(rownames(state.x77)),n,prob=state.x77[,"Population"],replace=TRUE),
                Hobby=sample(as.factor(c("Shopping","TV")),n,replace=TRUE))
    X$"Sampling.weight"<-sampling::calib(Xs = model.matrix(~X$State+0),d=X$"Sampling.weight",total = state.x77[,"Population"],method="linear")
    X
  })
save(CRE_data,file="data/CRE_data.rda")
}

