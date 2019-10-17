%
%function [PSTH]=raster2psth(RASTER,Fsd,T)
%
%   FILE NAME       : RASTER 2 PSTH
%   DESCRIPTION     : Converts a raster in spet format to a PSTH
%
%   RASTER          : Rastergram in spet format
%   Fsd             : Desired sampling rate (Hz)
%   T               : PSTH duration (sec)
%
%Returned Variables
%
%	PSTH            : Post Stimulus Histogram
%
function [PSTH]=raster2psth(RASTER,Fsd,T)

%Generating PSTH
[RAS,Fs]=rasterexpand(RASTER,Fsd,T);
PSTH=mean(RAS);