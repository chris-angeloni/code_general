%
% function  [RASTERLin,RASTERLog] = natsoundraster(Data,Bits,QuantType,TD,OnsetT,ChannelNumber,Unit)
%
%	FILE NAME 	: NAT SOUND RASTER
%	DESCRIPTION : Generates the rastergrams for natural sound data 
%                 at multiple quantization bits and linear or log
%	              quantizer.
%
%	Data            : Data structure obtained using "READTANK"
%                     Data is formated as follows:
%
%                       Data.Snips              - Snipet Waveforms
%                       Data.Fs                 - Sampling Rate
%                       Data.SnipsTimeStamp     - Snipet Time Stamps
%                       Data.SortCode           - Sort Code for the Snipets
%                       Data.ChannelNumber      - Channel Number for the Snipets
%                       Data.Trig               - Trigger Event Times
%                       Data.Attenuation        - Event Attenuation Level
%                       Data.Frequency          - Event Frequency 
%                       Data.StimOff            - Stimulus Offset Time
%                       Data.StimOn             - Stimulus Onset Time
%                       Data.EventTimeStanp     - Event Time Stamp
%
%   Bits            : Number of quantization bit Sequence (From Param.mat File)
%   QuantType       : Quantization Type Sequence (From Param.mat File) 
%                     Note:      QuantType=0 -> Linear Quantizer
%                                QuantType=1 -> Log Quantizer
%   ChannelNumber   : Channel Number
%   Unit            : Unit Number (Optional, Otherwise All Units are Collapsed)
%
% RETURNED DATA
%
%	RASTERLin	: Linear Data Raster
%   RASTERLog   : Log Data Raster
%                   
%   (C) Monty A. Escabi, 8-2005
%
function [RASTERLin,RASTERLog] = natsoundraster(Data,Bits,QuantType,ChannelNumber,Unit)

%Finding Quantization Bits
BitsS=sort(Bits);
index=find(diff(BitsS)~=0);
BitsAxisLin=BitsS([1 index+1]);
BitsAxisLog=BitsS([1 index+1]);
clear BitsS

%Extracting Triggers and SPET Times
if nargin<5
   index=find(ChannelNumber==Data.ChannelNumber);                       %Use specified Channel
else
   index=find(Unit==Data.SortCode & ChannelNumber==Data.ChannelNumber); %Use specified Unit & Channel
end
spet=round(Data.SnipTimeStamp(index)*Data.Fs);          %Convert to SPET
Trig=round(Data.Trig*Data.Fs);                          %Syncrhonization Triggers
Trig=[Trig Trig(length(Trig))+mean(diff(Trig))];        %Adding End Trigger
T=mean(diff(Trig))+1000;                                %Trial Length + 1000 samples

%Isolating and Binning Data For Each Bit and QuantType
%Generates a RASTER Data Structure for Log Quantizer
N=length(Bits)/length(BitsAxisLog)/2;
for k=1:length(BitsAxisLog)
    
    %Finding All instances of a given Bit Number and Quant
    indexBit=find(Bits==BitsAxisLog(k) & QuantType==1);

    for n=1:N 

        %Finding SPET for a given Bit trial
        indexSPET=find(spet<Trig(indexBit(n)+1) & spet>Trig(indexBit(n)));
        RASTERLog(n+(k-1)*N).spet=round( (spet(indexSPET)-Trig(indexBit(n))) );
        RASTERLog(n+(k-1)*N).Fs=Data.Fs;
        RASTERLog(n+(k-1)*N).Bits=BitsAxisLog(k);
        
    end
end

%Isolating and Binning Data For Each Bit and QuantType
%Generates a RASTER Data Structure for Lin Quantizer
N=length(Bits)/length(BitsAxisLin)/2;
for k=1:length(BitsAxisLin)
    
    %Finding All instances of a given Bit Number and Quant
    indexBit=find(Bits==BitsAxisLin(k) & QuantType==0);

    for n=1:N 
        
        %Finding SPET for a given Bit trial
        indexSPET=find(spet<Trig(indexBit(n)+1) & spet>Trig(indexBit(n)));
        RASTERLin(n+(k-1)*N).spet=round( (spet(indexSPET)-Trig(indexBit(n))) );
        RASTERLin(n+(k-1)*N).Fs=Data.Fs;
        RASTERLin(n+(k-1)*N).Bits=BitsAxisLin(k);
        
    end
end