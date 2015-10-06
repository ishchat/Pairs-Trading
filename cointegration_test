library(zoo)
library(quantmod)
library(fUnitRoots)
library(tseries)
library("PerformanceAnalytics")
 

#HDFC<-read.csv("/home/ic10636/TR/HDFC_2012_2013.csv", header=TRUE)

#HDFCBANK<-read.csv("/home/ic10636/TR/HDFCBANK_2012_2013.csv", header=TRUE)

#HDFC<-read.csv("/home/ic10636/TR/HDFC_2014.csv", header=TRUE)

#HDFCBANK<-read.csv("/home/ic10636/TR/HDFCBANK_2014.csv", header=TRUE)

#HDFC<-read.csv("/home/ic10636/TR/HDFC_2013_2014.csv", header=TRUE)

#HDFCBANK<-read.csv("/home/ic10636/TR/HDFCBANK_2013_2014.csv", header=TRUE)

HDFC<-read.csv("/home/ic10636/TR/HDFC_2015.csv", header=TRUE)

HDFCBANK<-read.csv("/home/ic10636/TR/HDFCBANK_2015.csv", header=TRUE)

HDFC_dates=as.Date(HDFC[,1])

HDFCBANK_dates=as.Date(HDFCBANK[,1])

#converting to zoo object so that zoo functionalities can be used
a <- zoo(HDFC[,2:7], HDFC_dates)

#converting to quantmod zoo object so that quantmod functionalities can be used as well as zoo
a<-as.quantmod.OHLC(a, col.names = c("Open", "High","Low", "Close","Volume", "Adjusted"), name = NULL)

#converting to zoo object so that zoo functionalities can be used
b <- zoo(HDFCBANK[,2:7], HDFCBANK_dates)

#converting to quantmod zoo object so that quantmod functionalities can be used as well as zoo
b<-as.quantmod.OHLC(b, col.names = c("Open", "High","Low", "Close","Volume", "Adjusted"), name = NULL)

symbolLst<-c("HDFC","HDFCBANK")

title<-c("HDFC vs HDFC Bank")

stockPair <- list(
 a = coredata(Cl(a)), b = coredata(Cl(b)) 
,name=title) 


testForCointegration <- function(stockPairs){

#Step 1: Calculate the daily returns
dailyRet.a <- na.omit((Delt(stockPairs$a,type="arithmetic")))
dailyRet.b <- na.omit((Delt(stockPairs$b,type="arithmetic")))
dailyRet.a <- dailyRet.a[is.finite(dailyRet.a)] #Strip out any Infs (first ret is Inf)
dailyRet.b <- dailyRet.b[is.finite(dailyRet.b)]
 
print(length(dailyRet.a))
print(length(dailyRet.b))

#Step 2: Regress the daily returns onto each other
#Regression finds BETA and C in the linear regression retA = BETA * retB + C
regression <- lm(dailyRet.a ~ dailyRet.b + 0)
beta <- coef(regression)[1]
print(paste("The beta or Hedge Ratio is: ",beta,sep=""))
plot(x=dailyRet.b,y=dailyRet.a,type="p",main="Regression of RETURNS for Stock A & B") #Plot the daily returns
lines(x=dailyRet.b,y=(dailyRet.b*beta),col="blue")#Plot in linear line we used in the regression
 
 
#Step 3: Use the regression co-efficients to generate the spread
spread <- stockPairs$a - beta*stockPairs$b #Could actually just use the residual form the regression its the same thing
spreadRet <- Delt(spread,type="arithmetic")
spreadRet <- na.omit(spreadRet)
#spreadRet[!is.na(spreadRet)]
plot((spreadRet), type="l",main="Spread Returns") #Plot the cumulative sum of the spread
plot(spread, type="l",main="Spread Actual") #Plot the cumulative sum of the spread
#For a cointegrated spread the cumsum should not deviate very far from 0
#For a none-cointegrated spread the cumsum will likely show some trending characteristics
 
#Step 4: Use the ADF to test if the spread is stationary
#can use tSeries library
adfResults <- adf.test((spread),k=0,alternative="stationary")
 
print(adfResults)
if(adfResults$p.value <= 0.05){
print(paste("The spread is likely Cointegrated with a pvalue of ",adfResults$p.value,sep=""))
} else {
print(paste("The spread is likely NOT Cointegrated with a pvalue of ",adfResults$p.value,sep=""))
}
 
}


testForCointegration(stockPair)
