%
%function [RASTERc]=raster2cycleraster(RASTER,FMAxis,Ncyc,T,dT)
%
%
%   FILE NAME       : RASTER2CYCLERASTER
%   DESCRIPTION     : Converts a raster to a cycle raster
%
%   RASTER          : Rastergram in spet format
%   FMAxis          : Modulation frequency array
%   Ncyc            : Number of cycles to use for rastergram
%   T               : Amount of time to remove at begning of file to avoid
%                     adaptation effects (sec). Rounds off to assure that a
%                     intiger number of cycles are removed.
%   dT              : Timing offset for computing cycle rastergram. Used to
%                     construct the cycle rastergram at multiple phases
%                     (Default==0)
%
%Returned Variables
%
%	RASTERc		: RASTER containg each cycle
%
%   (C) Monty A. Escabi, Edit Aug 2012
%
function [RASTERc]=raster2cycleraster(RASTER,FMAxis,Ncyc,T,dT)

%Input Args
if nargin<5
    dT=0;
end

%Rescaling FM so that we select Ncyc periods
FMAxis=FMAxis/Ncyc;

%Number of Trials and Mod Conditions
L=length(FMAxis);
NTrial=size(RASTER,2)/length(FMAxis);

%Removing T seconds at begining of raster and make sure that raster is
%limited above by recording period - Rounds off so that it precisely 
%removes an integer number of cycles
Fs=RASTER(1).Fs;
for k=1:L
    for l=1:NTrial
        Tmin=ceil(T*FMAxis(k))/FMAxis(k);
        Tmax=floor(RASTER(l+(k-1)*NTrial).T*FMAxis(k))/FMAxis(k);
        i=find(RASTER(l+(k-1)*NTrial).spet/Fs>Tmin & RASTER(l+(k-1)*NTrial).spet/Fs<Tmax);
        RASTERt(l+(k-1)*NTrial).spet=RASTER(l+(k-1)*NTrial).spet(i)-round(Tmin*Fs);
        RASTERt(l+(k-1)*NTrial).Fs=Fs;
        RASTERt(l+(k-1)*NTrial).T=RASTER(l+(k-1)*NTrial).T-Tmin;
    end
end
RASTER=RASTERt;
clear RASTERt

%Generating Cycle Rastergram
RASTERc=[];
RASTERt=[];
for k=1:L
    for l=1:NTrial
        
        spet=1+(rem((RASTER(l+(k-1)*NTrial).spet)/Fs+dT,1/FMAxis(k))*Fs); %dT is used to generate at multiple phases
        spet=round(spet);   %Escabi, Dec 7, 2012
        CycleNum=floor(((RASTER(l+(k-1)*NTrial).spet/Fs+dT)*FMAxis(k)))+1;
        Ncycles=floor(FMAxis(k)*RASTER(l+(k-1)*NTrial).T);

        count=1;
        for m=1:Ncycles
            if m==1
                index=find(CycleNum==m | CycleNum==m+Ncycles);  %If exceeds Ncycles, wrap around the last cycle
            else        
                index=find(CycleNum==m);
            end
            if ~isempty(index)
                RASTERt(count).spet=[spet(index)];
                RASTERt(count).Fs=Fs;
                RASTERt(count).T=1/FMAxis(k);
                RASTERt(count).Fm=FMAxis(k)*Ncyc;
            else
                RASTERt(count).spet=[];
                RASTERt(count).Fs=Fs;
                RASTERt(count).T=1/FMAxis(k);
                RASTERt(count).Fm=FMAxis(k)*Ncyc;
            end

            count=count+1;
        end
        RASTERc=[RASTERc  RASTERt];
    end
end