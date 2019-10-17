%
% function [RTF] = rtfpsychoraster(Data,FM,GAMMA,TD,OnsetT,Unit)
%
%	FILE NAME 	: RTF PSYCHO RASTER
%	DESCRIPTION : Generates a rastergram for a "psychophysical" equivalent 
%                 RTF from single unit activity. The rastergrams are stored
%                 as a function of modulation frequnecy and index.
%
%	Data        : Data structure obtained using "READTANK"
%                 Data is formated as follows:
%
%                   Data.Snips              - Snipet Waveforms
%                   Data.Fs                 - Sampling Rate
%                   Data.SnipsTimeStamp     - Snipet Time Stamps
%                   Data.SortCode           - Sort Code for the Snipets
%                   Data.ChannelNumber      - Channel Number for the Snipets
%                   Data.Trig               - Trigger Event Times
%                   Data.Attenuation        - Event Attenuation Level
%                   Data.Frequency          - Event Frequency 
%                   Data.StimOff            - Stimulus Offset Time
%                   Data.StimOn             - Stimulus Onset Time
%                   Data.EventTimeStanp     - Event Time Stamp
%
%   FM          : Modulation rate vector (From Param.mat File)
%   RD          : Riple density vector
%   GAMMA       : Modulation index vector
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Unit        : Unit Number
%
% RETURNED DATA
%
%	RTF	        : RTF Data Structure
%
%                   RTF.RASTER              - Raster Structure for each FM
%                                             and FC
%                   RTF.FMAxis              - Modulation frequency axis
%                   RTF.RDAxis              - Ripple density axis
%                   RTF.GAMMAAxis           - Modulation index axis
%
%   (C) Monty A. Escabi, June 2009
%
function [RTF] = rtfpsychoraster(Data,FM,RD,GAMMA,TD,OnsetT,Unit)

%Finding Modulation Frequencies
FMs=sort(FM);
index=find(diff(FMs)~=0);
FMAxis=FMs([1 index+1]);
RDs=sort(RD);
index=find(diff(RDs)~=0);
RDAxis=RDs([1 index+1]);
GAMMAs=sort(GAMMA);
index=find(diff(GAMMAs)~=0);
GAMMAAxis=GAMMAs([1 index+1]);
clear FMs RDs GAMMAs

%Extracting Triggers and SPET Times
if nargin<5
   index=1:length(Data.SortCode);                       %Use all Units
else
   index=find(Unit==Data.SortCode);                     %Use specified Unit
end
spet=round(Data.SnipTimeStamp(index)*Data.Fs);          %Converint to SPET
Trig=round(Data.Trig*Data.Fs);                          %Syncrhonization Triggers
Trig=[Trig Trig(length(Trig))+mean(diff(Trig))];        %Adding End Trigger
T=mean(diff(Trig))+1000;                                %Trial Length + 1000 samples

%Isolating and Binning Data For Each FM, RD, and GAMMA
%Generates a RASTER Data Structure
N=length(find(FM==FM(1) & RD==RD(1) & GAMMA==GAMMA(1)));
for k=1:length(FMAxis)
    for l=1:length(RDAxis)
        for m=1:length(GAMMAAxis)
    
            if ~isempty(find(FMAxis(k)==FM & RDAxis(l)==RD & GAMMAAxis(m)==GAMMA))

                indexFM=find(FM==FMAxis(k) & RD==RDAxis(l) & GAMMA==GAMMAAxis(m));
                for n=1:N
                    %Finding SPET for a given FM and RD trial
                    indexSPET=find(spet<Trig(indexFM(n)+1) & spet>Trig(indexFM(n)));
                    RTF(k,l,m).RASTER(n).spet=round( (spet(indexSPET)-Trig(indexFM(n))) );
                    RTF(k,l,m).RASTER(n).Fs=Data.Fs;
                    RTF(k,l,m).FM=FMAxis(k);
                    RTF(k,l,m).RD=RDAxis(l);
                    RTF(k,l,m).GAMMA=GAMMAAxis(m);
                    RTF(k,l,m).RASTER(n).T=TD;
                    RTF(k,l,m).FMAxis=FMAxis;
                    RTF(k,l,m).RDAxis=RDAxis;
                    RTF(k,l,m).GAMMAAxis=GAMMAAxis;
                end
            end
        end
    end
end