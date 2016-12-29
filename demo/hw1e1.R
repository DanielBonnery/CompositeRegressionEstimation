names(rateofreturn)[2]<-"Rate"
rateofreturn$Sector<-as.factor(rateofreturn$Sector)
#save(rateofreturn,file="data/rateofreturn.rdata")
data("rateofreturn")
anova(  lm(Rate~Sector,data=rateofreturn)  )
write.csv(rateofreturn,"../../Data/rateofreturn.csv")
