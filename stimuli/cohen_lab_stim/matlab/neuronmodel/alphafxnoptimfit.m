%
%function [beta0,R0]=alphafxoptimfit(time,Fdata,beta1,beta2,deltabeta)
%
%       FILE NAME       : ALPHA FXN MODEL
%       DESCRIPTION     : Two segment alpha function. Used to fit EPSP or
%                         FTC PSTH with sharp onset 
%
%       time            : Time axis (msec)
%       Fdata           : Data
%       beta1,beta2     : Minimum (beta1) and maximum (beta2) alpha 
%                         fxn parameter array. Contains the following
%                         parameters: beta = [delay t1 t2 alpha]
%
%                         delay - temporal delay (msec)
%                         t1 - Rise Time Constant (msec)
%                         t2 - Decay Time Constant (msec)
%                         alpha - Alpha Function Amplitude
%       dbeta           : Step resolution for search 
%                         (Optional, Default==[1 1 1 1 1])
%
%OUTPUT SIGNAL
%
%       beta0           : Optimal Parameter Array
%       R0              : Residuals for optimum parameters
%       J0              : Jacobian Matrix for optimal parameters
%
function [beta0,R0,J0]=alphafxoptimfit(time,Fdata,beta1,beta2,dbeta)

%Input Arguments
if nargin<5
    db=1;
else
    db=dbeta;
end

R0=1E10;
for k=beta1(1):db(1):beta2(1)
    for l=beta1(2):db(2):beta2(2)
        for m=beta1(3):db(3):beta2(3)  
            for n=beta1(4):db(4):beta2(4)

                %Finding local minimum about operating point
                LB=[0 0 0 0 0];
                beta=[k l m n beta1(5)];
                [beta,Rnorm,R,EXITFLAG,OUTPUT,LAMBDA,J]=lsqcurvefit('alphafxnmodel',beta,time,Fdata,LB);
                beta
                
                %Optimum Solution
                if sum(R.^2)<sum(R0.^2)
                
                    R0=R;
                    beta0=beta;
                    J0=J;
                    
                end
                
            end
        end
    end
end