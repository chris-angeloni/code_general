
%
%function [RAS,Fs]=rasterexpand(RASTER,Fsd,T)
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
%       T               : Desired stimulus duration for generating RASTER
%                         Matrix (Optional, Othrwise finds the maximum in
%                         the spet array to determine T)
%
%Returned Values
%
%       RAS             : Raster matrix
%       Fs              : Sampling Rate
%
% (C) Monty A. Escabi, August 2005 (Edit March 2009, MAE)
%
function [RAS,Fsd]=rasterexpand(RASTER,Fsd,T)

%Finding RASTER Duration
if nargin<3
    for k=1:length(RASTER)
        MaxSpet=max(RASTER(k).spet); 
    end
else
    MaxSpet=T*RASTER(1).Fs;
end

%Expanding compressed data structure
Ntrials=length(RASTER);
%Ntime=1+ceil(MaxSpet/RASTER(1).Fs*Fsd); %Removed on July 2007, Yi / Monty
Ntime=1+ceil(MaxSpet/RASTER(1).Fs*Fsd);
RAS=zeros(Ntrials,Ntime);
for k=1:Ntrials
    
       % RAS(k,[1+round(RASTER(k).spet/RASTER(k).Fs*Fsd)])=Fsd*ones(size(RASTER(k).spet));
       if isnan([RASTER(k).spet])
            RAS(k,:)=0;
       elseif ~isempty([RASTER(k).spet])
            %RAS(k,[ceil(RASTER(k).spet/RASTER(k).Fs*Fsd)])=Fsd*ones(size(RASTER(k).spet));  % Yi, July2007
            %index=min([ceil(RASTER(k).spet(l)/RASTER(k).Fs*Fsd)],Ntime);
            %index=1+min([floor(RASTER(k).spet(l)/RASTER(k).Fs*Fsd)],Ntime);
            index=[ceil(RASTER(k).spet/RASTER(k).Fs*Fsd)];
            i=find(index<=Ntime & index>1);   %MAE, March 2009; edit Jul 2014
            index=index(i);         %MAE, Match 2009
            
%             if strcmp(circular,'y') & index>Ntime         %Wrap spike around to 0 phase
% %                 i=find(index>Ntime);    
% %                 index(i)=ones(size(i));
%                 index=1;
%             end
            for l=1:length(index)
                RAS(k,index(l))=RAS(k,index(l))+Fsd;  % MAE, Aug 2008
            end
            
       end
end