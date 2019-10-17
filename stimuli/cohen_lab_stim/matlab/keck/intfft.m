%
%function [y]=intfft(x,dtrend)
%
%       FILE NAME       : INT FFT
%       DESCRIPTION     : Signal Integrator - Performed via FFT
%			  Performs the inverse operator for the 
%			  difference sequence:
%			  x[n]-x[n-1], x[n-1]-x[n-2], . . .
%
%	x		: Input Signal 
%	y		: Output Signal
%	dtrend		: Detrend by removing minimum value ('y' or 'n')
%			  Default == 'n'
%
%			Transformations are as follows:
%	
%			x[n]-x[n-1] <--> Y(exp(jw)) = ( 1-exp(jw) ) * X(exp(jw))
%			x[n]        <--> Y(exp(jw)) / ( 1-exp(jw) )
%
%
function [y]=intfft(x,dtrend)

%Input Args
if nargin<2
	dtrend='n';
end

%FFT Length
NFFT=2^(ceil(log2(length(x))));

%Integrating in Frequency Domain
MeanX=mean(x);
x=x-MeanX;
w=(0:NFFT-1)/NFFT*2*pi;
d=exp(i*w)-1+1e-30;
x=[x(1:length(x)) zeros(1,NFFT-length(x))];
y=real(ifft(fft(x,NFFT)./d));
y=y-mean(y);
y=y+MeanX*(0:length(y)-1);
if strcmp(dtrend,'y')
	y=y-min(y);
end
