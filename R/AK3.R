KCPSunemployed<-function(){.4}
KCPSemployed<-function(){.7}
ACPSunemployed<-function(){.3}
ACPSemployed<-function(){.4}


AKCPS<-function(){c(a1=ACPSunemployed(),a2=ACPSemployed(),a3=0,k1=KCPSunemployed(),k2=KCPSemployed(),k3=0)}
#dfest
AK3 <-
  function(dfest,
           coeff=NULL,
           ak=list(AKCPS())){
    #dfest<-WSrg(list.tables,weight="pwsswgt",list.y="pumlr")
    if(is.null(coeff)){
      coeff<-CoeffAK3CPSl(dim(dfest)[1],ak,simplify=FALSE)}
    asaa = abind::adrop(plyr::aaply(coeff, 1:3, function(m2) {sum(aperm(dfest,3:1) * m2)},.drop=FALSE),drop=4)
    dimnames(asaa)[[1]]<-if(is.null(names(ak))){sapply(ak,function(x){paste0("AK3","-",paste(x[c(1:2,4:5)],collapse=","))})}else{names(ak)}
    Hmisc::label(asaa)<-"AK estimates for coeffs ak, employment status i2, month m2." 
    return(aperm(asaa,c(1,3,2)))}

#ak: a list of vectors of size 6.
CoeffAK3CPSl<-function(nmonth,ak,simplify=TRUE,statuslabel=c("0","1","_1")){
  coeff<-plyr::laply(ak,function(x){CoeffAK3CPS(nmonth=nmonth,x,simplify=simplify,statuslabel=statuslabel)},.drop=FALSE)
  names(dimnames(coeff))[1]<-c("ak")
  if(!is.null(names(ak))){dimnames(coeff)[[1]]<-names(ak)}
  Hmisc::label(coeff)<-"Coefficient matrix W[ak,i2,m2,i1,mis1,m1] such that AK estimate for coefficients ak, month m2 and employment status i2 is sum(W[ak,i2,m2,,,])*Y[,,]) where Y[i1,mis1,m1] is direct estimate on mis mis1 for emp stat i1 at month m1"
return(coeff)    }
#ak: a  vector of size 6.

CoeffAK3CPS<-function(nmonth,ak,simplify=TRUE,statuslabel=c("0","1","_1")){
  coeff<-array(0,c(3,nmonth,3,8,nmonth))
  dimnames(coeff)[[1]]<-statuslabel
  dimnames(coeff)[[3]]<-statuslabel
  S<-c(2:4,6:8)
  Sbar<-c(1,5)
  for (u in 1:3){
    coeff[1,,1,u,u]<-1
    a=ak[u];k=ak[3+u];
    for(i in 2:nmonth){
      coeff[u,i,u,,]<-coeff[u,(i-1),u,,]*k
      coeff[u,i,u,,i]<-(1-k)
      coeff[u,i,u,S-1,i-1]<-coeff[u,i,u,S-1,i-1]-k*4/3
      coeff[u,i,u,S,i]<-coeff[u,i,u,S,i]+k*4/3-8*a/3
      coeff[u,i,u,Sbar,i]<-coeff[u,i,u,Sbar,i]+8*a} }
  coeff<-coeff/8
  names(dimnames(coeff))<-c("i2","m2","i1","mis1","m1")
  Hmisc::label(coeff)<-"Coefficient matrix W[i2,m2,i1,mis1,m1] such that Ak estimate for month m2 and employment status i2 is sum(W[i2,m2,,,])*Y[,,]) where Y[i1,mis1,m1] is direct estimate on mis mis1 for emp stat i1 at month m1"
  if(simplify){  
    coeff=array(coeff,c(nmonth*3,nmonth*8*3))
  }
  return(coeff)}




CoeffAK3diff<-function(nmonth,ak,simplify=TRUE){
  coeff<-CoeffAK3CPSl(nmonth,ak,simplify=FALSE)
  coeff[,,,,2:nmonth,]<-coeff[,,,,2:nmonth,,drop=FALSE]-coeff[,,,,1:(nmonth-1),,drop=FALSE]
  coeff[,,,,1,]<-0
  if(simplify){
    coeff=array(coeff,c(length(ak),nmonth*3,nmonth*8*3))
    dimnames(coeff)[1]<-list(names(ak))}
  coeff
}



varAK3<-function(ak,Sigma){
  nmonth<-dim(Sigma)[1]
  coeff<-CoeffAK3CPSl(nmonth,list(ak))[,,1]
  XX=array(coeff%*%(array(aperm(Sigma,c(3:1,6:4)),rep(c(nmonth*8*3),2)))%*%t(coeff),rep(c(3,nmonth),2))
  dimnames(XX)<-rep(dimnames(Sigma)[c(3,1)],2)
  aperm(XX,c(2,4,1,3))}


varAK3diff<-function(ak,Sigma){
  nmonth<-dim(Sigma)[[1]]
  coeff<-CoeffAK3diff(nmonth,list(ak))[,,1]
  XX=array(coeff%*%(array(aperm(Sigma,c(3:1,6:4)),rep(c(nmonth*8*3),2)))%*%t(coeff),rep(c(3,nmonth),2))
  dimnames(XX)<-rep(dimnames(Sigma)[c(3,1)],2)
  aperm(XX,c(2,4,1,3))}

varAK3rat<-function(ak,Sigma,Scomppop,what=c(unemployed="0",employed="1")){
  nmonth<-dim(Sigma)[1]
  mati<-matrix(c(1,1,0,1),2,2)
  SM<-Scomppop[,what]
  X<-SM[,what["unemployed"]];Y<-apply(SM,1,sum)
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


