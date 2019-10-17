%
%function [H] = hc(naxis,wc)
%	
%	FILE NAME 	: hc
%	DESCRIPTION 	: impulse response of ideal filter
%
%	H		: Calculated impulse response
%	naxis		: Discrete time axis - usually an Array with sequence
%			  -N,-(N-1) .... -1, 0, 1, ....N-1, N
%	wc		: Cutoff Frequency (in radians, 0-pi).
%
function [H] = hc(naxis,wc)

H=wc./pi.*sinc(1/pi*wc*naxis);

