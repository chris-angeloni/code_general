%
%function [RASTERc]=raster2cyclerasterordered(RASTER,Fm,Ncyc,T,dT)
%
%
%   FILE NAME       : RASTER2CYCLERASTERORDERED
%   DESCRIPTION     : Converts a raster to a cycle raster, however, it
%                     orders the trials and periods so that it is easy to
%                     identify the period number and trial number
%
%   RASTER          : Rastergram in spet format
%   Fm              : Modulation frequency (Hz)
%   Ncyc            : Number of cycles to use for rastergram
%   T               : Amount of time to remove at begninng of file to avoid
%                     adaptation effects
%   dT              : Timing offset for computing cycle rastergram. Used to
%                     construct the cycle rastergram at multiple phases
%                     (Default==0)
%
%Returned Variables
%
%	RASTERc		: RASTER containg each cycle ordered according to trials
%                 and period number for each trial
%
function [RASTERc]=raster2cyclerasterordered(RASTER,Fm,Ncyc,T,dT)

%Input Args
if nargin<5
    dT=0;
end

%Corrected modulaiton frequency for Ncycles
Fm=Fm/Ncyc;         %Frequency corresponding to consecutive Ncyc rasters

%Number of Trials and Mod Conditions
NTrial=size(RASTER,2);

%Removing T seconds at begining of raster - Rounds off so that it precisely 
%removes a fixed number of cycles
Fs=RASTER(1).Fs;
if T~=0
        for l=1:NTrial
            TT=ceil(T*Fm)/Fm;
            i=find(RASTER(l).spet/Fs>TT);
            RASTERt(l).spet=RASTER(l).spet(i)-round(TT*Fs);
            RASTERt(l).Fs=Fs;
            RASTERt(l).T=RASTER(l).T-TT;
        end
    RASTER=RASTERt;
    clear RASTERt
end

%Generating Cycle Rastergram
RASTERc=[];
RASTERt=[];
for l=1:NTrial

    spet=1+(rem((RASTER(l).spet)/Fs+dT,1/Fm)*Fs); %dT is used to generate at multiple phases
    CycleNum=floor((RASTER(l).spet/Fs*Fm))+1;
    Ncycles=Fm*RASTER(l).T;

    for m=1:Ncycles
        index=find(CycleNum==m);
        if ~isempty(index)
            RASTERc(l,m).spet=[spet(index)];
            RASTERc(l,m).Fs=Fs;
            RASTERc(l,m).T=1/Fm;
        else
            RASTERc(l,m).spet=[];
            RASTERc(l,m).Fs=Fs;
            RASTERc(l,m).T=1/Fm;
        end
    end

end