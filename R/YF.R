#Sigma: an array  
CoeffYF<-function(Sigma,nmonth=dim(Sigma)[[2]]){
  Sigg<-array(aperm(Sigma,c(3,2,1,6,5,4)),rep(nmonth*8*3,2))
  XX<-t(matrix(rep(diag(3),8),3,24))
  X<-as.matrix(Matrix::.bdiag(lapply(1:nmonth,function(i){XX})))
  Xplus<-t(X)/8
  M<-diag(nmonth*8*3)-X%*%Xplus
  gi<-MASS::ginv(M%*%Sigg%*%M)
  W<-Xplus%*%(diag(nmonth*8*3)-M)%*%(diag(nmonth*8*3)-Sigg%*%gi)
  return(W)}

CoeffS2<-function(nmonth){
  XX<-t(matrix(rep(diag(3),8),3,24))
  X<-as.matrix(.bdiag(lapply(1:nmonth,function(i){XX})))
  Xplus<-t(X)/8
  W<-Xplus
  return(W)}
