#' Compute weighted sums
#'
#' @param list.tables A list of dataframes, order matters.
#' @param w either  a real number of a character string indicating the name of the weight variable.
#' @param id primary key of the tables, used to merge tables together.
#' @param y a string indicating the name of a factor variable common to all tables of list.tables.
#' @return a list of three arrays. 
#' @examples
#' douuble(list.tables=lapply(1:10,function(x){cbind(id=1:nrow(Orange),Orange)[sample(nrow(Orange),30),]}),w="circumference",id="id",y="Tree")

douuble <- function(list.tables,
               w,
               id,
               y){
  require(MASS)
  LL<-length(list.tables)
  keep= c(id,w,y)
  y.x<-paste0(y,".x")
  y.y<-paste0(y,".y")
  w.x<-paste0(w,".x")
  w.y<-paste0(w,".y")
  doubble=lapply(2:LL,function(i){
    df<-merge(list.tables[[i-1]][keep],list.tables[[i]][keep],by=id,all=FALSE)
    df0<-merge(list.tables[[i-1]][keep],list.tables[[i]][keep],by=id,all.x=TRUE)
    df1<-merge(list.tables[[i-1]][keep],list.tables[[i]][keep],by=id,all.y=TRUE)
    df0<-df0[is.na(df0[[y.y]]),]
    df1<-df1[is.na(df1[[y.x]]),]
    list(N01=reshape2::acast(df,as.formula(paste0(y.x,"~",y.y)),fun.aggregate=sum,value.var=w.y, fill = 0, drop = FALSE),
    N0=reshape2::acast(df0,as.formula(paste0("1~",y.x)),fun.aggregate=sum,value.var=w.x, fill = 0, drop = FALSE),
    N1=reshape2::acast(df1,as.formula(paste0("1~",y.y)),fun.aggregate=sum,value.var=w.y, fill = 0, drop = FALSE))
    })
  N01<-plyr::laply(doubble,function(x){x$N01})
  N0<-plyr::laply(doubble,function(x){x$N0})
  N1<-plyr::laply(doubble,function(x){x$N1})
  
  Hmisc::label(N01)<-paste0("Weighted (weight is: ",w,") count for ",y, "(t-1)=i and ", y,"(t)=j")
  names(dimnames(N01))<-c("t","i","j")
  names(N01)[[1]]<-names(list.tables)[2:LL]
  
  Hmisc::label(N0)<-paste0("Weighted (weight is: ",w,") count for ",y, "(t-1)=i and not in the sample at t")
  names(dimnames(N0))<-c("t","i")
  names(N0)[[1]]<-names(list.tables)[2:LL]
  
  Hmisc::label(N1)<-paste0("Weighted (weight is: ",w,") count for ",y, "(t)=i and not in the sample at t-1")
  names(dimnames(N1))<-c("t","i")
  names(N1)[[1]]<-names(list.tables)[2:LL]
  
  return(list(N01=N01,N0=N0,N1=N1))
  
  }




triple <- function(list.tables,
                    w,
                    id){
  require(MASS)
  #  list.tables=list(...);
  
  #id=c("hrlongid","pulineno")
  #w=w
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
    NN01=aggregate(df[S_1,][w],sum,by=list(factor(df[S_1,]$pumlrR_1),factor(df[S_1,]$pumlrR_0)))    
    for (i in 1:nrow(NN01)){N01[NN01$Group.1[i],NN01$Group.2[i]]<-NN01[pwsswgt][i]}}
    
    N09<-matrix(NA,3,3)
    rownames(N09)<-nnames
    colnames(N09)<-nnames
    if(any(S_9)){
    NN09=aggregate(df[S_9,][w],sum,by=list(factor(df[S_9,]$pumlrR_9),factor(df[S_9,]$pumlrR_0)))    
    for (j in 1:nrow(NN09)){N09[NN$Group.1[j],NN09$Group.2[j]]<-NN09[pwsswgt][j]}}
    
    NN1=aggregate(df[S_0,][w],sum,by=list(factor(df$pumlrR_0)))
    N1=NN1[w];names(N1)<-nnames
    
    list(N01=N01,N09=N09,N1=N1)
  })
    return(tripple)}
