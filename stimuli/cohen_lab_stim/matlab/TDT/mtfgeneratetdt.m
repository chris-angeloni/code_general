%
% function [MTF] = mtfgeneratetdt(Data,FM,TD,OnsetT,Unit)
%
%	FILE NAME 	: MTF GENERATE TDT
%	DESCRIPTION : Generates a MTF on the TDT system
%
%	Data        : Data structure obtained using "READTANK"
%                Data is formated as follows:
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
%   FM          : Modulation Rate Sequency (From Param.mat File)
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Unit        : Unit Number
%
% RETURNED DATA
%
%	MTF	        : MTF Data Structure
%
%                   MTF.RASTER              - Raster Structure for each FM
%                   MTF.FMAxis              - Modulation Frequency Axis
%                   MTF.Rate                - Rate MTF
%                   MTF.VS                  - Vector Strength MTF
%
%   (C) Monty A. Escabi 2004, (Edit Nov. 2006)
%
function [MTF] = mtfgeneratetdt(Data,FM,TD,OnsetT,Unit)

%Finding Modulation Frequencies
FMs=sort(FM);
index=find(diff(FMs)~=0);
MTF.FMAxis=FMs([1 index+1]);
clear FMs

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

%Isolating and Binning Data For Each FM
%Generates a RASTER Data Structure
N=length(FM)/length(MTF.FMAxis);
for k=1:length(MTF.FMAxis)
    
    %Finding All instances of a given FM
    indexFM=find(FM==MTF.FMAxis(k));

    for n=1:N
        %Finding SPET for a given FM trial
        indexSPET=find(spet<Trig(indexFM(n)+1) & spet>Trig(indexFM(n)));
        MTF.RASTER(n+(k-1)*N).spet=round( (spet(indexSPET)-Trig(indexFM(n))) );
        MTF.RASTER(n+(k-1)*N).Fs=Data.Fs;    
    end
end

%Generating Rate MTF
MTF.Rate=zeros(size(MTF.FMAxis));
for k=1:length(MTF.FMAxis)
    
    %Computing Rate MTF
    for n=1:N
        %Counting Number of Spikes
        MTF.Rate(k)=length(MTF.RASTER(n+(k-1)*N).spet)+MTF.Rate(k);
    end
    
    %Normalizing By Total Stimulus Duration=TD*N
    MTF.Rate(k)=MTF.Rate(k)/TD/N;
    
end

%Generating Vector Strength MTF
MTF.VS=zeros(size(MTF.FMAxis));
for k=1:length(MTF.FMAxis)

    Phase=[];
    for n=1:N
        
        %Extracting Spike Times
        SpikeTime=MTF.RASTER(n+(k-1)*N).spet/Data.Fs;
        index=find(SpikeTime<TD & SpikeTime>OnsetT);
        SpikeTime=SpikeTime(index);
        
        %Spike Time Phase Relative to Modulation Cycle 
        Phase=[Phase SpikeTime*MTF.FMAxis(k)*2*pi];
        
    end
    
    %Vector Strength - Golberg & Brown
    MTF.VS(k)=sqrt( sum(sin(Phase)).^2 + sum(cos(Phase)).^2 )/length(Phase);
    
end