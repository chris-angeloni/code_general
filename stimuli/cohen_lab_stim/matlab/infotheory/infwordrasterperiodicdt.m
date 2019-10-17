%
%function [InfoData]=infwordrasterperiodicdt(RASTER,B,Fm,sig,T)
%
%   FILE NAME       : INF WORD RASTER PERIOD DT
%   DESCRIPTION     : Entropy & Noise Entropy of a periodic Spike Train 
%                     obtained from the rastergram by computing the 
%                     Probability Distribution, P(W|t,s), of finding a B 
%                     letter Word, W, in the Spike Train at time T for a
%                     given periodic stimulus, s.
%                   
%                     The entropy is computed at multiple spike train 
%                     time-scales (sig) using a procedure similar to Panzeri
%                     et al. For each time-scale, a specifid ammount of
%                     jitter is added to the spike train, which removes
%                     temporal details finer than the jitter.
%
%   RASTER          : Rastergram
%	B               : Length of Word, number of bits per cycle for
%                     generating P(W) and P(W,t)
%   Fm              : Sound modulation Frequency (Hz)
%   sig             : Spike timing resolution (msec). This is adjusted by 
%                     adding uniformly distributed spike timing jitter to 
%                     the spike train
%   T               : Amount of time to remove at begning of file to avoid
%                     adaptation effects (sec). Rounds off to assure that a
%                     integer number of cycles are removed.
%
%Returned Variables
%
%   InfoData        : Data structurea containing all mutual information
%                     results
%
%                     .HWordt   : Noise Entropy per Word
%                     .HSect    : Noise Entropy per Second
%                     .HSpiket  : Noise Entropy per Spike
%                     .HWord    : Entropy per Word
%                     .HSec     : Entropy per Second
%                     .HSpike   : Entropy per Spike
%                     .Rate     : Mean Spike Rate
%                     .W        : Coded words for entropy calculation
%                     .Wt       : Coded words for noise entropy calculation
%                     .P        : Word distribution function
%                     .Pt       : Word distribution function for noise entropy
%                     .dt       : Spike train bin width used for spike
%                                 train (sec)
%                     .sig      : Spike timing resolution (msec). This
%                                 corersponds to the amount of jitter that
%                                 is added to the spike train prior to
%                                 computing information.
%                     .M        : number of trials
%
%
% (C) Monty A. Escabi, Dec. 2012
%
function [InfoData]=infwordrasterperiodicdt(RASTER,B,Fm,sig,T)

%Input Args
if nargin<5
    T=0;    
end

%Computing Entropy and Noise Entropy at multiple jitter conditions
for k=1:length(sig)
    
    clc
    disp(['Computing raw entropy for jitter=' num2str(sig(k)) ' and Fm=' num2str(Fm)])

    %Convert Raster to Cycle Raster and Adding Spike Timing Jitter
    [RASc]=raster2cycleraster(RASTER,Fm,1,T,0);
    [RASc]=rasteraddjitterunifcirc(RASc,sig(k),1,0);
    
    %Computing Mutual Information - note that we already removed T seconds
    %above in raster2cycleraster - no need to remove T again so we can use T=0
    [InfoData(k)]=infwordrasterperiodicpanzeri(RASc,B,Fm,0);
end

%Adding Jitter
for k=1:length(sig)
    InfoData(k).sig=sig(k);
end