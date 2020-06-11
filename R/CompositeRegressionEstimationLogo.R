#' Creates two png logo files in a given directory
#' @param fullpath 
#' @example 
#' CompositeRegressionEstimationLogo(tempdir())
#' fs::file_show(file.path(tempdir(),"logo_4.4.png"))
#' fs::file_show(file.path(tempdir(),"logo_4.12.png"))
CompositeRegressionEstimationLogo<-function(dirpath){
  period<-200501:200512
  list.tables<-lapply(data(list=paste0("cps",period),package="dataCPS"),function(x){get(x)[c("hrmis","hrhhid","pulineno","pwsswgt","pemlr","hrintsta")]});names(list.tables)<-period
  list.tables<-lapply(list.tables,function(L){
    L[["employmentstatus"]]<-forcats::fct_collapse(factor(L[["pemlr"]]),
                                                   "e"=c("1","2"),
                                                   "u"=c("3","4"),
                                                   "n"=c("5","6","7","-1"));
    L})
  
  Direct.est<-CompositeRegressionEstimation::WS(list.tables,weight="pwsswgt",list.y = "employmentstatus")
  U<-with(as.data.frame(Direct.est),
          (employmentstatus_ne)/(employmentstatus_ne+employmentstatus_nu))
  
  library(CompositeRegressionEstimation)
  Y<-CompositeRegressionEstimation::WSrg2(list.tables,rg = "hrmis",weight="pwsswgt",y = "employmentstatus")
  Umis<-plyr::aaply(Y[,,"e"],1:2,sum)/plyr::aaply(Y[,,c("e","u")],1:2,sum);
  
  mycolors <- rainbow(8) 
  logo<-ggplot(data=reshape2::melt(Umis),aes(x=m,y=value,color=factor(hrmis),group=hrmis))+
    geom_line(size=4)+
    xlab("")+ylab("")+
    scale_colour_manual(values = mycolors)+
    guides(colour=guide_legend(title="m.i.s."))+ 
    theme(legend.position = "none",
          axis.ticks = element_blank(),
          axis.title=element_blank(),
          axis.text=element_blank(),
          plot.margin = margin(0, 0, 0, 0, "cm"),
          panel.background = element_rect(fill = "grey10"),
          plot.background = element_rect(
            fill =  "black",
            colour = "black",
            size = 1
          ),
          panel.grid.major = element_line(colour = "grey30", linetype = "dotted"),
          panel.grid.minor = element_line(colour = "grey20", size = 2))
  logo_4.4.png<-SweaveLst::graph2pngfile("print(logo)",
                                     output=tempfile(fileext = ".png"),
                                     widthe=4,
                                     heighte=4)
  
  file.copy(logo_4.4.png,file.path(dirpath,"logo_4.4.png"),overwrite=TRUE)
  
  logo_4.12.png<-SweaveLst::graph2pngfile("print(logo)",
                                         output=tempfile(fileext = ".png"),
                                         widthe=12,
                                         heighte=4)
  file.copy(logo_4.12.png,file.path(dirpath,"logo_4.12.png"),overwrite=TRUE)
}