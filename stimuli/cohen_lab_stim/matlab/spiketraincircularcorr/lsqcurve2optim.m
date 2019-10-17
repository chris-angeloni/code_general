% function [beta,R0,J0]=lsqcurve4optim1(Tau,Ydata,T,betaL,betaU,lambda,lambdai)
function [beta,R0,J0]=lsqcurve2optim(X,Ydata,betaL,betaU)
% DESCRIPTION   : 2 parameter optimation with forced lambdai

%  X    :Input parameter
%    .lambdatot
%    .lambdai
%    .Tau
%    .T
%  Ydata :data to be fit
% betaL: lower limit of beta: [0 0];  
% betaU: Upper limit of beta: [T/2 2*lambda/Fm];

% beta  : beta(1):sigma; beta(2):p


db=[(betaU(1)-betaL(1))/5 (betaU(2)-betaL(2))/5];

R0=1E10;
% for l=(betaL(2)+0.00001):db(2):betaU(2)
    for k=(betaL(1)+0.00001):db(1):betaU(1)
        for l=(betaL(2)+db(2)):db(2):betaU(2)
            beta0=[k l];
            Tau=X.Tau;
            [BETA,Rnorm,R,EXITFLAG,OUTPUT,LAMBDA,J]=lsqcurvefit(@(BETA,Tau) gaussfun2(BETA,X),beta0,Tau,Ydata,betaL,betaU);
          
            if sum(R.^2)<sum(R0.^2) 
                R0=R;
                beta=BETA;
                J0=J;
            end % end of if
        end % end of l
end  % end of k

% beta0=[betaL(1)+0.00001 betaL(2)+0.00001];
% Tau=X.Tau;
% [BETA,Rnorm,R,EXITFLAG,OUTPUT,LAMBDA,J]=lsqcurvefit(@(BETA,Tau) gaussfun2(BETA,X),beta0,Tau,Ydata,betaL,betaU);
% beta=BETA;
% J0=J;
% R0=R;
       

