% Bootstrap Toolbox
%
%              Communications & Information Processing Group
%            Cooperative Research Centre for Satellite Systems
%          School of Electrical & Electronic Systems Engineering
%               Queensland University of Technology, 1998
%
%                       "Bootstrap Matlab Toolbox" 
%                                Ver 2.0
%
%               Abdelhak M. Zoubir and D. Robert Iskander
%
%
%
%  bootrsp     -  Bootstrap resampling procedure (univariate)
%  bootrsp2    -  Bootstrap resampling procedure (bivariate)
%  boottest    -  Bootstrap-based hypothesis test with pivoted
%                 test statistic (nested bootstrap)
%  boottestnp  -  Bootstrap-based hypothesis test with unpivoted
%                 test statistic 
%  boottestvs  -  Bootstrap-based hypothesis test with variance 
%                 stabilisation 
%  bpestcir    -  Procedure based on a circular block bootstrap 
%                 that estimates the variance of an estimator 
%  bpestdb     -  Procedure based on a double block bootstrap 
%                 that estimates the variance of an estimator 
%  confint     -  Confidence interval of the estimator of a parameter
%                 based on the bootstrap percentile-t method 
%  confintp    -  Confidence interval of the estimator of a parameter
%                 based on the bootstrap percentile method 
%  confinth    -  Confidence interval of the estimator of a parameter
%                 based on the bootstrap hybrid method
%  jackest     -  Jackknife estimator
%  jackrsp     -  Jackknife resampling procedure
%  segmcirc    -  Procedure that obtains a specified number of 
%                 overlapping or non-overlapping segments from 
%                 the "wrapped" around input data. Used in circular 
%                 block bootstrap procedures.
%  segments    -  Procedure that obtains a number of overlapping
%                 or non-overlapping segments from the input data.
%                 Used in block of blocks bootstrap procedures.
%  smooth      -  A running line smoother that fits the data 
%                 by linear least squares. Used to compute the
%                 variance stabilising transformation.
%                 (Thanks to Hwa-Tung Ong) 
%
%
%  example1    -  Confidence interval for the mean.
%  example2    -  Variance estimation
%  example4    -  Confidence interval for the mean (percentile-t)
%  example5    -  onfidence interval for the correlation coefficient
