MRP<-
  function(list.tables,
           w,
           id,
           list.xMRP,
           list.x1=character(0), #computed
           list.x2=character(0), #external
           list.y=NULL,
           calibmethod="linear",
           list.dft.x2,
           dft0.xMRP=NULL,
           Lagvec=c(1,2,3,8,9,10,11,12,13,14,15),
           timee=NULL,
           add.var=FALSE,
           returncalibvar=FALSE,
           returnweight=FALSE){
    require(MASS)
    
    #  list.tables=list(...);
    if(max(!sapply(list.tables,is.data.frame))){stop("MR: First arguments of MR must be data frame(s)", domain = NA)}
    if(is.null(timee)){timee=as.character(1:length(list.tables))}
    #controls
    if(is.null(list.y)){list.y<-list.xMRP}
    if(!is.character(w)||!is.vector(w)){stop("MR: argument w must be a character vector", domain = NA)}
    if(!is.character(list.xMRP )||!is.vector(list.xMRP )){stop("MR: argument list.xMRP  must be a character vector", domain = NA)}
    if(!is.character(list.y )||!is.vector(list.y )){stop("MR: argument list.y  must be a character vector", domain = NA)}
    WTot<-list()
    
    listtot.xMRP <- vector()
    LL<-length(list.tables)
    list.tablesplus<-NULL
    if(add.var){list.tablesplus<-lapply(list.tables,function(l){l[id]})}
    dft.xMRP<-dft0.xMRP #initial total for xMRP
    dft.y <- WS(list(list.tables[[1]]),list.y=list.y,weight=w)
      dfEstT<-dft.y
      if(is.null(dft0.xMRP)){
        dft.xMRP<-WS(list(list.tables[[1]]),list.y=list.xMRP,weight=w)}
      names(dft.xMRP)<-c("T",names(dft.xMRP)[-1])
    #Loop: for every table (every T), starting from the second table
    
    ajvar<-ajoutevariableP(list.tables,
                           id, 
                           list.xMRP,
                           w,
                           Lagvec)
    
      Results<-
      lapply(1:LL,function(l){        
        fdf<-factorisedf(ajvar$list.tables[[l]],
                       union(union(list.x1,list.x2),union(list.y,outer(list.xMRP,ajvar$lagvar[[l]],paste,sep="_lag"))))
        listtot<-fdf$nfdf
        dff<-cbind(ajvar$list.tables[[l]][,
                      setdiff(unique(c(id,w,list.y,names(ajvar$list.tables[[l]])[grep(w,names(ajvar$list.tables[[l]]))])),fdf$nfdf),drop=FALSE],
                   fdf$fdf)
        
        dft<-unlist(lapply(ajvar$lagvar[[l]],function(ll){
                     WS(list(dff),
                        weight=paste(w,"_lag",ll,sep=""),
                        list.y=names(dff)[grep(paste(list.xMRP,"_lag",ll,"_",sep=""),names(dff))])[,-1]}))
        dft<-cbind(T=l,if(!is.null(dft)){t(dft)}else{matrix(0,1,0)},
                  WS(list(dff),weight=w,list.y=list.x1)[,-1],
                  if(is.null(list.dft.x2[[l]])){matrix(0,1,0)})
        list.cal<-names(dft)[-1]
        if(length(list.cal)>0){
        Xs<-model.matrix(as.formula(paste("~ 0 ",paste(list.cal,collapse=" + "),sep =" + ")),dff);
        list.cal2=names(as.data.frame(Xs))
        d=as.vector(dff[,w], "numeric")
        for(varlistcal2 in setdiff(list.cal2,names(dft))){dft[varlistcal2] <- 0}
        W<-d*calib(Xs=Xs,d=d,total=as.vector(dft[list.cal2], "numeric"),q=rep(1,length(dff[,w])),method=c(calibmethod),description=FALSE,max_iter=500)
        dff[,"wcal"] <- W}else{dff[,"wcal"] <- dff[,w]}        
        dfEst<-WS(list(dff),weight="wcal",list.y=list.y,timee=l)
        return(list(W=if(returnweight){W},
               calibvar=if(returncalibvar){dff},
               dfEst=dfEst))})
    variables<-unique(unlist(lapply(Results, function(l){names(l$dfEst)})))
        
    return(list(dfEst=do.call(rbind,lapply(Results, function(l){df<-l$dfEst;df[variables[!is.element(variables,names(df))]]<-0;df})),
                calibvar=lapply(Results, function(l){l$calibvar}),
                W=lapply(Results, function(l){l$W})))}
