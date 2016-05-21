MLEE2<-function(prior,N01,N0,N1){
  
  log.likelihood<-function(P,N0,N1,N01){
    P<-matrix(P,3,3)/sum(P)
    
    sum(log(apply(P,1,sum))*N0,na.rm=TRUE)+
      sum(log(apply(P,2,sum))*N1,na.rm=TRUE)+
      sum(log(P)*N01,na.rm=TRUE)
    
  }
  
  
  posterior<-function(prior,N01,N0,N1){
    
    log.likelihood<-function(P,N0,N1,N01){
      P<-matrix(P,3,3)
      P<-matrix(P,3,3)/sum(P)
      P<-diag(apply(P,1,sum)^{-1})%*%P
      
      sum(log(apply(P,1,sum))*N0,na.rm=TRUE)+
        sum(log(apply(P,2,sum))*N1,na.rm=TRUE)+
        sum(log(P)*N01,na.rm=TRUE)
      
    }
    
    
    P<-N01/sum(N01)
    th<-vector()
    dif=1;k=1;dif2=1
    while(dif>10^{-7}&&k<10000){
      P0<-P
      for (i in 1:9){
        samplelike<-function(x){
          return(-log.likelihood(P+(x-P[i])*((1:9)==i),N0,N1,N01))}
        P[i]<-optimize(f=samplelike,interval=c(0,1),tol=dif/10000)$minimum
        P<-P/sum(P)
      } 
      k<-k+1
      dif=max(abs(P0-P))
      dif2=max(abs(P0-P))
      th<-cbind(th,P)
    }
    PP<-matrix(P,3,3)
    dimnames(PP)<-dimnames(N01)
    PP
  }
  
  
  P=rchisq(9,1,1);P<-P/sum(P)
  N01=matrix(rmultinom(1,60000,prob=P),3,3)
  N0=rmultinom(1,20000,prob=apply(matrix(P,3,3),1,sum))
  N1=rmultinom(1,20000,prob=apply(matrix(P,3,3),2,sum))
  #N0<-apply(N01,1,sum)
  # N1<-apply(N01,2,sum)
  Pest<-MLEE(N01,N0,N1)
  N01/sum(N01)
  Pest
  matrix(P,3,3)
  
  
  bestest<-function(P,t0,alpha){
    alpha*apply(P,2,sum)+(1-alpha)*(t0+apply(P,2,sum)-apply(P,1,sum))}
  
  BCLratio<-function(list.tables,
                     Alpha=(0:20)/20){
    
    TT<-sapply(list.tables,function(df){sum(df$pwsswgt)})
    DD<-douuble(list.tables)
    LL<-lapply(DD,function(dd){MLEE(dd$N01,dd$N0,dd$N1)})
    TTT<-lapply(Alpha,function(alpha){
      LLL<-matrix(apply(LL[[1]],1,sum),1,3)
      for(i in 1:length(LL)){LLL<-rbind(LLL,
                                        bestest(LL[[i]],LLL[i,],alpha))}
      diag(TT)%*%LLL
      
    }
    )
    
    
    LLLL<-do.call(abind,c(TTT,list(along=3)))
    
    dimnames(LLLL)<-list(names(list.tables),paste0("pumlrR_n",dimnames(LLLL)[[2]]),Alpha)
    LLLL
  }}
