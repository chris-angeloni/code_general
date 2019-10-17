%
% function [R] = tdtraster2matrix(RASTER,TD,Fs)
%
%	FILE NAME 	    : TDT RASTER 2 MATRIX
%	DESCRIPTION     : Converts a RASTER Data structure to 
%                     a matrix raster
%
%	RASTER          : RASTER Data Sructure
%                     RASTER(k).spet - Spike event times  
%                                      for each trial
%                     Raster(k).Fs   - Sampling Rate
%	TD              : Total stimulus duration (sec)
%
% RETURNED DATA
%
%	R					: Raster Matrix
%
%(C) Monty A. Escabi 2004
%
function [R] = tdtraster2matrix(RASTER,TD,Fs)

%Converting Rastergram to Time X Trial format
[Time,Trial,MaxTrial] = rasterconvert(RASTER);
i=find(Time<TD);
Time=Time(i);
Trial=Trial(i);

%Generating Rastergram Matrix
R=zeros(MaxTrial,ceil(TD*Fs));
for k=1:length(Trial)
   R(Trial(k),max(1,round(Time(k)*Fs)))=1;
end





