%
% function [RASTER] = rasterparam2(Data,Param1,Param2,Label1,Label2,TD,OnsetT,Unit)
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
%   Param1      : Vector containing Param1 sequence (From Param.mat File)
%   Param2      : Vector containing Param2 sequence
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Unit        : Unit Number
%
% RETURNED DATA
%
%	RAS	        : Matrix of Data structure RAS(k,l)
%
%                   RAS.RASTER          - Raster Structure for each
%                                         Param1 and Param2
%                   RAS.Param1          - Vector containing Param1 sequence
%                   RAS.Param2          - Vector containing Param1 sequence
%                   RAS.Param1Axis      - Axis for first parameter(e.g.,
%                                         modulation frequency)
%                   RAS.Param2Axis      - Axis for parameter 2 (e.g., 
%                                         Modulation index or bandwidth)
%                   RAS.Label1          - Label for parameter 1
%                   RAS.Label2          - Label for parameter 2
%
%   (C) Monty A. Escabi, Dec 2010 (Edit Sept 2014, MAE)
%
function [RAS] = rasterparam2(Data,Param1,Param2,Label1,Label2,TD,OnsetT,Unit)

%Finding Parameters
Param1s=sort(Param1);
index=find(diff(Param1s)~=0);
Param1Axis=Param1s([1 index+1]);
Param2s=sort(Param2);
index=find(diff(Param2s)~=0);
Param2Axis=Param2s([1 index+1]);
clear Param1s Param2s

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

%Isolating and Binning Data For Each Param1 and Param2
%Generates a RASTER Data Structure
N=length(find(Param1==Param1(1) & Param2==Param2(1)));
for k=1:length(Param1Axis)
    for l=1:length(Param2Axis)
    
        if ~isempty(find(Param1Axis(k)==Param1 & Param2Axis(l)==Param2))
            
            indexParam1=find(Param1==Param1Axis(k) & Param2==Param2Axis(l));
            for n=1:N
                %Finding SPET for a given Param1 trial
                indexSPET=find(spet<Trig(indexParam1(n)+1) & spet>Trig(indexParam1(n)));
                RAS(k,l).RASTER(n).spet=round( (spet(indexSPET)-Trig(indexParam1(n))) );
                RAS(k,l).RASTER(n).Fs=Data.Fs;
                RAS(k,l).Param1=Param1Axis(k);
                RAS(k,l).Param2=Param2Axis(l);
                RAS(k,l).RASTER(n).T=TD;
                RAS(k,l).Param1Axis=Param1Axis;
                RAS(k,l).Param2Axis=Param2Axis;
                RAS(k,l).Label1=Label1;
                RAS(k,l).Label2=Label2;
            end
        end
    end
end