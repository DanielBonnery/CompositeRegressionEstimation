factorisedf <-function(df,list.y){
  if(!is.null(list.y)){
    toconvert <- list.y[sapply(as.data.frame(df[, list.y,drop = FALSE]), class) %in% (c("factor", "character"))]
    toconvert_n <- toconvert[sapply(as.data.frame(df[, toconvert, drop = FALSE]), function(l) {length(unique(l))}) > 1]
    toconvert_1 <- setdiff(toconvert, toconvert_n)
    numeric<-setdiff(list.y,toconvert)
    
    fdf<-cbind(df[,-which((!is.element(names(df),list.y))|is.element(names(df),toconvert)),drop=FALSE])
    
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
      }
      else{df[,paste0(varn,"_n",unique(df[,varn]))]<-1}}
    fdf<-fdf[,setdiff(names(fdf),names(fdf)[grep("_nNA",names(fdf))])]
    names(fdf)<-gsub("-","_",names(fdf))}else{fdf=df}
  
  return(list(fdf=fdf,#all columns from df + conversion
              fdf2=fdf[,setdiff(names(fdf),toconvert)],#all columns from df + conversion -toconvert
              aconvertir=toconvert,
              apasconvertir=setdiff(list.y,toconvert),
              nfdf=names(fdf),          
              nfdf2=setdiff(names(fdf),toconvert)))}
