#' AK Estimator (recursive version)
#' 
#' @description  
#' Consider a sequence of monthly samples \eqn{(S_m)_{m\in\{1,\ldots,M\}}}. 
#' In the CPS, a sample \eqn{S_m} is the union of 8 rotation groups: 
#' \eqn{S_m=S_{m,1}\cup S_{m,2}\cup S_{m,3}\cup S_{m,4}\cup S_{m,5}\cup S_{m,6}\cup S_{m,7}\cup S_{m,8}},
#' where two consecutive samples are always such that 
#' \eqn{S_{m,2}=S_{m-1,1}},
#' \eqn{S_{m,3}=S_{m-1,2}},
#' \eqn{S_{m,4}=S_{m-1,3}},
#' \eqn{S_{m,6}=S_{m-1,5}},
#' \eqn{S_{m,7}=S_{m-1,6}},
#' \eqn{S_{m,8}=S_{m-1,7}}, and one year appart samples are always such that
#' \eqn{S_{m,5}=S_{m-12,1}},
#' \eqn{S_{m,6}=S_{m-12,2}},
#' \eqn{S_{m,7}=S_{m-12,3}},
#' \eqn{S_{m,8}=S_{m-12,4}}.
#' 
#' The subsamples \eqn{S_{m,g}} are called rotation groups, and rotation patterns different than the CPS rotation pattern are possible.
#' 
#' For each individual \eqn{k} of the sample \eqn{m}, one observes the employment status \eqn{Y_{k,m}} (A binary variable) of individual \eqn{k} at time \eqn{m}, and 
#' the survey weight \eqn{w_{k,m}}, as well as its "rotation group".
#' 
#' The AK composite estimator is defined in ``CPS Technical Paper (2006), [section 10-11]'':
#' 
#'For \eqn{m=1}, \eqn{\hat{t}_{Y_{.,1}}=\sum_{k\in S_1}w_{k,m}Y_{k,m}}.
#' 
#' For \eqn{m\geq 2}, 
#' \deqn{\hat{t}_{Y_{.,m}}= (1-K) \times \left(\sum_{k\in S_{m}} w_{k,m} Y_{k,m}\right)~+~K~\times~(\hat{t}_{Y_{.,m-1}} + \Delta_m)~+~ A~\times\hat{\beta}_m}
#' 
#' where \deqn{\Delta_m=\eta_0\times\sum_{k\in S_m\cap S_{m-1}}(w_{k,m} Y_{k,m}-w_{k,m-1} Y_{k,m-1})}
#' and \deqn{\hat{\beta}_m=\left(\sum_{k\notin S_m\cap S_{m-1}}w_{k,m} Y_{k,m}\right)~-~\eta_1~\times~\left(\sum_{k\in S_m\cap S_{m-1}}w_{k,m} Y_{k,m}\right)}
#' 
#' For the CPS, \eqn{\eta_0} is the ratio between the number of rotation groups in the sample and the number of overlaping rotation groups between two month, 
#' which is a constant  \eqn{\eta_0=4/3}; \eqn{\eta_1} is the ratio between the number of non overlaping rotation groups the number of overlaping rotation groups between two month, 
#' which is a constant of \eqn{1/3}.
#' 
#'    
#'  In the case of the CPS, the rotation group one sample unit  belongs to in a particular month  is a function
#' of the number of times it has been selected before, including this month, and so the rotation group of an individual in a particular month is called the "month in sample" variable.
#'    
#' For the CPS, in month \eqn{m} the overlap \eqn{S_{m-1}\cap      S_{m}} correspond to the individuals in the sample \eqn{S_m} with a value of month in sample equal to 2,3,4, 6,7 or 8.
#' The overlap \eqn{S_{m-1}\cap      S_{m}} correspond to the individuals in the sample \eqn{S_m} with a value of month in sample equal to 2,3,4, 6,7 or 8. as well as 
#' individuals in the sample \eqn{S_{m-1}} with a value of month in sample equal to 1,2,3, 5,6 or 7. 
#' When parametrising the function, the choice would be \code{group_1=c(1:3,5:7)} and \code{group0=c(2:4,6:8)}.
#'
#' Computing the estimators recursively is not very efficient. At the end, we get a linear combinaison of month in sample estimates
#' The functions \code{AK3}, and \code{WSrg} computes the linear combination directly and more efficiently.
#' 
#' @param list.tables a list of tables
#' @param w a character string: name of the  weights variable (should be the same in all tables)
#' @param list.y a vector of variable names
#' @param id a character string: name of the identifier variable  (should be the same in all tables)
#' @param groupvar a character string: name of the  rotation group variable (should be the same in all tables)
#' @param groups_1 a character string:
#' @param groups0  if \code{groupvar} is not null, a vector of possible values for L[[groupvar]]
#' @param eta0 a numeric value
#' @param eta1 a numeric value
#' @return
#' @details the function is based on the more general function CompositeRegressionEstimation::composite
#' @seealso CompositeRegressionEstimation::composite
#' @references  ``CPS Technical Paper (2006). Design and Methodology of the Current Population Survey. Technical Report 66, U.S. Census Bureau.", ``Gurney, M. and Daly, J. F. (1965). A multivariate approach to estimation in periodic sample surveys. In Proceedings of the Social Statistics Section, American Statistical Association, volume 242, page 257."
#' @examples
#' library(dataCPS)
#' data(cps200501,cps200502,cps200503,cps200504,
#'      cps200505,package="dataCPS") 
#' list.tables<-list(cps200501,cps200502,cps200503,cps200504,
#'                   cps200505)
#' w="pwsswgt";id=c("hrhhid","pulineno");groupvar=NULL;list.y="pemlr";dft0.y=NULL;
#' groups_1=NULL;
#' groups0=NULL;
#' Coef=c(alpha_1=0,alpha0=1,beta_1=0,beta0=0,gamma_1=0)
#' AK(list.tables,w=w,list.y="pemlr",id=id,groupvar=groupvar)
#' 
#' ## With the default choice of parameters for A,K,eta0,eta1
#' ## the composite is  equal to the direct estimator: we check
#' WS(list.tables = list.tables,weight = w,list.y = list.y)  
#' 
#' ## Example of use of a group variable. 
#' w="pwsswgt";id=NULL;groupvar="hrmis";list.y="pemlr";dft0.y=NULL;
#' groups_1=c(1:3,5:7);
#' groups0=c(2:4,6:8);
#' Coef=c(alpha0=1,alpha_1=0,beta_1=0,beta0=0,gamma_1=0)
#' AK(list.tables,w=w,list.y="pemlr",id=id,groupvar="hrmis")  
AK <-
function(list.tables,
         w,
         list.y,
         id=NULL,
         groupvar=NULL,
         groups_1=NULL,
         groups0=NULL,
         A=0,K=0,
         dft0.y=NULL,
         eta0=0,
         eta1=0){
  
  CoefAK<- c(alpha0 = (1-K),
             alpha_1 = K,
             beta0  = K*eta0-A*eta1,
             beta_1  = -K*eta0,
             gamma0 = A)
  
  return(composite(list.tables=list.tables,
                   w=w, 
                   id=id,
                   list.y=list.y, 
                   groupvar=groupvar,
                   groups_1=groups_1,
                   groups0=groups0,
                   Coef=CoefAK,
                   dft0.y=dft0.y))}


#'Add a rotation group indicator to all tables of a list when missing.
#'
#' @param list.tables a list of data.frames (order matter)
#' @param id a vector of character strings indicating the variable names for the sample unit primary key. 
#' @param rg.name a character string
#' @return a list of data.frames with a new variable named \code{rg.name}
 
 add.rg<-function(list.tables,id,rg.name){
 n<-length(list.tables)
 if(n>1){
 list.tables[[1]][[rg.name]]<-
     add.rg3(list.tables[[1]][FALSE,],
             list.tables[[1]],
             list.tables[[2]],id,rg.name)
  
 list.tables[[n]][[rg.name]]<-
     add.rg3(list.tables[[n-1]],
             list.tables[[n]],
             list.tables[[n]][FALSE,],id,rg.name)
             }
 if(n>2){
 for(i in 2:(n-1)){
 list.tables[[i]][[rg.name]]<-
     add.rg3(list.tables[[i-1]],
             list.tables[[i]],
             list.tables[[i+1]],id,rg.name)}}
}

 
#'Add a rotation group indicator to a table indicating wheter a unit is present in the previous and next samples.
#'
#' @details creates a variable named \code{rg.name} that takes values
#' 4 for elements present in the current and next tables only,
#' 3 for elements present in the current table only,
#' 2 for elements present in the previous, current and next tables,
#' 1 for elements present in the previous and current tables only.
#' 
#' depends on  dplyr, tidyr
#' @param df_1 a data frame, the previous table
#' @param df0 a data frame, the current table
#' @param df1 a data frame, the next table
#' @param id a vector of character strings indicating the variable names for the sample unit primary key. 
#' @param rg.name a character string
#' @return a list of data.frames with a new variable named \code{rg.name}
#' 
#' @examples
#' df <- expand.grid(x= 1:10, y = 1:10)
#'  df_1 <- df[sample(100,25),]
#'  df0 <- df[sample(100,25),]
#'  df1 <- df[sample(100,25),]
#'  id=c("x","y")
#'  add.rg3(df_1,df0,df1,c("x","y"))
 add.rg3<-function(df_1,df0,df1,id,rg.name="rg"){
   df0[[rg.name]]<-mutate(df0[id]%>% left_join(mutate(unique(df_1[id]),rg_1=1),by=id) %>% left_join(mutate(unique(df1[id]),rg1=-2),by=id)%>%
                                   tidyr::replace_na(list(rg_1 = 0,rg1=0)),
                                 rg=3+rg_1+rg1)$rg
   df0}