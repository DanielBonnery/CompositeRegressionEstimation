WSrg <-
  function(list.tables,weight=1,list.y=NULL,rg="hrmis"){
    #require(abind)
    #controls    
    #     if(max(!sapply(list.tables,is.data.frame))){stop("First argument(s) of WS must be  (a) data frame(s)", domain = NA)}
    
    #procedure
    
    L<-lapply(list.tables,function(df){
      #procedure
      list.y2<-list.y
      if(is.null(list.y)){list.y2<-names(df)[sapply(df,is.numeric)]}
      list.y2<-intersect(list.y2,names(df))
      w2<-weight
      if(is.numeric(weight)&&length(weight)==1){w2<-rep(weight,length(df[,1]))}
      if(is.character(weight)){w2<-as.matrix(df[,weight])}
      #convert factors and character to numeric
      fdf<-factorisedf(df,list.y2)
      df2<-cbind(df[fdf$apasconvertir],fdf$fdf)
      if(ncol(df2)>0){df2[is.na(df2)]<-0}
      w2[is.na(w2)]<-0
      #computation of weighted sum  
      dft<-t(as.vector(w2)*model.matrix(as.formula(paste(" ~ 0 +"  , paste(rg,collapse=" + "))),data=df[rg]))%*%as.matrix(df2);
            colnames(dft)=names(df2);
      amettrea0<-setdiff(unlist(lapply(
        list.y2[unlist(lapply(df[list.y2],is.factor))],
        function(var){
          paste(var,chartr("-.","__",levels(df[,var])),sep="_n")})),colnames(dft))
      zeros<-matrix(0,dim(dft)[1],length(amettrea0));
      colnames(zeros)<-amettrea0
      dft<-cbind(dft,zeros)
      return(dft)
    })
    variables1<-sort(unique(unlist(lapply(L,function(l){dimnames(l)[2]}))))
    variables2<-sort(unique(unlist(lapply(L,function(l){dimnames(l)[1]}))))
    
    L<-lapply(L,function(df){
      amettrea0<-setdiff(variables1,colnames(df))
      zeros<-matrix(0,nrow(df),length(amettrea0));colnames(zeros)<-amettrea0
      df=cbind(df,zeros)
      amettrea0<-setdiff(variables2,rownames(df))
      zeros<-matrix(0,length(amettrea0),ncol(df));rownames(zeros)<-amettrea0
      return(rbind(df,zeros))
    })
    L<-lapply(L,function(df){df[variables2,variables1]})
    
    dfEstT<- do.call("abind", c(L,along=0))
    #rownames(dfEstT)<-names(list.tables)
    #names(dfEstT)<-c("T",fdf$apasconvertir,fdf$nfdf)
    return(dfEstT)}