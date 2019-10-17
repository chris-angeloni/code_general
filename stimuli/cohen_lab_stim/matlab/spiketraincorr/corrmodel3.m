%
%function [R]=corrmodel(Beta,Tau)
%
%
%       FILE NAME       : CORR MODEL
%       DESCRIPTION     : Correlation model to fit Cross-Channel correlation
%			  from RASTERGRAM by a Gaussian function.
%
%	Beta		: System Parameters where Beta=[Rmean Tpeak sigma] where
%			  Rmean - Mean Correlation Value obtained from random 
%			  	  spikes due to coincidt spikes
%			  Rpeak - Peak Correlation Value
%			  sigma - Standard deviation (msec)
%	Tau		: Delay Axis
%
%Returned Variables
%	R		: Fitted Correlation Function
%
function [R]=corrmodel(Beta,Tau)

%Defining Parameters
Rmean=Beta(1);
Rpeak=Beta(2);
sigma=Beta(3)/1000;

%Fitting Correlation Function by Gaussian
R=Rmean + (Rpeak-Rmean) * exp(-Tau.^2./4/sigma^2);

