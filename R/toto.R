douuble <- function(list.tables,
               w="pwsswgt",
               id=c("hrlongid","pulineno")){
  require(MASS)
  #  list.tables=list(...);
  
  #id=c("hrlongid","pulineno")
  #w="pwsswgt"
  LL<-length(list.tables)
  keep= c(id,w,"pumlrR")
  doubble=lapply(2:LL,function(i){
    df<-merge(list.tables[[i-1]][keep],list.tables[[i]][keep],by=id,all=FALSE)
    df0<-merge(list.tables[[i-1]][keep],list.tables[[i]][keep],by=id,all.x=TRUE)
    df1<-merge(list.tables[[i-1]][keep],list.tables[[i]][keep],by=id,all.y=TRUE)
    df0<-df0[is.na(df0$pumlrR.y),]
    df1<-df1[is.na(df1$pumlrR.x),]
    NN=aggregate(df["pwsswgt.y"],sum,by=list(factor(df$pumlrR.x),factor(df$pumlrR.y)))    
    N01<-matrix(0,3,3)
    for (i in 1:nrow(NN)){N01[NN$Group.1[i],NN$Group.2[i]]<-NN$pwsswgt.y[i]}
    rownames(N01)<-levels(NN$Group.1)
    colnames(N01)<-levels(NN$Group.2)
    NN0=aggregate(df0["pwsswgt.x"],sum,by=list(factor(df0$pumlrR.x)))
    NN1=aggregate(df1["pwsswgt.y"],sum,by=list(factor(df1$pumlrR.y)))
    N0=NN0$pwsswgt.x;names(N0)<-NN0$Group.1
    N1=NN1$pwsswgt.y;names(N1)<-NN1$Group.1
    
    list(
    N01=N01,N0=N0,N1=N1)
  })
  #eval(parse(text=Sauve("doubble","serv")))
  return(doubble)}

triple <- function(list.tables,
                    w="pwsswgt",
                    id=c("hrlongid","pulineno")){
  require(MASS)
  #  list.tables=list(...);
  
  #id=c("hrlongid","pulineno")
  #w="pwsswgt"
  LL<-length(list.tables)
  list.tables2<-c(lapply(1:9,function(i){data.frame(hrlongid=character(0),
                                                   pulineno=character(0),
                                                   pwsswgt=numeric(0),
                                                   pumlrR=character(0))}),
  list.tables)
  keep= c(id,w,"pumlrR")
  tripple=lapply(10:(LL+9),function(t){
    df<-merge(list.tables2[[t]][c(keep,w)],list.tables2[[t-1]][keep],by=id,all.x=TRUE)
    df<-merge(df,                    list.tables2[[t-9]][keep],by=id,all.x=TRUE)
    names(df)[names(df)=="pumlrR.x"] <-"pumlrR_0"
    names(df)[names(df)=="pumlrR.y"] <-"pumlrR_1"
    names(df)[names(df)=="pumlrR"]   <-"pumlrR_9"
    S_0<-is.na(df["pumlrR_1"])&is.na(df["pumlrR_9"])
    S_1<-!is.na(df["pumlrR_1"])
    S_9<-is.na(df["pumlrR_1"])&!is.na(df["pumlrR_9"])

    nnames<-paste0("pumlrR_n",levels(df$pumlrR_0))
    N01<-matrix(NA,3,3)
    rownames(N01)<-nnames
    colnames(N01)<-nnames
    if(any(S_1)){
    NN01=aggregate(df[S_1,]["pwsswgt"],sum,by=list(factor(df[S_1,]$pumlrR_1),factor(df[S_1,]$pumlrR_0)))    
    for (i in 1:nrow(NN01)){N01[NN01$Group.1[i],NN01$Group.2[i]]<-NN01$pwsswgt[i]}}
    
    N09<-matrix(NA,3,3)
    rownames(N09)<-nnames
    colnames(N09)<-nnames
    if(any(S_9)){
    NN09=aggregate(df[S_9,]["pwsswgt"],sum,by=list(factor(df[S_9,]$pumlrR_9),factor(df[S_9,]$pumlrR_0)))    
    for (j in 1:nrow(NN09)){N09[NN$Group.1[j],NN09$Group.2[j]]<-NN09$pwsswgt[j]}}
    
    NN1=aggregate(df[S_0,]["pwsswgt"],sum,by=list(factor(df$pumlrR_0)))
    N1=NN1$pwsswgt;names(N1)<-nnames
    
    list(N01=N01,N09=N09,N1=N1)
  })
    return(tripple)}
