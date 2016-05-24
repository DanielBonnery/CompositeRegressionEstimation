AK3 <-
  function(dfest,
           coeff=NULL,
           ak=list(c(a1=0.2,a2=0.3,a3=0,k1=.2,k2=.3,k3=0))){
    #dfest<-WSrg(list.tables,weight="pwsswgt",list.y="pumlr")
    if(is.null(coeff)){
      coeff<-CoeffAK3(dim(dfest)[1],ak,simplify=FALSE)}
    asaa=array(apply(dfest,3,function(m1){
      apply(coeff,c(3,4),function(m2){sum(dfest*m2)})}),
      c(dim(dfest)[1],length(ak),dim(dfest)[3]))
    dmnmsak<-if(is.null(names(ak))){sapply(ak,function(x){paste0("AK2",x[1],"-",x[2])})}else{names(ak)}
    dimnames(asaa)=list(dimnames(dfest)[[1]],dmnmsak,dimnames(dfest)[[3]])
    return(aperm(asaa,c(1,3,2)))}

CoeffAK3<-function(nmonth,ak,simplify=TRUE){
  if(is.null(names(ak))){names(ak)<-1:length(ak)}
  coeff<-array(0,c(nmonth,8,nmonth,length(ak),3,3))
  dimnames(coeff)[4]<-list(sapply(ak,function(x){paste0(x[1],"-",x[2])}))
  dimnames(coeff)[[5]]<-listpumlrR
  dimnames(coeff)[[6]]<-listpumlrR
  S<-c(2:4,6:8)
  Sbar<-c(1,5)
  for (u in 1:3){
    coeff[1,,1,,u,u]<-1
    for(j in (1:length(ak))){
      a=ak[[j]][u];k=ak[[j]][3+u];
      for(i in 2:nmonth){
        coeff[,,i,j,u,u]<-coeff[,,(i-1),j,u,u]*k
        coeff[i,,i,j,u,u]<-(1-k)
        coeff[i-1,S-1,i,j,u,u]<-coeff[i-1,S-1,i,j,u,u]-k*4/3
        coeff[i,S,i,j,u,u]<-coeff[i,S,i,j,u,u]+k*4/3-8*a/3
        coeff[i,Sbar,i,j,u,u]<-coeff[i,Sbar,i,j,u,u]+8*a} }}
  coeff<-coeff/8
  if(simplify){  
    coeff=array(aperm(coeff,c(5,3,6,2,1,4)),c(nmonth*3,nmonth*8*3,length(ak)))
    dimnames(coeff)[3]<-list(names(ak))
  }
  return(coeff)}

if(FALSE){
  
  y=matrix(rnorm(nmonth*3),nmonth*3,1);
  coeff<-CoeffAK3(nmonth,list(rnorm(6)))[,,1];mean(coeff%*%X%*%y-y)
  y=rep(1:0,c(24,231))
  coeff%*%X%*%y;mean(coeff%*%X%*%y-y)
  y=rep(1:0,c(24,231))
  coeff<-CoeffYF(nmonth,Sigma);mean(coeff%*%X%*%y-y)
  a1=.1;a2=.2;k1=.1;k2=.2
  ak=list(c(a1=a1,a2=a1,a3=a1,k1=k1,k2=k1,k3=k1),c(a1=a2,a2=a2,a3=a2,k1=k2,k2=k2,k3=k2))
  coeffAK3<-CoeffAK3(nmonth,ak=ak)
  popnum<-1
  adde2<-"_1"
  nrepe=1
  #charge(paste0("coeffAK3_",popnum))    
  charge(paste0("mistotalscomp",adde2))
  mtc<-array(aperm(mistotalscomp[,,,1:nrepe,drop=FALSE],c(3,2,1,4)),c(prod(dim(mistotalscomp)[1:3]),nrepe))
  AK3comprep<-aperm(array(apply(mtc,2,function(X){apply(coeffAK3,3,function(m2){m2%*%X})}),c(3,nmonth,dim(coeffAK3)[3],nrep)),c(2,1,3,4))
  dimnames(AK3comprep)<-c(dimnames(mistotalscomp[,,,1:nrepe])[c(1,3)],list(paste0("AK3",dimnames(coeffAK3)[[3]])),list(1:nrepe))
  AK3comprep<-addU(AK3comprep)
  
  
  ak2<-list(c(.1,.1),c(.2,.2))
  coeff=CoeffAK3(nmonth,ak=ak)
  dfest=mistotalscomp[,,,1:nrep]
  AAKK2<-       AK2(dfest, coeff=coeff,ak=ak2)
  any(replicate(1000,
                (function(){x<-sample(85,1);y<-sample(3,1);z<-sample(2,1);
                            abs(AAKK2[x,y,z]-AK3comprep[x,y,z,1])>1e-8})()))
  
  charge("Sigma1")
  ak3=c(a1=a1,a2=a1,a3=a1,k1=k1,k2=k1,k3=k1)
  coeffAK3<-CoeffAK3(nmonth,list(ak3),simplify=TRUE)
  coeffAK2<-CoeffAK2(nmonth,list(ak2[[1]]))
  
  x<-sapply(c(85,3,85,8),function(x){sample(x,1)});x;
  abs(coeffAK3[(x[1]-1*3)+x[2],(x[3]-1)*8*3+(x[4]-1)*3+x[2],]-
        coeffAK2[x[3],x[4],x[1],])>1e-3;
  
  coeffAK3<-CoeffAK3(nmonth,list(ak3),simplify=FALSE)
  x<-sapply(dim(coeffAK3),function(x){sample(x,1)});x;
  any(replicate(10000,abs(coeffAK3[x[1],x[2],x[3],x[4],x[5],x[6]]-
                            coeffAK2[x[1],x[2],x[3],x[4]])>1e-3));
  
  
  varak2<-varAK(ak2[[1]],Sigma)
  varak3<-varAK3(ak3,Sigma)
  any(replicate(10000,
                (function(){x<-sapply(rep(c(85,3),each=2),function(x){sample(x,1)})
                            abs(varak2[x[1],x[2],x[3],x[4]]-varak3[x[1],x[2],x[3],x[4]])>1e-8})()))
  
  varak3[1,1,1,1]
  varak2[1,1,1,1]
  
}



CoeffAK3diff<-function(nmonth,ak,simplify=TRUE){
  coeff<-CoeffAK3(nmonth,ak,simplify=FALSE)
  coeff[,,2:nmonth,,,]<-coeff[,,2:nmonth,,,,drop=FALSE]-coeff[,,1:(nmonth-1),,,,drop=FALSE]
  coeff[,,1,,,]<-0
  if(simplify){
    coeff=array(aperm(coeff,c(5,3,6,2,1,4)),c(nmonth*3,nmonth*8*3,length(ak)))
    dimnames(coeff)[3]<-list(names(ak))}
  coeff
}



varAK3<-function(ak,Sigma){
  nmonth<-dim(Sigma)[1]
  coeff<-CoeffAK3(nmonth,list(ak))[,,1]
  XX=array(coeff%*%(array(aperm(Sigma,c(3:1,6:4)),rep(c(nmonth*8*3),2)))%*%t(coeff),rep(c(3,nmonth),2))
  dimnames(XX)<-rep(dimnames(Sigma)[c(3,1)],2)
  aperm(XX,c(2,4,1,3))}


varAK3diff<-function(ak,Sigma){
  nmonth<-dim(Sigma)[[1]]
  coeff<-CoeffAK3diff(nmonth,list(ak))[,,1]
  XX=array(coeff%*%(array(aperm(Sigma,c(3:1,6:4)),rep(c(nmonth*8*3),2)))%*%t(coeff),rep(c(3,nmonth),2))
  dimnames(XX)<-rep(dimnames(Sigma)[c(3,1)],2)
  aperm(XX,c(2,4,1,3))}

varAK3rat<-function(ak,Sigma,Scomppop){
  nmonth<-dim(Sigma)[1]
  what=c(paste0("pumlrR_n",0:1))
  mati<-matrix(c(1,1,0,1),2,2)
  SM<-Scomppop[,what]
  X<-SM[,"pumlrR_n0"];Y<-apply(SM,1,sum)
  V<-rbind(1,-X/Y)
  sigma<-varAK3(ak,Sigma)
  VV<-sapply(1:nmonth,function(i){V[,i]%*%mati%*%sigma[i,i,what,what]%*%t(V[,i]%*%mati)})/(Y^2)
}

varAK3diffrat<-function(ak,Sigma,Scomppop){
  nmonth<-dim(Sigma)[1]
  what=c(paste0("pumlrR_n",0:1))
  mati<-matrix(c(1,1,0,0,0,1,0,0,0,0,1,1,0,0,0,1),4,4)
  X<-Scomppop[,"pumlrR_n0"];Y<-apply(Scomppop[,what],1,sum)
  V<-t(sapply(1:(nmonth-1),function(i){c(-1/Y[i],1/Y[i+1],X[i]/(Y[i]^2),-X[i+1]/(Y[i+1]^2))}))
  sigma<-aperm(varAK3(ak,Sigma)[,,what,what],c(1,3,2,4))
  VV<-sapply(1:(nmonth-1),function(i){V[i,]%*%mati%*%array(sigma[i:(i+1),,i:(i+1),],rep(4,2))%*%t(V[i,]%*%mati)})
  names(VV)<-dimnames(Sigma)[[1]][-1]
  VV
}

varAK3ratmean<-function(ak,Sigma,Scomppop){mean(varAK3rat(ak,Sigma,Scomppop))}
varAK3diffratmean<-function(ak,Sigma,Scomppop){mean(varAK3diffrat(ak,Sigma,Scomppop))}
varAK3compratmean<-function(ak,Sigma,Scomppop){varAK3diffratmean(ak,Sigma,Scomppop)+varAK3ratmean(ak,Sigma,Scomppop)}

varAK3_n0<-function(ak,Sigma){varAK3(ak,Sigma)[,,"pumlrR_n0","pumlrR_n0"]}
varAK3_n1<-function(ak,Sigma){varAK3(ak,Sigma)[,,"pumlrR_n1","pumlrR_n1"]}

varAK3diff_n0<-function(ak,Sigma){varAK3diff(ak,Sigma)[,,"pumlrR_n0","pumlrR_n0"]}

varAK3_n0mean       <-function(ak,Sigma){mean(varAK3_n0(ak,Sigma))}
varAK3_n1mean       <-function(ak,Sigma){mean(varAK3_n1(ak,Sigma))}
varAK3diff_n0mean   <-function(ak,Sigma){mean(varAK3diff_n0(ak,Sigma))}

varAK3_n0mean2    <-function(ak,Sigma){varAK3_n0mean(ak2_n0to6(ak),Sigma)}
varAK3diff_n0mean2<-function(ak,Sigma){varAK3diff_n0mean(ak2_n0to6(ak),Sigma)}
varAK3_n1mean2    <-function(ak,Sigma){varAK3_n1mean(ak2_n1to6(ak),Sigma)}
varAK3_n0mean2comp    <-function(ak,Sigma){varAK3_n0mean(ak2_n0to6(ak),Sigma)+varAK3diff_n0mean(ak2_n0to6(ak),Sigma)}


#
if (FALSE){
  ak<-c(.2,.3,0,.2,.3,0)
  Sigma2<-varAK3(ak,Sigma)
  ccma<-calcvarmeana(AKcomprep)
  par(mfrow=c(1,3))
  sapply(listpumlrR,function(ccc){plot(ccma[,ccc,,"var"],sapply(1:85,function(i){Sigma2[i,i,ccc,ccc]}))})
  Sigma3<-varAK3rat(ak,Sigma,Scomppop)
  par(mfrow=c(1,1))
  ccc<-"unemployment";plot(ccma[,ccc,,"var"],Sigma3)
  
  Sigma2<-varAKdiff3(ak,Sigma)
  ccma<-calcvarmeanadiff(AK2_papacomprep,ScomppopUdiff)
  par(mfrow=c(1,3))
  sapply(listpumlrR,function(ccc){plot(ccma[,ccc,,"var"],sapply(1:84,function(i){Sigma2[i,i,ccc,ccc]}))})
  Sigma3<-varAKdiffrat(ak,Sigma,Scomppop)
  par(mfrow=c(1,1))
  ccc<-"unemployment";plot(ccma[,ccc,,"var"],Sigma3)
  
  
  
}
ak2_n0to6<-function(ak){c(ak[1],0,0,ak[2],0,0)}
ak2_n1to6<-function(ak){c(0,ak[1],0,0,ak[2],0)}

ak4to6<-function(ak){c(ak[1:2],0,ak[3:4],0)}
ak6to4<-function(ak){ak[c(1,2,4,5)]}

varAK3ratmean4<-function(ak,Sigma,Scomppop){varAK3ratmean(ak4to6(ak),Sigma,Scomppop)}
varAK3diffratmean4<-function(ak,Sigma,Scomppop){varAK3diffratmean(ak4to6(ak),Sigma,Scomppop)}
varAK3compratmean4<-function(ak,Sigma,Scomppop){varAK3compratmean(ak4to6(ak),Sigma,Scomppop)}

pen<-function(x){1000000000000000*(exp(100*(x))-100*x-5000*x^2-1)}
contraint<-function(ak){sum(pen((ak-1)*(ak>1)-ak*(ak<0)))}
varAK3ratmean4contraint<-function(ak,Sigma,Scomppop){varAK3ratmean4(ak,Sigma,Scomppop)+contraint(ak)}
varAK3diffratmean4contraint<-function(ak,Sigma,Scomppop){varAK3diffratmean4(ak,Sigma,Scomppop)+contraint(ak)}
varAK3compratmean4contraint<-function(ak,Sigma,Scomppop){varAK3compratmean4(ak,Sigma,Scomppop)+contraint(ak)}


bestAK3<-function(Sigma,Scomppop,
                  startval=c(0,0,0,0),
                  itnmax=100,
                  what=list(level=varAK3ratmean4,change=varAK3diffratmean4,compromise=varAK3compratmean4)){
  lapply(what,function(fn){
    oo<-optimx::optimx(startval,
               fn=fn,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma,Scomppop=Scomppop);
    ak4to6(c(oo$p1,oo$p2,oo$p3,oo$p4))})}


bestAK3grille<-function(Sigma,Scomppop,
                  itnmax=100,
                  what=list(level=varAK3ratmean4,change=varAK3diffratmean4,compromise=varAK3compratmean4)){
  n=4
  X=seq(0,1,length=10^n+1)
  ak3all<-lapply(X,function(x){y<-floor(x*10^(1:n));y<-(y-10*c(0,y[1:(n-1)]))/10;c(y[1:2],0,y[3:4],1,0)})
  lapply(ak3all,function(ak){})
  
  lapply(what,function(fn){
    oo<-optimx(startval,
               fn=fn,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma,Scomppop=Scomppop);
    ak4to6(c(oo$p1,oo$p2,oo$p3,oo$p4))})}




bestAK3sep<-function(Sigma,
                     startval=c(0.3,0.4,0.4,0.7),
                     itnmax=100){
  oo0 <-optimx(startval[c(1,3)],fn=varAK3_n0mean2    ,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo0d<-optimx(startval[c(1,3)],fn=varAK3diff_n0mean2,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo1 <-optimx(startval[c(1,3)],fn=varAK3_n1mean2    ,itnmax=itnmax,method="Nelder-Mead",Sigma=Sigma);
  oo0c<-optimx(startval[c(1,3)],
               fn=varAK3_n0mean2comp,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma);
list(levelsep     =c(oo0$p1 ,oo1$p1,0,oo0$p2 ,oo1$p2,0),
     changesep    =c(oo0d$p1,oo1$p1,0,oo0d$p2,oo1$p2,0),
     compromisesep=c(oo0c$p1,oo1$p1,0,oo0c$p2,oo1$p2,0))

}


bestAK3contraint<-function(Sigma,Scomppop,
                           startval=c(0.3,0.4,0.4,0.7),
                           itnmax=100,
                           what=list(levelc=varAK3ratmean4contraint,
                                     changec=varAK3diffratmean4contraint,
                                     compromisec=varAK3compratmean4contraint)){
  lapply(what,function(fn){
    oo<-optimx(startval,
               fn=fn,itnmax=itnmax,method="Nelder-Mead",
               Sigma=Sigma,Scomppop=Scomppop);
    ak4to6(c(oo$p1,oo$p2,oo$p3,oo$p4))})}


