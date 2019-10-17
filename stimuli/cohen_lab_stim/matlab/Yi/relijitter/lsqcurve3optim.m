function [beta,R0,J0]=lsqcurve3optim(Tau,Ydata,T,betaL,betaU)

% DESCRIPTION   : 3 parameter optimation

db=[(betaU(1)-betaL(1))/5 (betaU(2)-betaL(2))/5 (betaU(3)-betaL(3))/5];

R0=1E10;
for k=(betaL(1)+db(1)/100):db(1):betaU(1)
    for l=(betaL(2)+db(2)/100):db(2):betaU(2)
        for m=(betaL(3)+db(3)/100):db(3):betaU(3)
            beta0=[k l m];
            LB=betaL;
            UB=betaU;
            [X,Rnorm,R,EXITFLAG,OUTPUT,LAMBDA,J]=lsqcurvefit(@(X,Tau) gaussfun(X,Tau,T),beta0,Tau,Ydata,LB,UB);
            
            if sum(R.^2)<sum(R0.^2)
                R0=R;
                beta=X;
                J0=J;
            end % end of if
            
        end % end of m
    end  % end l
end  % end of k
