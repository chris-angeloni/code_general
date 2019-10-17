%
%function [Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfit(Ravg,Tau)
%
%
%       FILE NAME       : CORR MODEL FIT
%       DESCRIPTION     : Gaussian Function fit of Cross-Channel correlation
%			  from RASTERGRAM.
%
%	Ravg		: Average Cross-Channel Correlation
%	Tau		: Delay Axis
%
%Returned Variables
%	Rmodel		: Optimal Fitted Correlation Function
%	Rmean		: Mean Correlation Value obtained from random 
%			  spikes due to coincident spikes
%	Tpeak		: Peak Correlation Value
%	sigma		: Spike timing jitter standard deviation (msec)
%	p		: Trial-to-trial probability of reproducing a given 
%			  action potential.
%	lambda		: Mean spike rate (assuming p=1 )
%
function [Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfit(Ravg,Tau)

%Finding Initial Parameters
Rpeak=max(Ravg);
i=find(Tau>0.05);
Rmean=mean(Ravg(i));
sigma=3;

%Selecting Central Portion of Cross-Channel Correlation 
i=find(abs(Tau)<0.020);
Ra=Ravg(i);
T=Tau(i);

%Finding Optimal Parameters
beta=nlinfit(T,Ra,'corrmodel',[Rmean Rpeak sigma]);
%beta=lsqcurvefit('corrmodel',[Rmean Rpeak sigma],T,Ra);

%Finding Parameters and Recomputing Optimal Model
Rmean=beta(1);
Rpeak=beta(2);
sigma=beta(3);
Rmodel=corrmodel([Rmean Rpeak sigma],T);
sig=sigma/1000;
lambda=1/sqrt(4*pi*sig^2)*Rmean/(Rpeak-Rmean)+1;
p=sqrt( (Rpeak-Rmean)*sqrt(4*pi*(sig)^2) / (lambda) );

%Plotting Data and Model
hold off
plot(T,Ra,'k')
hold on
plot(T,Rmodel)
xlabel('Delay (msec)')
ylabel('Crosscorrelation Amplitude')
pause(.1)

