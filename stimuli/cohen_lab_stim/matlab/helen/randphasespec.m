%
%function [Y]=randphasespec(X)
%
%   FILE NAME   : RAND PHASE SPEC
%   DESCRIPTION : Randomizes the phase spectrum of a signal but
%                 preserves the magnitude spectrum
%
%   X           : Input signal
%
%RETURNED VARIABLES
%
%	Y           : Ouput phase shifted signal
%
%	(C) Monty A. Escabi, Jan 2007
%
function [Y]=randphasespec(X)

%Phase shifting
N=length(X);
XX=fft(X);
if N/2==floor(N/2)
    Phase=[exp(i*rand(1,N/2-1)*2*pi)];
    Phase=[1 Phase 1 conj(fliplr(Phase))];
else
    Phase=[exp(i*rand(1,floor(N/2))*2*pi)];
    Phase=[1 Phase conj(fliplr(Phase))];
end
Y=ifft(XX.*Phase);