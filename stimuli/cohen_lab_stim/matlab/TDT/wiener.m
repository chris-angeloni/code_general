%
%function [H] = wiener(X,Y,beta,N)
%
%	FILE NAME 	: WIENER
%	DESCRIPTION	: Optimal Wiener Filter Estimate
%
%	X	        : Input Signal
%	Y		: Output Signal
%	beta		: Kaiser window smoothing factor
%	N		: Filter order
%
% (C) Monty A. Escabi 2004
%
function [H] = wiener(X,Y,beta,N)

%Frequency Domain Approximation To Wiener Filter
Pxx=csd(X,X,N)';
Pxy=csd(X,Y,N)';
Hl=Pxy./Pxx;
Hu=fliplr(conj(Hl(2:length(Hl)-1)));
H=fftshift(real(ifft([Hl Hu])));
H=H.*kaiser(length(H),beta)';
