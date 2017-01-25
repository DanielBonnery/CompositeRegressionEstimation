#' Compute weighted sums
#'
#' @param list.tables A list of dataframes
#' @param weight either a real number of a character string indicating the name of the weight variable.
#' @param list.y: list of variables whose weighted sum needs to be computed. It can be factor or character variables.
#' @return a dataframe. 
#' @examples
#' WS(plyr::dlply(CRE_data,.variables=~time),"Sampling.weight",c("Hobby","Status","State"));
#' WS(plyr::dlply(CRE_data,.variables=~time),"Sampling.weight",character(0));


WS <-
function(list.tables,weight=1,list.y=NULL,sep="_n"){
  L<-if(identical(list.y,character(0))){lapply(list.tables,function(df){numeric(0)})}else{
  lapply(list.tables,function(df){
    #procedure
    list.y2<-list.y
    if(is.null(list.y)){list.y2<-names(df)[sapply(df,is.numeric)]}
    list.y2<-setdiff(intersect(list.y2,names(df)),weight)
    w2<-weight
    if(is.numeric(weight)&&length(weight)==1){w2<-rep(weight,length(df[,1]))}
    if(is.character(weight)){w2<-as.matrix(df[,weight])}
    #convert factors and character to numeric
    fdf<-factorisedf(df,list.y2)
    df2<-cbind(df[fdf$apasconvertir],fdf$fdf)
    
    if(ncol(df2)>0){df2[is.na(df2)]<-0}
    w2[is.na(w2)]<-0
    #computation of weighted sum  
    
    dft<-t(w2)%*%as.matrix(df2);colnames(dft)=names(df2);
    amettrea0<-setdiff(unlist(lapply(
      list.y2[unlist(lapply(df[list.y2],is.factor))],
      function(var){
        paste(var,chartr("-. ","___",levels(df[,var])),sep=sep)})),colnames(dft))
    zeros<-matrix(0,1,length(amettrea0));colnames(zeros)<-amettrea0
    dft<-cbind(dft,zeros)
      return(dft)
  })}
    variables<-unique(unlist(lapply(L,colnames)))
    L<-lapply(L,function(df){
      amettrea0<-setdiff(variables,colnames(df))
      zeros<-matrix(0,1,length(amettrea0));colnames(zeros)<-amettrea0
      return(cbind(df,zeros))
    })
    dfEstT<- do.call("rbind", lapply(L, function(df){df[, variables]}))
    rownames(dfEstT)<-names(list.tables)
    #names(dfEstT)<-c("T",fdf$apasconvertir,fdf$nfdf)
  return(dfEstT)}
