#' Regression Composite estimation
#' @details 
#' The `MR` function allows to compute the general class of "modified regression" estimators  proposed by Singh, see: 
#' * "Singh, A.~C., Kennedy, B., and Wu, S. (2001). Regression composite estimation for the Canadian Labour Force Survey: evaluation and implementation, Survey Methodology}, 27(1):33--44."
#' * "Singh, A.~C., Kennedy, B., Wu, S., and Brisebois, F. (1997). Composite estimation for the Canadian Labour Force Survey. Proceedings of the Survey Research Methods Section, American Statistical Association}, pages 300--305."
#' * "Singh, A.~C. and Merkouris, P. (1995). Composite estimation by modified regression for repeated surveys. Proceedings of the Survey Research Methods Section, American Statistical Association}, pages 420--425."
#' Modified regression is  general approach that consists in calibrating on one or more proxies for "the previous month". Singh describes what properties the proxy variable has to follow, and proposes two diferent proxy variables (proxy 1, proxy 2), as well as using the two together. The estimator obtained with proxy 1 is called "MR1", the estimator obtained with proxy 2 is called "MR2"" and the estimator obtained with both proxy 1 and proxy 2 in the model is called MR3. 
#' Fuller, W.~A. and Rao, J. N.~K. (2001) " A regression composite estimator with application to the Canadian Labour Force Survey, Survey Methodology, 27(1):45--51)", use an estimator in the class described by Singh that with a proxy chosen to be an affine combination of proxy 1 and proxy 2. 
#' The coefficient of the combination is denoted \eqn{\alpha} and the Modified Regression estimator obtained is called by the authors Regression Composite estimator. 
#' \eqn{\alpha=0} gives MR1 and \eqn{\alpha=1} gives MR2.

#' For  \eqn{\alpha\in[0,1]}, the  regression composite estimator of \eqn{t_{y}}  is a calibration  estimator \eqn\left(\hat{t}^{\text{MR},\alpha}_y\right)_{m,.}} defined as follows: 
#' provide calibration totals \eqn{\left(t^{adj}_{x}\right)_{m,.}} for the auxiliary variables (they can be equal to the true totals when known or estimated), 
#' then  define \eqn{ \left(\hat{t}^{\text{MR} ,\alpha}_z\right)_{1,.}=\left(\hat{t}^{\text{Direct}}_z\right)_{1,.},}  
#' and \eqn{w_{1,{k}}^{{\text{MR}} ,\alpha}=w_{1,{k}}} if \eqn{k\in S_1}, 0 otherwise. 
#' For \eqn{m \in \{2,\ldots, M\}},  recursively define 
#' \eqn{z^\star[(\alpha)]_{m,{k},.}=\left|\begin{array}{ll}     \alpha\left(\tau_m^{-1}         \left(z_{m-1,{k},.}-z_{m,{k},.}\right) +z_{m,{k},.}\right)     +(1-\alpha)~z_{m-1,{k},.} & \text{if }k\in S_{m}\cap S_{m-1},\\ \alpha~ z_{m,{k},.} +(1-\alpha)~\left(\sum_{k\in S_{m-1}}w_{m-1,{k}}^{{\text{MR}} ,\alpha}\right)^{-1}\left(\hat{t}_y ^{\mathrm{c}}\right)_{m-1,.} & \text{if }k\in S_{m}\setminus S_{m-1},\end{array}\right.}
#' where \eqn{\tau_m=\left(\sum_{k\in S_m\cap S_{m-1}}w_{m,{k}}\right)^{-1}\sum_{k\in S_m}w_{m,{k}}}.
#' Then the regression composite estimator of \eqn{\left(t_{y}\right)_{m,.}} is given by \eqn{\left(\hat{t}^{{\text{MR}},\alpha}_y\right)_{m,.}=\sum_{k\in S_m}w^{{\text{MR}},\alpha}_{m,{k}}y_{m,{k}},}
#' where 
#' \eqn{\left(w^{{\text{MR}},\alpha}_{m,.}\right)\!=\!\arg\min\left\{\sum_{k\in U}\frac{ \left(w^\star_{k}-w_{m,{k}}\right)^2}{1(k\notin S_m)+w_{m,{k}}}\left|w^\star\in\mathbb{R}^{U},\!\!\!\begin{array}{l}\sum_{k\in S_m} w^\star_{k}{z^\star}[(\alpha)]_{m,{k},.}\!=\!\left(\hat{t}^{{\text{MR}},\alpha}_z\right)_{m-1,.}\\\sum_{k\in S_m} w^\star_{k}x_{m,{k},.}=\left(t^{adj}_{x}\right)_{m,.}\end{array}\right.\right\},}
#' and \eqn{\left(\hat{t}^{{\text{MR}},\alpha}_z\right)_{m,.}= \sum_{k\in S_m}w^{{\text{MR}},\alpha}_{m,{k}}{z^\star}[(\alpha)]_{m,{k}},} where \eqn{1(k\notin S_m)=1} if \eqn{k\notin S_m} and \eqn{0} otherwise.
#' The following code allows to compute the Regression composite estimation (MR1 corresponds to \eqn{\alpha=0}, MR2 corresponds to \eqn{\alpha=1}, and MR3 to 'Singh=TRUE') In this example we compute MR1, MR2, MR3 and regression composite for \eqn{\alpha=.5,.75,} and  \eqn{.95}.
#' @param list.tables A list of dataframes
#' @param w either a real number of a character string indicating the name of the weight variable.
#' @param id an identifier
#' @param list.y: list of variables whose weighted sum needs to be computed. It can be factor or character variables.
#' @param list.xMR list of variables used to compute proxy composite regression variable
#' @param list.x1    list of auxiliary variables used in the cablibration, whose calibrated weighted total has to be equal to initially weithed total
#' @param list.x2 id list of auxiliary variables used in the cablibration, whose calibrated weighted total has to be equal to values provided by list.dft.x2  
#' @param list.dft.x2 id list of auxiliary variables used in the cablibration, whose calibrated weighted total has to be equal to initially weithed total 
#' @param Alpha a vector of alpha values. if alpha="01", this will compute MR3
#' @param theta a numerical value
#' @param mu0 a numerical value
#' @param Singh a boolean
#' @param dispweight a boolean
#' @param analyse a boolean
#' @return a dataframe. 
#' @examples
#' MR(list.tables<-
#' plyr::dlply(CRE_data,.variables=~time),w="Sampling.weight",list.xMR="Status",id="Identifier",list.y=c("Hobby","Status","State"))$dfEst;
 

MR <- function(list.tables,
               w,
               id,
               list.xMR=NULL,
               list.x1=NULL, #computed
               list.x2=NULL, #external
               list.y=NULL,
               calibmethod="linear",
               Alpha=.75,
               theta=3/4,
               list.dft.x2=NULL,
               dft0.xMR=NULL,
               mu0=NULL,
               Singh=TRUE,
               dispweight=FALSE,
               analyse=FALSE){
  require(MASS)
  #  list.tables=list(...);
  
  amettrea0<-function(matrice,noms){
    zeros<-matrix(0,nrow(matrice),length(noms));
    colnames(zeros)<-noms
    return(cbind(matrice,zeros))}
  
  #for(alpha in Alpha){assign(paste0("dft.xMR.",alpha),0)}
  if(is.null(list.y)){list.y<-character(0)}
  WTot<-list()
  listtot.xMR <- vector()
  LL<-length(list.tables)
  dft.xMR<-dft0.xMR #initial total for xMR
  dft.y <- WS(list(list.tables[[1]]),list.y=list.y,weight=w)
  Alphac<-c(Alpha,if(Singh){"01"}else{character(0)})
  weightdisp<-array(NA,dim=c(7,length(Alphac),LL-1))
  dimnames(weightdisp)<-
    list(c("0",".25",".5",".75","1","var","mean"),
         Alphac,
         names(list.tables[-1]))
  
  dfEstT=lapply(Alphac,function(alphac){dft.y})
  names(dfEstT)<-Alphac
  if(is.null(dft0.xMR)){
    dft.xMR.init<-WS(list(list.tables[[1]]),
                     list.y=list.xMR,
                     weight=w)
    dft.xMR<-lapply(Alphac,
                    function(alphac){
                      if(alphac=="01"){
                        dft.xMR0<-dft.xMR.init;dft.xMR1<-dft.xMR.init
                        colnames(dft.xMR0)<-paste0(colnames(dft.xMR.init),".01.0")
                        colnames(dft.xMR1)<-paste0(colnames(dft.xMR.init),".01.1")
                        return(cbind(dft.xMR0,dft.xMR1))}
                      if(alphac!="01"){
                        dft.xMR<-dft.xMR.init
                        colnames(dft.xMR)<-paste0(colnames(dft.xMR.init),".",alphac)
                        return(dft.xMR)}})
    names(dft.xMR)<-Alphac}
    mu<-mu0
  
  if(analyse){AAA=list()}
  #Loop: for every table (every T), starting from the second table
  for (i in 2:LL){
    #print(i)
    weightdispi=numeric(0)
    df1f.y<-factorisedf(list.tables[[i-1]],list.xMR);
    df2f.y<-factorisedf(list.tables[[i]],list.xMR);
    df2f.x1<-factorisedf(list.tables[[i]],list.x1);
    df2f.x2<-factorisedf(list.tables[[i]],list.x2);
    df1 <- cbind((list.tables[[i-1]])[,c(id,w),drop=FALSE],df1f.y$fdf)
    df2 <- cbind((list.tables[[i]])[,c(id,w,unique(c(list.y,list.x1,list.x2,list.xMR))),drop=FALSE],
                 df2f.y$fdf[setdiff(df2f.y$nfdf,c(id,w,unique(c(list.y,list.x1,list.x2,list.xMR))))],
                 df2f.x1$fdf[setdiff(df2f.x1$nfdf,c(c(id,w,unique(c(list.y,list.x1,list.x2,list.xMR))),df2f.y$nfdf))],
                 df2f.x2$fdf[setdiff(df2f.x2$nfdf2,c(c(id,w,unique(c(list.y,list.x1,list.x2,list.xMR))),df2f.y$nfdf,df1f.y$nfdf2))])
    listtot.xMR <- union(listtot.xMR,union(df2f.y$nfdf,setdiff(list.xMR,df2f.y$aconvertir)))
    listtot.xMR<-union(listtot.xMR,union(df2f.y$nfdf,df1f.y$nfdf))
    for(y in setdiff(listtot.xMR,names(df2))){df2[,y]<-0}
    for(y in setdiff(listtot.xMR,names(df1))){df1[,y]<-0}
    listtot.x1<-df2f.x1$nfdf2
    listtot.x2<-if(is.null(list.x2)){character(0)}else{df2f.x2$nfdf}
    
    
    df1$Overlap<-1
    df<-merge(df1,df2,by=id,all.y=TRUE)
    Overlap<-!is.na(df$Overlap)
    keep=c(id)
    df[is.na(df)]<-0
    
    
    if(is.null(mu)){
      mu.init<-WS(list(df1),list.y=listtot.xMR,weight=w)/sum(df1[,w])
      mu<-lapply(Alphac,function(alphac){
        mu<-mu.init    
        mu<-amettrea0(mu,setdiff(listtot.xMR,colnames(mu)))
        colnames(mu)<-paste0(colnames(mu),".",alphac)
        return(mu)})
      names(mu)<-Alphac}    
    for (y in listtot.xMR){
      MR2<- (df[paste0(y,".y")]*(!Overlap)+
               ((1/theta*
                  (df[paste0(y,".x")]-df[paste0(y,".y")])+
                  df[paste0(y,".y")])*Overlap))
      for (alpha in Alpha){
        alphac<-as.character(alpha)
        MR1<-(mu[[alphac]][,paste0(y,".",alphac)]*!Overlap) + (df[,paste0(y,".x")]*Overlap)      
        df[,paste0(y,".",alphac)]<-(1-alpha)*MR1+alpha*MR2}
      if(Singh){
        df[paste0(y,".01.0")]<-
          mu[["01"]][,paste0(y,".01")]*!Overlap+ 
          df[,paste0(y,".x")]*Overlap
        df[paste0(y,".01.1")]<-MR2}}
    keep=c(id,outer(listtot.xMR,
                    c(Alpha,if(Singh){c("01.0","01.1")}else{character(0)}),
                    paste,sep='.'))  
    df3<-merge(df2,df[,keep],by=id)
    mu<-list()
    dft.x1<-WS(list.tables=list(df2),list.y=listtot.x1,weight=w)#computation of totals for x1
    dft.x2=list.dft.x2[[i]] # for x2, totals are provided as an entry
    
    for(alphac in Alphac){
      #print(alphac)
      dft<-cbind(dft.x1,
                 dft.x2,
                 dft.xMR[[alphac]])
      list.cal<-c(listtot.x1,listtot.x2,
                  if(alphac!="01"){paste0(listtot.xMR,".",alphac)}
                  else{outer(listtot.xMR,c(".01.0",".01.1"),paste0)})#list of names of calibration variables
      Xs<-model.matrix(as.formula(paste("~ 0 ",paste(list.cal,collapse=" + "),sep =" + ")),df3);
      list.cal2=colnames(Xs)
      #computation of calibration weights for GREG
      d<-as.vector(df3[,w], "numeric")
      dft<-amettrea0(dft,setdiff(list.cal2,colnames(dft)))
      gg<-sampling::calib(Xs=Xs,d=d,total=as.vector(dft[,list.cal2], "numeric"),q=rep(1,length(df3[,w])),
                method=c(calibmethod),description=FALSE,max_iter=500)
      W<-d*gg
      df3[,paste("W.",alphac,sep='')] <- W
      weightdispi<-cbind(weightdispi,c(quantile(gg),var=var(gg),mean=mean(gg)))
      #computation of totals with new weights
      dfEst<-WS(list(df3),list.y=list.y,weight=paste0("W.",alphac))
      dfEstMR <- dfEstT[[alphac]]
      dfEst<-amettrea0(dfEst,setdiff(colnames(dfEstMR), colnames(dfEst)))
      dfEstMR<-amettrea0(dfEstMR,setdiff( colnames(dfEst),colnames(dfEstMR)))
      dfEstT[[alphac]]<-rbind(dfEstMR,dfEst[,colnames(dfEstMR)])
      if(alphac!="01"){
        dft.xMR[[alphac]]<-WS(list(df3),list.y=listtot.xMR,                        
                              weight=paste("W.",alphac,sep=''))
        colnames(dft.xMR[[alphac]])<-
          paste(colnames(dft.xMR[[alphac]]),".",alphac,sep='')
        mu[[alphac]]<-dft.xMR[[alphac]]/sum(W)}
      if(alphac=="01"){
        dft.xMR[[alphac]]<-WS(list(df3),list.y=listtot.xMR,weight=paste("W.",alphac,sep=''))
        colnames(dft.xMR[[alphac]])<-paste0(colnames(dft.xMR[[alphac]]),".01")
        mu[[alphac]]<-dft.xMR[[alphac]]/sum(W)
        dft.xMR0<-dft.xMR[[alphac]];dft.xMR1<-dft.xMR[[alphac]]
        colnames(dft.xMR0)<-paste0(colnames(dft.xMR[[alphac]]),".0")
        colnames(dft.xMR1)<-paste0(colnames(dft.xMR[[alphac]]),".1")
        dft.xMR[[alphac]]<-cbind(dft.xMR0,dft.xMR1)}
    }
      if(analyse){AAA<-c(AAA,list(df3))}
      colnames(weightdispi)<-Alphac
      weightdisp[,,i-1]<-weightdispi
    
  }
    dfEstT<-do.call(abind::abind,c(dfEstT[Alphac],list(along=3)))
    names(dimnames(dfEstT))<-c("t","y","Alpha")
    dimnames(dfEstT)[[1]]<-names(list.tables)
    Hmisc::label(dfEstT)<-"MR(alpha) estimate for variable y at time t"
  return(list(dfEst=dfEstT,weightdisp=weightdisp,AAA=if(analyse){AAA}else{NULL}))}

  