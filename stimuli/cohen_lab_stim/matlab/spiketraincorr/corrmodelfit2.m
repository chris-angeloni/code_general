%
%function [Rmodel,Rmean,Rpeak,sigma]=corrmodelfit(Ravg,Tau)
%
%
%       FILE NAME       : CORR MODEL FIT
%       DESCRIPTION     : Gaussian Function fit of Cross-Channel correlation
%			  from RASTERGRAM.
%
%	Ravg		: Average Cross-Channel Correlation
%	Tau         : Delay Axis
%
%Returned Variables
%	Rmodel		: Optimal Fitted Correlation Function
%	Rmean		: Mean Correlation Value obtained from random 
%                 spikes due to coincidt spikes
%	Tpeak		: Peak Correlation Value
%	sigma		: Standard deviation (msec)
%
function [Rmodel,Rmean,Rpeak1,sigma1,Rpeak2,sigma2]=corrmodelfit(Ravg,Tau)

%Finding Initial Parameters
Rpeak1=max(Ravg)/2;
Rpeak2=max(Ravg)/2;
i=find(Tau>0.05);
Rmean=mean(Ravg(i));
sigma1=5;
sigma2=.1;

%Selecting Central Portion of Cross-Channel Correlation 
i=find(abs(Tau)<0.030);
Ra=Ravg(i);
T=Tau(i);

%Finding Optimal Parameters
beta=nlinfit(T,Ra,'corrmodel2',[Rmean Rpeak1 sigma1 Rpeak2 sigma2]);

%Finding Parameters and Recomputing Optimal Model
Rmean=beta(1);
Rpeak1=beta(2);
sigma1=beta(3);
Rpeak1=beta(4);
sigma1=beta(5);

Rmodel=corrmodel2([Rmean Rpeak1 sigma2 Rpeak2 sigma2],T);

