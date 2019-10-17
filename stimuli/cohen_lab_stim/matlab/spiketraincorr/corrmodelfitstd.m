%
%function [Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfitstd(Ravg,Tau)
%
%       FILE NAME       : CORR MODEL FIT STD
%       DESCRIPTION     : Gaussian Function fit of Cross-Channel correlation
%			  from RASTERGRAM. Fits by finding the optimal
%			  standard deviation.
%
%	Ravg		: Average Cross-Channel Correlation
%	Tau		: Delay Axis
%
%Returned Variables
%	Rmodel		: Optimal Fitted Correlation Function
%       Rmean		: Mean Correlation Value obtained from random
%			  spikes due to coincidt spikes
%       Tpeak		: Peak Correlation Value
%       sigma		: Standard deviation (msec)
%
function [Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfitstd(Ravg,Tau)

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
%sigma=nlinfit(T,(Ra-Rmean)/(Rpeak-Rmean),'corrmodelstd',[sigma]);
sigma=lsqcurvefit('corrmodelstd',sigma,T,(Ra-Rmean)/(Rpeak-Rmean));

%Finding Parameters and Recomputing Optimal Model
Rmodel=corrmodel([Rmean Rpeak sigma],Tau);
sig=sigma/1000;
%lambda=1/sqrt(4*pi*sig^2)*Rmean/(Rpeak-Rmean)+1;
%p=sqrt( (Rpeak-Rmean)*sqrt(4*pi*(sig)^2) / (lambda) );

lambda=1+Rmean/(Rpeak-Rmean)/sqrt(4*pi*sig^2);
p=(Rpeak-Rmean)*sqrt(4*pi*sig^2)/sqrt(Rmean+(Rpeak-Rmean)*sqrt(4*pi*sig^2));

%Plotting Data and Model
hold off
plot(Tau(i),Ravg(i),'k')
hold on
plot(Tau(i),Rmodel(i))
pause(.1)

