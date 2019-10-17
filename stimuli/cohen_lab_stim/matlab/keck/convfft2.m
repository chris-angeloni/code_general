%function [F] = convfft2(X,Y)
%
%	FILE NAME 	: CONVFFT2
%	DESCRIPTION 	: Discrete 2D-Convolution performed by using FFT
%			  Both input matrices must be of identical size.
%			  Note that this is a circular convolution and 
%			  one must therefore append zeros to avoid edge
%			  effects
%
%	X		: Matrix 1
%	Y		: Matrix 2
%
function [F] = convfft2(X,Y)

%Append Zeros for Dyadic Sample Grid
N1=2^nextpow2(size(X,1));
N2=2^nextpow2(size(X,2));

%Performing Convolution
F=1/size(X,1)/size(Y,2)*real(ifft2(fft2(Y,N1,N2).*fft2(X,N1,N2)));

% Note that the normalization only works when the original size of X is used
% This is because the appended zeros don't count in the average conv

