%
%function [y]=noise1overx(fb,Fs,alpha,a,b,M,seed)
%
%       FILE NAME       : NOISE 1 OVER X
%       DESCRIPTION     : Bandlimited noise signal with 1/abs(x)^(alpha/2) 
%			  amplitude distribution
%
%       fb              : Upper Bandlimit Frequency
%       Fs              : Sampling Frequency
%	alpha		: 1/x distribution exponent
%	a,b		: Amplitude Limits for 1/x distribution
%			  Amplitude E [a,b]
%       M               : Number of Samples
%
%Optional 
%
%	seed		: Seed for random number generator 
%
function [y]=noise1overx(fb,Fs,alpha,a,b,M,seed)

%Generating Uniformly Distributed Noise
x=noiseunif(fb,Fs,M,seed);

%Finding parameters for p(x)
if alpha==2
	alpha=1.9999;	%Otherwise need to use natural log
end
beta=1-alpha/2;
c=2/beta*(b^beta - a^beta);

%Generating p(x)=1/x^(alpha/2) distributed noise signal by transforming
%uniformly distributed noise -> y=Finv (x)
%where F is the CDF of p(y) and Finv( F(x) ) = x 
y=zeros(1,length(x));
i1=find(x>0.5);
i2=find(x<=0.5);
y(i1)=(beta*c*(x(i1)-0.5)+a.^beta).^(1/beta);
y(i2)=-(b^beta-beta*c*x(i2)).^(1/beta);
