composite <-
function(list.tables,
         w,
         list.y,
         id=NULL,
         groupvar=NULL,
         groups_1=NULL,
         groups_0=NULL,
         Coef=c(Total_0=1,Total_1=0,Totalinter_1=0,Totalinter_0=0,Totaldiff_0=0),
         dft0.y=NULL){
   # list.tables=list(...);
    #controls
       if(is.null(id)&is.null(groupvar)){stop("Composite: give a value for id or for groupvar")}
    #if(max(!sapply(list.tables,is.data.frame))){stop("Composite: First arguments of AK must be data frames", domain = NA)}
    #if(!is.character(id)||!is.vector(id)){stop("Composite: Argument id is not a character vector", domain = NA)}
    if(!is.character(w)||!is.vector(w)){stop("Composite: Argument w is not a character vector", domain = NA)}
    if(!is.character(list.y)||!is.vector(list.y)){stop("Composite: argument list.y is not a character vector", domain = NA)}
    for (dff in list.tables){
      if (!is.null(id)){
      if (max(!id %in% names(dff))){stop(gettextf("Composite: variable(s) %s are not in some dataframes",paste(id[!id %in% names(dff)],collapse=", ")), domain = NA)}}
      if (!(w %in% names(dff))){stop(gettextf("Composite: weight variable %s is not in dataframe",w), domain = NA)}
      if (max(!list.y %in% names(dff))){stop(gettextf("Composite: variable(s) %s are not in dataframe",paste(list.y[!list.y %in% names(dff)],collapse=", ")), domain = NA)}
      if (!is.double(dff[,w])){stop(gettextf("Composite: The weight variable %s of dataframes of ... must be a numeric variable.",w), domain = NA)}}
    
  dft.y<-dft0.y #initial total for y
  #if NA, initial computation of totals of contral variables.
  if(is.null(dft.y)){	
    dft.y<-WS(list(list.tables[[1]]),weight=w,list.y=list.y)}
  listtot.y<-vector()
  dfEstT<-dft.y
  #Loop: for every table (every T), starting from the second table
  LL<-length(list.tables)
  creegroupvar<-is.null(groupvar)  
    if(creegroupvar){
	keeps=c(w,id)}
    if(!creegroupvar){
	keeps=c(w,groupvar)}
  for (i in 2:LL){
    df_1f<-factorisedf(list.tables[[i-1]],list.y);
    df_0f<-factorisedf(list.tables[[i]]  ,list.y);
    df_1=data.frame((list.tables[[i-1]])[,keeps,drop=FALSE],df_1f$fdf)
    df_0=data.frame((list.tables[[i]])  [,keeps,drop=FALSE],df_0f$fdf)
    names(df_1)<-c(keeps,df_1f$nfdf)
    names(df_0)<-c(keeps,df_0f$nfdf)
    if(creegroupvar){
	groupvar <- "groupvar"
	groups_1<-c(1)
	groups_0<-c(1)
	df_0<-merge("$<-"(df_1[id],groupvar,1),df_0,by=id,all.y=TRUE)
	df_1<-merge("$<-"(df_0[id],groupvar,1),df_1,by=id,all.y=TRUE)}
    #if(!is.null(groupvar)){keeps=c(id,w,groupvar)}
    listtot.y<-union(listtot.y,union(df_0f$nfdf,df_1f$nfdf))
    for(y in setdiff(listtot.y,df_1f$nfdf)){df_1[y]<-0}
    for(y in setdiff(listtot.y,df_0f$nfdf)){df_0[y]<-0}

    #computation of the composite estimator
    amettrea0<-function(matrix,listvar){
      amettrea0<-setdiff(listvar, colnames(matrix))
      zeros<-matrix(0,nrow(matrix),length(amettrea0));
      colnames(zeros)<-amettrea0
      return(cbind(matrix,zeros))}
    dft.y <-amettrea0(dft.y,listtot.y)
    dfEstT<-amettrea0(dfEstT,listtot.y)
    df_1  <-amettrea0(df_1,listtot.y)
    df_0  <-amettrea0(df_0,listtot.y)
    
    #TotEstimate_1     <-as.matrix(WS(list(df_1)                        ,weight=w,list.y=listtot.y)[listtot.y])
    TotEstimate_0      <-WS(list(df_0)                        ,weight=w,list.y=listtot.y)[,listtot.y]
    inter2<-sapply(df_0[[groupvar]],function(x){x%in%groups_0})
    inter1<-df_1[[groupvar]]%in%groups_1
    TotEstimateIntert_0<-WS(list(df_0[inter2,]),weight=w,list.y=listtot.y)[,listtot.y]
    TotEstimateIntert_1<-WS(list(df_1[inter1,]),weight=w,list.y=listtot.y)[,listtot.y]
    TotEstimateDiff_1  <-WS(list(df_1[!inter1,]),weight=w,list.y=listtot.y)[,listtot.y]

    dft.y<-t(cbind(dft.y[,listtot.y],TotEstimate_0,TotEstimateIntert_0,TotEstimateIntert_1,TotEstimateDiff_1)%*%
      Coef[c("Total_1",  "Total_0",  "Totalinter_0",  "Totalinter_1",  "Totaldiff_0")])
	
    colnames(dft.y)<-listtot.y
    dfEstT<-rbind(dfEstT[,listtot.y],dft.y[,listtot.y])
  }
  rownames(dfEstT)<-names(list.tables)  
  return(dfEstT)}
