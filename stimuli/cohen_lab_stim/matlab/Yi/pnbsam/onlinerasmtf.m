%	FILE NAME 	: ONLINE RASTER MTF
%	DESCRIPTION : Online Generate Raster and mtf 
%
%   Flag        : 0: SAM; 1: PNB; 2: onset
% RETURNED DATA
%	RASspet	    : compressed spet RASTER format
%                .spet         - spike event time
%                .Fs
%                .T
%  MTF             


function [RASspet,MTF]=onlinerasmtf(Data,Flag)

if Flag==2
  [RASspet, RAStt, FMAxis] = rastergen(Data,2,'cyc',0,1,0,100);
  [MTF]= mtfrtgenerate(RASspet,FMAxis,2,'cyc',0,1,100);
elseif Flag==0
  [RASspet, RAStt, FMAxis] = rastergen(Data,0,'duration',1,4,0,10)
  [MTF]= mtfrtgenerate(RASspet,FMAxis,0,'duration',1,4,10)
else Flag==1
  [RASspet, RAStt, FMAxis] = rastergen(Data,1,'duration',1,4,0,10)
  [MTF]= mtfrtgenerate(RASspet,FMAxis,1,'duration',1,4,10)
end