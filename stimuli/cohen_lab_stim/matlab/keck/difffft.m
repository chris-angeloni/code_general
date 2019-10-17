%
%function [y]=difffft(x)
%
%       FILE NAME       : DIFF FFT
%       DESCRIPTION     : Signal Differentiator - Performed via FFT
%			  Calculates the differnece sequence: 
%			  x[n]-x[n-1], x[n-1]-x[n-2], . . .
%
%	x		: Input Signal 
%	y		: Output Signal
%
%			Transformations are as follows:
%	
%			x[n]-x[n-1] <--> Y(exp(jw)) = ( 1-exp(jw) ) * X(exp(jw))
%			x[n]        <--> Y(exp(jw)) / ( 1-exp(jw) )
%
%
function [y]=difffft(x)

%FFT Length
NFFT=2^(ceil(log2(length(x))));

%Taking Derivative in Frequency Domain
w=(0:NFFT-1)/NFFT*2*pi;
d=exp(i*w)-1+1E-12;
y=real(ifft(fft(x,NFFT).*d));

