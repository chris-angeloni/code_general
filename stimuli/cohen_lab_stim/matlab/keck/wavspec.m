%function [taxis,faxis,wspec] = wavspec(M,x,W0,H0,delay)
%
%	FILE NAME 	: WAVSPEC
%	DESCRIPTION 	: Wavelet Spectogram
%
%	M		: Number of decompositions
%	x		: Input Signal
%	W0		: 0th Order Wavlet coefficients
%	H0		: 0th Order Scaling Coefficients 
%	delay		: Used to correct for filter delay
%			  Default N/2
%	wavspec		: Wavelet Spectogram Coefficients
%
function [C] = wavspec(M,x,W0,H0,delay)

%Recursive Decomposition
if M~=1

	C   = dwt1d(1,x,W0,H0,delay);
	N   = size(C);
	C1  = wavspec(M-1,decimate1d(C(1,:)).*(-1).^(1:N(2)/2),W0,H0,delay);	
	C1  = expand1d(C1);
	N   = size(C1);
	for k=1:N(1)
		C1(k,:)  = convfft(C1(k,:),W0,delay);
	end

	N   = size(C);	
	C2  = wavspec(M-1,decimate1d(C(2,:)).*(-1).^(1:N(2)/2),W0,H0,delay);
	C2  = expand1d(C2);
	N=size(C2);
	for k=1:N(1)
		C2(k,:)  = convfft(C2(k,:),H0,delay);
	end

	C=[C1' C2']';
else
	C=x;
end

