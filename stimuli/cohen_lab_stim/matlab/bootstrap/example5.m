
% 
%  This Matlab script provides an interactive way to reproduce 
%  Example 5: Confidence interval for the correlation coefficient
%  reported in:
%  Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application in
%  Signal Processing. IEEE Signal  Processing Magazine, 
%  Vol. 15, No. 1, pp. 55-76, 1998.

%  Created by A. M. Zoubir and D. R. Iskander
%  June 1998

disp('   ')
disp('This Matlab script provides an interactive way to reproduce')
disp('Example 5: Confidence interval for the correlation coefficient')
disp('reported in:')
disp('Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application')
disp('in Signal Processing. IEEE Signal  Processing Magazine,')
disp('Vol. 15, No. 1, pp. 55-76, 1998.')
disp('   ')
disp('   ')
disp('   CONFIDENCE INTERVAL FOR THE CORRELATION COEFFICIENT')
disp('   ---------------------------------------------------')
disp('   ')
disp('   ')
disp('This example illustrates an application of the bootstrap')
disp('for estimating a confidence interval for the correlation')
disp('coefficient.')
disp('   ')
disp('Suppose that X=Z1+W and Y=Z2+W, where Z1, Z2, and W are')
disp('pairwise independent and identically distributed. In this')
disp('case, the correlation coefficient of X and Y is rho=0.5.')
disp('We draw n=15 realizations of Z1, Z2, and W.')
disp('   ')
disp('n=15;w=randn(1,n);z1=randn(1,n);z2=randn(1,n);')
n=15;w=randn(1,n);z1=randn(1,n);z2=randn(1,n);
disp('    ')
disp('x=z1+w; y=z2+w;')
x=z1+w; y=z2+w;
disp('    ')
disp('Press any key to continue')
pause
disp('Knowing that the distribution of Z1, Z2, and W is Gaussian,')
disp('one can calculate the 95% confidence interval as')
disp('    ')
disp('C=corrcoef(x,y);rho=C(1,2);')
C=corrcoef(x,y);rho=C(1,2);
disp('Lo=tanh(-1.96/sqrt(n-3)+rho)')
disp('Up=tanh(1.96/sqrt(n-3)+rho)')
Lo=tanh(-1.96/sqrt(n-3)+rho)
Up=tanh(1.96/sqrt(n-3)+rho)
disp('Press any key to continue')
pause
disp('On the other hand, we can use bootstrap percentile-t method')
disp('[Lo,Up]=confint(x,''correl'',0.05,199,25,y)')
disp('    ')
disp('Please wait ...')
[Lo,Up]=confint(x,'correl',0.05,199,25,y)
disp('Press any key to continue')
pause

disp('   ')
disp('End of Example 5')
