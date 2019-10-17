%function [Taxis,W] = splinewin(p,alpha,T,Fs)
%
%       FILE NAME       : SPLINE WIN 
%       DESCRIPTION     : B-Spline Window Function as designed by   
%                         Escabi / Roark Filter Function
%	p		: Smoothing parameter (>1)
%	alpha		: TW Parameter (0,1)
%	T		: Window Width (sec)
%	Fs		: Smapling Frequency
%
function [Taxis,W] = splinewin(p,alpha,T,Fs)

%Setting up Arrays
T2=T/2;
Ts=1./Fs;
Taxis=-T2*(1+alpha):Ts:T2*(1+alpha);
W=zeros(size(Taxis));

%Calculating Window Function from B-Spline Derivation
for k=0:p,
	W=W+(-1)^k*gamma(p+1)/gamma(p-k+1)/gamma(k+1)*( ( max( 0 , p/2*((abs(Taxis)-T2)/alpha/T2+1)-k )).^p - (p-k).^p);
end
W=-W/gamma(p+1);
