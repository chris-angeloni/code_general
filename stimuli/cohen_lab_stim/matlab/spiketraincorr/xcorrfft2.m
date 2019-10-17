%function [R] = xcorrfft2(X,Y)
%
%	FILE NAME 	: XCORR FFT2
%	DESCRIPTION 	: Discrete 2D-Xcorrelation performed by using FFT
%			  Both input matrices must be of identical size.
%			  Note that this is a circular convolution and 
%			  one must therefore append zeros to avoid edge
%			  effects
%
%
%	X		: Matrix 1
%	Y		: Matrix 2
%
%	Note: Autocorrelation should be normalized by the energy 
%	      of the window function applied to the data - This 
%	      is essentially the std of the window -> std(w(x1,x2))
%	      For a square window this corresponds to sqrt(N1*N2)
%	      Note that this normalization is equivalent to applying a 
%	      window of unit energy (std)
%
function [R] = xcorrfft2(X,Y)

%Append Zeros for Dyadic Sample Grid
N1=2^nextpow2(size(X,1));
N2=2^nextpow2(size(X,2));

%Performing X-Correlation
R=1/size(Y,1)/size(Y,2)*real(ifft2(fft2(Y,N1,N2).*conj(fft2(X,N1,N2))));

% Note that the normalization only works when the original size of X is used
% This is because the appended zeros don't count in the average xcorr
% Try it out for X=randn(128,129);, R=xcorrfft2(X,X);
% max(max(R)) should be 1 = var(reshape(X,1,127*129)) !!!
%

