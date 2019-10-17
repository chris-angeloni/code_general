%
%function [RAS]=rastercompress(RASTER,Fs,T)
%
%       FILE NAME       : RASTER COMPRESS
%       DESCRIPTION     : Converts a rastergram array to compressed format
%                         using ISI data structure
%	
%       RASTER          : Rastergram Matrix
%       Fs              : Sampling rate
%       T               : Stimulus time (sec) 
%                         (Optional)
%
%Returned Values
%
%RAS:                   : Raster data structure
%                         spet: spike event time 
%                         Fs: sampling rate
%                         T: Trial duration in seconds
%
% (C) Monty A. Escabi, August 2005
%
function [RAS]=rastercompress(RASTER,Fs,T)

%Converting to compressed data structure
for k=1:size(RASTER,1)
    RAS(k).Fs=Fs;
	RAS(k).spet=find(RASTER(k,:)~=0);
    if exist('T') 
        RAS(k).T=T;
    end
end