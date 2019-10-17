
% 
%  This Matlab script provides an  interactive way to reproduce
%  Example 2: Variance estimation reported in:
%  Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application in
%  Signal Processing. IEEE Signal  Processing Magazine, 
%  Vol. 15, No. 1, pp. 55-76, 1998.

%  Created by A. M. Zoubir and D. R. Iskander
%  June 1998

disp('   ')
disp('This Matlab script provides an interactive way to reproduce')
disp('Example 2: Variance estimation reported in:')
disp('Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application')
disp('in Signal Processing. IEEE Signal  Processing Magazine,')
disp('Vol. 15, No. 1, pp. 55-76, 1998.')
disp('   ')
disp('   ')
disp('                VARIANCE ESTIMATION')
disp('                -------------------')
disp('   ')
disp('   ')
disp('This example illustrates an application of the bootstrap')
disp('for estimating the variance of the parameter of a first-')
disp('order autoregressive (AR) time series. One may choose to')
disp('use dependent-data bootstrap techniques to solve this')
disp('problem.')
disp('For simplicity we proceed as in the paper indicated above')
disp('   ')
disp('STEP 0: Conduct the experiment and generate T observations,')
disp('        x_t, t=0,...,T-1, from a first-order AR process, X_t')
disp('   ')
disp('T=128; a=-0.6;')
disp('x=filter(1,[1 a],randn(1,T));')
T=128; a=-0.6;
x=filter(1,[1 a],randn(1,T));
disp('   ')
disp('Press any key to continue')
pause
disp('   ')
disp('STEP 1: Calculation of the residuals. Estimate the parameter a')
disp('        and define residuals z(t)=x(t)+hat{a}*x(t-1),t=0,...,T-1') 
disp('   ')
disp('x=x-mean(x);')
disp('c=xcov(x);')
disp('hat_a=-c(T+1)/c(T)')
x=x-mean(x);
c=xcov(x);
hat_a=-c(T+1)/c(T)
disp('hat_z=filter(1,[1 a],x);')
hat_z=filter([1 hat_a],1,x);
disp('   ')
disp('Press any key to continue')
pause
disp('   ')
disp('STEP 2: Resampling. Create a bootstrap sample by sampling the') 
disp('        the residuals with replacement and letting x^*(0)=x(0)')
disp('        and x^*(t)=-hat{a}*x^*(t-1)+z^*(t)')
disp('   ')
disp('zstar=bootrsp(hat_z);')
disp('xstar=filter(1,[1 hat_a],zstar);')
zstar=bootrsp(hat_z);
xstar=filter(1,[1 hat_a],zstar);
disp('   ')
disp('Press any key to continue')
pause
disp('   ')
disp('STEP 3: Calculation of the bootstrap estimate. After centring')
disp('        x^*(t), obtain hat{a}^* from x^*(t)')
disp('   ') 
disp('xstar=xstar-mean(xstar);')
disp('c1=xcov(xstar);')
disp('hat_astar=-c1(T+1)/c1(T)')
xstar=xstar-mean(xstar);
c1=xcov(xstar);
hat_astar=-c1(T+1)/c1(T)

disp('Press any key to continue')
pause
disp('   ')
disp('STEP 4: Repetition. Repeat steps 2 and 3 large number of times,')
disp('        say B=1000.') 
disp('    ')
disp('Zstar=bootrsp(hat_z,1000);')
disp('Xstar=filter(1,[1 hat_a],Zstar);')
disp('Xstar-ones(T,1)*mean(Xstar);')
disp('a_vector=zeros(1,1000);')
disp('for k=1:1000,')
disp('   c=xcov(Xstar(:,k));')
disp('   a_vector(k)=-c(T+1)/c(T);')
disp('end')
Zstar=bootrsp(hat_z,1000);
Xstar=filter(1,[1 hat_a],Zstar);
Xstar=Xstar-ones(T,1)*mean(Xstar);
a_vector=zeros(1,1000);
disp('    ')
disp('Please wait ...')
for k=1:1000,
  c=xcov(Xstar(:,k));
  a_vector(k)=-c(T+1)/c(T);
end
disp('    ')
disp('Press any key to continue')
pause
disp('   ')
disp('STEP 5: Variance estimation. Calculate the variance of a_vector')
disp('var_a=var(a_vector)')
var_a=var(a_vector)

disp('    ')
disp('Press any key to continue')
pause
disp('    ')
disp('End of Example 2')
