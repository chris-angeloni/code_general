%
%function [RASTER]=cycleraster2periodraster(RASTERc,Fm,Ncyc,Ntrial,L)
%
%   FILE NAME       : CYCLERASTER 2 PERIOD RASTER
%   DESCRIPTION     : Synthetical generates a periodic dot-raster from a single
%                     cycle dot raster using the procedure of Zheng et al
%                     2008. Does so by randomly selecting single cycles
%                     from a 1-cycle dot raster (RASTERc) and adding copies
%                     successively at each period (determined by Fm).
%
%   RASTERc         : Cycle rastergram in spet format
%                     .spet - spike event time (sample number)
%                     .Fs   - sampling rate (Hz)
%                     .T    - total raster duration (sec)
%   Fm              : Modulation frequency for synthetic periodic raster
%   Ncyc            : Number of cycles for the periodic raster
%   Ntrial          : Number of trials for the periodic raster
%   L               : Number of cycles to remove from the begining of the
%                     periodic dot raster. If the steady state response is
%                     desired one needs to remove at least 
%
%                           ceil(RASTERc(1).T*Fm)
%
%                   number of cycles (optional, Default==0)
%
%RETURNED VARIABLES
%
%	RASTER          : Periodic dot raster in spet format
%                     .spet - spike event time (sample number)
%                     .Fs   - sampling rate (Hz)
%                     .T    - total raster duration (sec)
%
%   (C) Monty A. Escabi, June 2014
%
function [RASTER]=cycleraster2periodraster(RASTERc,Fm,Ncyc,Ntrial,L)

%Input Args
if nargin<5
    L=0;
end

%Initializing 
M=length(RASTERc);
for k=1:Ntrial
        RASTER(k).spet=[];
        RASTER(k).Fs=RASTERc(1).Fs;
        RASTER(k).T=RASTERc(1).T*(Ncyc-L);
end

%Generating Synthetic Periodic RASTER
Fs=RASTERc(1).Fs;
for k=1:Ntrial
    for l=1:L+Ncyc
   
        %Randomly selecting cycles from RASTERc and appending to RASTER
        i=randsample(M,1);
        RASTER(k).spet=sort(round([RASTER(k).spet RASTERc(i).spet+1/Fm*Fs*(l-1)]));
        
    end
end

%Removing Cycles at the begining and end
for k=1:length(RASTER)

    i=find(RASTER(k).spet>L/Fm*Fs & RASTER(k).spet<=(L+Ncyc)/Fm*Fs);
    RASTER(k).spet=round(RASTER(k).spet(i)-L*1/Fm*Fs);
    
end