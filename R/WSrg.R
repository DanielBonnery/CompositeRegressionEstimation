#' Weighted sums by rotation groups
#' @param list.tables a named list of data frames
#' @param weight a character string  indicating the variable name or a numerical value 
#' @param list.y a vector of character strings indicating the study variables
#' @param rg a character string indicating the name of the rotation group.
#' @return an array
#' @examples
#' library(dataCPS)
#' period<-200501:200512
#' list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);
#' names(list.tables)<-period
#' Y<-WSrg(list.tables,"pwsswgt",list.y="pemlr",rg="hrmis")
#' dimnames(Y);dim(Y)
#' Y<-plyr::daply(plyr::ldply(list.tables,function(L){L[c("pemlr","pwsswgt","hrmis")]},.id="m"),
#' ~m+pemlr+hrmis,function(d){data.frame(y=sum(d$pwsswgt))})[names(list.tables),,]
#' dimnames(Y);dim(Y)
#' system.time(plyr::daply(plyr::ldply(list.tables,,function(L){L[c("pemlr","pwsswgt","hrmis")]}),
#' ~.id+pemlr+hrmis,function(d){data.frame(y=sum(d$pwsswgt))}))
#' system.time(WSrg(list.tables,weight="pwsswgt",list.y="pemlr",rg="hrmis"))
WSrg <-
  function(list.tables,weight=1,list.y=NULL,rg="hrmis",rescale=F,dimname1="m"){
    #require(abind)
    #controls    
    #     if(max(!sapply(list.tables,is.data.frame))){stop("First argument(s) of WS must be  (a) data frame(s)", domain = NA)}
    
    #procedure
    if(is.null(names(list.tables))){names(list.tables)=1:length(list.tables)}
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
    names(dimnames(dfEstT))<-c(dimname1,rg,"y")
    #rownames(dfEstT)<-names(list.tables)
    #names(dfEstT)<-c("T",fdf$apasconvertir,fdf$nfdf)
    if(rescale){dfEstT<-dfEstT*dim(dfEstT)[2]}
    return(dfEstT)}


#' Weighted sums by rotation groups
#' @param list.tables a named list of data frames
#' @param weight a character string  indicating the variable name or a numerical value 
#' @param y a character strings indicating one study variable
#' @param rg a character string indicating the name of the rotation group.
#' @return an array
#' @examples
#' library(dataCPS)
#' period<-200501:200512
#' list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),get);
#' names(list.tables)<-period
#' Y<-WSrg2(list.tables,"pwsswgt",list.y=c("pemlr","pwsswgt"),rg="hrmis")
#' Y<-WSrg2(list.tables,"pwsswgt",list.y=c("pemlr"),rg="hrmis")
WSrg2 <-
  function(list.tables,weight,y,rg="hrmis",rescale=F,dimname1="m"){
    tottab<-plyr::ldply(list.tables,function(L){L[c(y,weight,rg)]},.id=dimname1)
    if(is.numeric(tottab[[y]])){
        plyr::daply(
          tottab[c(rg,dimname1,y,weight)],
          as.formula(paste0("~",paste(c(dimname1,rg),collapse="+"))),
          function(d){y=sum(d[[weight]]*d[[y]])})[names(list.tables),]      
      }else{
      plyr::daply(
        tottab[c(rg,dimname1,y,weight)],
        as.formula(paste0("~",paste(c(dimname1,rg,y),collapse="+"))),
        function(d){y=sum(d[[weight]])})[names(list.tables),,]}}
