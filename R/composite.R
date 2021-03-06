#' Linear Composite Estimator from overlap and non overlapping consecutive subsamples direct totals
#' @description  
#' Consider a sequence of monthly samples \eqn{(S_m)_{m\in\{1,\ldots,M\}}}. 
#' For each individual \eqn{k} of the sample \eqn{m}, one observes the employment status \eqn{Y_{k,m}} (A binary variable) of individual \eqn{k} at time \eqn{m}, and 
#' the survey weight \eqn{w_{k,m}}.
#' The following program allows to compute recursively for \eqn{m=1,\ldots,M} the Census composite estimator of the total of \eqn{Y_{.,m}} 
#' with coefficients  defined recursively as follows:
#' 
#' 
#' For \eqn{m=1}, \eqn{\hat{t}_{Y_{.,1}}=\sum_{k\in S_1}w_{k,m}Y_{k,m}}.
#' 
#' For \eqn{m\geq 2}, 
#' \deqn{\hat{t}_{Y_{.,m}}= \left[\begin{array}{c} \hat{t}_{Y_{.,m-1}}\\ \sum_{k\in S_{m}} w_{k,m} Y_{k,m}\\\sum_{k\in S_{m-1}\cap      S_{m}} w_{k,m-1} Y_{k,m-1}\\ \sum_{k\in S_{m-1}\cap      S_{m}} w_{k,m} Y_{k,m}\\\sum_{k\in S_{m}\setminus S_{m-1}} w_{k,m} Y_{k,m}\end{array}\right]^{\mathrm{T}}\times \left[\begin{array}{c}\alpha_{(-1)}\\\alpha_{0}\\\beta_{(-1)}\\\beta_0\\\gamma_0\end{array}\right]}
#' 
#' 
#' This function computes the estimators for given values of \eqn{\alpha,\beta,\gamma}.
#' 
#' An example of use of such estimate is the Census Bureau AK estimator: it is a special case of this estimator, with the values of \eqn{\alpha,\beta,\gamma} that are given as a function of two parameters A and K: 
#' \deqn{\left[\begin{array}{c}\alpha_{(-1)}\\\alpha_0\\\beta_{(-1)}\\\beta_0\\\gamma_0\end{array}\right]=\left[\begin{array}{c}K\\ 1-K\\ -4~K/3\\(4K-A)/3  \\A \end{array}\right]}
#' for more references, please refer to the function \code{CompositeRegressionEstimation::AK}.
#'
#' See  ``CPS Technical Paper (2006). Design and Methodology of the Current Population Survey. Technical Report 66, U.S. Census Bureau."
#' \deqn{ \begin{array}{clll}\hat{t}_{Y_{.,m}}=&& K&\times \hat{t}_{Y_{.,m-1}}\\&+&(1-K)&\times  \sum_{k\in S_{m}} w_{k,m} Y_{k,m}\\&+&(-4K/3)&\times\sum_{k\in S_{m-1}\cap      S_{m}} w_{k,m-1} Y_{k,m-1}\\&+&(4K-A)/3 &\times\sum_{k\in S_{m-1}\cap      S_{m}} w_{k,m} Y_{k,m}\\&+&A&\times\sum_{k\in S_{m}\setminus S_{m-1}} w_{k,m} Y_{k,m}\end{array}}
#' 
#'  
#' Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates
#' The functions \code{AK3}, and \code{WSrg} computes the linear combination directly and more efficiently.
#' 
#' For the CPS, in month \eqn{m} the overlap \eqn{S_{m-1}\cap      S_{m}} correspond to the individuals in the sample \eqn{S_m} with a value of month in sample equal to 2,3,4, 6,7 or 8.
#' The overlap \eqn{S_{m-1}\cap      S_{m}} correspond to the individuals in the sample \eqn{S_m} with a value of month in sample equal to 2,3,4, 6,7 or 8. as well as 
#' individuals in the sample \eqn{S_{m-1}} with a value of month in sample equal to 1,2,3, 5,6 or 7. 
#' When parametrising the function, the choice would be \code{group_1=c(1:3,5:7)} and \code{group0=c(2:4,6:8)}.
#' @param list.tables a list of tables
#' @param w a character string: name of the  weights variable (should be the same in all tables)
#' @param list.y a vector of variable names
#' @param id a character string: name of the identifier variable  (should be the same in all tables)
#' @param groupvar a character string: name of the  rotation group variable (should be the same in all tables)
#' @param groups_1 a character string:
#' @param groups0  if \code{groupvar} is not null, a vector of possible values for L[[groupvar]]
#' @return
#' @seealso CompositeRegressionEstimation::AK
#' @examples
#' library(dataCPS)
#' 
#' data(cps200501,cps200502,cps200503,cps200504,
#'      cps200505,package="dataCPS") 
#' list.tables<-list(cps200501,cps200502,cps200503,cps200504,
#'                   cps200505)
#' w="pwsswgt";id=c("hrhhid","pulineno");groupvar=NULL;list.y="pemlr";dft0.y=NULL;
#' groups_1=NULL;groups0=NULL;Coef=c(alpha_1=0,alpha0=1,beta_1=0,beta0=0,gamma0=0)
#' composite(list.tables,w=w,list.y="pemlr",id=id,groupvar=groupvar)
#' ##With the default choice of parameters for \code{Coef}, the composite is  equal to the direct estimator: we check
#' WS(list.tables = list.tables,weight = w,list.y = list.y)  
#' ## Example of use of a group variable. 
#' w="pwsswgt";id=NULL;groupvar="hrmis";list.y="pemlr";dft0.y=NULL;
#' groups_1=c(1:3,5:7);groups0=c(2:4,6:8);Coef=c(alpha0=1,alpha_1=0,beta_1=0,beta0=0,gamma0=0)
#' composite(list.tables,w=w,list.y="pemlr",id=id,groupvar="hrmis")  
#' 
#' ## Check we get the same results with two different methods.
#' x=expand.grid(mis=paste0(1:8),k=1:10)
#' list.tables<-plyr::llply(1:5,function(m){dplyr::mutate(x,w=1,y1=mis*10^(m-1),y2=1)})
#' Y<-WSrg(list.tables,weight="w",list.y=c("y1","y2"),rg="mis",dimname1="m")
#' 
#' alpha0=runif(1);
#' alpha_1=1-alpha0;
#' beta0=runif(1)
#' beta_1=runif(1)
#' gamma0=runif(1)
#' Coef=c(alpha_1=alpha_1,
#'                 alpha0=alpha0,
#'                 beta0=beta0,
#'                 beta_1=beta_1,
#'                 gamma0=gamma0)
#' W<-W.rec(months=dimnames(Y)$m,
#'          groups=dimnames(Y)$mis,
#'          Coef=Coef)
#' CC1<-arrayproduct::`%.%`(W,Y,list(c=character(0),n="m2",p=c("m1","rg1")),list(c=character(0),p=c("m","mis"),q="y"))
#' w="w";id=NULLgroupvar="mis";list.y=c("y1","y2");dft0.y=NULL;
#' groups_1=paste0(c(1:3,5:7));groups0=paste0(c(2:4,6:8));
#' CC2<-composite(list.tables,w=w,list.y=c("y1","y2"),groupvar="mis",groups_1=groups_1,groups0=groups0,Coef=Coef)  
#' Y[,,1];CC1[,1];CC2[,1]
#' W[1,1,];W[2,1,];sum(W[2,,])
#' 


composite <-
  function(list.tables,
           w,
           list.y,
           id=NULL,
           groupvar=NULL,
           groups_1=NULL,
           groups0=NULL,
           #Coef=c(Total_1=1,Total0=0,Totalinter0=0,Totalinter_1=0,Totaldiff_1=0),
           Coef=c(alpha_1=0,alpha0=1,beta_1=0,beta0=0,gamma0=0),
           dft0.y=NULL){
    # list.tables=list(...);
    #controls
    if(is.null(id)&is.null(groupvar)){stop("Composite: give a value for id or for groupvar")}
    #if(max(!sapply(list.tables,is.data.frame))){stop("Composite: First arguments of AK must be data frames", domain = NA)}
    #if(!is.character(id)||!is.vector(id)){stop("Composite: Argument id is not a character vector", domain = NA)}
    if(!is.character(w)||!is.vector(w)){stop("Composite: Argument w is not a character vector", domain = NA)}
    if(!is.character(list.y)||!is.vector(list.y)){stop("Composite: argument list.y is not a character vector", domain = NA)}
    for (dff in list.tables){
      if (!is.null(id)){
        if (max(!id %in% names(dff))){stop(gettextf("Composite: variable(s) %s are not in some dataframes",paste(id[!id %in% names(dff)],collapse=", ")), domain = NA)}}
      if (!(w %in% names(dff))){stop(gettextf("Composite: weight variable %s is not in dataframe",w), domain = NA)}
      if (max(!list.y %in% names(dff))){stop(gettextf("Composite: variable(s) %s are not in dataframe",paste(list.y[!list.y %in% names(dff)],collapse=", ")), domain = NA)}
      if (!is.double(as.data.frame(dff)[,w])){stop(gettextf("Composite: The weight variable %s of dataframes of ... must be a numeric variable.",w), domain = NA)}}
    
    dft.y<-dft0.y #initial total for y
    #if NA, initial computation of totals of contral variables.
    if(is.null(dft.y)){	
      dft.y<-WS(list(list.tables[[1]]),weight=w,list.y=list.y)}
    listtot.y<-vector()
    dfEstT<-dft.y
    #Loop: for every table (every T), starting from the second table
    LL<-length(list.tables)
    creegroupvar<-is.null(groupvar)  
    if(creegroupvar){
      keeps=c(w,id)}
    if(!creegroupvar){
      keeps=c(w,groupvar)}
    for (i in 2:LL){
      #WS(list.tables[i],w,list.y)
      df_1f<-factorisedf(list.tables[[i-1]],list.y);
      df0f<-factorisedf(list.tables[[i]]  ,list.y);
      df_1=data.frame((list.tables[[i-1]])[,keeps,drop=FALSE],df_1f$fdf)
      df0=data.frame((list.tables[[i]])  [,keeps,drop=FALSE],df0f$fdf)
      names(df_1)<-c(keeps,df_1f$nfdf)
      names(df0)<-c(keeps,df0f$nfdf)
      #WS(list.tables[i],w,list.y);WS(list.tables=list(df0),weight=w,df0f$nfdf);nrow(df0)
      if(creegroupvar){
        groupvar <- "groupvar"
        groups_1<-groups0 <-1
        df0<-merge(df0 ,unique("$<-"(df_1[id],groupvar,1)),by=id,all.x=TRUE)
        #WS(list.tables[i],w,list.y);WS(list.tables=list(df0),weight=w,df0f$nfdf);nrow(df0)
        df_1<-merge(df_1,unique("$<-"(df0[id],groupvar,1)),by=id,all.x=TRUE)}
      #if(!is.null(groupvar)){keeps=c(id,w,groupvar)}
      listtot.y<-union(listtot.y,union(df0f$nfdf,df_1f$nfdf))
      for(y in setdiff(listtot.y,df_1f$nfdf)){df_1[y]<-0}
      for(y in setdiff(listtot.y,df0f$nfdf)){df0[y]<-0}
      
      #computation of the composite estimator
      amettrea0<-function(matrix,listvar){
        amettrea0<-setdiff(listvar, colnames(matrix))
        zeros<-matrix(0,nrow(matrix),length(amettrea0));
        colnames(zeros)<-amettrea0
        return(cbind(matrix,zeros))}
      dft.y <-amettrea0(dft.y,listtot.y)
      dfEstT<-amettrea0(dfEstT,listtot.y)
      df_1  <-amettrea0(df_1,listtot.y)
      df0   <-amettrea0(df0,listtot.y)
      
      #TotEstimate_1     <-as.matrix(WS(list(df_1)            ,weight=w,list.y=listtot.y)[listtot.y])
      TotEstimate0      <-WS(list(df0)            ,weight=w,list.y=listtot.y)[,listtot.y]
      inter0<-is.element(df0[[groupvar]],groups0)
      inter_1<-is.element(df_1[[groupvar]],groups_1)
      TotEstimateIntert0<-WS(list(df0[inter0,]),weight=w,list.y=listtot.y)[,listtot.y]
      TotEstimateIntert_1<-WS(list(df_1[inter_1,]),weight=w,list.y=listtot.y)[,listtot.y]
      TotEstimateDiff0  <-WS(list(df0[!inter0,]),weight=w,list.y=listtot.y)[,listtot.y]
      
      dft.y<-t(cbind(dft.y[,listtot.y],TotEstimate0,TotEstimateIntert_1,TotEstimateIntert0,TotEstimateDiff0)%*%
                 Coef[c("alpha_1","alpha0","beta_1","beta0","gamma0")])
      
      colnames(dft.y)<-listtot.y
      dfEstT<-rbind(dfEstT[,listtot.y,drop=FALSE],dft.y[,listtot.y,drop=FALSE])
    }
    rownames(dfEstT)<-names(list.tables)  
    return(dfEstT)}







#' general month in sample estimates weights for recursive linear combinaison of mis estimates
#' 
#' @param months an integer, indicating number of months
#' @param nmonth an integer, indicating number of months
#' @param ngroup  a vector of character strings or numeric string
#' @param groups  a vector of character strings or numeric string
#' @param Coef a named vector of 5 numeric value 
#' @param S a vector of integers indicating the indices of the rotation group in the sample that overlap with the previous sample: groups[S] are the overlapping rotation groups
#' @param S_1 a vector of integers indicating the indices of the corresponding rotation group of S in the previous month
#' @return an array of AK coefficients  W[m2,m1,mis1] such that Ak estimate for month m2  is sum(W[y2,,])*Y) where Y[m1,mis1] is direct estimate on mis mis1 for emp stat y1 at month m1.
#' @examples
#' alpha0=runif(1);
#' alpha_1=1-alpha0;
#' beta0=runif(1)
#' beta_1=runif(1)
#' gamma0=runif(1)
#' W<-W.rec(months=1:3,
#'          groups=1:8,
#'          Coef=c(alpha_1=alpha_1,
#'                 alpha0=alpha0,
#'                 beta_1=beta_1,
#'                 beta0=beta0,
#'                 gamma0=gamma0))
#' dimnames(W) 
#' if(all(W[1,1,]==1)){"this part is fine"}else{"there is a problem"}    
#' m<-sample(2:3,1)
#' if(all(abs(W[m,m,c(1,5)]-(alpha0+gamma0))<1e-10)){"this part is fine"}else{"there is a problem"}    
#' if(all(abs(W[m,m,c(2:4,6:8)]-(alpha0+beta0))<1e-10)){"this part is fine"}else{"there is a problem"}    
#' if(all(abs(W[m,m-1,c(1:3,5:7)]-(alpha_1*W[m-1,m-1,c(1:3,5:7)]+beta_1))<1e-10)){"this part is fine"}else{"there is a problem"}    
#' if(all(abs(W[m,m-1,c(4,8)]-(alpha_1*W[m-1,m-1,c(4,8)]))<1e-10)){"this part is fine"}else{"there is a problem"}    

#' x=expand.grid(mis=paste0(1:8),k=1:10)
#' list.tables<-plyr::llply(1:5,function(m){dplyr::mutate(x,w=1,y1=strtoi(mis)*10^(m-1),y2=1)})
#' Y<-WSrg(list.tables,weight="w",list.y=c("y1","y2"),rg="mis",dimname1="m")
#' 
#' xx<-function(Coef){
#' W=W.rec(months = dimnames(Y)[["m"]],
#'         groups = dimnames(Y)[["mis"]],
#'         S=c(2:4,6:8),Coef=Coef)
#' #plyr::aaply(1:dim(W)[1],1,function(i){plyr::aaply(W[i,,],1,sum)})
#' CC1<-arrayproduct::`%.%`(W,Y,list(c=character(0),n="m2",p=c("m1","rg1")),list(c=character(0),p=c("m","mis"),q="y"))
#' w="w";id=NULL;groupvar="mis";list.y=c("y1","y2");dft0.y=NULL;
#' groups_1=paste0(c(1:3,5:7));groups0=paste0(c(2:4,6:8));
#' CC2<-composite(list.tables,w=w,list.y=c("y1","y2"),id=id,groupvar=groupvar,groups_1=groups_1,groups0=groups0,Coef=Coef)  
#' a=sample(5,1)
#' c(w=CC1[a,1],r=CC2[a,1])}
#' xx(c(alpha_1=0,alpha0=1,beta_1=0,beta0=0,gamma0=0))
#' xx(Coef=c(alpha_1=runif(1),alpha0=runif(1),beta_1=runif(1),beta0=runif(1),gamma0=runif(1)))





W.rec<-function(months,
               groups,
               S=c(2:4,6:8),
               S_1=S-1,
               Coef=c(alpha_1=0,alpha0=1,beta_1=0,beta0=0,gamma0=0)){
  nmonth<-length(months)
  ngroup<-length(groups)
  W<-array(0,c(nmonth,nmonth,ngroup))
  dimnames(W)<-list(m2=months,m1=months,rg1=groups)
  Hmisc::label(W)<-"Coefficient matrix W[m2,m1,mis1] such that Ak estimate for month m2  is sum(W[y2,,])*Y) where Y[m1,mis1] is direct estimate on mis mis1 for emp stat y1 at month m1"
  Sbar<-setdiff(1:ngroup,S)
  W[1,1,]<-1
  for(i in 2:nmonth){
    W[i,,]<-W[(i-1),,]*Coef["alpha_1"]
    W[i,i,]<-Coef["alpha0"]
    W[i,i-1,S_1]<-W[i,i-1,S_1]+Coef["beta_1"]
    W[i,i,S]<-W[i,i,S]+Coef["beta0"]
    W[i,i,Sbar]<-W[i,i,Sbar]+Coef["gamma0"]} 
  return(W)}










