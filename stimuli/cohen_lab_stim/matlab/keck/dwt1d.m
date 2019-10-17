%function [C] = dwt1d(M,x,W0,H0,delay)
%
%	FILE NAME 	: DWT1D 
%	DESCRIPTION 	: Dicrete 1D Wavelet X-Form using a
%			  Separable wavelet and scaling function
%			  No Decimation
%
%	M		: Number of decompositions
%	x		: Input Signal
%	W0		: 0th Order Wavlet coefficients
%	H0		: 0th Order Scaling Coefficients 
%	delay		: Used to correct for filter delay
%			  Default N/2
%	C		: Discrete Wavelet Coefficients
%
function [C] = dwt1d(M,x,W0,H0,delay)

%Preparing Buffers - Adjusting to Radix 2
N=length(x);
if length(x)~=2^floor(log2(N))
	x(N+1:2^(1+floor(log2(N))))=zeros(1,2^(1+floor(log2(N)))-N);
	N=length(x);
end
C=zeros(M+1,N);
C(1,:)=x;

%Wavelet decomposition
for i=1:M

	%Message
	f=['Decomposing Scale ',int2str(i-1)];
	disp(f);

	%ith scale decomposition
	C(i+1,:)= convfft(C(i,:),H0,delay*2^(i-1));
	C(i,:)	= convfft(C(i,:),W0,delay*2^(i-1));
	H0	= expand1d(H0);
	W0	= expand1d(W0);
	
end
