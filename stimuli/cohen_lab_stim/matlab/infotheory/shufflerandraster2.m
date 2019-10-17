%
%function [RASTER]=shufflerandraster2(RASTER,refractory)
%
%   FILE NAME       : SHUFFLE RAND RASTER
%   DESCRIPTION     : Shuffles a RASTERGRAM. Produces Poisson 
%                     intervals and same number of spikes as the original
%                     RASTERGRM.
%
%   RASTER          : Rastergram data structure. Contains the following
%                     elements:
%                    
%                   .spet   - spike event times for each trial
%                   .Fs     - sampling rate
%                   .T      - trial duration in sec
%   refractory      : Refractory period (msec)
%
%RETURNED VARIABLES
%
%   RASTER          : Randomized raster
%
% (C) Monty A. Escabi, July 2007
%
function [RASTER]=shufflerandraster2(RASTER,refractory)

%Generating Random RASTER
for k=1:size(RASTER,2)
    [RASTER(k).spet]=shufflerandspet2(RASTER(k).spet,RASTER(k).Fs,refractory,RASTER(k).T);
end