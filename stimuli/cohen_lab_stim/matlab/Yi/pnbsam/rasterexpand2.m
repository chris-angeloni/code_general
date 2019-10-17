
%
%function [RAS,Fs]=rasterexpand(RASTER,Fsd,Period,Flag)
%
%       FILE NAME       : RASTER EXPAND
%       DESCRIPTION     : Converts a compressed rastergram data structure
%                         to matrix format (0 and Fsd)
%	
%       RASTER          : Rastergram Data Structure
%                         spet: spike event time 
%                         Fs: sampling rate
%
%       Fsd             : Desired Sampling Rate for Matrix (Hz)
%       Period          : Period of stimulus
%       Flag            : =0, one period as the maximum SPET (for cir-corr)
%                       : =1, the true MaxSpet from spike
%
%Returned Values
%
%       RAS             : Raster data structure
%       Fs              : Sampling Rate
%
% (C) Monty A. Escabi, August 2005 (Edit Sept 2006)
%  Modified by Yi Zheng, 2007.  Add Flag to adapt cir-correlation
%
function [RAS,Fsd]=rasterexpand(RASTER,Fsd,Period,Flag)

if nargin<4
    Flag=1;
end

%Finding Maximum SPET
for k=1:length(RASTER)
   if Flag==0
       MaxSpet=Period*RASTER(1).Fs;
   else
       MaxSpet=max(RASTER(k).spet); 
   end
end

%Expanding compressed data structure
Ntrials=length(RASTER);
% Ntime=1+ceil(MaxSpet/RASTER(1).Fs*Fsd);
Ntime=round(MaxSpet/RASTER(1).Fs*Fsd);
RAS=zeros(Ntrials,Ntime);
for k=1:Ntrials
       RAS(k,[1+round(RASTER(k).spet/RASTER(k).Fs*Fsd)])=Fsd*ones(size(RASTER(k).spet));
end