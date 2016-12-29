#' Convert variables to numeric in dataframe.
#'
#' @param dfr A dataframe
#' @param list.y character vector containing the names of the variables to be converted.
#' @return list of variables whose weighted sum needs to be computed. It can be factor or character variables.
#' @examples
#' WS(list(cars),"dist","speed")


factorisedf <-function(dfr,list.y){
    do.call(cbind,
            lapply(list.y,function(x){model.matrix(as.formula(paste0("~",x,"+0")))}))
    toconvert <- list.y[sapply(as.data.frame(dfr[, list.y,drop = FALSE]), class) %in% (c("factor", "character"))]
    toconvert_n <- toconvert[sapply(as.data.frame(dfr[, toconvert, drop = FALSE]), function(l) {length(unique(l))}) > 1]
    toconvert_1 <- setdiff(toconvert, toconvert_n)
    numericv<-setdiff(list.y,toconvert)
  
    fdf=dfr[,numericv,drop=FALSE]
    
    for(varn in toconvert_n){
      dfr[,varn]<-paste("_n",factor(dfr[,varn],exclude=NULL),sep="")
      formulaa=as.formula(paste(c(" ~ 0  ", varn), collapse=" + "))
      fdf=cbind(fdf,model.matrix(formulaa, dfr))}
    for(varn in toconvert_1){
      if(is.factor(dfr[,varn])){
        leve<-levels(dfr[,varn])
        uni<-leveunique(dfr[,varn])
        fdf[,paste0(varn,"_n",leve)]<-0
        fdf[,paste0(varn,"_n",leve[unique(dfr[,varn])])]<-1
      }else{fdf[,paste0(varn,"_n",unique(dfr[,varn]))]<-1}}
    fdf<-fdf[,setdiff(names(fdf),names(fdf)[grep("_nNA",names(fdf))]),drop=FALSE]
    names(fdf)<-gsub("-","_",names(fdf))
  
  return(list(fdf=fdf,#all columns from df + fdf
              fdf2=fdf,#same
              aconvertir=toconvert,
              apasconvertir=setdiff(list.y,toconvert),
              nfdf=names(fdf),          
              nfdf2=setdiff(names(fdf),toconvert)))}
