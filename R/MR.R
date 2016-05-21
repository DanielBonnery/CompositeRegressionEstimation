MR <- function(list.tables,
               w,
               id,
               list.xMR,
               list.x1, #computed
               list.x2, #external
               list.y=NULL,
               calibmethod="linear",
               Alpha=.5,
               theta=3/4,
               list.dft.x2,
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
    print(i)
    weightdispi=numeric(0)
    df1f.y<-factorisedf(list.tables[[i-1]],list.xMR);
    df2f.y<-factorisedf(list.tables[[i]],list.xMR);
    df2f.x1<-factorisedf(list.tables[[i]],list.x1);
    df2f.x2<-factorisedf(list.tables[[i]],list.x2);
    df1 <- cbind((list.tables[[i-1]])[,c(id,w),drop=FALSE],df1f.y$fdf)
    df2 <- cbind((list.tables[[i]])[,c(id,w,unique(c(list.y,list.x1,list.x2,list.xMR))),drop=FALSE],
                 df2f.y$fdf[setdiff(df2f.y$nfdf,names(df))],
                 df2f.x1$fdf[setdiff(df2f.x1$nfdf,c(names(df),df2f.y$nfdf))],
                 df2f.x2$fdf[setdiff(df2f.x2$nfdf2,c(names(df),df2f.y$nfdf,df1f.y$nfdf2))])
    listtot.xMR <- union(listtot.xMR,union(df2f.y$nfdf,setdiff(list.xMR,df2f.y$aconvertir)))
    listtot.xMR<-union(listtot.xMR,union(df2f.y$nfdf,df1f.y$nfdf))
    for(y in setdiff(listtot.xMR,names(df2))){df2[,y]<-0}
    for(y in setdiff(listtot.xMR,names(df1))){df1[,y]<-0}
    listtot.x1<-df2f.x1$nfdf2
    listtot.x2<-df2f.x2$nfdf
    
    
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
    dft.x1<-WS(list(df2),list.y=listtot.x1,weight=w)#computation of totals for x1
    dft.x2=list.dft.x2[[i]] # for x2, totals are provided as an entry
    
    for(alphac in Alphac){
      print(alphac)
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
      gg<-calib(Xs=Xs,d=d,total=as.vector(dft[,list.cal2], "numeric"),q=rep(1,length(df3[,w])),
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
  return(list(dfEst=dfEstT,weightdisp=weightdisp,AAA=if(analyse){AAA}else{NULL}))}

  