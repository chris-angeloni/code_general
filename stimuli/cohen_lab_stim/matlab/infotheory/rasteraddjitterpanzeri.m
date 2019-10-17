%
%function [RAS]=rasteraddjitterpanzeri(RASTER,Fsd,sig)
%
%   FILE NAME   : RASTER ADD JITTER UNIF CIRC
%   DESCRIPTION : Adds spike timming jitter according to panzeri and
%                 colleauges. Resolution is sig msec.
%
%   RASTER      : Dot Rastergram data structure (spet format)
%                 .spet - spike event time (sample number)
%                 .Fs   - sampling rate (Hz)
%                 .T    - total raster duration (sec)
%   Fsd         : Desired sampling rate to add jitter
%   sig         : Range of jitter distribution (ms).
%
%RETURNED VARIABLES
%
%   RAS         : Noisy Spike Event Time Array
%
%   (C) Monty A. Escabi, Aug 2012
%
function [RAS]=rasteraddjitterpanzeri(RASTER,sig)

%Adding jitter one trial at a time
Fs=RASTER(1).Fs;
T=RASTER(1).T;
for k=1:length(RASTER)
    
    RAS(k).spet=spetaddjitterpanzeri(RASTER(k).spet,Fs,T,sig);
    RAS(k).Fs=Fs;
    RAS(k).T=T;
    
end