%
%function [D]=sdmraster(RASTER1,RASTER2,Fsd,tc)
%
%       FILE NAME       : Spike Distance Raster
%       DESCRIPTION     : Computes the spike distance metric between two
%                         rasters as described by Van Rossum, 1999. Returns
%                         a matrix containing the spike distance between
%                         all possible trial combinations
%
%       RASTER1         : RASTER containing spike even times for condition 1
%       RASTER2         : RASTER containing spike even times for condition 2
%       Fs              : Desired sampling rate (Hz)
%       tc              : Time constant (msec)
%
%RETURNED VARIABLES
%
%       D               : Spike distance matrix
%
%       (C) Monty A. Escabi, March 2009
%
function [D]=sdmraster(RASTER1,RASTER2,Fsd,tc)

for k=1:length(RASTER1)
    for l=1:length(RASTER2)
        
        [D(k,l)]=sdm(RASTER1(k).spet,RASTER2(l).spet,RASTER1(1).Fs,Fsd,RASTER1(1).T,tc);
        
    end
end