%
% function [MTF] = mtfpsychoraster(Data,FM,GAMMA,TD,OnsetT,Unit)
%
%	FILE NAME 	: MTF PSYCHO RASTER
%	DESCRIPTION : Generates a rastergram for a "psychophysical" equivalent 
%                 MTF from single unit activity. The rastergrams are stored
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
%   GAMMA       : Modulation index vector
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Unit        : Unit Number
%
% RETURNED DATA
%
%	MTF	        : MTF Data Structure
%
%                   MTF.RASTER              - Raster Structure for each FM
%                                             and FC
%                   MTF.FMAxis              - Modulation frequency axis
%                   MTF.GAMMAAxis           - Modulation index axis
%
%   (C) Monty A. Escabi, March 2009
%
function [MTF] = mtfpsychoraster(Data,FM,GAMMA,TD,OnsetT,Unit)

%Finding Modulation Frequencies
FMs=sort(FM);
index=find(diff(FMs)~=0);
FMAxis=FMs([1 index+1]);
GAMMAs=sort(GAMMA);
index=find(diff(GAMMAs)~=0);
GAMMAAxis=GAMMAs([1 index+1]);
clear FMs GAMMAs

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

%Isolating and Binning Data For Each FM and GAMMA
%Generates a RASTER Data Structure
N=length(find(FM==FM(1) & GAMMA==GAMMA(1)));
for k=1:length(FMAxis)
    for l=1:length(GAMMAAxis)
    
        if ~isempty(find(FMAxis(k)==FM & GAMMAAxis(l)==GAMMA))
            
            indexFM=find(FM==FMAxis(k) & GAMMA==GAMMAAxis(l));
            for n=1:N
                %Finding SPET for a given FM trial
                indexSPET=find(spet<Trig(indexFM(n)+1) & spet>Trig(indexFM(n)));
                MTF(k,l).RASTER(n).spet=round( (spet(indexSPET)-Trig(indexFM(n))) );
                MTF(k,l).RASTER(n).Fs=Data.Fs;
                MTF(k,l).GAMMA=GAMMAAxis(l);
                MTF(k,l).FM=FMAxis(k);
                MTF(k,l).RASTER(n).T=TD;
                MTF(k,l).FMAxis=FMAxis;
                MTF(k,l).GAMMAAxis=GAMMAAxis;
            end
        end
    end
end