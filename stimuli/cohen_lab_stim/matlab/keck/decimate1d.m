%function [y] = decimate1d(x)
%
%	FILE NAME 	: DECIMATE1D
%	DESCRIPTION 	: Decimates the vector x by a factor of 2
%
%	Note		: Make sure signal is prefiltered!!!
%			: x must be radix 2
%
%	x		: Prefilterd Input Signal
%	y		: Decimated Output Signal
%
function [y] = decimate1d(x)

%Down Sampling/Decimating
N=length(x)/2;
y=x(1:2:2*N-1);
