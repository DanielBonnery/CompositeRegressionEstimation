ajoutevariable <-
  function(df1,df2,
           id, 
           list.xMR,
           w,
           theta=3/4,
           Alpha=.5,
           mu=NULL){
   #controls
#     if(!is.data.frame(df1)){stop("Argument df1 of ajoutevariable must be  a data frame", domain = NA)}
#     if(!is.data.frame(df2)){stop("Argument df2 of ajoutevariable must be  a data frame", domain = NA)}
#     #control on id
#     if(!is.character(id)||!is.vector(id)){stop("Argument id of ajoutevariable must be a character vector", domain = NA)}
#     if (max(!id %in% names(df1))){stop(gettextf("variable(s) %s are not in argument df1 of ajoutevariable",paste(id[!id %in% names(df1)],collapse=", ")), domain = NA)}
#     if (max(!id %in% names(df2))){stop(gettextf("variable(s) %s are not in argument df2 of ajoutevariable",paste(id[!id %in% names(df2)],collapse=", ")), domain = NA)}
#     #control on w
#     if(!is.character(w)||!is.vector(w)){stop("ajoutevariable: argument w must be a character vector", domain = NA)}
#     if (!w %in% names(df1)){stop(gettextf("ajoutevariable: weight variable %s must be in argument df1 dataframe",w), domain = NA)}
#     if (!w %in% names(df2)){stop(gettextf("ajoutevariable: weight variable %s is not in argument df2 dataframe",w), domain = NA)}
#     if (!is.double(df1[,w])){stop(gettextf("The weight variable %s of argument df1 dataframe must be a numeric variable.",w), domain = NA)}
#     if (!is.double(df2[,w])){stop(gettextf("The weight variable %s of argument df2 dataframe must be a numeric variable.",w), domain = NA)}
#     #control on list.xMR
#     if (max(!list.xMR %in% names(df1))){stop(gettextf("variable(s) %s are not in argument df1 dataframe",paste(list.xMR[!list.xMR %in% names(df1)],collapse=", ")), domain = NA)}
#     if (max(!list.xMR %in% names(df2))){stop(gettextf("variable(s) %s are not in argument df2 dataframe",paste(list.xMR[!list.xMR %in% names(df2)],collapse=", ")), domain = NA)}
    
    df1$At<-1
    df<-merge(df1,df2,by=id,all.y=TRUE)
    At<-!is.na(df$At)
    keep=c(id)
      
    for (y in list.xMR){
    df[paste(y,".1",sep='')]<-df[paste(y,".y",sep='')]
    df[At,paste(y,".1",sep='')]<-1/theta*
          (df[At,paste(y,".x",sep='')]-df[At,paste(y,".y",sep='')])+
          df[At,paste(y,".y",sep='')]}
      keep=union(keep,paste(list.xMR,".1",sep=''))
    
    if(is.null(mu)){mu<-WS(list(df1),list.y=list.xMR,weight=w)/sum(df1[,w])}
    amettrea0<-function(matrice,noms){
    zeros<-matrix(0,nrow(matrice),length(noms));
    colnames(zeros)<-noms
    return(cbind(matrice,zeros))}
    mu<-amettrea0(mu,setdiff(list.xMR,colnames(mu)))
    for (alpha in Alpha){
    for (y in list.xMR){
      df[paste0(y,".0")]<-mu[[alphac]][,y]
      df[At,paste(y,".0",sep='')]<-df[At,paste(y,".x",sep='')]}
    keep=union(keep,paste(list.xMR,".0",sep=''))
    for (y in list.xMR){
      df[paste(y,".",alpha,sep='')]<-
          alpha*df[paste(y,".1",sep='')]+
        (1-alpha)*df[paste(y,".0",sep='')]
    }
    keep=union(keep,outer(list.xMR,Alpha,paste,sep='.'))}
  df3<-merge(df2,df[,keep],by=id)
  return(df3)
}
