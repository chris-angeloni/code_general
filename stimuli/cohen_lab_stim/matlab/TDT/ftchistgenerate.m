%
% function [FTC] = ftchistgenerate(Data,T1,T2,Fs,Channel,SPLOffset)
%
%	FILE NAME 	: FTC HIST Generate
%	DESCRIPTION : Generates a level & frequency dependent histogram 
%                 from FTC data on the TDT system
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
%   T1          :   Histogram window start time (msec)
%   T2          :   Histogram window end time (msec)
%   Fs          :   Histogram sampling frequency (Hz)
%   Channel     : Channel number to compute FTC. Optional parameter. If it
%                 is not specified assumes that the data structure
%                 contains a single channel and uses all of the data. To
%                 generate an FTC for 16 channel see FTCGENERATE16.
%   SPLoffset   : SPL offset to convert ATT to true SPL (dB)
%
% RETURNED DATA
%
%	FTCHist	    : Tunning Curve Data Structure
%
%                   FTCHist.Fs              - Sampling Rate
%                   FTCHist.Freq            - Frequency Axis
%                   FTCHist.Level           - Sound Level Axis (dB)
%                   FTCHist.time            - Time axis (msec)
%                   FTCHist.data            - Data matrix
%                   FTC.NFTC                - Number of FTC repeats
%                   FTC.T1                  - FTC Window start time (msec)
%                   FTC.T2                  - FTC Window end time (msec)
%
% (C) Monty A. Escabi, Oct 2005 (modified Feb 2012)
%
function [FTCHist] = ftchistgenerate(Data,T1,T2,Fs,Channel,SPLOffset)

%Input Arguments
if nargin<6
    SPLoffset=0;
end

%Number of Snips
Nsnips=max(Data.SortCode)+1;

%Removing Junk Data
index=find(Data.Attenuation>-500);
Data.Attenuation=Data.Attenuation(index);
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

%Generating Time Histogram for Each Trigger Event
for k=1:length(EventTS)-1
    for l=0:Nsnips-1
        
        index=find(SnipTS>EventTS(k)+T1/1000 & SnipTS<EventTS(k)+T2/1000 & Data.SortCode==l);
        ResponseTimeStamp=SnipTS(index)-EventTS(k);
        index=round(ResponseTimeStamp*Fs)+1-ceil(T1/1000*Fs);
        FTCHist(l+1).Data(k,:)=zeros(1,1+floor(T2/1000*Fs)-ceil(T1/1000*Fs));
        if ~isempty(index)
            FTCHist(l+1).Data(k,index)=ones(1,length(index));
        end
    end 
end

%Generate Frequency Axis
Freq=sort(Data.Frequency);
index=[1 1+find(diff(Freq)>0)];
for k=1:Nsnips
    FTCHist(k).Freq=Freq(index);    
end
clear Freq

%Generate SPL Axis
Level=sort(Data.Attenuation);
index=[1 1+find(diff(Level)>0)];
for k=1:Nsnips
    FTCHist(k).Level=Level(index)+SPLOffset;
end
NFTC=round(length(Level)/length(FTCHist(1).Level)/length(FTCHist(1).Freq));   %Number of Tunning Curve Repeats
clear Level

%Generating Time Axis
for k=1:Nsnips
    FTCHist(k).time=[round(T1/1000*Fs):round(T2/1000*Fs)]/Fs*1000;
end

%Adding Number of Tunning Curves, T1 and T2 to FTC matrix
for k=1:Nsnips
    FTCHist(k).NFTC=NFTC;
    FTCHist(k).T1=T1;
    FTCHist(k).T2=T2;
end

%Sorting Trigger Events according to Frequency and SPL and 
%Generating Tuning Curve Matrix for each Snipet
for k=1:length(FTCHist(1).Freq)
    for l=1:length(FTCHist(1).Level)
        for m=0:Nsnips-1
            
            index=find(Data.Frequency==FTCHist(m+1).Freq(k) & Data.Attenuation==FTCHist(m+1).Level(l));
            FTCHist(m+1).data(k,l,:)=sum(FTCHist(m+1).Data(index,:));
            
        end
    end
end

%Removing Temporary Data Field
FTCHist=rmfield(FTCHist,'Data');