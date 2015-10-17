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
We select those combinations which give Sharpe ratio above 0.5

WalkForwardTesting.R
Walk-forward testing described here: http://www.easyexpertforex.com/walk-forward-analysis.html
Backtesting vs. Walk forward analysis: http://www.forexfactory.com/showthread.php?t=459242
Backtesting :
The first dataset, we use to optimise our parameters on, is called "in-sample" (is). The second, unseen, dataset is called "out-of-sample" (oos).
Pros:
We now have a lower chance to get overfitted parameters, as we use an independent dataset to validate our parameter-choices.
Cons:
a.Due to the infinite amount of senseless/unsound relationships within the markets, we still have a (too high) risk for overfitting, as chances are too high that we just got parameters that are valid (curvefitted) on both datasets, but not valid in the future.
If the system did not work in out-of-sample and you then begin to tune your parameters until you get good oos-results, your oos-results are not longer "unseen" and becoming "in-sample", which makes the whole approach using 2 datasets useless!
b.We still use a very larg part of our data (in-sample) to find the best parameters, which also means we use a lot "old" data. That is not a good decision as the behaviour of the markets in the past is not equal to the behaviour of today.
c.Not just our in-sample dataset is too huge, also our out-of-sample dataset is too huge and therefore un-realistic. In the example above it would be a few years, but would you really like to trade a system for years before choosing new, re-adjusted, parameters? I would not!

Walk Forward Analysis: It is the same thing like doing a normal back- & out of sample-test, but we do it over and over again, so we end up not just with 1 test-case but with many (100-150 in most cases, up to 1000 if we choose very small test-period).
That way we can verify our system + our optimisation-methodology on many, many independent test-cases, which is THE reason why we want to use WFA instead of every other analysis-method described in here.
Pros:
For our final analysis-report, we only take into account the green test-results, as they are the "unseen future" relative to the red optimisation-windows.
That way, we simulate the same process we would face during live trading: Optimisation on the past, trading on the (relative) future!
That allows us to draw meaningfull answers to the initial question, as we only analyse performance in "the future".
We use all data available for our testing
We have 100-150 independent "PAST=>FUTURE"-relationship-tests, which gives us a clue about the future performance, not the past performance!
We avoid overfitting, as we use different datasets to optimise and verify our parameters
If we want to trade live, we simply make "one more step" of the WFA, optimise on the last available data (the "red" dataset would then end at the end of the chart), and then trade "in the future" (the "green" dataset would be our live trading). So we trade the system using the EXACT same methodology we have tested 100-150 times already.
Due to the frequent re-optimisation of parameters, the EA is also continuously re-adapted to the markets, which will most likely increase the overall profit.
A traditional backtest answers the question "How good was my EA in the past", whereas a Walk Forward Analysis answers the question "How good will my EA be in the future, during live trading".
It does not only evaluate an EA, it also evaluates the corresponding trading plan that determines how to pick the best parameters for live trading.
Cons:
Most EAs will not pass this test. But this is not bad, because lets be honest, almost all EAs in existance are bullshit. So if almost all EAs tested with this approach would give bad results, that would be great.

Now coming back to our code description:
From the resulting parameters of the exhaustive search, we begin walk-forward analysis. We take 2 years of training data and use the optimized parameter combinations (which gave Sharpe Ratio>0.5 from exhaustive search) to see Sharpre Ratio. Then we take 6 months of data for validation (in terms of Sharpe ratio) of this parameter combinations. Whichever combinations pass the test, we subject them to next stage oWalk forward analysis by sliding our training data window and validation data windows 6 months in the future. We repreat above procedure and keep sliding the windows 6 months at a time to ultimately reach few combinations which performed well throughout the whole Walk forward analysis.

