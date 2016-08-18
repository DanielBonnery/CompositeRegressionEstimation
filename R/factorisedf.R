factorisedf <-function(df,list.y){
  
  #idea:
  #for each character or factor variables of list.y will be replaced by
  # a number equal to the number of factors of 0-1 variables. 
  #check parameters
  if(!is.data.frame(df)){stop("factorisedf: argmuent df must be  a data frame", domain = NA)}
  if(!is.null(list.y)){
    #   if(length(list.y)>0){
    #   if(!is.character(list.y)||!is.vector(list.y)){stop("factorisedf: argument list.y must be a character vector", domain = NA)}
    #   if ((max(!list.y %in% names(df)))&!is.null(list.y)){stop(gettextf("factorisedf: variable(s) %s are not in argument df dataframe",paste(list.y[!list.y %in% names(df)],collapse=", ")), domain = NA)}}
    #convert factors and character to numeric
    aconvertir <- list.y[sapply(as.data.frame(df[, list.y,drop = FALSE]), class) %in% (c("factor", "character"))]
    aconvertir1 <- aconvertir[sapply(as.data.frame(df[, aconvertir, drop = FALSE]), function(l) {length(unique(l))}) > 1]
    aconvertir0 <- setdiff(aconvertir, aconvertir1)
    
    fdf<-cbind(df[,-which((!is.element(names(df),list.y))|is.element(names(df),aconvertir)),drop=FALSE])
    if(length(aconvertir1)>0){
      for(var in aconvertir1){
        df[,var]<-paste("_n",factor(df[,var],exclude=NULL),sep="")
        formulaa=as.formula(paste(c(" ~ 0  ", var), collapse=" + "))
        fdf=cbind(fdf,model.matrix(formulaa, df))}
      formulaa=as.formula(paste(c(" ~ 0  ", aconvertir1), collapse=" + "))
      fdf2=cbind(df[,-which((!is.element(names(df),list.y))|is.element(names(df),aconvertir)),drop=FALSE],
                 data.matrix(df[,aconvertir0,drop=FALSE]) ,
                 model.matrix(formulaa, df))
      fdf2<-fdf2[,setdiff(names(fdf2),names(fdf2)[grep("_nNA",names(fdf2))])]
      fdf<-fdf[,setdiff(names(fdf),names(fdf)[grep("_nNA",names(fdf))])]
      names(fdf)<-gsub("-","_",names(fdf))
      return(list(fdf=fdf,#all columns from df + conversion
                  fdf2=fdf2,#all columns from df + conversion -aconvertir0
                  aconvertir=aconvertir,
                  apasconvertir=setdiff(list.y,aconvertir),
                  nfdf=names(fdf),          
                  nfdf2=names(fdf2)))}
    
    if(length(aconvertir1)==0){
      return(list(fdf=df[,character(0)],
                  fdf2=df[,list.y],
                  aconvertir=aconvertir,
                  apasconvertir=setdiff(list.y,aconvertir),
                  nfdf=character(0),          
                  nfdf2=list.y))}
  }
  else{
    dimension<-dim(df)[1]
    
    return(list(fdf=df[,character(0)],
                fdf2=df[,character(0)],
                aconvertir=character(0),
                apasconvertir=character(0),
                nfdf=character(0),          
                nfdf2=character(0)))}
  
}
