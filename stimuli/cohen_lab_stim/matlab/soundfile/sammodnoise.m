%
%function [X]=sammodnoise(BW,Fm,gamma,T,Fs)
%
%   FILE NAME   : SAM MOD NOISE
%   DESCRIPTION : Generates a .WAV file which is used for 
%                 MTF experiments
%
%   BW          : Noise Bandwidth
%                 Default==inf (Flat Spectrum Noise)
%                 Otherwise BW=[F1 F2]
%                 where F1 is the lower cutoff and
%                 F2 is the upper cutoff frequencies
%   Fm          : Modulation Frequency (Hz)
%   gamma       : Modulation Index (0 < gamma < 1)
%   T           : Stimulus Duration (sec)
%   Fs          : Sampling frequency
%
%RETURNED VARIBLES
%
%   X           : SAM NOISE
%
%(C) Monty A. Escabi, Oct 2005 (Edit Aug 2008)
%
function [X]=sammodnoise(BW,Fm,gamma,T,Fs)

%Generaging Modulation Segment
if BW~=inf
    %N=noiseblfft(BW(1),BW(2),Fs,round(T*Fs));
    N=noiseblh(BW(1),BW(2),Fs,round(T*Fs));     %Changed 12/10/10, better statistics
else
    N=2*(rand(1,round(Fs*T))-0.5);     
end
X=N.*((1-gamma/2)+gamma/2.*sin(2*pi*Fm/Fs*(0:length(N)-1) - pi/2) );
[W]=window(Fs,3,100,2);
W=W(1:floor(length(W)/2));
X(length(X):-1:length(X)-length(W)+1)=X(length(X):-1:length(X)-length(W)+1).*W;
X(1:length(W))=X(1:length(W)).*W;   %Added Aug 2008