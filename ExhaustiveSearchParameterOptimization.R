library(zoo)
library(quantmod)
library(fUnitRoots)
library(tseries)
library("quantmod")
library("PerformanceAnalytics")

system("rm /home/ic10636/TR/mydata.csv")

system("rm /home/ic10636/TR/spread.csv")

system("rm /home/ic10636/TR/shortPositions.csv")

system("rm /home/ic10636/TR/longPositions.csv")

system("rm /home/ic10636/TR/positions.csv")

try(system("rm /home/ic10636/TR/results.csv"))

#Jan 2012 – Dec 2013; Jan 2014 – Jun 2014
#Jul 2012 – Jun 2014; Jul 2014 – Dec 2014
#Jan 2013 – Dec 2014; Jan 2015 – Jun 2015

#HDFC<-read.csv("/home/ic10636/TR/HDFC_Jan2007_Dec2008.csv", header=TRUE)

#HDFCBANK<-read.csv("/home/ic10636/TR/HDFCBANK_Jan2007_Dec2008.csv", header=TRUE)

#HDFC<-read.csv("/home/ic10636/TR/HDFC_Jul2012_Jun2014.csv", header=TRUE)

#HDFCBANK<-read.csv("/home/ic10636/TR/HDFCBANK_Jul2012_Jun2014.csv", header=TRUE)

#HDFC<-read.csv("/home/ic10636/TR/HDFC_Jan2013_Dec2014.csv", header=TRUE)

#HDFCBANK<-read.csv("/home/ic10636/TR/HDFCBANK_Jan2013_Dec2014.csv", header=TRUE)

HDFC<-read.csv("/home/ic10636/TR/HDFC_Jan2010_Jun2010.csv", header=TRUE)

HDFCBANK<-read.csv("/home/ic10636/TR/HDFCBANK_Jan2010_Jun2010.csv", header=TRUE)

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

results<-data.frame(lookback=numeric(),nStd=numeric(),SharpeRatio=numeric())

myfunction <- function(lookback, nStd) {

#print(c("lookback :",lookback)) 
#print(c("nStd :", nStd))

#We know this pair is cointegrated from the tutorial
#http://gekkoquant.com/2012/12/17/statistical-arbitrage-testing-for-cointegration-augmented-dicky-fuller/
#The tutorial found the hedge ratio to be 0.9653

stockPairs <- list(a = coredata(Cl(a)), b = coredata(Cl(b)), hedgeRatio = 0.955855267428892, name=title)

#stockPair <- list(a = Cl(a), b = Cl(b), hedgeRatio = 0.714234014925243, name=title)
 

##Most of the processing is done insode this function which takes the stockPair as input

simulateTrading <- function(stockPair) {

transaction_cost = .05

#Generate the spread
spread <- stockPair$a - stockPair$hedgeRatio*stockPair$b

write.table("spread", append = TRUE, "/home/ic10636/TR/spread.csv")

write.table(spread, append = TRUE, "/home/ic10636/TR/spread.csv")

#Strategy is if the spread is greater than +/- nStd standard deviations of it's rolling 'lookback' day standard deviation
#Then go long or short accordingly
#lookback <- 90 #look back 90 days
#nStd <- 1.5 #Number of standard deviations from the mean to trigger a trade
 
#align = "right" is important for our interpretetaion of rolling mean
movingAvg = rollmean(spread,lookback,align="right",fill=NA) #Moving average
#movingAvg = rollmean(spread,lookback,fill=NA) #Moving average
movingStd = rollapply(spread,lookback,sd,align="right",fill=NA) #Moving standard deviation / bollinger bands


write.table("movingAvg", append = TRUE, "/home/ic10636/TR/movingAvg.csv")
write.table(movingAvg, append = TRUE, "/home/ic10636/TR/movingAvg.csv")

write.table("movingStd", append = TRUE, "/home/ic10636/TR/movingStd.csv")
write.table(movingStd, append = TRUE, "/home/ic10636/TR/movingStd.csv")

upperThreshold = movingAvg + nStd*movingStd
lowerThreshold = movingAvg - nStd*movingStd

write.table("upperThreshold ", append = TRUE, "/home/ic10636/TR/upperThreshold.csv")
write.table(upperThreshold, append = TRUE, "/home/ic10636/TR/upperThreshold.csv")

write.table("lowerThreshold", append = TRUE, "/home/ic10636/TR/lowerThreshold.csv")
write.table(lowerThreshold, append = TRUE, "/home/ic10636/TR/lowerThreshold.csv")
 
aboveUpperBand <- spread>upperThreshold
belowLowerBand <- spread<lowerThreshold
 
aboveMAvg <- spread>movingAvg
belowMAvg <- spread<movingAvg
 
aboveUpperBand[is.na(aboveUpperBand)]<-0
belowLowerBand[is.na(belowLowerBand)]<-0
aboveMAvg[is.na(aboveMAvg)]<-0
belowMAvg[is.na(belowMAvg)]<-0


write.table("aboveUpperBand", append = TRUE, "/home/ic10636/TR/aboveUpperBand.csv")
write.table(aboveUpperBand, append = TRUE, "/home/ic10636/TR/aboveUpperBand.csv")

write.table("belowLowerBand", append = TRUE, "/home/ic10636/TR/belowLowerBand.csv")
write.table(belowLowerBand, append = TRUE, "/home/ic10636/TR/belowLowerBand.csv")

write.table("aboveMAvg", append = TRUE, "/home/ic10636/TR/aboveMAvg.csv")
write.table(aboveMAvg, append = TRUE, "/home/ic10636/TR/aboveMAvg.csv")

write.table("belowMAvg", append = TRUE, "/home/ic10636/TR/belowMAvg.csv")
write.table(belowMAvg, append = TRUE, "/home/ic10636/TR/belowMAvg.csv")


#We want to enter the short position when spread goes above upperThreshold. Suppose the spread mean reverts later and declines we will finally
#exit the short position when spread crosses belowMAvg. 
#We want to exit here as is it has got close to long position threshold at this point and may mean revert (and start rising) from below. 
#If that happens we start losing profit. so it is best to be safe and exit short position at belowMAvg
#Similar argument holds true for exiting the long position

#Here we calculate the position in the two stocks Using vectorisation as it faster than the while loop
#The function basically does a cumulative sum, but caps the sum to a min and max value
#In shortPositionFunc, the min limit -1 takes care of multiple triggers without any exit and limits it to -1. We only want 1 short position at a time. 
#Only if it exits can another short later happen
#In shortPositionFunc, the max limit 0 takes care of spread going below MAvg without having entered the short position in the first place (or else it would become 1 #without the cap 0)
#In longPositionFunc, the max value 1 takes care of multiple successive triggers without any exit and limits it to 1. We only want 1 long position at a time. Only if it exits can another long later happen
#In longPositionFunc, the min limit 0 takes care of spread going above MAvg without having entered the long position in the first place (or else it would become -1 #without the cap 0)
#In -1*aboveUpperBand+belowMAvg, first the 2 vectors get added together element by element resulting in -1, 0  and 1 as the outputs
#-1 is when it has crossed aboveUpperBand, 0 is when it is between aboveUpperBand and MAvg and 1 is when it is below MAvg
#shortPositionFunc when used with Reduce will get applied to first 2 elements of the sum of vectors -1*aboveUpperBand+belowMAvg
#Now you can make cases for all possible combinations of first 2 values and what will be value of shortPositions in each case
#Then reduce adds this number to the third number in the vector and produces second number. And #so on. This is happening due to accumulate = TRUE option
cappedCumSum <- function(x, y,max_value,min_value) max(min(x + y, max_value), min_value)
shortPositionFunc <- function(x,y) { cappedCumSum(x,y,0,-1) }
longPositionFunc <- function(x,y) { cappedCumSum(x,y,1,0) }
shortPositions <- Reduce(shortPositionFunc,-1*aboveUpperBand+belowMAvg,accumulate=TRUE)
longPositions <- Reduce(longPositionFunc,-1*aboveMAvg+belowLowerBand,accumulate=TRUE)

write.table("shortPositions", append = TRUE, "/home/ic10636/TR/shortPositions.csv")

write.table(shortPositions, append = TRUE, "/home/ic10636/TR/shortPositions.csv")

write.table("longPositions", append = TRUE, "/home/ic10636/TR/longPositions.csv")

write.table(longPositions, append = TRUE, "/home/ic10636/TR/longPositions.csv")

#shortPositions and longPositions will never have overlapping -1 and 1 in the same index
#So adding the two will not erase any short or long position. Positions vector will contain all shorts and long positions
positions = longPositions + shortPositions

write.table("positions", append = TRUE, "/home/ic10636/TR/positions.csv")

write.table(positions, append = TRUE, "/home/ic10636/TR/positions.csv")

#dev.new()
par(mfrow=c(2,1))
plot(movingAvg,col="red",ylab="Spread",type='l',lty=2)
title("Shell A vs B spread with bollinger bands")
lines(upperThreshold, col="red")
lines(lowerThreshold, col="red")
lines(spread, col="blue")
legend("topright", legend=c("Spread","Moving Average","Upper Band","Lower Band"), inset = .02,
lty=c(1,2,1,1),col=c("blue","red","red","red")) # gives the legend lines the correct color and width
 
plot((positions),type='l')


#Calculate spread daily ret
#stockPair$a - stockPair$hedgeRatio*stockPair$b
aRet <- Delt(stockPair$a,k=1,type="arithmetic")
bRet <- Delt(stockPair$b,k=1,type="arithmetic")
dailyRet <- aRet - stockPair$hedgeRatio*bRet
dailyRet[is.na(dailyRet)] <- 0
 

#tradingRet <- dailyRet * positions
tradingRet <- dailyRet * Lag(positions, 1) * (1-transaction_cost)

#aRet[is.na(aRet)] <- 0
#bRet[is.na(bRet)] <- 0
#tradingRet <- aRet * Lag(longPositions,1) - stockPair$hedgeRatio * bRet * Lag(shortPositions,1) 

#variable with same name as function will store return value of function
simulateTrading <- tradingRet
}

#Calling the function simulateTrading
tradingRet <- simulateTrading(stockPairs)

#HDFC_dates has order later to earlier and tradingRet has opposite order so need to do rev() so that correct data points get combined
tradingRetZoo <- zoo(tradingRet, rev(HDFC_dates))

print(head(tradingRetZoo))


#### Performance Analysis ####

#csv file has data from later to earlier dates so data frame also has same order
CNX_NIFTY <- read.csv("/home/ic10636/TR/CNX_NIFTY.csv", header=TRUE)

#CNX_NIFTY_dates has data from later to earlier dates
CNX_NIFTY_dates <- as.Date(CNX_NIFTY[,1])

#Zoo object changes order of data frame to earlier to later
#converting to zoo object so that zoo functionalities can be used
CNX_NIFTY_zoo <- zoo(CNX_NIFTY[,2:7], CNX_NIFTY_dates)


#quantmod object has order earlier to later
#converting to quantmod zoo object so that quantmod functionalities can be used as well as zoo
CNX_NIFTY_quantmod <- as.quantmod.OHLC(CNX_NIFTY_zoo, col.names = c("Open", "High","Low", "Close","Volume", "Adjusted"), name = NULL)


#Calculate returns for the index

#quantmod object has order earlier to later so Cl() has same order and then coredata which strips of any dates also has same order
#Delt retains same order of earlier to later dates. Note that earliest date will have NA as there is nothing before it to calculate delta
#indexRet <- Delt(coredata(Cl(CNX_NIFTY_quantmod)),k=1,type="arithmetic") #Daily returns
indexRet <-Delt(stockPairs$b,k=1,type="arithmetic") #Daily returns

#CNX_NIFTY_dates has order later to earlier and indexret has opposite order so need to do rev() so that correct data points get combined
indexRet <- zoo(indexRet, rev(HDFC_dates))

zooTradeVec <- merge(tradingRetZoo,indexRet) #merge the two zoo object
#zooTradeVec <- tradingRetZoo #merge the two zoo object

#colnames(zooTradeVec) <- c("Stat Arb","Index")
zooTradeVec <- na.omit(zooTradeVec)
 
#print(head(zooTradeVec))
#print(head(as.vector(zooTradeVec[,1])))
#print(head(data.frame(zooTradeVec[,1])))

#Lets see how all the strategies faired against the index
#if(FALSE){
#dev.new()
#charts.PerformanceSummary(as.data.frame(as.character(index(zooTradeVec)), coredata(zooTradeVec)),main="Performance of Statarb Strategy",geometric=FALSE)

cat("Sharpe Ratio")
print(SharpeRatio.annualized(tradingRetZoo))

return(c(SharpeRatio.annualized(tradingRetZoo), Return.annualized(tradingRetZoo), StdDev.annualized(tradingRetZoo)))

#write.table("lookback", append = TRUE, "/home/ic10636/TR/results.csv")
#write.table(lookback, append = TRUE, "/home/ic10636/TR/results.csv")
#write.table("nStd", append = TRUE, "/home/ic10636/TR/results.csv")
#write.table(nStd, append = TRUE, "/home/ic10636/TR/results.csv")
#write.table("Sharpe Ratio", append = TRUE, "/home/ic10636/TR/results.csv")
#write.table(SharpeRatio.annualized(tradingRetZoo), append = TRUE, "/home/ic10636/TR/results.csv")

} # myfunction ends here

#Exhaustive search for parameter optimization
for (lookback in seq(5,150, by = 5)) {
for (nStd in c(.5,1,1.5,2)){
SharpeRatio = myfunction(lookback, nStd)[1]
Return = myfunction(lookback, nStd)[2]
StdDev = myfunction(lookback, nStd)[3]

results<-rbind(results, data.frame(matrix(c(lookback, nStd, SharpeRatio, Return, StdDev),nrow=1)))
                            }
                                      }
colnames(results) <- c("lookback", "nStd", "SharpeRatio","Return","StdDev")
write.table("results", append = TRUE, "/home/ic10636/TR/results.csv")
write.table(results, append = TRUE, "/home/ic10636/TR/results.csv")
