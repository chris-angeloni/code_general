%function [Fo,A]=foanal(x,Fs)
%	
%	FILE NAME 	: FO ANAL
%	DESCRIPTION 	: Finds Fo using the analytic signal method.
%
%	x		: Input Signal
%	Fs		: Sampling Frequency
%
%	Fo		: Measured Fundamental Frequency Profile
%	A		: Amplitude profile 
%
function [Fo,A]=foanal(x,Fs)

%Obtaining analytic signal 
Hx=hilbert(x);

%Amplitude Profile
A=abs(Hx);

%Instantaneous Frequency Profile
Fo=1/2/pi*diff( unwrap(angle(Hx)) )*Fs;


