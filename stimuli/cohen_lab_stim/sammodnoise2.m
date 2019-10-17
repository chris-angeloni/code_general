%
%function [X]=sammodnoise2(BW,Fm,gamma,T,Fs)
%
%   FILE NAME   : SAM MOD NOISE 2
%   DESCRIPTION : Generates a SAM noise segment. Similar to SAMMODNOISE
%                 with a few modifications
%
%                 a) variance is scaled by 1+gamma^2/2 so that power is the
%                    same as for unmodulated noise.
%                 b) Uses NOISEUNIF to generate bandpass uniform noise
%                 c) Changed the equation for SAM modulated signal
%                 d) made the window gating rise time variable
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
%   RT          : Rise time for window gating (msec) (Default==10 msec)
%   seed        : Random number generator seed (Optional)
%
%RETURNED VARIBLES
%
%   X           : SAM NOISE
%
%(C) Monty A. Escabi, Edit Aug 2008
%
function [X]=sammodnoise2(BW,Fm,gamma,T,Fs,RT,seed)

%Random number generator seed
if nargin<7
    seed=sum(100*clock);
end
if nargin<6
    RT=10;
end

%Generaging Modulation Segment
if BW~=inf
    N=noiseunif([BW(1) BW(2)],Fs,round(T*Fs),seed);
else
    rand('seed',seed);
    N=2*(rand(1,round(Fs*T))-0.5);     
end
X=N.*(1+gamma.*sin(2*pi*Fm/Fs*(0:length(N)-1) - pi/2) );
[W]=window(Fs,3,T,RT);
W=W(1:floor(length(W)/2));
X(length(X):-1:length(X)-length(W)+1)=X(length(X):-1:length(X)-length(W)+1).*W;
X(1:length(W))=X(1:length(W)).*W;

%Normalizing 
X=X/sqrt(1+gamma^2/2);