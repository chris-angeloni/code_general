%
%function [D]=sdmrasterg(RASTER1,RASTER2,Fsd,fc,BW,P)
%
%       FILE NAME       : SPIKE DISTANCE METRIC RASTER G
%       DESCRIPTION     : Computes the spike distance metric between two
%                         rasters. Similar to  Van Rossum, 1999. Returns
%                         a matrix containing the spike distance between
%                         all possible trial combinations. Instead
%                         of filtering with a first order lowpass filter,
%                         a Gabor bandpass filter is used.
%
%       RASTER1         : RASTER containing spike even times for condition 1
%       RASTER2         : RASTER containing spike even times for condition 2
%       Fs              : Desired sampling rate (Hz)
%       fc              : Gabor fitler center frequency (Hz)
%       BW              : Gabor filter 3 dB bandwidth (Hz)
%       P               : Gabor filter phase (0-2*pi, Default==0)
%
%RETURNED VARIABLES
%
%       D               : Spike distance matrix
%
%       (C) Monty A. Escabi, March 2009
%
function [D]=sdmrasterg(RASTER1,RASTER2,Fsd,fc,BW,P)

%Input Args
if nargin<6
    P=0;
end

for k=1:length(RASTER1)
    for l=1:length(RASTER2)
        
        [D(k,l)]=sdmg(RASTER1(k).spet,RASTER2(l).spet,RASTER1(1).Fs,Fsd,RASTER1(1).T,fc,BW,P);
        
    end
end