BCL <- function(list.tables,
                w,
                id,
                list.xBCL,
                list.x1, #computed
                list.x2, #external
                list.y=NULL,
                calibmethod="linear",
                list.dft.x2,
                dft0.xBCL=NULL,
                mu0=NULL,
                analyse=FALSE){
  require(MASS)
  #  list.tables=list(...);
  if(FALSE){
  list.xBCL="pumlrR"
  dft0.xBCL=NULL
  w="pwsswgt"
  mu0=NULL
  analyse=FALSE
  list.x1=NULL
  list.x2=NULL
  id=c("hrlongid","pulineno")
  list.dft.x2<-NULL
  calibmethod="linear"}
  
  amettrea0<-function(matrice,noms){
    zeros<-matrix(0,nrow(matrice),length(noms));
    colnames(zeros)<-noms
    return(cbind(matrice,zeros))}
  
  if(is.null(list.y)){list.y<-list.xBCL}
  WTot<-list()
  listtot.xBCL <- vector()
  LL<-length(list.tables)
  dft.xBCL<-dft0.xBCL #initial total for xBCL
  dft.y <- WS(list(list.tables[[1]]),list.y=list.y,weight=w)
  weightdisp<-array(NA,dim=c(7,LL-1))
  dimnames(weightdisp)<-
    list(c("0",".25",".5",".75","1","var","mean"),
         names(list.tables[-1]))
  
  dfEstT=dft.y
  if(is.null(dft0.xBCL)){
    dft.xBCL.init<-WS(list(list.tables[[1]]),
                      list.y=list.xBCL,
                      weight=w)
    dft.xBCL<-dft.xBCL.init
    colnames(dft.xBCL)<-paste0(colnames(dft.xBCL),".lagstar")
  }
  mu<-mu0
  
  if(analyse){AAA=list()}
  #Loop: for every table (every T), starting from the second table
  for (i in 2:LL){
    print(i)
    weightdispi=numeric(0)
    df1f.y<-factorisedf(list.tables[[i-1]],list.xBCL);
    df2f.y<-factorisedf(list.tables[[i]],list.xBCL);
    df2f.x1<-factorisedf(list.tables[[i]],list.x1);
    df2f.x2<-factorisedf(list.tables[[i]],list.x2);
    df1 <- cbind((list.tables[[i-1]])[,c(id,w),drop=FALSE],df1f.y$fdf)
    df2 <- cbind((list.tables[[i]])[,c(id,w,setdiff(list.y,union(union(df2f.y$nfdf,df2f.x1$nfdf),df2f.x2$nfdf))),drop=FALSE],
                 df2f.y$fdf[setdiff(df2f.y$nfdf,union(df2f.x1$nfdf,df2f.x2$nfdf))],
                 df2f.x1$fdf[setdiff(df2f.x1$nfdf,df2f.x2$nfdf)],
                 df2f.x2$fdf)
    listtot.xBCL <- union(listtot.xBCL,union(df2f.y$nfdf,setdiff(list.xBCL,df2f.y$aconvertir)))
    listtot.xBCL<-union(listtot.xBCL,union(df2f.y$nfdf,df1f.y$nfdf))
    for(y in setdiff(listtot.xBCL,names(df2))){df2[,y]<-0}
    for(y in setdiff(listtot.xBCL,names(df1))){df1[,y]<-0}
    listtot.x1<-df2f.x1$nfdf
    listtot.x2<-df2f.x2$nfdf
    
    
    df1$Overlap<-1
    df<-merge(df1,df2,by=id,all.y=TRUE)
    Overlap<-!is.na(df$Overlap)
    keep=c(id)
    df[is.na(df)]<-0
    
    
    if(is.null(mu)){
      mu.init<-WS(list(df1),list.y=listtot.xBCL,weight=w)/sum(df1[,w])
      mu<-mu.init    
      mu<-amettrea0(mu,setdiff(listtot.xBCL,colnames(mu)))}
    
    
    prevlag<-function(x,Overlap,df){
      XX= apply(
        t(apply(as.matrix(df[Overlap,paste0(listtot.xBCL,".x")]),2,function(x){x*
                                                                                 as.matrix(df[Overlap,paste0(w,".y")])})/
            sum(df[Overlap,paste0(w,".y")]))%*%
          as.matrix(df[Overlap,paste0(listtot.xBCL,".y")])
        ,2,function(x){x/sum(x)})
      as.matrix(x)%*%t(XX)}
    df[paste0(listtot.xBCL,".lagstar")]<-
      df[paste0(listtot.xBCL,".x")]*Overlap+
      prevlag(df[paste0(listtot.xBCL,".y")],Overlap,df)*(!Overlap)
    
    keep=c(id,paste0(listtot.xBCL,".lagstar"))
    df3<-merge(df2,df[,keep],by=id)
    mu<-list()
    dft.x1<-WS(list(df2),list.y=listtot.x1,weight=w)#computation of totals for x1
    dft.x2=list.dft.x2[[i]] # for x2, totals are provided as an entry
    
    dft<-cbind(dft.x1,
               dft.x2,
               dft.xBCL)
    list.cal<-c(listtot.x1,listtot.x2,
                paste0(listtot.xBCL,".lagstar"))#list of names of calibration variables
    Xs<-model.matrix(as.formula(paste("~ 0 ",paste(list.cal,collapse=" + "),sep =" + ")),df3);
    list.cal2=colnames(Xs)
    #computation of calibration weights for GREG
    d<-as.vector(df3[,w], "numeric")
    dft<-amettrea0(dft,setdiff(list.cal2,colnames(dft)))
    gg<-calib(Xs=Xs,d=d,total=as.vector(dft[,list.cal2], "numeric"),q=rep(1,length(df3[,w])),
              method=c(calibmethod),description=FALSE,max_iter=500)
    W<-d*gg
    df3[,"W.BCL"] <- W
    weightdispi<-cbind(weightdispi,c(quantile(gg),var=var(gg),mean=mean(gg)))
    #computation of totals with new weights
    dfEst<-WS(list(df3),list.y=list.y,weight="W.BCL")
    dfEstBCL <- dfEstT
    dfEst<-amettrea0(dfEst,setdiff(colnames(dfEstBCL), colnames(dfEst)))
    dfEstBCL<-amettrea0(dfEstBCL,setdiff( colnames(dfEst),colnames(dfEstBCL)))
    dfEstT<-rbind(dfEstBCL,dfEst[,colnames(dfEstBCL)])
    dft.xBCL<-WS(list(df3),list.y=listtot.xBCL,weight="W.BCL")
    colnames(dft.xBCL)<-
      paste0(colnames(dft.xBCL),".lagstar")
    mu<-dft.xBCL/sum(W)
  }
  if(analyse){AAA<-c(AAA,list(df3))}
#  weightdisp[,,i-1]<-weightdispi
  
return(list(dfEst=dfEstT,weightdisp=weightdisp,AAA=if(analyse){AAA}else{NULL}))}

