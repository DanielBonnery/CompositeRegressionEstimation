BCL0 <- function(list.tables,
                w,
                id,
                list.x2, #external
                list.y,
                calibmethod="linear",
                list.dft.x2,
                analyse=FALSE){
  require(MASS)
  
  amettrea0<-function(matrice,noms){
    zeros<-matrix(0,nrow(matrice),length(noms));
    colnames(zeros)<-noms
    return(cbind(matrice,zeros))}
  
  WTot<-list()
  LL<-length(list.tables)

  BCLL<-lapply (1:LL,function(i){
    df2f.x2<-factorisedf(list.tables[[i]],list.x2);
    df2 <- cbind((list.tables[[i]])[,c(id,w,setdiff(list.y,df2f.x2$nfdf)),drop=FALSE],
                 df2f.x2$fdf)
    list.cal<-df2f.x2$nfdf  
    Xs<-model.matrix(as.formula(paste("~ 0 ",paste(list.cal,collapse=" + "),sep =" + ")),df2);
    list.cal2=colnames(Xs)
    d<-as.vector(df2[,w], "numeric")
    dft<-list.dft.x2[i,list.cal]
    gg<-calib(Xs=Xs,d=d,total=as.vector(dft, "numeric"),q=rep(1,length(df2[,w])),
              method=c(calibmethod),description=FALSE,max_iter=500)
    W<-d*gg
    df2[,"W.BCL0"] <- W
    WS(list(df2),list.y=list.y,weight="W.BCL0")
  })
  varr<-unique(do.call(c,lapply(BCLL,colnames)))
  dfEst<-t(array(unlist(lapply(BCLL,function(l){amettrea0(l,noms=varr)[,varr]})),c(length(varr),LL),dimnames=list(varr,names(list.tables))))
  return(list(dfEst=dfEst))}

