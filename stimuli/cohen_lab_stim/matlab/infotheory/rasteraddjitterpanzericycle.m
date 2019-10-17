%
%function [RAS]=rasteraddjitterpanzericycle(RASTER,sig)
%
%   FILE NAME   : RASTER ADD JITTER PANZERI CYCLE
%   DESCRIPTION : Adds spike timming jitter according to Panzeri et al. for
%                 a circulare dot-raster (cycle-raster). 
%
%                 The jittered spike train is performed by shuffling the
%                 spike times within a window of sig msec.
%
%                 Note: the procedure does NOT preserve the ISI
%                 distribution. Thus, if Fs is very high (>1000 Hz) then
%                 you could potentially genearte spikes outside the
%                 refractory period.
%
%   RASTER      : Cycle dot-rster in spet format
%   Fs          : Sampling rate
%   T           : Spike train duration (ms)
%   sig         : Range of jitter distribution (ms). Spikes are shuffled /
%                 jittered within a window of duration sig msec.
%
%                 Note: T should be an integer multiple of sig. In other
%                 words, T/sig = integer value. If this is not the case, 
%                 the algorithms finds the closest value of sig so that 
%                 T/sig=int holds.
%
%RETURNED VARIABLES
%
%    RAS        : Shuffled cycle dot-rster (i.e., cycle raster) in spet 
%                 format. Includes sig as an element of the raster data
%                 sturcture to indicate the shuffled resolution.
%
%   (C) Monty A. Escabi, Oct 2012
%
function [RAS]=rasteraddjitterpanzericycle(RASTER,sig)

%Adding jitter one trial at a time
Fs=RASTER(1).Fs;
T=RASTER(1).T*1000;
for k=1:length(RASTER)
    
    [RAS(k).spet,sig]=spetaddjitterpanzericycle(RASTER(k).spet,Fs,T,sig);
    RAS(k).Fs=Fs;
    RAS(k).T=T/1000;
    try,RAS(k).Fm=RASTER(1).Fm;,end
    RAS(k).sig=sig;     %Jittered resolution
    
end