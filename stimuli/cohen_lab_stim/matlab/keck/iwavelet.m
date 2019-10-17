%function [Imageout] = iwavelet(M,Imagein,W0,H0,delay,norm)
%
%	FILE NAME 	: IWAVELET 
%	DESCRIPTION 	: Dicrete Image wavelet X-Form using a
%			  Separable wavelet and scaling function
%
%	M		: Number of decompositions
%	W0		: 0th Order Wavlet coefficients
%	H0		: 0th Order Scaling Coefficients 
%	delay		: Used to correct for filter delay
%	norm		: Normalize 'y' (yes) or 'n' (no)
%
function [Imageout] = iwavelet(M,Imagein,W0,H0,delay,norm)

%Preparing Buffers
N=length(Imagein);
Imageout=zeros(size(Imagein));

if norm=='y'
	%Wavelet decomposition
	for i=1:M
		%Message
		f=['Decomposing Scale ',int2str(i-1)];
		disp(f);

		%ith scale decomposition
		Imageout(N/2^i+1:N/2^(i-1),N/2^i+1:N/2^(i-1))=inorm(idownsam(iconvfft(Imagein(1:N/2^(i-1),1:N/2^(i-1)),W0,W0,delay)));
		Imageout(1:N/2^i,1:N/2^i)=inorm(idownsam(iconvfft(Imagein(1:N/2^(i-1),1:N/2^(i-1)),H0,H0,delay)));
		Imageout(1:N/2^i,N/2^i+1:N/2^(i-1))=inorm(idownsam(iconvfft(Imagein(1:N/2^(i-1),1:N/2^(i-1)),H0,W0,delay)));
		Imageout(N/2^i+1:N/2^(i-1),1:N/2^i)=inorm(idownsam(iconvfft(Imagein(1:N/2^(i-1),1:N/2^(i-1)),W0,H0,delay)));
	end
elseif norm=='n'
	%Wavelet decomposition
	for i=1:M
		%Message
		f=['Decomposing Scale ',int2str(i-1)];
		disp(f);

		%ith scale decomposition
		Imageout(N/2^i+1:N/2^(i-1),N/2^i+1:N/2^(i-1))=idownsam(iconvfft(Imagein(1:N/2^(i-1),1:N/2^(i-1)),W0,W0,delay));
		Imageout(1:N/2^i,1:N/2^i)=idownsam(iconvfft(Imagein(1:N/2^(i-1),1:N/2^(i-1)),H0,H0,delay));
		Imageout(1:N/2^i,N/2^i+1:N/2^(i-1))=idownsam(iconvfft(Imagein(1:N/2^(i-1),1:N/2^(i-1)),H0,W0,delay));
		Imageout(N/2^i+1:N/2^(i-1),1:N/2^i)=idownsam(iconvfft(Imagein(1:N/2^(i-1),1:N/2^(i-1)),W0,H0,delay));
	end
else
	dips('norm icorectly set!!!')
end
