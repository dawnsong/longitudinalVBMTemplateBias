library(longpower)
library(plotly)
library(reshape)
library(RColorBrewer)


rho4cross<- 0 #cross-sectional
rho4longi<- 0.1 #longitudinal
rho<-c(rho4cross, rho4longi)
#power<-0.8
sigma2cross<- 2.1 #cross-sectional
sigma2longi<- .6 #longitudinal
sigma2<-c(sigma2cross, sigma2longi)
gType<-c('Cross-sectional', 'Longitudinal')

nScan<-c(2, 3, 4, 5, 6, 7, 8, 9, 10)
delta<-.75 #fix effect size
nSubj<-2*c(5, 10, 20) #total subject size

epower <- matrix(0,length(gType)*length(nSubj)*length(nScan),4) # #subj, #scan, #power, #grp
colnames(epower)<-c('Type', 'nSubjects', 'nSessions',  'EstimatedPower')
for(grp in 1:length(gType)){
for(nsub in 1:length(nSubj)){
for(nsess in 1:length(nScan)){
  R <- matrix(rho[grp], nrow = nScan[nsess], ncol = nScan[nsess])
  diag(R) <- 1
  llp <- liu.liang.linear.power(delta=delta , N=nSubj[nsub],
                                u=list(u1 = rep(1, nScan[nsess]), # treatment
                                       u2 = rep(0, nScan[nsess])), # control       
                                v = list(v1 = rep(1, nScan[nsess]), v2 = rep(1, nScan[nsess])), # intercept
                                sigma2=sigma2[grp],
                                sig.level=0.05,
                                R=R, alternative = "two.sided" #, power=power
  )
  ep <- llp$power
  ridx <- 1+(grp-1)*length(nSubj)*length(nScan) + (nsub-1)*length(nScan) + (nsess -1)
  epower[ridx, ] <-c(gType[grp], nSubj[nsub], nScan[nsess], ep)
}  
}
}




#####################################################################
# plot  
#####################################################################
m<-as.data.frame(epower, stringsAsFactors = F)
m$Type <- as.factor(m$Type)
m$nSubjects <- as.factor(m$nSubjects) 
m$nSessions <- as.numeric(m$nSessions) 
m$EstimatedPower <- as.numeric(m$EstimatedPower)

 
plt<-ggplot(data=m, aes(y=EstimatedPower, x=nSessions, color=Type, shape=nSubjects, linetype=nSubjects))+geom_line(size=1.2)
plt<-plt + theme_bw() +theme(text=element_text(size=20), legend.position = c(.8,0.25), legend.key.width = unit(4, "line")) # +scale_color_viridis(discrete = TRUE)

#plt<-plt + ylab("Required sample size") +xlab("Effect size (Cohen's d)")
plt<-plt + xlab("Number of longitudinal sessions or cross-sectional samplings") +ylab("Estimated power") 
#plt<-plt + labs(title = "Sample size are bigger for unpaired two-sample T-test" ) #sprintf("Power=%g", power4test))
#plt<-plt + labs(title = "Cross-sectional is less powered than longitudinal, with Cohen's d as 0.75" , linetype="Total Subjects") #sprintf("Power=%g", power4test))
plt<-plt + scale_linetype_manual(values=c("dotted","dashed","solid")) #solid, dotdash, dotted, or (1,4,3)
#plt<-plt + xlim(0,500)
ggsave(sprintf("power4crossLongitudinalComparision-CohenD%g.png", delta), plt, width=12, height=7, dpi=300)
plt
