%
%function [RASTER]=shufflerandraster(RASTER)
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
%
%RETURNED VARIABLES
%
%   RASTER          : Randomized raster
%
% (C) Monty A. Escabi, July 2007
%
function [RASTER]=shufflerandraster(RASTER)

%Generating Random RASTER
for k=1:size(RASTER,2)
    [RASTER(k).spet]=shufflerandspet(RASTER(k).spet,RASTER(k).Fs,RASTER(k).T);
end