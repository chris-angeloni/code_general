%
%function [RAS]=rasteraddjitter(RASTER,sigma,p,lambdan)
%
%   FILE NAME   : RASTER ADD JITTER
%   DESCRIPTION : Adds spike timming jitter, reproducibility noise
%                 and additive noise to a dot raster. Trial-to-trial 
%                 reproducibility is modeled by a bernoulli process with 
%                 probability p (p<1). For the case where p > 1, p 
%                 represents the number of "reliable" spikes and p follows 
%                 a Poisson distribution with mean of p. Finally the 
%                 timmming jitter is modeled by a gaussian distribution 
%                 with standard deviation sigma. Finally, the model also 
%                 includes spontaneous Poisson noise.
%
%   RASTER      : Dot Rastergram data structure (spet format)
%                 .spet - spike event time (sample number)
%                 .Fs   - sampling rate (Hz)
%                 .T    - total raster duration (sec)
%   sigma       : Standard deviation of jitter distribution (msec).
%   p           : Trial-to-trial probability of producing an action
%                 potential.
%   lambdan     : Spike Rate for additive Noise component.
%
%RETURNED VARIABLES
%
%   RAS         : Noisy dot rastergram
%
%   (C) Monty A. Escabi, Aug 2012
%
function [RAS]=rasteraddjitter(RASTER,sigma,p,lambdan)

RAS=RASTER;
for k=1:length(RASTER)
    
    [RAS(k).spet]=spetaddjitter(RASTER(k).spet,sigma,p,lambdan,RASTER(1).Fs,RASTER(1).T);
    
end