%
%function [H] = hi(naxis,wc,alpha,p)
%	
%	FILE NAME 	: hi
%	DESCRIPTION 	: impulse response of optimal interpolation 
%			  filter as designed by Escabi and Roark
%
%	H		: Calculated impulse response
%	naxis		: Discrete time axis - usually an Array with sequence
%			  -N,-(N-1) .... -1, 0, 1, ....N-1, N
%	alpha		: Transition width parameter.
%	p		: Smoothing Parameter.
%	wc		: Cutoff Frequency (in radians, 0-pi).
%
function [H] = hi(naxis,wc,alpha,p)

H=sinc(1/pi*wc*naxis);
W=sinc(1/pi*alpha.*wc.*naxis./p).^p;
H=H.*W;

