%
%function [Y]=intfft2(X)
%
%       FILE NAME       : INT FFT 2
%       DESCRIPTION     : 2-D Signal Integrator - Performed via FFT
%			  Performs the inverse operator for the 
%			  difference sequence:
%			  x[n]-x[n-1], x[n-1]-x[n-2], . . .
%
%	X		: Input Matrix
%	Y		: Output Matrix
%	dtrend		: Detrend by removing minimum value ('y' or 'n')
%			  Default == 'n'
%
%			Transformations are as follows:
%	
%			x[n]-x[n-1] <--> Y(exp(jw)) = ( 1-exp(jw) ) * X(exp(jw))
%			x[n]        <--> Y(exp(jw)) / ( 1-exp(jw) )
%
function [Y]=intfft2(X,dtrend)

%Input Args
if nargin<2
	dtrend='n';
end

%FFT Length
NFFT1=2^(ceil(log2(size(X,1))));
NFFT2=2^(ceil(log2(size(X,2))));

%2-D Integration - Performed as a separable transform
%Uses the 1-D Integration Routine 
for k=1:NFFT2
	X(:,k)=intfft(X(:,k)',dtrend)';
end
for k=1:NFFT1
	X(k,:)=intfft(X(k,:),dtrend);
end
Y=X;

