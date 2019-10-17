%
% function [Time,Trial,MaxTrial] = rasterconvert(RASTER)
%
%	FILE NAME 	    : RASTER CONVERT
%	DESCRIPTION     : Converts a RASTER Data structure to 
%                     a Time vs. Trial array
%
%	RASTER          : RASTER Data Sructure
%                     RASTER(k).spet    - Spike event times  
%                                         for each trial
%                     Raster(k).Fs      - Sampling Rate
%	MaxTrial			: Maximum Trial - in case no spikes in
%						  trial
%
% RETURNED DATA
%
%	Time            : Spike Time
%   Trial           : Trial Number
%
%   (C) Monty A. Escabi 2004
%
function [Time,Trial,MaxTrial] = rasterconvert(RASTER)

%Generating MTF RASTER
Time=[];
Trial=[];
for k=1:length(RASTER)

    Time=[Time RASTER(k).spet/RASTER(k).Fs];
    Trial=[Trial k*ones(size(RASTER(k).spet))];
    
end
MaxTrial=length(RASTER);
