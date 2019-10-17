%
%function [RASTER]=shuffleraster(RASTER)
%
%   FILE NAME       : SHUFFLE RASTER
%   DESCRIPTION     : Shuffles a RASTERGRAM by randmozing the ISIs for each
%                     trial. This preserves the first order ISI statistics.
%
%	RASTER          : RASTERGRAM in compressed data structure format      
%
% (C) Monty A. Escabi, Jan 2011
%
function [RASTER]=shuffleraster(RASTER)

RAS=RASTER;
for k=1:length(RAS)
 
    if length(RAS(k).spet)>1
        RASTER(k).spet=shufflespet(RAS(k).spet);
    else
        RASTER(k).spet=RASTER(k).spet;    
    end
    
end