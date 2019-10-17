%
% function [FTC] = ftcgenerate(Data,T1,T2,Channel,SPLoffset)
%
%	FILE NAME 	: FTC Generate
%	DESCRIPTION : Generates a frequency tunning curve on the TDT system
%
%	Data        : Data structure obtained using "READTANK"
%                 Data is formated as follows:
%
%                   Data.Snips              - Snipet Waveforms
%                   Data.Fs                 - Sampling Rate
%                   Data.SnipTimeStamp      - Snipet Time Stamps
%                   Data.SortCode           - Sort Code for the Snipets
%                   Data.ChannelNumber      - Channel Number for the Snipets
%                   Data.Trig               - Trigger Event Times
%                   Data.Attenuation        - Event Attenuation Level
%                   Data.Frequency          - Event Frequency 
%                   Data.StimOff            - Stimulus Offset Time
%                   Data.StimOn             - Stimulus Onset Time
%                   Data.EventTimeStanp     - Event Time Stamp
%                   
%   T1          : FTC window start time
%   T2          : FTC window end time
%   Channel     : Channel number to compute FTC. Optional parameter. If it
%                 is not specified assumes that the data structure
%                 contains a single channel and uses all of the data. To
%                 generate an FTC for 16 channel see FTCGENERATE16.
%   SPLoffset   : SPL offset to convert ATT to true SPL (dB)
%
% RETURNED DATA
%
%	FTC	        : Tunning Curve Data Structure
%
%                   FTC.Freq                - Frequency Axis
%                   FTC.Level               - Sound Level Axis (dB)
%                   FTC.data                - Data matrix
%                   FTC.NFTC                - Number of FTC repeats
%                   FTC.T1                  - FTC Window start time
%                   FTC.T2                  - FTC Window end time
%
%   (C) Monty A. Escabi, Aug. 2005 (Edit Feb 2012)
%
function [FTC] = ftcgenerate(Data,T1,T2,Channel,SPLoffset)

%Input Arguments
if nargin<5
    SPLoffset=0;
end

%Number of Snips
Nsnips=max(Data.SortCode)+1;

%Removing Junk Data
index=find(Data.Attenuation>-500);
Data.Attenuation=Data.Attenuation(index)+SPLoffset;
Data.Frequency=Data.Frequency(index);
Data.EventTimeStamp=Data.EventTimeStamp(index);

%Selecting Data for a specific channel
if exist('Channel') & ~isempty(Channel)
    i=find(Data.ChannelNumber==Channel);
    Data.SnipTimeStamp=Data.SnipTimeStamp(i);
    Data.SortCode=Data.SortCode(i);
end

%Some Definitions
EventTS=[Data.EventTimeStamp max(Data.EventTimeStamp)+mean(diff(Data.EventTimeStamp))];
SnipTS=Data.SnipTimeStamp;

%Extracting Spike Count Data for each Event
for k=1:length(EventTS)-1
    for l=0:Nsnips-1
        
        index=find(SnipTS>EventTS(k)+T1/1000 & SnipTS<EventTS(k)+T2/1000 & Data.SortCode==l);
        FTC(l+1).Data(k)=length(index);
        
    end 
end

%Generate Frequency Axis
Freq=sort(Data.Frequency);
index=[1 1+find(diff(Freq)>0)];
for k=1:Nsnips
    FTC(k).Freq=Freq(index);    
end
clear Freq

%Generate SPL Axis
Level=sort(Data.Attenuation);
index=[1 1+find(diff(Level)>0)];
for k=1:Nsnips
    FTC(k).Level=Level(index);
end
NFTC=round(length(Level)/length(FTC(1).Level)/length(FTC(1).Freq));   %Number of Tunning Curve Repeats
clear Level

%Adding Number of Tunning Curves, T1 and T2 to FTC matrix
for k=1:Nsnips
    FTC(k).NFTC=NFTC;
    FTC(k).T1=T1;
    FTC(k).T2=T2;
end

%Generating Tuning Curve Matrix for each Snipet
for k=1:length(FTC(1).Freq)
    for l=1:length(FTC(1).Level)
        for m=0:Nsnips-1
            
            index=find(Data.Frequency==FTC(m+1).Freq(k) & Data.Attenuation==FTC(m+1).Level(l));
            FTC(m+1).data(k,l)=sum(FTC(m+1).Data(index));
            
        end
    end
end

%Removing Temporary Data Field
FTC=rmfield(FTC,'Data');