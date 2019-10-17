%
%function [R]=corrmodel2(Beta,Tau)
%
%
%   FILE NAME       : CORR MODEL
%   DESCRIPTION     : Correlation model to fit Cross-Channel correlation
%                     from RASTERGRAM by a Gaussian function.
%
%	Beta		: System Parameters where Beta=[Rmean Tpeak sigma] where
%                 Rmean - Mean Correlation Value obtained from random 
%			  	  spikes due to coincidt spikes
%                 Tpeak - Peak Correlation Value
%                 sigma - Standard deviation (msec)
%	Tau         : Delay Axis
%
%Returned Variables
%	R		: Fitted Correlation Function
%
function [R]=corrmodel2(Beta,Tau)

%Defining Parameters
Rmean=Beta(1);
Rpeak1=Beta(2);
sigma1=Beta(3)/1000;
Rpeak2=Beta(4);
sigma2=Beta(5)/1000;

%Fitting Correlation Function by Gaussian
R=Rmean + Rpeak1 * exp(-Tau.^2./2/sigma1^2) + Rpeak2 * exp(-Tau.^2./2/sigma2^2);
plot(Tau,R)
pause(0.1)
