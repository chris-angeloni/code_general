%
%function [RAS]=rasteraddjitterunif(RASTER,sig,p,lambdan)
%
%   FILE NAME   : RASTER ADD JITTER UNIF
%   DESCRIPTION : Adds spike timming jitter, reproducibility noise
%                 and additive noise to a "spet" action potential
%                 sequence. Trial-to-trial reproducibility is modeled
%                 by a bernoulli process with probability p (p<1). For
%                 the case where p > 1, p represents the number of 
%                 "reliable" spikes and p follows a Poisson distribution
%                 with mean of p. Finally the timmming jitter is modeled by
%                 uniform distribution with a total excursion of dt. 
%                 Finally, the model also includes spontaneous Poisson 
%                 noise.
%
%   RASTER      : Dot Rastergram data structure (spet format)
%                 .spet - spike event time (sample number)
%                 .Fs   - sampling rate (Hz)
%                 .T    - total raster duration (sec)
%   sig         : Range of jitter distribution (ms).
%   p           : Trial-to-trial probability of producing an action
%                 potential.
%   lambdan     : Spike Rate for additive Noise component.
%
%RETURNED VARIABLES
%
%   RAS         : Noisy Spike Event Time Array
%
%   (C) Monty A. Escabi, Aug 2012
%
function [RAS]=rasteraddjitterunif(RASTER,sig,p,lambdan)

RAS=RASTER;
for k=1:length(RASTER)
    
    [RAS(k).spet]=spetaddjitterunif(RASTER(k).spet,sig,p,lambdan,RASTER(1).Fs);
    
end