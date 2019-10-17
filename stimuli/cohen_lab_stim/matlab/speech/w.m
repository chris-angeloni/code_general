%
%function [W] = w(naxis,wc,alpha,p)
%	
%	FILE NAME 	: w
%	DESCRIPTION 	: impulse response of optimal window as designed by
%			  Escabi and Roark.
%	FUNCTION CALL	: w(naxis,wc,alpha,m);
%	W		: Calculated impulse response
%	naxis		: Discrete time axis - usually an Array with sequence
%			  -N,-(N-1) .... -1, 0, 1, ....N-1, N
%	alpha		: Transition width parameter.
%	p		: Smoothing Parameter.
%	wc		: Cutoff Frequency (in radians, 0-pi).
%
function [W] = w(naxis,wc,alpha,p)

W=sinc(1/pi.*alpha.*wc.*naxis./p).^p;

