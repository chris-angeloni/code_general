%
%function [RASTERc]=raster2partialcyclerastermatrix(RASTER,Fm,T,Fsd,TW,dT)
%
%   FILE NAME       : RASTER2CYCLERASTERMATRIX
%   DESCRIPTION     : Converts a raster to a cycle raster matrix at a
%                     desired sampling rate (Fs). Similar to
%                     RASTER2CYCLERASTERMATRIX except that the words dont
%                     have to be 1 cycle. The words are choosen at each
%                     cycle phase so that there is one word per cycle
%                     generated.
%
%   RASTER          : Rastergram in spet format
%   Fm              : Modulation frequency
%   T               : Amount of time to remove at begninng of file to avoid
%                     adaptation effects
%   Fsd             : Desired sampling rate (Hz)
%   TW              : Word duration (msec). The word duration is arbitrary. 
%                     It can be either greater or less then the cycle 
%                     duration (1/Fm).
%   dT              : Timing offset for computing cycle rastergram. Used to
%                     construct the cycle rastergram at multiple phases
%                     (Default==0)
%
%Returned Variables
%
%	RASTERc		: RASTER containg each cycle in matrix format
%
function [RASTERc]=raster2partialcyclerastermatrix(RASTER,Fm,T,Fsd,TW,dT)

%Input Args
if nargin<6
    dT=0;
end

%Number of Trials
NTrial=size(RASTER,2);

%Removing T seconds at begining of raster - Rounds off so that it precisely 
%removes a fixed number of cycles
Fs=RASTER(1).Fs;
if T~=0
        for l=1:NTrial
            TT=ceil(T*Fm)/Fm;
            i=find(RASTER(l).spet/Fs>TT);
            RASTERt(l).spet=RASTER(l).spet(i)-TT*Fs;
            RASTERt(l).Fs=Fs;
            RASTERt(l).T=RASTER(l).T-TT;
        end
    RASTER=RASTERt;
    clear RASTERt
end

%Finding Cycle RASTER Duration in number of samples
Lcyc=ceil(TW*Fm);
MaxSpet=Lcyc*1/Fm*RASTER(1).Fs;

%Expanding compressed data structure
Ntrials=length(RASTER);
Ncycles=ceil((RASTER(1).T)*Fm); %Maximum possible number of cycles allowed
Ntime=ceil( round(MaxSpet/RASTER(1).Fs*Fsd*1000000)/1000000  ); %Round operation and multiplication by 1M is necessary to avoid round off errors
                                                                %Note that 1M is beyond resolution of Fs                                             
%Initializing Cycle Rastergram
RASTERc=zeros(Ntrials*Ncycles,Ntime);

%Generating Cycle Rastergram
count=0;
for l=1:NTrial
    for m=1:Ncycles
        
        %Finding SPETS for each cycle
        if 1/Fm*(m-1)>=0 & 1/Fm*(m-1)+1/Fm*Lcyc-dT<=RASTER(1).T
            %Finding spets for each word
            i=find( (RASTER(l).spet)/Fs+dT>1/Fm*(m-1) & (RASTER(l).spet)/Fs+dT<1/Fm*(m-1)+1/Fm*Lcyc );

            spet=floor(Fsd*((RASTER(l).spet(i))/Fs - (1/Fm*(m-1) - dT)))+1;
            count=count+1;
            
            %Adding spikes to raster matrix
            for j=1:length(spet)
                RASTERc(count,spet(j))=RASTERc(count,spet(j))+Fsd;
            end
            
        end
    end
end

%Truncating Words to TW
Ntime=ceil(round(TW*Fsd*1000000)/1000000);  %Round operation and multiplication by 1M is necessary to avoid round off errors
RASTERc=RASTERc(1:count,1:Ntime);