%
%function [Y]=randphasespec2d(X)
%
%   FILE NAME   : RAND PHASE SPEC 2D
%   DESCRIPTION : Randomizes the phase spectrum of a 2D image but
%                 preserves the magnitude spectrum
%
%   X           : Input image
%
%RETURNED VARIABLES
%
%	Y           : Ouput phase shifted image
%
%	(C) Monty A. Escabi, Jan 2007
%
function [Y]=randphasespec2d(X)


%Phase shifting
N1=size(X,1);
N2=size(X,2);
XX=fft2(X);
if N1/2==floor(N1/2)
    Phase1=[exp(i*rand(1,N1/2-1)*2*pi)];
    Phase1=[1 Phase1 1 conj(fliplr(Phase1))];
else
    Phase1=[exp(i*rand(1,floor(N1/2))*2*pi)];
    Phase1=[1 Phase1 conj(fliplr(Phase1))];
end
if N2/2==floor(N2/2)
    Phase2=[exp(i*rand(1,N2/2-1)*2*pi)];
    Phase2=[1 Phase2 1 conj(fliplr(Phase2))];
else
    Phase2=[exp(i*rand(1,floor(N2/2))*2*pi)];
    Phase2=[1 Phase2 conj(fliplr(Phase2))];
end

% Y=ifft(XX.*(Phase1'*Phase2));