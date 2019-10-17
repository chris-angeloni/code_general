
%function [R]=gaussmodel(Beta,t)

%       FILE NAME       : Gaussian MODEL
%       DESCRIPTION     : Gaussian distribution
%
%	Beta		: System Parameters where Beta=[Rmean Tpeak sigma] where
%			  Rpeak - Peak Correlation Value
%			  sigma - Standard deviation (msec)
%	t		: time Axis
%
%Returned Variables
%	R		: 
%  Yi Zheng, Jan2007

function [R]=gaussmodel(Beta,t)

%Defining Parameters
mu=Beta(1);
sigma=Beta(2);

R=1/sigma/sqrt(2*pi) * exp(-(t-mu).^2./2/sigma^2);

