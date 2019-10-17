%
%function [InfoData]=infwordrasterperiodicmodeldt(RASTER,B,Fm,sig,M,T)
%
%   FILE NAME       : INF WORD RASTER PERIOD MODEL DT
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
%                     The Information is computed using a model cycle 
%                     raster that is fitted to the original data.
%
%   RASTER          : Rastergram
%	B               : Length of Word, number of bits per cycle for
%                     generating P(W) and P(W,t)
%   Fm              : Sound modulation Frequency (Hz)
%   sig             : Spike timing resolution (msec). This is adjusted by 
%                     adding uniformly distributed spike timing jitter to 
%                     the spike train
%   M               : Number of trials for model cycle raster that are used
%                     to compute mutual information. If M is a vector, the
%                     information is computed for different data lengths.
%   T               : Amount of time to remove at begning of file to avoid
%                     adaptation effects (sec). Rounds off to assure that a
%                     intiger number of cycles are removed.
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
function [InfoData]=infwordrasterperiodicmodeldt(RASTER,B,Fm,sig,M,T)

%Generating model cycle raster
[RASmodel]=jittermodelcyclerasteroptim(RASTER,Fm,max(M)+1,T); 

%Computing Entropy and Noise Entropy at multiple jitter conditions
for k=1:length(sig)
    
    %Adding Spike Timing Jitter to Model Raster
    [RAS]=rasteraddjitterunifcirc(RASmodel,sig(k),1,0);
    
    for l=1:length(M)
        clc
        disp(['Computing raw entropy for jitter=' num2str(sig(k)) ' and M=' num2str(M(l))  ' and Fm=' num2str(Fm)])

        %Computing Mutual Information
        [InfoData(k,l)]=infwordrasterperiodicpanzeri(RAS(1:M(l)+1),B,Fm,0);
    end
end

%Adding Jitter and number of trials to data structure
for k=1:length(sig)
    for l=1:length(M)
        
    InfoData(k,l).sig=sig(k);
    InfoData(k,l).M=M(l);
    
    end
end