%
%function [RASTERc]=raster2cyclerastermatrix(RASTER,Fm,Ncyc,T,Fsd,dT)
%
%
%   FILE NAME       : RASTER2CYCLERASTERMATRIX
%   DESCRIPTION     : Converts a raster to a cycle raster matrix at a
%                     desired sampling rate (Fs)
%
%   RASTER          : Rastergram in spet format
%   Fm              : Modulation frequency
%   Ncyc            : Number of cycles to use for generating rastergram
%   T               : Amount of time to remove at begninng of file to avoid
%                     adaptation effects
%   Fsd             : Desired sampling rate (Hz)
%   dT              : Timing offset for computing cycle rastergram. Used to
%                     construct the cycle rastergram at multiple phases
%                     (Default==0)
%
%Returned Variables
%
%	RASTERc		: RASTER containg each cycle in matrix format
%
%   (C) Monty A. Escabi, Edit Aug 2012
%
function [RASTERc]=raster2cyclerastermatrix(RASTER,Fm,Ncyc,T,Fsd,dT)

%Input Args
if nargin<6
    dT=0;
end

%Number of Trials
NTrial=size(RASTER,2);

%Removing T seconds at begining of raster and make sure that raster is
%limited above by recording period - Rounds off so that it precisely 
%removes an integer number of cycles
Fs=RASTER(1).Fs;
for l=1:NTrial
    Tmin=ceil(T*Fm)/Fm;
    Tmax=floor(RASTER(l).T*Fm)/Fm;
    i=find(RASTER(l).spet/Fs>Tmin & RASTER(l).spet/Fs<Tmax);
    RASTERt(l).spet=RASTER(l).spet(i)-Tmin*Fs;
    RASTERt(l).Fs=Fs;
    RASTERt(l).T=RASTER(l).T-Tmin;
end
RASTER=RASTERt;
clear RASTERt

%Finding Cycle RASTER Duration in number of samples
MaxSpet=Ncyc*1/Fm*RASTER(1).Fs;

%Expanding compressed data structure
Ntrials=length(RASTER);
Ncycles=floor(RASTER(1).T/(1/Fm*Ncyc));
Ntime=ceil( round(MaxSpet/RASTER(1).Fs*Fsd*1000000)/1000000  ); %Round operation and multiplication by 1M is necessary to avoid round off errors
                                                                %Note that 1M is beyond resolution of Fs     
%Initializing Cycle Rastergram
RASTERc=zeros(Ntrials*Ncycles,Ntime);

%Generating Cycle Rastergram
for l=1:NTrial

    spet=1+floor(Fsd*rem((RASTER(l).spet)/Fs+dT,1/Fm*Ncyc));   %dT is used to generate at multiple phases
    CycleNum=ceil(((RASTER(l).spet)/Fs+dT)/(1/Fm*Ncyc));
    Ncycles=floor(Fm*RASTER(l).T/Ncyc);

    index=find(CycleNum==Ncycles+1);            %Make sure to wrap around Ncycle+1
    if numel(index)
        CycleNum(index)=ones(1,numel(index));
    end
            
    for j=1:length(spet)
        RASTERc(CycleNum(j)+(l-1)*Ncycles,spet(j))=RASTERc(CycleNum(j)+(l-1)*Ncycles,spet(j))+Fsd;
    end

end