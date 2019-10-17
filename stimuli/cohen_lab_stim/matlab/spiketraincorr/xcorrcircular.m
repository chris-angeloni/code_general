%
%function [R] = xcorrcircular(X,Y,Delay)
%
%	FILE NAME       : XCORR CIRCULAR
%	DESCRIPTION 	: Discrete circular cross correlation. Performs the
%                     circular cross correlation using an FFT algorithm.
%
%       X,Y         : Input Signals
%       Delay       : Rearanges the correlation output (R) so that the
%                     zeroth bin is centered about the center of the
%                     correaltion function (at the floor(N/2)+1 sample).
%                     Otherwize, the zeroth bin of the correaltion function
%                     is located at the first sample of R. (OPTIONAL,
%                     Default == 'n')
%
%   RETURNED VARIABLES 
%
%       R           : Circular Cross correalation between X and Y
%
%   (C) Monty A. Escabi, July 2007
%
function [R] = xcorrcircular(X,Y,Delay)

%Input Arguments
if nargin<3
   Delay='n';
end

%Computing Circular Correlation
R=ifft( fft(X).*conj(fft(Y)) );

%Dealy so the R(0) is centered about N/2+1 if desired
if Delay=='y'
    R=fftshift(R);
end