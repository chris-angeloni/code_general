%
%function [GModel]=strfgaborfit(STRFs,STRF,taxis,faxis,n,theta,betaLB,betaUB)
%
%   FILE NAME       : STRF GABOR FIT
%   DESCRIPTION     : STRF model opimization routine. The STRF is fitted
%                     using a least squares minimization procedure. The
%                     temporal and spectral receptive fields are fitted
%                     with a gabor function.
%
%   STRFs           : Significant STRF
%   STRFm           : Original STRF
%   taxis           : Frequency Axis (Hz)
%   faxis           : Time axis (sec)
%   n               : Maximum number of iterations
%   theta           : Target error percentage
%   betaLB          : Lower bound for model parameters (Optional)
%   betaUB          : Upper bound for model parameters (Optional)
%
%RETURNED VARIABLES
%
%   GMOdel           : Data structure containing the following model
%                      results
%   .taxis           : Time axis (msec)
%   .faxis           : Frequency Axis
%   .STRFm1          : First order STRF model
%   .STRFm2          : Second order STRF model
%   .beta1           : STRF parameter vector
%       PARAMETERS FOR FIRST STRF COMPONENTS
%                     beta(1): Peak delay (msec)
%                     beta(2): Gaussian temporal duration (msec)
%                     beta(3): Best temporal modulation frequency (Hz)
%                     beta(4): Temporal phase (0-2*pi)
%                     beta(5): Time warping coefficient
%                     beta(6): Best octave frequency, xo
%                     beta(7): Gaussian spectral bandwidth (octaves)
%                     beta(8): Best spectral modulation frequency (cycles/octave)
%                     beta(9): Spectral phase (0-2*pi)
%                     beta(10): Peak Amplitude
%       PARAMETERS FOR SECOND STRF COMPONENT ALSO INCLUDE
%                     beta(11): Peak delay (msec)
%                     beta(12): Gaussian temporal duration (msec)
%                     beta(13): Best temporal modulation frequency (Hz)
%                     beta(14): Temporal phase (0-2*pi)
%                     beta(15): Time warping coefficient
%                     beta(16): Best octave frequency, xo
%                     beta(17): Gaussian spectral bandwidth (octaves)
%                     beta(18): Best spectral modulation frequency (octaves)
%                     beta(19): Spectral phase (0-2*pi)
%                     beta(20): Peak Amplitude
%   .Cov1           : Parameter covariance matrix for first order model
%   .Cov2           : Parameter covariance matrix for second order model
%   .FI1            : Fisher information matrix for first order model
%   .FI2            : Fisher information matrix for second order model
%   .P1             : Ratio test for first order model: The model is 
%                     significant if P(10)>1.96
%   .P2             : Ratio test for second order model: The model is
%                     significant if P(10)>1.96 & P(20)>1.96
%   .Order          : Model order determined by significance test
%
% (C) Monty A. Escabi, October 2006. Revised by Chen, Mar. 2007
%
function [GModel]=strfgaborfit(STRFs,STRF,taxis,faxis,n,theta,betaLB,betaUB)

%Paramater Lower and Upper bounds
if nargin<7
    betaLB=[0  0  0   0    0 0 0 0 0    0                    ];
end
if nargin<8
    betaUB=[50 50 350 2*pi 1 8 8 4 2*pi 5*max(max(abs(STRF)))];
end

%Estimating initial STRF parameters
[RFParam]=strfparam(taxis-min(taxis),faxis,STRFs,500,4);
beta(1)=RFParam.delay;
beta(3)=mean(abs(RFParam.BestFm));
if beta(3)<1/betaUB(2)*1000
   beta(2)=beta(1);
else   
   beta(2)=1/beta(3)*1000;
end
beta(4)=pi/4;
beta(5)=.5;
beta(6)=RFParam.BF;
beta(8)=mean(abs(RFParam.BestRD));
if beta(8)<1/betaUB(7)
   beta(7)=1;
else
   beta(7)=1/beta(8);
end
beta(9)=0;
beta(10)=max(max(STRF))
N=1;
%Fitting separable STRF model (to estimate initial parameters with
%significant STRF)
input.taxis=1000*(taxis-min(taxis));
input.X=log2(faxis/faxis(1));
[beta1,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,J1]=lsqcurvefit('strfgabor1',beta,input,STRFs,betaLB,betaUB);

%Fitting separable STRF model to real data
[beta1,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,J1]=lsqcurvefit('strfgabor1',beta1,input,STRF,betaLB,betaUB);
STRFm1=strfgabor1(beta1,input);

%Fitting nonseparable STRF model to real data and finding normalized mean squared erorr
betaLB=[betaLB betaLB];
betaUB=[betaUB betaUB];
beta0=[beta1 beta1];

[beta2,RESNORMm,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,J2]=lsqcurvefit('strfgabor2',beta0,input,STRF,betaLB,betaUB);

STRFm2=strfgabor2(beta2,input);
index=find(STRFs);
MSE=sum( (STRFm2(index)-STRFs(index)).^2 ) / sum(STRFs(index).^2)
RESNORMm

%If result not good, parameters spread 25% 
if MSE>theta
    
       beta=beta0.*(1+(rand(size(beta0))-0.5)*0.25);
       [beta,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,J2]=lsqcurvefit('strfgabor2',beta,input,STRF,betaLB,betaUB);
           if RESNORM<RESNORMm
              beta2=beta;
              STRFm2=strfgabor2(beta2,input);
              MSE=sum((STRFm2(index)-STRFs(index)).^2 ) / sum(STRFs(index).^2)
              RESNORMm=RESNORM
           end         
end

%If still not good, randomize some key parameters
while MSE>theta && N<n

       beta=beta0.*(1+(rand(size(beta0))-0.5)*0.25);

       beta(3)=rand*betaUB(3);                         %Best temporal modulation frequency
       if beta(3)<1/betaUB(2)*1000
          beta(2)=beta(1);                           
       else   
          beta(2)=1/beta(3)*1000.*(1+(rand-0.5)*0.25); %Temporal duration
       end
       beta(8)=rand*betaUB(8);                         %Ripple density
       if beta(8)<1/betaUB(7)
          beta(7)=1;
       else
          beta(7)=1/beta(8).*(1+(rand-0.5)*0.25);      %Spectral bandwidth
       end
       beta(4)=2*pi*rand;
       beta(9)=2*pi*rand;   
       
       beta(13)=rand*betaUB(13);      
       if beta(13)<1/betaUB(12)*1000
          beta(12)=beta(11);
       else   
          beta(12)=1/beta(13)*1000.*(1+(rand-0.5)*0.25);
       end
       beta(18)=rand*betaUB(18);
       if beta(18)<1/betaUB(17)
          beta(17)=1;
       else
          beta(17)=1/beta(18).*(1+(rand-0.5)*0.25);
       end
       beta(14)=2*pi*rand;
       beta(19)=2*pi*rand;
      
       [beta,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,J]=lsqcurvefit('strfgabor2',beta,input,STRF,betaLB,betaUB);
      
           if RESNORM<RESNORMm
              J2=J;
              beta2=beta;
              STRFm2=strfgabor2(beta2,input);
              MSE=((sum(sum(STRFs.^2)))-(sum(sum(STRFm2(index).^2))))/(sum(sum(STRFs.^2)))
              RESNORMm=RESNORM
           end   
        
       N=N+1    
           
end
    
%Covariance Matrix
Cov1=full(inv(J1'*J1));         %Covariance Matrix
Cov2=full(inv(J2'*J2));         %Covariance Matrix
index=find(STRFs==0);
Var=var(STRF(index));           %Noise variance estimate
FI1=Cov1*Var;                   %Fisher Information Matrix
FI2=Cov2*Var;                   %Fisher Information Matrix
P1=beta1./sqrt(diag(FI1)');     %Ratio Test
P2=beta2./sqrt(diag(FI2)');     %Ratio Test


% Calculating similarity index
[RSTRF] = strfcorr(STRFs,STRFm2,taxis,faxis);

%Creating Data Structure
GModel.taxis=taxis;
GModel.faxis=faxis;
GModel.STRFs=STRFs;
GModel.STRF=STRF;
GModel.STRFm1=STRFm1;
GModel.STRFm2=STRFm2;
GModel.beta1=beta1;
GModel.beta2=beta2;
GModel.Cov1=Cov1;
GModel.Cov2=Cov2;
GModel.FI1=FI1;
GModel.FI2=FI2;
GModel.P1=P1;
GModel.P2=P2;
GModel.MSE=MSE;
GModel.SI=RSTRF.SI;
GModel.N=N;

if P2(20)>1.96 & P2(10)>1.96
    GModel.Order=2;
elseif P1(10)>1.96;
    GModel.Order=1;
else
    GModel.Order=0;
end