%
%function [x,y]=fomatch(x,y)
%
%       FILE NAME       : fomatch
%       DESCRIPTION     : Matches Fo or To profiles for finding
%			  correletaion coefficient
%
%       x               : Input Signal 1
%	y		: Input Signal 2
%
function [x,y]=fomatch(x,y)

%Signal Lengths
NX=length(x);
NY=length(y);

%Finding X-Correlations
Cyx=xcorrfft(y-mean(y),x-mean(x),0);

%Finding Delay
delay=find(Cyx==max(Cyx))-NY+sign(find(Cyx==max(Cyx))-NY);

%Shifting
if delay>0
	x=x(delay:NY);
elseif delay<0
	y=y(-delay:NX);
end

%Truncating to same length
N=min(length(x),length(y));
x=x(1:N);
y=y(1:N);
