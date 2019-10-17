%
%function [R]=corrmodelstd(sigma,Tau)
%
%
%       FILE NAME       : CORR MODEL
%       DESCRIPTION     : Correlation model to fit Cross-Channel correlation
%			  from RASTERGRAM by a Gaussian function.
%			  Normalized for R(0)=1 and R(inf)=0
%
%	sigma		: Standard deviation (msec)
%	Tau		: Delay Axis
%
%Returned Variables
%	R		: Fitted Correlation Function
%
function [R]=corrmodelstd(sigma,Tau)

%Defining Parameters
sigma=sigma/1000;

%Fitting Correlation Function by Gaussian
R=exp(-Tau.^2./4/sigma^2);

