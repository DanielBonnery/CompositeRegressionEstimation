ajoutevariableP2 <-
  function(list.tables,
           id, 
           list.xMRP2,
           w,
           Lagvec=c(1)){
    #control on id
    if(!is.character(id)||!is.vector(id)){stop("Argument id of ajoutevariable must be a character vector", domain = NA)}
   #control on w
    LL<-length(list.tables)
    list.vartot<-unique(unlist(sapply(list.tables,names)))
#    At<-"At"
#    while(any(is.element(paste(At,1:LL,sep=""),list.vartot))){At<-paste(At,"t",sep="")}
#    list.tables2<-lapply(1:LL,function(l){ll<-list.tables[[l]];ll[At]<-l;return(ll)})
    keep<-c(id, w,list.xMRP)
      return(list(list.tables=lapply(1:LL,
             function(l){
               df<-list.tables[[l]]
               Lags<-Lagvec[is.element(l-Lagvec,1:l)]
               for (lag in Lags){
                      df2<-list.tables[[l-lag]][,keep]
                      names(df2)<-c(id,paste(c(w,list.xMRP),lag,sep="_lag"))
                    df<-merge(df,df2,by=id,all.x=TRUE)}
               return(df)}),
                  lagvar=lapply(1:LL,function(l){Lagvec[is.element(l-Lagvec,1:l)]}),
                  lagmonth=lapply(1:LL,function(l){intersect(1:l,l-Lagvec)})))}
