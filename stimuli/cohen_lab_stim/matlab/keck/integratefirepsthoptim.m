%
%function [beta0,R0,J0]=integratefirepsthoptim(Im,PSTH,beta1,beta2,L,Fs,dbeta)
%
%       FILE NAME       : INTEGRATE FIRE PSTH OPTIM
%       DESCRIPTION     : Finds the optimal IF neruon parameters so to fit
%                         the predicted PSTH to an actual PSTH.
%
%       Im              : Input Membrane Current Signal
%       PSTH            : PSTH
%       beta1,beta2     : Minimum (beta1) and maximum (beta2) integratefire
%                         model parameters: beta = [Tau Tref Nsig SNR]
%
%                         Tau  - Membrane time constant (msec) 
%                         Tref - Refractory period (msec) 
%                         Nsig - Normalized threshold (number of std)
%                         SNR  - signal to noise ration (dB)
%
%       dbeta           : Step resolution for search 
%                         (Optional, Default==[1 1 1 1])
%
%OUTPUT SIGNAL
%
%       beta0           : Optimal Parameter Array
%       R0              : Residuals for optimum parameters
%       J0              : Jacobian Matrix for optimal parameters
%
function [beta0,R0,J0]=integratefirepsthoptim(Im,PSTH,beta1,beta2,L,Fs,dbeta)

%Input Arguments
if nargin<7
    db=[1 1 1 1];
else
    db=dbeta;
end

%Adding Fs and L to Membrane current - required for INTEGRATEFIREPSTH
Im=[Fs L Im];

%Findingn Optimal Solution
R0=1E10;
for k=beta1(1):db(1):beta2(1)
    for l=beta1(2):db(2):beta2(2)
        for m=beta1(3):db(3):beta2(3)  
            for n=beta1(4):db(4):beta2(4)

                %Finding local minimum about operating point
                LB=[0 0 0 -30];
                UB=[500 20 4 30];
                beta=[k l m n]
                [beta,Rnorm,R,EXITFLAG,OUTPUT,LAMBDA,J]=lsqcurvefit('integratefirepsth',beta,Im,PSTH,LB,UB);
                
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