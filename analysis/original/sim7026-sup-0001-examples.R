
###############################################################
# Example 1: Human papillomavirus in Girona from 2010 to 2014 #
###############################################################

##########
# 1. Data set and descriptive
##########

i=1.6; p=0.1353; T=52*5
1-pnorm(sqrt((T/2)*((1-p^2)/(1+p^2)))*(1.6-1))

data=read.csv("diagnosticat4.csv",header=TRUE,sep=";")
serie=ts(data[data[,"Setmana"]!=53,"Girona"],freq=52,start=c(2008,1))
serie2=window(serie, start=c(2010,1), end=c(2014,52))

par(las=1,font.axis=4,font.lab=4,font=2,cex=2) 
plot(serie2,col="darkgray",xlab="Period of study",
ylab="Number of cases",main="",lwd=5,xaxt = "n") 
axis(1,2010:2015,as.character(2010:2015))
axis(2)

# Exploring possible patterns of trend and seasonality in the series

t1=c(1:length(serie2))
c1=cos(2*pi*t1/52)
s1=sin(2*pi*t1/52)
c2=cos(2*pi*t1/26)
s2=sin(2*pi*t1/26)

c(summary(serie2),var(serie2))

ajustdata.serie=summary(lm(serie2~ t1+s1+c1+s2+c2)); ajustdata.serie

# Series seems to be stationary. It makes sense to perform the ACF and PACF of the series

par(mfrow=c(2,1))
par(las=1,font.axis=4,font.lab=4,font=2,cex=1.5)  
a <- acf(na.omit(serie2),main="",ylim=c(-0.15,0.15),lag.max=100,plot=FALSE)
plot(a$acf[-1],type="h",main="",xlab="Lag",ylab="ACF",
ylim=c(-0.15,0.15),las=1,xaxt="n",col="black",lwd=4)
abline(h=0)
x <- c(0,20,40,60,80,100)
y <- c(0,20,40,60,80,100)
axis(1, at=x, labels=y)
abline(h=c(2/sqrt(a$n.used),-2/sqrt(a$n.used)),lty=c(2,2),col="darkgray",lwd=4)
a <- pacf(na.omit(serie2),main="",ylim=c(-0.15,0.15),lag.max=100,plot=FALSE)
plot(a$acf,type="h",main="",xlab="Lag",ylab="PACF",
ylim=c(-0.15,0.15),las=1,xaxt="n",col="black",lwd=4)
abline(h=0)
x <- c(0,20,40,60,80,100)
y <- c(0,20,40,60,80,100)
axis(1, at=x, labels=y)
abline(h=c(2/sqrt(a$n.used),-2/sqrt(a$n.used)),lty=c(2,2),col="darkgray",lwd=4)

##########
# 2. Checking if the process is actually under-reported
##########

# Comparing if the Poisson distribution is better than the mixture of two Poisson distribution by
# using the AIC criteria.

# Poisson

y=serie2
poisson=function(p)
{
ml=NULL
for(t in 1:length(y)) ml[t]=-p[1]+y[t]*log(p[1])-log(factorial(y[t]))
return(-sum(ml))
}
res=nlm(poisson, p=c(0.5), hessian=TRUE, print.level=2)

# Mixture two Poisson

install.packages("mixtools")
library(mixtools)
x=matrix(rep(1,length(serie2)),ncol=1)
y=as.numeric(serie2)
fit=poisregmixEM(y,x,addintercept=FALSE,k=2,epsilon=1e-8,maxit=100000,verb=TRUE)
c(fit$lambda[1],exp(fit$beta)[1],exp(fit$beta)[2]) 

# AIC

aic <- function(x) 2*length(x$estimate) - (-2*x$minimum)
aic(res)			      # AIC Poisson
-2*(-388.9213)+2*3	# AIC mixture


# Using the theoretical model of ACF of Y

a=acf(na.omit(serie2),main="",ylim=c(-0.15,0.15),
lag.max=100,plot=FALSE,type="correlation")
a10=a$acf[2:10]; la10=log(a10); k=1:9

m=lm(la10~k)
summary(m)
predict(m)

par(las=1,font.axis=4,font.lab=4,font=2,cex=3)
plot(k,la10,pch=19,ylab="log(pk)",xlab="Lag",lwd=5)
lines(predict(m),lwd=5,col="darkgray")
x <- 1:9
axis(1, at=x)
text(7,-3.6,"log(pt)=-2.03-0.17k")


##########
# 3. Estimating the parameters of the model
##########

# Based on the naive method

install.packages("mixtools")
library(mixtools)
x=matrix(rep(1,length(serie2)),ncol=1)
y=as.numeric(serie2)
fit=poisregmixEM(y,x,addintercept=FALSE,k=2,epsilon=1e-8,maxit=100000,verb=TRUE)
c(fit$lambda[1],exp(fit$beta)[1],exp(fit$beta)[2]) 

# Computing alpha1, lambda1, omega and q

if(exp(fit$beta)[1]>exp(fit$beta)[2])
{
omega=1-fit$lambda[1]
q=exp(fit$beta)[2]/exp(fit$beta)[1]
p=acf(serie2,plot=FALSE)$acf[2]
a=p*(((1-omega*(1-q))+exp(fit$beta)[1]*(omega*(1-omega)*(1-q)^2))/(1-omega*(1-q))^2)
lambda=(1-a)*exp(fit$beta)[1]
}
if(exp(fit$beta)[2]>exp(fit$beta)[1])
{
omega=fit$lambda[1]
q=exp(fit$beta)[1]/exp(fit$beta)[2]
p=acf(serie2,plot=FALSE)$acf[2]
a=p*(((1-omega*(1-q))+exp(fit$beta)[2]*(omega*(1-omega)*(1-q)^2))/(1-omega*(1-q))^2)
lambda=(1-a)*exp(fit$beta)[2]
}

# Computing alpha2 and lambda 2

if(exp(fit$beta)[1]>exp(fit$beta)[2])
{
a2=acf(serie2,plot=FALSE)$acf[3]/acf(serie2,plot=FALSE)$acf[2]
l2=(1-a2)*exp(fit$beta)[1]
}
if(exp(fit$beta)[2]>exp(fit$beta)[1])
{
a2=acf(serie2,plot=FALSE)$acf[3]/acf(serie2,plot=FALSE)$acf[2]
l2=(1-a2)*exp(fit$beta)[2]
}
# Based on MLE

y=serie2

th=10+trunc(2.765+2*sqrt(2.765))
ds=NULL; ds=data.frame(x=rep(0:th,time=length(y)),y=rep(y,each=(th+1)))
dt=NULL; dt=data.frame(xt=rep(0:th,time=(th+1)),xt1=rep(0:th,each=(th+1)))

x=NULL; x=0:th

MLunder=function(p)
{

# Emission probabilities

nde=NULL
emission=function(yx)
{
pe=NULL
if(yx[1]<yx[2])   pe=0
if(yx[1]==yx[2])  pe=(1-p[3])+p[3]*(p[4]^yx[1])
if(yx[1]>yx[2])   pe=p[3]*dbinom(x=as.numeric(yx[2]),size=as.numeric(yx[1]),p=p[4])
return(pe)
}
nde=cbind(ds,pe=apply(ds,1,emission))

# Transition probabilities 

ndt=NULL
transition=function(xx)
{
pt=0			
for(k in 0:min(xx[1],xx[2]))
{
pt=pt+((p[1]^k*(1-p[1])^(xx[2]-k)*p[2]^(xx[1]-k)*factorial(xx[2]))/(factorial(k)*factorial(xx[1]-k)*factorial(xx[2]-k)))
}
return(exp(-p[2])*pt)
}
ndt=cbind(dt,pt=apply(dt,1,transition))

# Alpha(1)

ppo=0
for(i in 1:length(x))
{
ppo[i]=((exp(-(p[2]/(1-p[1])))*((p[2])/(1-p[1]))^x[i])/factorial(x[i]))*unique(nde[nde[,"y"]==y[1] & nde[,"x"]==x[i],])[3]
}

# Applying the forward algorithm. Computing the matrix ppa in order to obtain alpha_n(X_n) which allows us to obtain the LF of
# the hidden process.

ppa=matrix(NA,nrow=c(th+1),ncol=length(y))
ppa[,1]=log(unlist(ppo))

# In order to solve the problems due to under-flow, we compute in this way the alpha values.

for(j in 2:length(y))
{
for(i in 1:length(x))
{
ppa[i,j]=log(sum(exp(log(rep(unique(nde[nde[,"y"]==y[j] & nde[,"x"]==x[i],"pe"]),length(x)))+log(ndt[ndt[,"xt"]==x[i],"pt"])+ppa[,j-1])))
}
}
return(-log(sum(exp(ppa[,ncol(ppa)]))))
}

# Using the nlm procedure to obtain the MLE of the model parameters.

res=nlm(MLunder, p=c(0.504,1.372,0.868,0.377), hessian=TRUE, print.level=2)

# Confidence levels for these estimates.

IC.lower <- res$estimate-1.96*sqrt(diag(solve(res$hessian)))
IC.upper <- res$estimate+1.96*sqrt(diag(solve(res$hessian)))
cbind(IC.lower,IC.upper)

##########
# 4. Reconstructing the hidden chain using the Viterbi algorithm
##########

nde=NULL
emission=function(yx,omega,q)
{
pe=NULL
if(yx[1]<yx[2])   pe=0
if(yx[1]==yx[2])  pe=(1-omega)+omega*(q^yx[1])
if(yx[1]>yx[2])   pe=omega*dbinom(x=as.numeric(yx[2]),size=as.numeric(yx[1]),p=q)
return(pe)
}
nde=cbind(ds,pe=apply(ds,1,emission,omega=res$estimate[3],q=res$estimate[4]))

ndt=NULL
transition=function(xx,alpha,lambda)
{
pt=0			
for(k in 0:min(xx[1],xx[2]))
{
pt=pt+((alpha^k*(1-alpha)^(xx[2]-k)*lambda^(xx[1]-k)*factorial(xx[2]))/(factorial(k)*factorial(xx[1]-k)*factorial(xx[2]-k)))
}
return(exp(-lambda)*pt)
}
ndt=cbind(dt,pt=apply(dt,1,transition,alpha=res$estimate[1],lambda=res$estimate[2]))

ppo=0
for(i in 1:length(x))
{
ppo[i]=((exp(-(res$estimate[2]/(1-res$estimate[1])))*((res$estimate[2])/(1-res$estimate[1]))^x[i])/factorial(x[i]))*unique(nde[nde[,"y"]==y[1] & nde[,"x"]==x[i],])[3]
}

ppa=matrix(NA,nrow=c(th+1),ncol=length(y))
ppa[,1]=log(unlist(ppo))

for(j in 2:length(y))
{
for(i in 1:length(x))
{
ppa[i,j]=log(max(exp(log(rep(unique(nde[nde[,"y"]==y[j] & nde[,"x"]==x[i],"pe"]),length(x)))+log(ndt[ndt[,"xt"]==x[i],"pt"])+ppa[,j-1])))
}
}

# Function which allows us to apply the Viterbi algorithm based on the results of the matrix ppa.
# The matrix ppa includes the alpha values computed in each step. For each step, we get the most probable value.

viterbi.rec.func=function(x) which(x==max(x[x!="-Inf"]))-1

Xrec=apply(ppa,2,viterbi.rec.func)
Xrec=ts(Xrec, freq=52,start=c(2010,1))

# Plotting the observed and the hidden chains.

par(las=1,font.axis=4,font.lab=4,font=2,cex=2,mar = par()$mar + c(4,0,0,0),xpd=TRUE) 
plot(serie2,col="darkgray",xlab="Period of study",
ylab="Number of cases",main="",lwd=5,xaxt = "n",ylim=c(0,6)) 
lines(Xrec,col="black",main="",lwd=5)
axis(1,2010:2015,as.character(2010:2015))
axis(2)
legend(2010.8,-2, fill=c("darkgray","black"),
c("Observed process  ","Hidden process"),horiz=TRUE)


##########
# 5. Checking the model by means of the mid-pseudo-residuals.
##########

# Probability P(Yn<=yn,(Y1,Y2,...Yn-1,Yn+1,Yt))

prob=list()
for(m in 1:length(serie2))
{
serie=ts(data[data[,"Setmana"]!=53,"Girona"],freq=52,start=c(2008,1))
serie2=window(serie, start=c(2010,1), end=c(2014,52))
xt=NULL; xt=serie2[m]
pr=NULL
for(r in 0:xt)
{
serie2[m]=r
y=serie2
th=10+trunc(2.612+2*sqrt(2.612))
ds=NULL; ds=data.frame(x=rep(0:th,time=length(y)),y=rep(y,each=(th+1)))
dt=NULL; dt=data.frame(xt=rep(0:th,time=(th+1)),xt1=rep(0:th,each=(th+1)))
x=NULL; x=0:th
p=c(0.5166827,1.6229410,0.9220269,0.3256388)

LfunUINAR=function(p)
{
nde=NULL
emission=function(yx)
{
pe=NULL
if(yx[1]<yx[2])   pe=0
if(yx[1]==yx[2])  pe=(1-p[3])+p[3]*(p[4]^yx[1])
if(yx[1]>yx[2])   pe=p[3]*dbinom(x=as.numeric(yx[2]),size=as.numeric(yx[1]),p=p[4])
return(pe)
}
nde=cbind(ds,pe=apply(ds,1,emission))

ndt=NULL
transition=function(xx)
{
pt=0			
for(k in 0:min(xx[1],xx[2]))
{
pt=pt+((p[1]^k*(1-p[1])^(xx[2]-k)*p[2]^(xx[1]-k)*factorial(xx[2]))/(factorial(k)*factorial(xx[1]-k)*factorial(xx[2]-k)))
}
return(exp(-p[2])*pt)
}
ndt=cbind(dt,pt=apply(dt,1,transition))

ppo=0
for(i in 1:length(x))
{
ppo[i]=((exp(-(p[2]/(1-p[1])))*((p[2])/(1-p[1]))^x[i])/factorial(x[i]))*unique(nde[nde[,"y"]==y[1] & nde[,"x"]==x[i],])[3]
}
ppa=matrix(NA,nrow=c(th+1),ncol=length(y))
ppa[,1]=log(unlist(ppo))

for(j in 2:length(y))
{
for(i in 1:length(x))
{
ppa[i,j]=log(sum(exp(log(rep(unique(nde[nde[,"y"]==y[j] & nde[,"x"]==x[i],"pe"]),length(x)))+log(ndt[ndt[,"xt"]==x[i],"pt"])+ppa[,j-1])))
}
}
return(sum(exp(ppa[,ncol(ppa)])))
}
pr[r+1]=LfunUINAR(p)
}
prob[[m]]=pr
print(m)
}

# Probability P(Y1,Y2,...Yn-1,Yn+1,Yt)

data=read.csv("diagnosticat4.csv",header=TRUE,sep=";")
serie=ts(data[data[,"Setmana"]!=53,"Girona"],freq=52,start=c(2008,1))
serie2=window(serie, start=c(2010,1), end=c(2014,52))

L=NULL
for(k in 1:length(serie2))
{
y=NULL; y=serie2[-k]
th=10+trunc(2.612+2*sqrt(2.612))
ds=NULL; ds=data.frame(x=rep(0:th,time=length(y)),y=rep(y,each=(th+1)))
dt=NULL; dt=data.frame(xt=rep(0:th,time=(th+1)),xt1=rep(0:th,each=(th+1)))
x=NULL; x=0:th
p=c(0.5166827,1.6229410,0.9220269,0.3256388)

LfunUINAR=function(p)
{
nde=NULL
emission=function(yx)
{
pe=NULL
if(yx[1]<yx[2])   pe=0
if(yx[1]==yx[2])  pe=(1-p[3])+p[3]*(p[4]^yx[1])
if(yx[1]>yx[2])   pe=p[3]*dbinom(x=as.numeric(yx[2]),size=as.numeric(yx[1]),p=p[4])
return(pe)
}
nde=cbind(ds,pe=apply(ds,1,emission))

ndt=NULL
transition=function(xx)
{
pt=0			
for(k in 0:min(xx[1],xx[2]))
{
pt=pt+((p[1]^k*(1-p[1])^(xx[2]-k)*p[2]^(xx[1]-k)*factorial(xx[2]))/(factorial(k)*factorial(xx[1]-k)*factorial(xx[2]-k)))
}
return(exp(-p[2])*pt)
}
ndt=cbind(dt,pt=apply(dt,1,transition))

ppo=0
for(i in 1:length(x))
{
ppo[i]=((exp(-(p[2]/(1-p[1])))*((p[2])/(1-p[1]))^x[i])/factorial(x[i]))*unique(nde[nde[,"y"]==y[1] & nde[,"x"]==x[i],])[3]
}

ppa=matrix(NA,nrow=c(th+1),ncol=length(y))
ppa[,1]=log(unlist(ppo))

for(j in 2:length(y))
{
for(i in 1:length(x))
{
ppa[i,j]=log(sum(exp(log(rep(unique(nde[nde[,"y"]==y[j] & nde[,"x"]==x[i],"pe"]),length(x)))+log(ndt[ndt[,"xt"]==x[i],"pt"])+ppa[,j-1])))
}
}
return(sum(exp(ppa[,ncol(ppa)])))
}
L[k]=LfunUINAR(p)
print(k)
}

# newprobl is ut^-
# newprobu is ut^+

newprobl=NULL
for(i in 1:length(prob)) newprobl[i]=sum(prob[[i]][-length(prob[[i]])])
newprobu=unlist(lapply(prob,sum))

a=newprobl/L
b=newprobu/L
a[a>1]=0.999999999999
b[b>1]=0.999999999999

# mid-pseudo-residuals

mps=qnorm((a+b)/2)

par(mfrow=c(2,1))
par(las=1,font.axis=4,font.lab=4,font=2,cex=1.5)  
a <- acf(mps,main="",ylim=c(-0.15,0.20),lag.max=100,plot=FALSE)
plot(a$acf[-1],type="h",main="",xlab="Lag",ylab="ACF",
ylim=c(-0.20,0.20),las=1,xaxt="n",col="black",lwd=4)
abline(h=0)
x <- c(0,20,40,60,80,100)
y <- c(0,20,40,60,80,100)
axis(1, at=x, labels=y)
abline(h=c(2.60/sqrt(a$n.used),-2.60/sqrt(a$n.used)),lty=c(2,2),col="darkgray",lwd=4)
a <- pacf(mps,main="",ylim=c(-0.15,0.20),lag.max=100,plot=FALSE)
plot(a$acf,type="h",main="",xlab="Lag",ylab="PACF",
ylim=c(-0.20,0.20),las=1,xaxt="n",col="black",lwd=4)
abline(h=0)
x <- c(0,20,40,60,80,100)
y <- c(0,20,40,60,80,100)
axis(1, at=x, labels=y)
abline(h=c(2.60/sqrt(a$n.used),-2.60/sqrt(a$n.used)),lty=c(2,2),col="darkgray",lwd=4)


#####################################################
# Example 2: Botulism in Canada from 1970 from 2013 #
#####################################################

##########
# 1. Data set and descriptive
##########

data=read.csv("bot.csv", sep=";", header=TRUE, dec=",",skip=1)[,2]
data=as.numeric(as.character(data))
serie=ts(data,freq=1,start=c(1933,1))
serie=ts(data[37:80],freq=1,start=c(1970,1))
serie[41]=2
N=read.csv("popC.csv",sep=";")
N=N[38:81,]
N[,3]=N[,2]/1000000

c(summary(serie),var(serie))

par(las=1,font.axis=4,font.lab=4,font=2,cex=2) 
plot(serie,col="darkgray",xlab="Period of study",
ylab="Number of cases",main="",lwd=5,xaxt = "n") 

##########
# 2. Checking if the process is actually under-reported
##########

# In this case, as the series is not stationary, the methods applied in the previous example cannot be applied here.

##########
# 3. Estimating the parameters of the model
##########

# Based only on MLE

th=20+max(serie)
ds=NULL; ds=data.frame(x=rep(0:th,time=length(serie)),y=rep(serie,each=(th+1)))
dt=NULL; dt=data.frame(xt=rep(0:th,time=(th+1)),xt1=rep(0:th,each=(th+1)))

y=serie
x=NULL; x=0:th

MLunder=function(p)
{

# Emission probabilities

nde=NULL
emission=function(yx)
{
pe=NULL
if(yx[1]<yx[2])   pe=0
if(yx[1]==yx[2])  pe=(1-p[3])+p[3]*(p[4]^yx[1])
if(yx[1]>yx[2])   pe=p[3]*dbinom(x=as.numeric(yx[2]),size=as.numeric(yx[1]),p=p[4])
return(pe)
}
nde=cbind(ds,pe=apply(ds,1,emission))

# Transition probabilities

transition=function(xx,n)
{
pt=0			
for(k in 0:min(xx[1],xx[2]))
{
pt=pt+((p[1]^k*(1-p[1])^(xx[2]-k)*(p[2]*(n/10000000))^(xx[1]-k)*factorial(xx[2]))/(factorial(k)*factorial(xx[1]-k)*factorial(xx[2]-k)))
}
return(exp(-(p[2]*(n/10000000)))*pt)
}

# Alpha(1)

ppo=0
for(i in 1:length(x))
{
ppo[i]=((exp(-((p[2]*(N[1,2]/10000000))/(1-p[1])))*((p[2]*(N[1,2]/10000000))/(1-p[1]))^x[i])/factorial(x[i]))*unique(nde[nde[,"y"]==y[1] & nde[,"x"]==x[i],])[3]
}

# Applying the forward algorithm. Computing the matrix ppa in order to obtain alpha_n(X_n) which allows us to obtain the LF of
# the hidden process.

ppa=matrix(NA,nrow=c(th+1),ncol=length(y))
ppa[,1]=log(unlist(ppo))

# In order to solve the problems due to under-flow, we compute in this way the alpha values.

for(j in 2:length(y))
{
ndt=NULL
ndt=cbind(dt,pt=apply(dt,1,transition,n=N[j,2]))
for(i in 1:length(x))
{
ppa[i,j]=log(sum(exp(log(rep(unique(nde[{nde[,"y"]==y[j] & nde[,"x"]==x[i]},"pe"]),length(x)))+log(ndt[ndt[,"xt"]==x[i],"pt"])+ppa[,j-1])))
}
}
return(-log(sum(exp(ppa[,ncol(ppa)]))))
}

# Using the nlm procedure to obtain the MLE of the model parameters.

res=nlm(MLunder, p=c(0.5920177, 2.4752721, 0.6710520, 0.3170722), hessian=TRUE, print.level=2)

# Confidence levels for these estimates.

IC.lower <- res$estimate-1.96*sqrt(diag(solve(res$hessian)))
IC.upper <- res$estimate+1.96*sqrt(diag(solve(res$hessian)))
cbind(IC.lower,IC.upper)

##########
# 4. Reconstructing the hidden chain using the Viterbi algorithm
##########

nde=NULL
emission=function(yx,omega,q)
{
pe=NULL
if(yx[1]<yx[2])   pe=0
if(yx[1]==yx[2])  pe=(1-omega)+omega*(q^yx[1])
if(yx[1]>yx[2])   pe=omega*dbinom(x=as.numeric(yx[2]),size=as.numeric(yx[1]),p=q)
return(pe)
}
nde=cbind(ds,pe=apply(ds,1,emission,omega=res$estimate[3],q=res$estimate[4]))

transition=function(xx,n,alpha,lambda)
{
pt=0			
for(k in 0:min(xx[1],xx[2]))
{
pt=pt+((alpha^k*(1-alpha)^(xx[2]-k)*(lambda*n/10000000)^(xx[1]-k)*factorial(xx[2]))/(factorial(k)*factorial(xx[1]-k)*factorial(xx[2]-k)))
}
return(exp(-(lambda*n/10000000))*pt)
}

ppo=0
for(i in 1:length(x))
{
ppo[i]=((exp(-(res$estimate[2]*(N[1,2]/10000000)/(1-res$estimate[1])))*((res$estimate[2]*(N[1,2]/10000000))/(1-res$estimate[1]))^x[i])/factorial(x[i]))*unique(nde[nde[,"y"]==y[1] & nde[,"x"]==x[i],])[3]
}

ppa=matrix(NA,nrow=c(th+1),ncol=length(y))
ppa[,1]=log(unlist(ppo))

for(j in 2:length(y))
{
ndt=NULL
ndt=cbind(dt,pt=apply(dt,1,transition,n=N[j,2],alpha=res$estimate[1],lambda=res$estimate[2]))
for(i in 1:length(x))
{
ppa[i,j]=log(sum(exp(log(rep(unique(nde[{nde[,"y"]==y[j] & nde[,"x"]==x[i]},"pe"]),length(x)))+log(ndt[ndt[,"xt"]==x[i],"pt"])+ppa[,j-1])))
}
}

# Function which allows us to apply the Viterbi algorithm based on the results of the matrix ppa.
# The matrix ppa includes the alpha values computed in each step. For each step, we get the most probable value.

viterbi.rec.func=function(x) which(x==max(x[x!="-Inf"]))-1

Xrec=apply(ppa,2,viterbi.rec.func)
Xrec=ts(Xrec, freq=1,start=c(1970,1))

t=1970:2014

# Plotting the observed and the hidden chains.

pdf("BotuSerie.pdf",height=12,width=15)
par(las=2,font.axis=4,font.lab=4,font=2,cex=2,mar = par()$mar + c(4,0,0,0),xpd=TRUE) 
plot(y,col="darkgray",xlab="Period of study",ylab="Number of cases",main="",lwd=5,xaxt = "n",ylim=c(0,40)) 
lines(Xrec,col="black",main="",lwd=5)
lines(ts(N[,3],freq=1,start=c(1970,1)),lwd=5,col="black",lty=2)
axis(1,t[t%%3==0],as.character(t[t%%3==0]))
axis(2)
legend(1977,-17, fill=c("darkgray","black"),c("Observed process  ","Hidden process"),horiz=TRUE)
dev.off()

##########
# 5. Checking the model by means of the mid-pseudo-residuals.
##########

# Probability P(Yn<=yn,(Y1,Y2,...Yn-1,Yn+1,Yt))

prob=list()
for(m in 42:length(serie))
{
data=read.csv("bot.csv", sep=";", header=TRUE, dec=",",skip=1)[,2]
data=as.numeric(as.character(data))
serie=ts(data,freq=1,start=c(1933,1))
serie=ts(data[37:80],freq=1,start=c(1970,1))
serie[41]=2
N=read.csv("popC.csv",sep=";")
N=N[38:81,]
xt=NULL; xt=serie[m]
pr=NULL
for(r in 0:xt)
{
serie[m]=r
y=serie
th=20+max(y)
ds=NULL; ds=data.frame(x=rep(0:th,time=length(serie)),y=rep(serie,each=(th+1)))
dt=NULL; dt=data.frame(xt=rep(0:th,time=(th+1)),xt1=rep(0:th,each=(th+1)))
x=NULL; x=0:th
p=c(0.5920177, 2.4752721, 0.6710520, 0.3170722)

LfunUINAR=function(p)
{
nde=NULL
emission=function(yx)
{
pe=NULL
if(yx[1]<yx[2])   pe=0
if(yx[1]==yx[2])  pe=(1-p[3])+p[3]*(p[4]^yx[1])
if(yx[1]>yx[2])   pe=p[3]*dbinom(x=as.numeric(yx[2]),size=as.numeric(yx[1]),p=p[4])
return(pe)
}
nde=cbind(ds,pe=apply(ds,1,emission))

transition=function(xx,n)
{
pt=0			
for(k in 0:min(xx[1],xx[2]))
{
pt=pt+((p[1]^k*(1-p[1])^(xx[2]-k)*(p[2]*n/10000000)^(xx[1]-k)*factorial(xx[2]))/(factorial(k)*factorial(xx[1]-k)*factorial(xx[2]-k)))
}
return(exp(-(p[2]*n/10000000))*pt)
}

ppo=0
for(i in 1:length(x))
{
ppo[i]=((exp(-(((p[2]*N[1,2]/10000000))/(1-p[1])))*(((p[2]*N[1,2]/10000000))/(1-p[1]))^x[i])/factorial(x[i]))*unique(nde[nde[,"y"]==y[1] & nde[,"x"]==x[i],])[3]
}

ppa=matrix(NA,nrow=c(th+1),ncol=length(y))
ppa[,1]=log(unlist(ppo))

for(j in 2:length(y))
{
ndt=NULL
ndt=cbind(dt,pt=apply(dt,1,transition,n=N[j,2]))
for(i in 1:length(x))
{
ppa[i,j]=log(sum(exp(log(rep(unique(nde[{nde[,"y"]==y[j] & nde[,"x"]==x[i]},"pe"]),length(x)))+log(ndt[ndt[,"xt"]==x[i],"pt"])+ppa[,j-1])))
}
}
return(sum(exp(ppa[,ncol(ppa)])))
}
pr[r+1]=LfunUINAR(p)
}
prob[[m]]=pr
print(m)
}

# Probability P(Y1,Y2,...Yn-1,Yn+1,Yt)

data=read.csv("bot.csv", sep=";", header=TRUE, dec=",",skip=1)[,2]
data=as.numeric(as.character(data))
serie=ts(data,freq=1,start=c(1933,1))
serie=ts(data[37:80],freq=1,start=c(1970,1))
serie[41]=2
N=read.csv("popC.csv",sep=";")
N=N[38:81,]

L=NULL
for(k in 1:length(serie))
{
y=serie[-k]
th=20+max(y)
ds=NULL; ds=data.frame(x=rep(0:th,time=length(serie)),y=rep(serie,each=(th+1)))
dt=NULL; dt=data.frame(xt=rep(0:th,time=(th+1)),xt1=rep(0:th,each=(th+1)))
x=NULL; x=0:th
p=c(0.5920177, 2.4752721, 0.6710520, 0.3170722)

LfunUINAR=function(p)
{
nde=NULL
emission=function(yx)
{
pe=NULL
if(yx[1]<yx[2])   pe=0
if(yx[1]==yx[2])  pe=(1-p[3])+p[3]*(p[4]^yx[1])
if(yx[1]>yx[2])   pe=p[3]*dbinom(x=as.numeric(yx[2]),size=as.numeric(yx[1]),p=p[4])
return(pe)
}
nde=cbind(ds,pe=apply(ds,1,emission))

transition=function(xx,n)
{
pt=0			
for(k in 0:min(xx[1],xx[2]))
{
pt=pt+((p[1]^k*(1-p[1])^(xx[2]-k)*(p[2]*n/10000000)^(xx[1]-k)*factorial(xx[2]))/(factorial(k)*factorial(xx[1]-k)*factorial(xx[2]-k)))
}
return(exp(-(p[2]*n/10000000))*pt)
}

ppo=0
for(i in 1:length(x))
{
ppo[i]=((exp(-(((p[2]*N[1,2]/10000000))/(1-p[1])))*(((p[2]*N[1,2]/10000000))/(1-p[1]))^x[i])/factorial(x[i]))*unique(nde[nde[,"y"]==y[1] & nde[,"x"]==x[i],])[3]
}

ppa=matrix(NA,nrow=c(th+1),ncol=length(y))
ppa[,1]=log(unlist(ppo))

for(j in 2:length(y))
{
ndt=NULL
ndt=cbind(dt,pt=apply(dt,1,transition,n=N[j,2]))
for(i in 1:length(x))
{
ppa[i,j]=log(sum(exp(log(rep(unique(nde[{nde[,"y"]==y[j] & nde[,"x"]==x[i]},"pe"]),length(x)))+log(ndt[ndt[,"xt"]==x[i],"pt"])+ppa[,j-1])))
}
}
return(sum(exp(ppa[,ncol(ppa)])))
}
L[k]=LfunUINAR(p)
print(k)
}

# newprobl is ut^-
# newprobu is ut^+

newprobl=NULL
for(i in 1:length(prob)) newprobl[i]=sum(prob[[i]][-length(prob[[i]])])
newprobu=unlist(lapply(prob,sum))

a=newprobl/L
b=newprobu/L
a[a>1]=0.999999999999
b[b>1]=0.999999999999

# mid-pseudo-residuals

mps=qnorm((a+b)/2)

pdf("ValidaBotu.pdf",height=15,width=20)
par(mfrow=c(2,1))
par(las=1,font.axis=4,font.lab=4,font=2,cex=1.5)  
a <- acf(mps,main="",ylim=c(-0.15,0.20),lag.max=100,plot=FALSE)
plot(a$acf[-1],type="h",main="",xlab="Lag",ylab="ACF",
ylim=c(-0.35,0.35),las=1,xaxt="n",col="black",lwd=4)
abline(h=0)
x <- c(0,20,40,60,80,100)
y <- c(0,20,40,60,80,100)
axis(1, at=x, labels=y)
abline(h=c(2/sqrt(a$n.used),-2/sqrt(a$n.used)),lty=c(2,2),col="darkgray",lwd=4)
a <- pacf(mps,main="",ylim=c(-0.15,0.20),lag.max=100,plot=FALSE)
plot(a$acf,type="h",main="",xlab="Lag",ylab="PACF",
ylim=c(-0.35,0.35),las=1,xaxt="n",col="black",lwd=4)
abline(h=0)
x <- c(0,20,40,60,80,100)
y <- c(0,20,40,60,80,100)
axis(1, at=x, labels=y)
abline(h=c(2/sqrt(a$n.used),-2/sqrt(a$n.used)),lty=c(2,2),col="darkgray",lwd=4)
dev.off()



