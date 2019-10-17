%
%function [R]=corrmodel(Beta,Tau)
%
%
%       FILE NAME       : CORR MODEL
%       DESCRIPTION     : Correlation model to fit Cross-Channel correlation
%			  from RASTERGRAM by a Gaussian function.
%
%	Beta		: System Parameters where Beta=[Rmean Tpeak sigma] where
%			  Rpeak - Peak Correlation Value
%			  sigma - Standard deviation (msec)
%	Tau		: Delay Axis
%
%Returned Variables
%	R		: Fitted Correlation Function
%
function [R]=corrmodel(Beta,Tau)

%Defining Parameters
Rpeak=Beta(1);
sigma=Beta(2)/1000;

%Fitting Correlation Function by Gaussian
R=Rpeak * exp(-Tau.^2./4/sigma^2);

