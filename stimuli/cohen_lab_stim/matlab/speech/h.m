%
%function [H] = h(naxis,wc,alpha,P)
%	
%	FILE NAME 	: h
%	DESCRIPTION 	: impulse response of optimal filter as designed by
%			  Escabi and Roark.
%	FUNCTION CALL	: h(naxis,wc,alpha,m);
%	H		: Calculated impulse response
%	naxis		: Discrete time axis - usually an Array with sequence
%			  -N,-(N-1) .... -1, 0, 1, ....N-1, N
%	alpha		: Transition width parameter.
%	P		: Smoothing Parameter.
%	wc		: Cutoff Frequency (in radians, 0-pi).
%	To Run		: h(naxis,pi/2,.5,4);
%
function [H] = h(naxis,wc,alpha,p)

%Filter and Window Design
H=wc./pi.*sinc(1/pi*wc.*naxis);
W=sinc(1/pi.*alpha.*wc.*naxis./p).^p;
H=H.*W;

