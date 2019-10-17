%
%function [dH] = dhi(naxis,wc,alpha,p)
%	
%	FILE NAME 	: dhi
%	DESCRIPTION 	: Derivative impulse response of optimal interpolation 
%			  filter as designed by Escabi and Roark
%
%	dH		: Calculated derivative impulse response
%	naxis		: Discrete time axis - usually an Array with sequence
%			  -N,-(N-1) .... -1, 0, 1, ....N-1, N
%	alpha		: Transition width parameter.
%	p		: Smoothing Parameter.
%	wc		: Cutoff Frequency (in radians, 0-pi).
%
function [dH] = dhi(naxis,wc,alpha,p)

%i=find(naxis==0);
naxis=naxis+1E-10;

a=alpha/p;
dH=sinc(1/pi*a*wc*naxis).^(p-1)*a*wc^2./(a*wc.*naxis).^3./(wc*naxis).^3;
dH=dH.*( sin(a*wc*naxis).*cos(wc*naxis).*wc.*naxis + p*sin(wc*naxis).*cos(a*wc*naxis)*a*wc.*naxis - (1+p)*sin(wc*naxis).*sin(a*wc*naxis) );
