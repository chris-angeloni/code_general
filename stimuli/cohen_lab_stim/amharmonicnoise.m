%
%function [X]=amharmonicnoise(f1,f2,df,alpha,beta1,beta2,T,Fs)
%
%   FILE NAME   : AM HARMONIC NOISE
%   DESCRIPTION : Generates a harmonic noise complex with.
%
%   f1          : Lower frequency
%   f2          : Upper freqency
%   df          : Harmonic spacing
%   alpha       : Controls the slope of the spectrum. Spectrum is assumed
%                 to drop off as f^(-alpha)
%   beta1       : Phase parameter (0 to 1). Allows the phase of each tone
%                 to vary from cosine phase (0) to random phase (1).
%   beta2       : Freq jitter parameter (0 to 1). 0 indicates no jitter 1 
%                 indicates maximum jitter. Adds jitter to the harmonic
%                 components. Amount of jitter is uniformly distrbuted as 
%                 df*X where X is a uniformly distributed random variable, 
%                 X ~ [-.5 .5]
%   T           : Stimulus Duration (sec)
%   Fs          : Sampling frequency (Hz)
%
%RETURNED VARIBLES
%
%   X           : HARMONIC NOISE COMPLEX
%
%(C) Monty A. Escabi, November 2009
%
function [X]=amharmonicnoise(f1,f2,df,alpha,beta1,beta2,T,Fs)

M=round(T*Fs);
X=zeros(1,M);
for k=1:round((f2-f1)/df)
    
    freq=f1+df*(k-1)+(rand-.5)*beta2*df;
    P=rand*beta1*2*pi;
    X=X+freq.^(-alpha/2).*sin(2*pi*freq*(1:M)/Fs+P);
    
end

%Gating with Window
W=windowm(Fs,3,M,5);
X=X.*W;