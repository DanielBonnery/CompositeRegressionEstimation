AK <-
function(list.tables,
         w,
         list.y,
         id=NULL,
         groupvar=NULL,
         groups_1=NULL,
         groups_0=NULL,
         A=0,K=0,
         dft0.y=NULL){
  CoefAK<-c(Total_0=1,Total_1=1,Totalinter_1=4/3,Totalinter_0=4/3,
							Totaldiff_0=1)
      Coef <- c((1-K)*CoefAK["Total_0"],
    K           *CoefAK["Total_1"],
    -K     *CoefAK["Totalinter_1"],
    (K-A/4)*CoefAK["Totalinter_0"],
    A*CoefAK["Totaldiff_0"])
              
  return(composite(list.tables=list.tables,w=w, id=id,list.y=list.y, groupvar=groupvar,groups_1=groups_1,groups_0=groups_0,Coef=Coef,dft0.y=dft0.y))}
