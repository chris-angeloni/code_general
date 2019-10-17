
% 
%  This Matlab script provides an interactive way to reproduce 
%  Example 4: Confidence interval for the mean reported in:
%  Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application in
%  Signal Processing. IEEE Signal  Processing Magazine, 
%  Vol. 15, No. 1, pp. 55-76, 1998.

%  Created by A. M. Zoubir and D. R. Iskander
%  June 1998
disp('   ')
disp('This Matlab script provides an interactive way to reproduce')
disp('Example 4: Confidence interval for the mean reported in:')
disp('Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application')
disp('in Signal Processing. IEEE Signal  Processing Magazine,')
disp('Vol. 15, No. 1, pp. 55-76, 1998.')
disp('   ')
disp('   ')
disp('           CONFIDENCE INTERVAL FOR THE MEAN')
disp('           --------------------------------')
disp('   ')
disp('   ')
disp('As in Example 1, let X_1,...,X_n be a random sample from')
disp('some unknown distribution with mean mu and variance sigma^2.') 
disp('We wish to find an estimator of mu with a (1-alpha)100%') 
disp('confidence interval. Let hat{mu} and hat{sigma^2} be the sample')
disp('mean and the sample variance of X, respectively. Alternatively')
disp('to Example 1, we will base our method for finding a confidence')
disp('interval for mu on the statistic')
disp('   ')
disp('                               hat{mu}-mu')
disp('                hat{mu_gamma}=------------ ')
disp('                               hat{sigma2}')
disp('   ')
disp('which asymptotically has a distribution that is free of unknown')
disp('parameters. A procedure for calculating a confidence interval is')
disp('described in Table 8 of aforementioned paper. Such an interval')
disp('is known as a percentile-t confidence interval.')
disp('   ')
disp('Press any key to continue')
pause
disp('We will generate first some data.')
disp('X=randn(1,20);')
X=randn(1,20);
disp('   ')
disp('Calculate the percentile-t confidence interval using')
disp('[Lo,Up]=confint(X,''mean'',0.05,199,25)')
disp('    ')
disp('Please wait ...')
[Lo,Up]=confint(X,'mean',0.05,199,25)
disp('Press any key to continue')
pause
disp('    ')
disp('End of Example 4')
