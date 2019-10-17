%
%function [JitterModel]=corrmodelfit(Rnoise,lambdap,Tau,disp)
%
%   FILE NAME       : CORR MODEL FIT
%   DESCRIPTION     : Gaussian Function fit for Noise correlogram analysis.
%                     Computes the spike timing jitter and reliability.
%
%	Rnoise          : Average Noise Correlogram
%   lambdap         : Measured spike rate (lambda_i * p)
%	Tau             : Delay Axis (msec)
%	disp            : Display: 'y' or 'n', Defualt=='n'
%
%Returned Variables
%
% JitterModel : Data structure containing
%       .Rmodel     - Optimal Fitted Correlation Function
%       .sigmag     - Gaussian model Jitter STD
%       .pg         - Gaussian model reliability
%       .lambdag    - Gaussian model ideal firing rate
%       .sigma      - Jitter STD
%       .p          - Reliability
%       .lambda     - Ideal firing rate
%       .lambdap    - Firing rate including reliability errors
%
% (C) Monty A. Escabi, Edit Aug 2009
%
function [JitterModel]=corrmodelfit(Rnoise,lambdap,Tau,disp)

%Input Arguments
if nargin<3
	disp='y';
end

%Converting Tau to seconds
Tau=Tau/1000;

%Fitting Gaussian Jitter Model to Rnoise
i=find(abs(Tau)<.050);    %Select only values with delays < 50 msec for optimization
[beta,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = lsqcurvefit(@(beta,Tau) beta(1)*lambdap*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2),[0.5 10],Tau(i),Rnoise(i),[0 0],[1.1 20]);
sigmag=beta(2);
pg=beta(1);
Rmodel=beta(1)*lambdap*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2);

%Direct Estimate of Jitter and Reliability
Fsd=1./(Tau(2)-Tau(1));
Ncenter=(length(Rnoise)-1)/2+1;
%dN=min(max(find(Rnoise>1/2*max(Rnoise)))-Ncenter,floor((Ncenter-1)/6))   %Makes sure the 1/2 duration                                                                           %does not exceed the number of samples
dN=min(ceil(sigmag/1000*Fsd),floor((Ncenter-1)/6));
if dN==0    %In case jitter is too tight
   dN=1; 
end
Rnoise2=Rnoise(Ncenter-dN*5:Ncenter+dN*5);    %Select segment 5 sigmag wide relative to center
Tau2=Tau(Ncenter-dN*5:Ncenter+dN*5);
Mean=sum(Tau2.*Rnoise2/sum(Rnoise2));
sigma=sqrt(abs(sum((Tau2-Mean).^2.*Rnoise2/sum(Rnoise2))));
sigma=sigma*1000/sqrt(2);       %Divide by sqrt(2) because correlation is sqrt(2) as wide as jitter    
p=sum(Rnoise)/Fsd/lambdap;

%Plotting Data and Model
if strcmp(disp,'y')
	hold off
	plot(Tau,Rnoise,'k')
	hold on
	plot(Tau,Rmodel)
	xlabel('Delay (msec)')
	ylabel('Crosscorrelation Amplitude')
	pause(.1)
end

%Data Structure containing Model and Parameters
JitterModel.Rmodel=Rmodel;
JitterModel.sigmag=sigmag;
JitterModel.pg=pg;
JitterModel.lambdag=lambdap/pg;
JitterModel.sigma=sigma;
JitterModel.p=p;
JitterModel.lambda=lambdap/p;
JitterModel.lambdap=lambdap;