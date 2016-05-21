#imput:
# list of arrays
# 
nmonth=2
gamma=rchisq(3^nmonth,1)
gammaAf<-function(gamma){array(gamma,rep(3,round(log(length(gamma))/log(3))))}
gamma=gamma/sum(gamma)

gammaAk<-function(gamma,Ak,A){apply(gammaAf(gamma),Ak,sum)}
A=1:nmonth
Af<-function(y){unique(do.call(c,lapply(y,function(l){l$Ak})))}

y=lapply(-14:nmonth,
         function(i){
           Ak=i+c(0:3,12:15)
           Ak<-Ak[Ak>0&Ak<=nmonth]
           if(length(Ak)>0){
           y=array(rmultinom(1,100,gammaAk(gamma,Ak,A)),rep(3,length(Ak)))
           list(y=y,Ak=Ak)}else{NULL}})
y<-y[!sapply(y,is.null)]

likelihood<-function(gamma2,y){
  sum(sapply(y,function(l){sum(l$y*log(gammaAk(c(gamma2,1-sum(gamma2)),l$Ak,A)))}))}

library("optimx")
max.likelihood<-
  function(y,A=NULL){
    if(is.null(A)){A=Af(y)}
    oo=optimx(par=gamma[-length(gamma)],fn=likelihood,itnmax=2,method="L-BFGS-S",control=list(maximize=TRUE),lower=0,upper=1,y=y)
    oo=optimx(par=gamma[-length(gamma)],fn=likelihood,itnmax=2,method="Nelder-Mead",control=list(maximize=TRUE),y=y)
    oo=optimx(par=gamma[-length(gamma)],fn=likelihood,itnmax=2,method="L-BFGS-S",control=list(maximize=TRUE),lower=0,upper=1,y=y)
  }
  








deltarot<-function(tt,Approx=FALSE){
  x0<-tt+c(15)
  x_1<-tt+c(0:2,12:14)
  x_9<-tt+c(3)
  delta0<-c(x0,if(tt==1){x_1}else{numeric(0)},if(tt<10|Approx){x_9}else{numeric(0)})
  delta_1<-if(tt==1){numeric(0)}else{x_1}
  delta_9<-if(tt<10&!Approx){numeric(0)}else{x_9}
  return(list(delta0=delta0,delta_1=delta_1,delta_9=delta_9))
}

Delta<-lapply(1:85,deltarot)
# 
# deltarot2<-function(tt,mergee=3,powere=3){
#   totposlag<-c(0:3,9:15)
#   maxlag<-tt-1
#   mis<-tt+c(15:12,3:0)
#   
#   rellaggroups<-c(lapply(0:powere,function(i){0:i}),lapply(1:powere,function(i){i:powere}))
#   rellagroupnames<-sapply(rellaggroups,function(i){paste0("N",paste(i,collapse=""))})
#   
#   lagmis<-lapply(1:8,function(i){
#     x=if(i<5){0:(i-1)}else{c(0:(i-5),(9:12)+i-5)}
#     x<-x[x<tt]
#     })
#   
#   lagmiscut<-lapply(lagmis,function(lagss){lagss[lagss<=mergee]})
#   
#   laggroups<-lapply(rellaggroups,function(ll){
#     (1:8)[sapply(1:8,function(i){identical(lagmiscut[[i]],ll)})]})
#   
#  
#   sousgroupes<-
#     lapply(0:mergee,function(i){
#       do.call(c,
#               lapply(1:8){if(identical(lagmiscut[[i]],mis[i])mis[[i]][all(mis[[i]]==0:j)]}
#   }
#   x0<-tt+c(15)
#   x_1<-tt+c(0:2,12:14)
#   x_2<-tt+c(0:2,12:14)
#   x_3<-tt+c(0:2,12:14)
#   x_9<-tt+c(3)
#   x_10<-tt+c(0:2,12:14)
#   x_11<-tt+c(0:2,12:14)
#   x_12<-tt+c(0:2,12:14)
#   
#   delta0<-c(x0,if(tt==1){x_1}else{numeric(0)},if(tt<10|Approx){x_9}else{numeric(0)})
#   delta_1<-if(tt==1){numeric(0)}else{x_1}
#   delta_9<-if(tt<10&!Approx){numeric(0)}else{x_9}
#   return(list(delta0=delta0,delta_1=delta_1,delta_9=delta_9))
# }


soussamplesf<-function(sample1,TT){list(
  sss0=lapply(1:TT,function(tt){c(sample1[,Delta[[tt]]$delta0])}),
  sss_1=lapply(1:TT,function(tt){c(sample1[,Delta[[tt]]$delta_1])}),
  sss_9=lapply(1:TT,function(tt){c(sample1[,Delta[[tt]]$delta_9])}))}

Totalsf<-function(soussamples,tablespopA,Approx=FALSE){
  list(
    N_t=t(sapply(1:TT,function(tt){apply(tablespopA[soussamples$sss0[[tt]],,tt],2,sum)})),
    N_t_tp1=do.call(abind,c(lapply(1:(TT-1),function(tt){
      t(tablespopA[soussamples$sss_1[[tt+1]],,tt+1])%*%tablespopA[soussamples$sss_1[[tt+1]],,tt]
    }),list(along=3))),
    N_t_tp9=if(!Approx){do.call(abind,c(lapply(1:(TT-9),function(tt){
      t(tablespopA[soussamples$sss_9[[tt+9]],,tt+9])%*%tablespopA[soussamples$sss_9[[tt+9]],,tt]
    }),list(along=3)))}else{NULL})}

#AA<-function(A){array(outer(outer(1:dim(A)[1],1:dim(A)[2],paste,sep="-"),1:dim(A)[3],paste,sep="-"),dim(A))}

#param is a vector of lenght 
#ex:

Tmat<-function(param){
  pi1<-t(c(param[1:2],1-sum(param[1:2])))
  Tmatrices<-do.call(abind,c(lapply(2:TT,
                                    function(tt){
                                      A<-matrix(param[(2+(tt-2)*6)+(1:6)],3,2)
                                      cbind(A,1-A[,1]-A[,2])
                                    }),
                             list(along=3)))
  
  list(pi1=pi1,Tmatrices=Tmatrices)
}

T_1_tf<-function(T_t_tp1){
  T_1_t<-T_t_tp1
  for(tt in 2:(dim(T_t_tp1)[3])){
    T_1_t[,,tt]<-T_1_t[,,tt-1]%*%T_1_t[,,tt]}
  T_1_t}

pitf2<-function(pi1,T_1_t){
  rbind(pi1,t(sapply(1:dim(matparam$Tmatrices)[3],function(tt){
    pi1%*%T_1_t[,,tt]})))}

pitf<-function(matparam){
  pit<-matparam$pi1
  pitc<-pit
  for(tt in 1:dim(matparam$Tmatrices)[3]){
    pitc<-pitc%*%matparam$Tmatrices[,,tt]
    pit<-rbind(pit,pitc)}
  pit
}

T_t_tp1f<-function(matparam){matparam$Tmatrices}

T_t_tp9f<-function(T_t_tp1){
  do.call(abind,c(
    lapply(1:(dim(T_t_tp1)[3]-8),function(tp1){
      T_t_tp1[,,tp1]%*%
        T_t_tp1[,,tp1+1]%*%
        T_t_tp1[,,tp1+2]%*%
        T_t_tp1[,,tp1+3]%*%
        T_t_tp1[,,tp1+4]%*%
        T_t_tp1[,,tp1+5]%*%
        T_t_tp1[,,tp1+7]%*%
        T_t_tp1[,,tp1+8]})
    ,list(along=3)))}



loge<-function(AN,AT){sum(apply(cbind(c(AN),c(AT)),1,function(x){
  if(x[1]==0){0}else{if(x[2]>0){x[1]*log(x[2])}else{-1e300}}
}))}

dive<-function(AN,ATP,AT){sum(apply(cbind(c(AN),c(ATP),c(AT)),1,function(x){
  if(x[1]*x[2]==0){0}else{if(x[3]!=0){x[1]*x[2]/x[3]}else{sign(x[1]*x[2])*1e300}}
}))}




loglike<-function(param,Totals,TT,Approx=FALSE){
  matparam=Tmat(param)
  T_t_tp1<-matparam$Tmatrices
  if(!Approx){T_t_tp9<-T_t_tp9f(T_t_tp1)}
  pit<-pitf(matparam)
  10*sum(loge(Totals$N_t,pit))+
    sum(loge(Totals$N_t_tp1,T_t_tp1))+
    if(!Approx){sum(loge(Totals$N_t_tp9,T_t_tp9))}else{0}+
    -1e300*(param<0||param>1)
}

M<-do.call(abind,
           c(lapply(1:6,
                    function(i){
                      A=matrix(1*((1:6)==i),3,2);
                      cbind(A,-A[,1]-A[,2])}),list(along=3)))

gradloglike<-function(param,Totals,TT,Approx=FALSE){
  pi1prime<-matrix(c(1,0,-1,0,1,-1),3,2)
  matparam=Tmat(param)
  T_t_tp1<-matparam$Tmatrices
  T_1_t<-T_1_tf(T_t_tp1)
  T_t_tp9<-T_t_tp9f(T_t_tp1)
  pit<-pitf(matparam)
  c(sapply(1:2,function(i){
    sum(  dive(Totals$N_t,pitf(list(pi1=pi1prime[,i],Tmatrices=matparam$Tmatrices)),pit))}),
    sapply(1:(TT-1),function(tt){
      sapply(1:6,function(i){
        T_t_tp1prime<-T_t_tp1;T_t_tp1prime[,,tt]<-M[,,i]
        sel=max(1,tt-8):min(TT-9,tt)
        if(!Approx){T_t_tp9prime=T_t_tp9f(T_t_tp1prime[,,max(1,tt-8):min(TT-1,tt+8)])}
        pitp<-pitf(list(pi1=matparam$pi1,Tmatrices=T_t_tp1prime))
        10*sum(  dive(Totals$N_t[(tt+1):TT,],pitp[(tt+1):TT,],pit[(tt+1):TT,]))+
          sum(dive(Totals$N_t_tp1[,,tt],M[,,i],T_t_tp1[,,tt]))+
          if(!Approx){sum(dive(Totals$N_t_tp9[,,sel,drop=FALSE],T_t_tp9prime,T_t_tp9[,,sel,drop=FALSE]))}else{0}
      })
    }))
}


gradloglike4<-function(param,Totals,TT,Approx=FALSE){
  pi1prime<-matrix(c(1,0,-1,0,1,-1),3,2)
  matparam=Tmat(param)
  T_t_tp1<-matparam$Tmatrices
  T_1_t<-T_1_tf(T_t_tp1)
  T_t_tp9<-T_t_tp9f(T_t_tp1)
  pit<-pitf(matparam)
  c(sapply(1:2,function(i){
    sum(  Totals$N_t*dive(pitf(list(pi1=pi1prime[,i],Tmatrices=matparam$Tmatrices)),pit))}),
    sapply(1:(TT-1),function(tt){
      sapply(1:6,function(i){
        T_t_tp1prime<-T_t_tp1;T_t_tp1prime[,,tt]<-M[,,i]
        sel=max(1,tt-8):min(TT-9,tt)
        T_t_tp1prime2<-T_t_tp1prime;T_t_tp1prime2[,,-sel]<-0
        if(!Approx){T_t_tp9prime=T_t_tp9f(T_t_tp1prime2)}
        pitp<-pitf(list(pi1=matparam$pi1,Tmatrices=T_t_tp1prime))
        sum(  (Totals$N_t*dive(pitp,pit))[(tt+1):TT,])+
          sum(Totals$N_t_tp1[,,tt]*dive(M[,,i],T_t_tp1[,,tt]))+
          if(!Approx){sum(Totals$N_t_tp9*dive(T_t_tp9prime,T_t_tp9))}else{0}
      })
    }))
}



gradloglike2<-function(param,Totals,TT,Approx=FALSE){
  alpha<-min(param,(1-param),1e-8)/2;LP<-length(param)
  sapply(1:LP,function(i){
    delta<-alpha*((1:LP)==i);
    (loglike(param+delta,Totals,TT,Approx)-
       loglike(param-delta,Totals,TT,Approx))/(2*alpha)})}




initpar<-function(N_t,N_t_tp1,TT){
  x<-
    c((N_t[,1]/sum(N_t[,1]))[1:2],
      (N_t_tp1/aperm(apply(N_t_tp1,c(1,3),function(i){rep(sum(i),3)}),c(2,1,3)))[,1:2,])
  x[x==0]<-0.0001
  x[x==1]<-0.9998
  0.99*x
}

thetahat<-function(Totals,TT,Approx=FALSE,method="L-BFGS-B",itnmax=NULL){
  dimparam<-dimparamf(TT)  
    if(method=="L-BFGS-B"){
      optimx(initpar(Totals$N_t,Totals$N_t_tp1,TT),
             fn=loglike,
             gr=gradloglike,
             lower=rep(0,dimparam),
             upper=rep(1,dimparam),
             method="L-BFGS-B",
             itnmax=itnmax,
             control=list(maximize=TRUE),
             Totals=Totals,TT=TT,Approx=Approx)}
  else{   
    optimx(initpar(Totals$N_t,Totals$N_t_tp1,TT),
               fn=loglike,itnmax=itnmax,method="Nelder-Mead",
           control=list(maximize=TRUE,
                        alpha=0.9999,
                        beta=1,
                        gamma=1.001),
               Totals=Totals,TT=TT,Approx=Approx)}
  
}
