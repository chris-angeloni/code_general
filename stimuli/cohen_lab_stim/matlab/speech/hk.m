%
%function [H] = hk(naxis,wc,alpha,m)
%	
%	FILE NAME 	: hk
%	DESCRIPTION 	: impulse response of optimal filter as designed by
%			  kaiser.
%	FUNCTION CALL	: hk(naxis,wc,alpha,m);
%	H		: Calculated impulse response
%	naxis		: Discrete time axis - usually an Array with sequence
%			  -N,-(N-1) .... -1, 0, 1, ....N-1, N
%	alpha		: Transition width parameter.
%	m		: Smoothing Parameter.
%	wc		: Cutoff Frequency (in radians, 0-pi).
%	To Run		: h(naxis,pi/2,.5,4);
%
function [H] = hk(naxis,wc,N,beta)

H=wc/pi*sinc(1/pi*wc*naxis);
tempW=kaiser(2*N+1,beta);
W=zeros(size(H));
for n=1:length(tempW)-1,
	W(n)=tempW(n);
end
H=H.*W;



