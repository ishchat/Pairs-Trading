# Pairs-Trading
Pairs trading is based in the idea that returnrs of some stock pairs are cointegrated (some linear combination of the return of the stocks known as the Spread is a stationary time series). Due to being stationary, the mean of spread won't change with time and thus has a predictable behavior. We can use this property to generate profits. Whenever we see the Spread has increased and moved far from the mean, we know it will revert back. We can thus take positions in the 2 stocks to our advantage.

In this project, cointegration test, exhaustive search and walk forward testing have been implemented for Pairs trading.

cointegration_test.R
This code calculates the daily close-close returns of the 2 stock pairs and performs regression on them to find the hedge ratio (Beta of the linear model).Then it uses Adjusted Dickey Fuller test on the linear model combination (Spread) to identify cointegrated pairs (Spread would be a stationary time series).

exhaustive_search_optim.R
The Pairs trading strategy is : Enter the short position when spread goes above upperThreshold as the spread will mean revert. Similary enter the long position when spread goes below lowerThreshold. The upperThreshold and lowerThreshold ar ecalculated from rolling mean and rolling standard deviations of the spread.
upperThreshold = movingAvg + nStd*movingStd
lowerThreshold = movingAvg - nStd*movingStd
Thus, there are 2 parameters in this strategy:
a.Lookback period for moving average and moving standard deviation calculation
b.Number of standard deviations from the mean to trigger a trade (nStd)
Once the cointegrated pair and the spread have been found from the first code, we use it in the 2nd code to do an exhaustive search on the combination of parameters for the strategy. 
We select those combinations which give Sharpe ratio above .5

