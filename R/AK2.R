AK2 <-
  function(dfest,coeff=NULL,
           ak=list(c(0,0))){
    #dfest<-WSrg(list.tables,weight="pwsswgt",list.y="pumlr")
    if(is.null(coeff)){
      coeff<-CoeffAK(dim(dfest)[1],ak)}
    asaa=array(apply(dfest,3,function(m1){
      apply(coeff,c(3,4),function(m2){sum(m1*m2)})}),
      c(dim(dfest)[1],length(ak),dim(dfest)[3]))
    dmnmsak<-if(is.null(names(ak))){sapply(ak,function(x){paste0("AK2",x[1],"-",x[2])})}else{names(ak)}
    dimnames(asaa)=list(dimnames(dfest)[[1]],dmnmsak,dimnames(dfest)[[3]])
    return(aperm(asaa,c(1,3,2)))}


CoeffAK2<-function(nmonth,ak,simplify=TRUE){
  if(is.null(names(ak))){names(ak)<-1:length(ak)}
  coeff<-array(0,c(nmonth,8,nmonth,length(ak)))
  dimnames(coeff)[4]<-list(sapply(ak,function(x){paste0(x[1],"-",x[2])}))
  
  
  S<-c(2:4,6:8)
  Sbar<-c(1,5)
  
  coeff[1,,1,]<-1
  for(j in (1:length(ak))){
    a=ak[[j]][1];k=ak[[j]][2];
    for(i in 2:nmonth){
      coeff[,,i,j]<-coeff[,,(i-1),j]*k
      coeff[i,,i,j]<-(1-k)
      coeff[i-1,S-1,i,j]<-coeff[i-1,S-1,i,j]-k*4/3
      coeff[i,S,i,j]<-coeff[i,S,i,j]+k*4/3-8*a/3
      coeff[i,Sbar,i,j]<-coeff[i,Sbar,i,j]+8*a} }
  coeff<-coeff/8
  if(simplify){
    coeff=array(c(coeff,rep(0*coeff,3),coeff,rep(0*coeff,3),coeff),c(dim(coeff),3,3))
    coeff=array(aperm(coeff,c(5,3,6,2,1,4)),c(nmonth*3,nmonth*8*3,length(ak)))
    dimnames(coeff)[3]<-list(names(ak))
  }
  
  return(coeff)
}
if(FALSE){
  charge("ak2CPS");ak2CPS
  charge("akCPS");akCPS
  coeff2<-CoeffAK2(85,ak2CPS,simplify=TRUE)
  coeff3<-CoeffAK3(85,akCPS[2],simplify=TRUE)
  max(abs(coeff2-coeff3))  
}
CoeffAK2diff<-function(nmonth,ak){
  coeff<-CoeffAK2(nmonth,ak)
  coeff[,,2:nmonth,]<-coeff[,,2:nmonth,]-coeff[,,1:(nmonth-1),]
  coeff[,,1,]<-0
  coeff
}



varAK<-function(ak,Sigma){
  A<-ak[1];  K<-ak[2];
  nmonth<-dim(Sigma)[1]
  coeff<-array(CoeffAK2(nmonth,list(ak)),c(nmonth*8,nmonth))
  XX=array(apply(array(Sigma,rep(c(nmonth*8,3),2)),c(2,4),function(sigma){t(coeff)%*%sigma%*%coeff}),rep(c(nmonth,3),each=2))
  dimnames(XX)<-rep(dimnames(Sigma)[c(1,3)],each=2)
  XX}


varAKdiff<-function(ak,Sigma){
  nmonth<-dim(Sigma)[[1]]
  coeff<-array(CoeffAK2diff(nmonth,list(ak)),c(nmonth*8,nmonth))
  XX=array(apply(array(Sigma,rep(c(nmonth*8,3),2)),c(2,4),function(sigma){t(coeff)%*%sigma%*%coeff}),rep(c(nmonth,3),each=2))[-1,-1,,]
  dimnames(XX)<-rep(c(list(dimnames(Sigma)[[1]][-1]),dimnames(Sigma)[3]),each=2)
  XX}

varAKrat<-function(ak,Sigma,Scomppop){
  nmonth<-dim(Sigma)[1]
  what=c(paste0("pumlrR_n",0:1))
  mati<-matrix(c(1,1,0,1),2,2)
  SM<-Scomppop[,what]
  X<-SM[,"pumlrR_n0"];Y<-apply(SM,1,sum)
  V<-rbind(1,-X/Y)
  sigma<-varAK(ak,Sigma)
  VV<-sapply(1:nmonth,function(i){V[,i]%*%mati%*%sigma[i,i,what,what]%*%t(V[,i]%*%mati)})/(Y^2)
  
}

varAKratmean<-function(ak,Sigma,Scomppop){
  mean(varAKrat(ak,Sigma,Scomppop))}

varAKdiffrat<-function(ak,Sigma,Scomppop){
  nmonth<-dim(Sigma)[1]
  what=c(paste0("pumlrR_n",0:1))
  mati<-matrix(c(1,1,0,0,0,1,0,0,0,0,1,1,0,0,0,1),4,4)
  X<-Scomppop[,"pumlrR_n0"];Y<-apply(Scomppop[,what],1,sum)
  V<-t(sapply(1:(nmonth-1),function(i){c(-1/Y[i],1/Y[i+1],X[i]/(Y[i]^2),-X[i+1]/(Y[i+1]^2))}))
  sigma<-aperm(varAK(ak,Sigma)[,,what,what],c(1,3,2,4))
  VV<-sapply(1:(nmonth-1),function(i){V[i,]%*%mati%*%array(sigma[i:(i+1),,i:(i+1),],rep(4,2))%*%t(V[i,]%*%mati)})
  names(VV)<-dimnames(Sigma)[[1]][-1]
  VV
}
varAKdiffratmean<-function(ak,Sigma,Scomppop){
  mean(varAKdiffrat(ak,Sigma,Scomppop))
}
varAKcompratmean<-function(ak,Sigma,Scomppop){
  mean(varAKdiffrat(ak,Sigma,Scomppop))
}

varAKcompratmean<-function(ak,Sigma,Scomppop){
  varAKdiffratmean(ak,Sigma,Scomppop)+varAKratmean(ak,Sigma,Scomppop)
}

#
if (FALSE){
  ak<-c(.2,.3)
  Sigma2<-varAK(ak,Sigma)
  ccma<-calcvarmeana(AK2_papacomprep)
  par(mfrow=c(1,3))
  sapply(listpumlrR,function(ccc){plot(ccma[,ccc,,"var"],sapply(1:85,function(i){Sigma2[i,i,ccc,ccc]}))})
  Sigma3<-varAKrat(ak,Sigma,Scomppop)
  par(mfrow=c(1,1))
  ccc<-"unemployment";plot(ccma[,ccc,,"var"],Sigma3)
  
  Sigma2<-varAKdiff(ak,Sigma)
  ccma<-calcvarmeanadiff(AK2_papacomprep,ScomppopUdiff)
  par(mfrow=c(1,3))
  sapply(listpumlrR,function(ccc){plot(ccma[,ccc,,"var"],sapply(1:84,function(i){Sigma2[i,i,ccc,ccc]}))})
  Sigma3<-varAKdiffrat(ak,Sigma,Scomppop)
  par(mfrow=c(1,1))
  ccc<-"unemployment";plot(ccma[,ccc,,"var"],Sigma3)
  
  
  
}

bestAK2<-function(Sigma,Scomppop,
                 startval=c(0.2,0.3),
                 itnmax=100,
                 what=list(level=varAKratmean,change=varAKdiffratmean,compromise=varAKcompratmean),
                 namese=c("level","change","compromise")){
  ak<-  mclapply(what,function(fn){
    oo<-optimx(startval,
               fn=fn,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma,Scomppop=Scomppop);c(oo$p1,oo$p2)})  
  names(ak)<-namese
  ak
}
