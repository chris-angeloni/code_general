%function [Imageout] = iconvfft(Imagein,X,Y,delay)
%
%	FILE NAME 	: CONVFFT
%	DESCRIPTION 	: Discrete 2-D Convolution performed by using FFT
%			  using separable filter funtions X and Y
%	delay		: Used to correct for filter delay
%	X		: Filter for X-Direction
%	Y		: Filter for Y-Direction
%
function [Imageout] = iconvfft(Imagein,X,Y,delay)

%Finding size
N=length(Imagein);
Imageout=zeros(size(Imagein));

%Image Convolution
for i=1:N
		Imageout(i,1:N)=convfft(Imagein(i,1:N),X,delay);
end
Imageout=rot90(Imageout);
for i=1:N
		Imageout(i,1:N)=convfft(Imageout(i,1:N),Y,delay);
end
