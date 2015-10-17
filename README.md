# Pairs-Trading
Pairs trading is based in the idea that returnrs of some stock pairs are cointegrated (some linear combination of the return of the stocks known as the Spread is a stationary time series). Due to being stationary, the mean of spread won't change with time and thus has a predictable behavior. We can use this property to generate profits. Whenever we see the Spread has increased and moved far from the mean, we know it will revert back. We can thus take positions in the 2 stocks to our advantage.

In this project, cointegration test, exhaustive search and walk forward testing have been implemented for Pairs trading.
coint_1_test.R
This code uses Adjusted Dickey Fuller test to identify cointegrated pairs and does regression to identify the linear combination (Spread) which would be a stationary with time.

exhaustive_search_optim.R
Once the cointegrated pair and the spread has been found, we use it in the 2nd code to do an exhaustive search on the parameters for the process. 
