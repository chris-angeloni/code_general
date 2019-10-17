%function [F] = convlinfft(X,Y)
%
%	FILE NAME 	: CON 1D VFFT
%	DESCRIPTION 	: Discrete Linear Convolution performed by using FFT
%			  If the input X and Y are Matrices, a linear
%			  convolution is performed on each row of the Matrix
%			  For a Matrices of dimmensions N x Nx and N x Ny the 
%			  output contains N x Nx+Ny-1 elements
%
%	X		: Signal 1
%	Y		: Signal 2
%
%RETURNED VARIABLES
%	F		: Output	
%
function [F] = convlinfft(X,Y)

%Defining sequence lengths
if size(Y,2)>1 & size(Y,1)>1
	NY=size(Y,2);
	NX=size(X,2);
else
	NY=length(Y);
	NX=length(X);
end	

%FFT Length
N=2^nextpow2(NX+NY-1);

%Performing convolution
F=real(ifft(fft(X',N).*fft(Y',N)))';
F=F(:,1:NX+NY-1);
