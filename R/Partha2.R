ratios<-
  function(df_1,df_0,
           w,
           id,
           list.y){
#    fdf_0<-factorisedf(df_0[c(id,list.y)],list.y)
#    fdf_1<-factorisedf(df_1[c(id,list.y)],list.y)
    df<-merge(df_1[c(w,id,list.y)],
              df_0[c(w,id,list.y)],
              by=id,
              all=FALSE)
    list.y.x<-paste0(list.y,".x")
    list.y.y<-paste0(list.y,".y")
    rat<-WS(list(df),
       list.y=c(list.y.x,list.y.y),
       weight=paste0(w,".y"))
    finalnamesy<-colnames(rat)[grep(".y",colnames(rat))]
    finalnamesx<-gsub(".y",".x",finalnamesy)
    finalnamesx2<-intersect(finalnamesx,colnames(rat))
    finalnamesy2<-intersect(gsub(".x",".y",finalnamesx),colnames(rat))
    finalnames<-gsub(".x","",finalnamesx2)
rat<-as.vector(rat[,finalnamesy2])/as.vector(rat[,finalnamesx2])
names(rat)<-finalnamesy2
    return(rat)}

RA<-
  function(list.tables,
           w,
           id,
           list.y,
           Alpha){
    direct<-
  WS(list.tables,
     list.y=list.y,
     weight=w)
nrowe<-ncol(direct)
    rat<-t(sapply(2:length(list.tables),
             function(i){ratios(list.tables[[i-1]],list.tables[[i]],w,id,list.y)}))
    if(is.list(rat)){
      ratcolnames<-dimnames(rat)[2][[1]]
      rat<-matrix(unlist(rat),nrow=dim(rat)[1])
      colnames(rat)<-ratcolnames    
    }
    rat<-rbind(rep(1,ncol(rat)),rat)
    matrat<-lapply(Alpha,function(alpha){alpha* direct+
         (1-alpha)*rat*direct[c(1,1:(nrow(direct)-1)),]})
    names(matrat)=Alpha

    #
    if(FALSE){
    plot(direct[,"pumlrR_n1"],type='l')
    points(matrat[[1]][,"pumlrR_n1"],type='l',col='red')
    
    direct[1:3,]
    rat[1:3,]
    (rat*direct[c(1:(nrow(direct))),])[1:3,]
    plot(rat[,2],type='l');points(direct[,2]/direct[c(1,1:84),2],type='l',col='red')}
    return(matrat)}
