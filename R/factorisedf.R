factorisedf <-function(df,list.y){
  if(!is.null(list.y)){
    toconvert <- list.y[sapply(as.data.frame(df[, list.y,drop = FALSE]), class) %in% (c("factor", "character"))]
    toconvert_n <- toconvert[sapply(as.data.frame(df[, toconvert, drop = FALSE]), function(l) {length(unique(l))}) > 1]
    toconvert_1 <- setdiff(toconvert, toconvert_n)
    numericv<-setdiff(list.y,toconvert)
  
    fdf=df[,numericv,drop=FALSE]
    
    for(varn in toconvert_n){
      df[,varn]<-paste("_n",factor(df[,varn],exclude=NULL),sep="")
      formulaa=as.formula(paste(c(" ~ 0  ", varn), collapse=" + "))
      fdf=cbind(fdf,model.matrix(formulaa, df))}
    for(varn in toconvert_1){
      if(is.factor(df[,varn])){
        leve<-levels(df[,varn])
        uni<-leveunique(df[,varn])
        fdf[,paste0(varn,"_n",leve)]<-0
        fdf[,paste0(varn,"_n",leve[unique(df[,varn])])]<-1
      }else{fdf[,paste0(varn,"_n",unique(df[,varn]))]<-1}}
    fdf<-fdf[,setdiff(names(fdf),names(fdf)[grep("_nNA",names(fdf))]),drop=FALSE]
    names(fdf)<-gsub("-","_",names(fdf))}else{fdf=df[,character(0),drop=FALSE]}
  
  return(list(fdf=fdf,#all columns from df + fdf
              fdf2=fdf,#same
              aconvertir=toconvert,
              apasconvertir=setdiff(list.y,toconvert),
              nfdf=names(fdf),          
              nfdf2=setdiff(names(fdf),toconvert)))}
