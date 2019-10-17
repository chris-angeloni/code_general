% A rudimentary statistics toolbox.
% Version 1.03, 27-Jul-95
% Copyright (c) Anders Holtsberg.
% Comments and suggestions to andersh@maths.lth.se.
%
% Distribution functions.
%   dbeta     - Beta density function.
%   dbinom    - Binomial probability function.
%   dchisq    - Chisquare density function.
%   df        - F density function.
%   dgamma    - Gamma density function.
%   dhypgeo   - Hypergeometric probability function.
%   dnorm     - Normal density function.
%   dt        - Student t density function.
%
%   pbeta     - Beta distribution function.
%   pbinom    - Binomial cumulative probability function.
%   pchisq    - Chisquare distribution function.
%   pf        - F distribution function.
%   pgamma    - Gamma distribution function.
%   phypgeo   - Hypergeometric cumulative probability function.
%   pnorm     - Normal distribution function.
%   pt        - Student t cdf.
%
%   qbeta     - Beta inverse distribution function.
%   pbinom    - Binomial inverse cdf.
%   qchisq    - Chisquare inverse distribution function.
%   qf        - F inverse distribution function.
%   qgamma    - Gamma inverse distribution function.
%   qhypgeo   - Hypergeometric inverse cdf.
%   qnorm     - Normal inverse distribution function.
%   qt        - Student t inverse distribution function.
%
%   rbeta     - Random numbers from the beta distribution.
%   rbinom    - Random numbers from the binomial distribution.
%   rchisq    - Random numbers from the chisquare distribution.
%   rf        - Random numbers from the F distribution
%   rgamma    - Random numbers from the gamma distribution.
%   rhypgeo   - Random numbers from the hypergeometric distribution.
%   rnorm     - Normal random numbers (use randn instead).
%   rt        - Random numbers from the student t distribution.
%
% Logistic regression.
%   logitfit  - Fit a logistic regression model.
%   lodds     - Log odds function.
%   loddsinv  - Inverse of log odds function.
%
% Various functions.
%   bincoef   - Binomial coefficients.
%   getdata   - Some famous multivariate data sets.
%   quantile  - Empirical quantile (percentile).
%
% Resampling methods.
%   covjack   - Jackknife estimate of the variance of a parameter estimate.
%   covboot   - Bootstrap estimate of the variance of a parameter estimate.
%   stdjack   - Jackknife estimate of the parameter standard deviation.
%   stdboot   - Bootstrap estimate of the parameter standard deviation.
%   rboot     - Simulate a bootstrap resample from a sample.
%   ciboot    - Bootstrap confidence interval.
%   test1b    - Bootstrap t test and confidence interval for the mean.
%
% Tests, confidence intervals, and model estimation.
%   cmpmod    - Compare small linear model versus large one.
%   ciquant   - Nonparametric confidence interval for quantile.
%   lsfit     - Fit a least squares model.
%   lsselect  - Select a predictor subset for regression.
%   test1n    - Tests and confidence intervals, one normal sample.
%   test1r    - Test for median equals 0 using rank test.
%   test2n    - Tests and confidence intervals, two normal samples.
%   test2r    - Test for equal location of two samples using rank test.
%
% Graphics.
%   qqnorm    - Normal probability paper.
%   qqplot    - Plot empirical quantile vs empirical quantile.
%   linreg    - Linear or polynomial regression, including plot.
%   histo     - Plot a histogram (alternative to hist).
%   plotsym   - Plot with symbols.
%   plotdens  - Draw a nonparametric density estimate.
%   identify  - Identify points on a plot by clicking with the mouse.
%   pairs     - Pairwise scatter plots.
