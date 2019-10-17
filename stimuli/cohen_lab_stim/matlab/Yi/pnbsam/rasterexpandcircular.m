
%
%function [RASc,Fs]=rasterexpandcircular(RASTERc,Fsd,T)
%
%       FILE NAME       : RASTER EXPAND CIRCULAR
%       DESCRIPTION     : Converts a compressed cycle rastergram data structure
%                         to matrix format (0 and Fsd) cycle rastergram. 
%	
%       RASTER          : Rastergram Data Structure
%                         spet: spike event time 
%                         Fs: sampling rate
%
%       Fsd             : Desired Sampling Rate for Matrix (Hz)
%       T               : Desired stimulus period for generating RASTER
%                         Matrix
%
%Returned Values
%
%       RASc            : Cycle Raster data structure
%       Fs              : Sampling Rate
%
% (C) Monty A. Escabi, August 2005 (Edit Aug 2008, MAE)
%
function [RASc,Fsd]=rasterexpandcircular(RASTERc,Fsd,T)

%Finding Cycle RASTER Duration in number of samples
MaxSpet=T*RASTERc(1).Fs;

%Expanding compressed data structure
Ntrials=length(RASTERc);
Ntime=ceil(MaxSpet/RASTERc(1).Fs*Fsd);
RASc=zeros(Ntrials,Ntime);
for k=1:Ntrials
       if isnan([RASTERc(k).spet])
            RASc(k,:)=0;
       elseif ~isempty([RASTERc(k).spet])
            index=[ceil(RASTERc(k).spet/RASTERc(k).Fs*Fsd)];
            i=find(index>Ntime);    
            index(i)=ones(size(i));
            for l=1:length(index)
                RASc(k,index(l))=RASc(k,index(l))+Fsd;  % MAE, Aug 2008
            end
       end
end