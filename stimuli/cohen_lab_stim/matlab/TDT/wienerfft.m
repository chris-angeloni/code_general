%
%function [H] = wienerfft(X,Y,beta,N)
%
%	FILE NAME 	: WIENER FFT
%	DESCRIPTION	: Optimal Wiener Filter Estimate
%                 Derived using frequency domain estimator.
%
%	X           : Input Signal
%	Y           : Output Signal
%	beta		: Kaiser window smoothing factor
%	N           : Filter order
%
% (C) Monty A. Escabi, December 2008
%
function [H] = wienerfft(X,Y,beta,N)

%Frequency Domain Approximation To Wiener Filter
M=max(length(X),length(Y));
NFFT=pow2(nextpow2(max(length(X),length(Y))));
%W=kaiser(NFFT,beta)';
W=zeros(NFFT,1)';
W(1:M)=kaiser(M,beta);  %Zero Padded Window
X=[X zeros(1,NFFT-length(X))];
Y=[Y zeros(1,NFFT-length(Y))];
X=fft(X.*W,NFFT);
Y=fft(Y.*W,NFFT);
H=real(ifft(X.*conj(Y)./abs(X).^2,NFFT));
H=fliplr(H);
H=[H(length(H)) H(1:N-1)];