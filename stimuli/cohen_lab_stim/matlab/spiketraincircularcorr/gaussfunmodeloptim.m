%
%function [beta,R0,J0]=gaussfunmodeloptim(X,Ydata)
%
%   FILE NAME       : GAUSS FUN MODEL OPTIM
%   DESCRIPTION     : Optimized sums of gaussian model used to fit circular
%                     shuffled correlogram. Edited version of LSQCURVE2OPTIM
%                     originally written by Yi.
%
%   X               : Data structure containing input information
%
%     .lambdatot    : Measured firing rate (spikes/sec)
%     .Tau          : Correlation delay axis (msec)
%     .Fm           : Modulation Frequency (Hz)
%
%   Ydata           : Measured correlogram
%
%RETURNED VALUES
%
%   beta            : Optimal model parameters
%
%                     beta(1) = sigma (msec)
%                     beta(2) = x_hat, number of reliable spikes per cycle
%
% (C) Monty A. Escabi, May 2011
%
function [beta,R0,J0]=gaussfunmodeloptim(X,Ydata)

%Upper and lower bound on model parameters
Fm=X.Fm;
T=1/Fm;
lambda=X.lambda;
betaL=[0 0];
betaU=[T/2*1000 lambda/Fm];     %Sigma provided in msec

%Step size
db=[(betaU(1)-betaL(1))/5 (betaU(2)-betaL(2))/5];

%Optimizing the model
R0=1E10;
% for l=(betaL(2)+0.00001):db(2):betaU(2)
    for k=(betaL(1)+0.00001):db(1):betaU(1)
        for l=(betaL(2)+db(2)):db(2):betaU(2)
            beta0=[k l];
            Tau=X.Tau;
            [BETA,Rnorm,R,EXITFLAG,OUTPUT,LAMBDA,J]=lsqcurvefit('gaussfunmodel',beta0,X,Ydata,betaL,betaU);
          
            if sum(R.^2)<sum(R0.^2) 
                R0=R;
                beta=BETA;
                J0=J;
            end % end of if
        end % end of l
end  % end of k

%Make Sure Beta(2) is within bounds
if BETA(2)*Fm>lambda
   BETA(2)=lambda/Fm; 
end
% beta0=[betaL(1)+0.00001 betaL(2)+0.00001];
% Tau=X.Tau;
% [BETA,Rnorm,R,EXITFLAG,OUTPUT,LAMBDA,J]=lsqcurvefit(@(BETA,Tau) gaussfun2(BETA,X),beta0,Tau,Ydata,betaL,betaU);
% beta=BETA;
% J0=J;
% R0=R;