%
%function [Iout]=lapgaus(Iin,alpha)
%
%       FILE NAME       : LAPGAUS
%       DESCRIPTION     : Laplacian of Gausian Image Filter
% 
%       Iin		: Inoput Image
%       alpha		: Standard Deviation - Smoothing Parameter
%       Iout		: Output Image
%
function [Iout]=lapgaus(Iin,alpha)
N=length(Iin);

%FFT
Iout=fftshift(fft2(Iin));

%Laplacian of gaussian filter
for k=1:N
	for j=1:N
		x(k,:)=-N/2:N/2-1;
		y(:,j)=(-N/2:N/2-1)';
	end
end

H=(x.^2+y.^2) .* exp( -(2*pi/N*alpha).^2 .* (x.^2+y.^2));
Iout=ifft2(fftshift(H.*Iout));

