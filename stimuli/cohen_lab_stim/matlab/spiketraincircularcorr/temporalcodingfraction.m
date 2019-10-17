%
%function [F]=temporalcodingfraction(RASTER,Fm,Ncyc,T,FmMax)
%
%   FILE NAME   : Temporal Coding Fraction
%   DESCRIPTION : New version of the Temporal coding fraction. This version 
%                 of the TCF is different from that defined by Yi & Escabi
%                 (2013): 
%
%                           F = lambda_ac^2/(lambda_dc + lambda_ac)^2
%
%                 This new version takes into account the power of the time
%                 varying spike train (not just simply the DCs from the ac
%                 and dc components). It is defined as
%
%                           F = sum(Ak^2)/sum(A0^2 + Ak^2)
%
%                 where Ak are the Fourier coefficients of the harmonic
%                 componets in the response and A0 is the DC coefficient.
%                 The sum is taken strictly over the statistically
%                 significant coefficients (i.e., those that exceed the
%                 significance level (p<0.001) for a random spike train
%                 with identical firing rate.
%
%   RASTER      : Rastergram in spet format
%   Fm          : Modulation frequency (Hz)
%   Ncyc        : Number of cycles to use for rastergram (Default = 4)
%   T           : Amount of time to remove at begning of file to avoid
%                 adaptation effects (sec). Rounds off to assure that a
%                 integer number of cycles are removed. (Default = 0)
%   FmMax       : Maximum modualtion frequency used to compute temporal
%                 coding fraction (Default = 128 Hz)
%
%RETURNED VARIABLES
%
%   F           : Harmonic analysis based temporal coding fraction
%
% (C) Monty A. Escabi, July 2014
%
function [F]=temporalcodingfraction(RASTER,Fm,Ncyc,T,FmMax)

%Input Arguments
if nargin<5
    FmMax=128;
end
if nargin<4
    T=0;
end
if nargin<3
    Ncyc=4;
end

%Converting the response dot raster to a cycle rastergram
Fsd=Fm*100;                             %100 samples / cycle
[RASTERc]=raster2cycleraster(RASTER,Fm,Ncyc,T);
[RData]=rastercircularshufcorrfast(RASTERc,Fsd,'y',1);

%Computing Power Spectrum by taking the FT of the SAC
Prr=fftshift(abs(fft(RData.Rshuf)));
N=(length(Prr)-1)/2;
faxis=(-N:N)/2/N*Fsd;

%Generating power spectrum of a noisy spike train (Null hypothesis) -
%repeated NB times
NB=100;
for i=1:NB
        [RASTERn]=rasteraddjitterunifcirc(RASTERc,1/Fm*Ncyc*1000,1,0);
        [RDataNoise]=rastercircularshufcorrfast(RASTERn,Fsd,'y',1);
        Pnn(:,i)=fftshift(abs(fft(RDataNoise.Rshuf)));
end

%Finding DC response power
i=find(faxis<Fm/2 & faxis>-Fm);
DC=sum(Prr(i));

%Finding AC response power
dFm=Fm/4;
l=[];   
for fm=Fm:Fm:FmMax
    m=find(faxis<fm+dFm & faxis>fm-dFm);

    n=[];
    if max(Prr(1,m)>std(reshape(Pnn(m,:),1,numel(Pnn(m,:))))+std(reshape(Pnn(m,:),1,numel(Pnn(m,:))))*3)   %Finding components above significance level (mean+3*SD)
        n=[n m];
    end
    l=[l n];
end
AC=2*sum(Prr(l));   %Note I multiply by two to account for the power at the (-) frequencies

%Temporal Coding Fraction
F=AC/(AC+DC);