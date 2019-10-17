%
%function [RAS] = rastertimetrial2matrix(RASTER,Fsd)
%
%	FILE NAME 	    : RASTER CONVERT
%	DESCRIPTION     : Converts a RASTER Time vs. Trial arrays data
%                     structure to a compressed spet RASTER data structure
%
%	RASTER          : RASTER Data Sructure
%                       .Time   - Spike time array (msec)
%                       .Trial  - Trial number array
%   Fsd             : Desired sampling rate for SPET (Hz)
%
% RETURNED DATA
%
%	RAS                 : Matrix Format
%
%   (C) Monty A. Escabi, September 2006
%
function [RAS] = rastertimetrial2matrix(RASTER,Fsd)

[RAS] = rastertimetrial2spet(RASTER,Fsd);
[RAS] = rasterexpand(RAS,Fsd);