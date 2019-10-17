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
%   beta1       : phase parameter: 0 to 1
%   beta2       : freq jitter parameter
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
function [X]=amparametricnoise(f1,f2,df,beta1,beta2,T,Fs)

M=round(T*Fs);
X=zeros(1,M);
for k=1:round((f2-f1)/df)
    
    freq=f1+df*(k-1)+(rand-.5)*beta2*df;
    P=rand*beta1*2*pi;
    X=X+sin(2*pi*freq*(1:M)/Fs+P);
    
end