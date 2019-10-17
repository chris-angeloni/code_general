%function [y] = expand1d(x)
%
%	FILE NAME 	: EXPAND1D
%	DESCRIPTION 	: Expand the vector x by a factor of 2
%
%	Note		: x must be radix 2
%
%	x		: Input Signal
%	y		: Decimated Output Signal
%
function [y] = expand1d(x)

%Expanding
N=size(x);
y=zeros(N(1),N(2)*2);
y(:,1:2:2*N(2)-1)=x;
