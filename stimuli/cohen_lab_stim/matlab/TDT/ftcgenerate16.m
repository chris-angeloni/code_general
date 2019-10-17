%
% function [FTC16] = ftcgenerate16(Data,T1,T2,Order,SPLoffset,ChanOffset)
%
%	FILE NAME 	: FTC Generate
%	DESCRIPTION : Generates a frequency tunning curve on the TDT system
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
%   T1          : FTC window start time
%   T2          : FTC window end time
%   Order       : Channel order for plotting (Optional, 
%                 Default or [] = no mapping. Typically the channel order
%                 is a vecotor containing 16 channels with the map for the
%                 channel ordering. The following special cases can also be
%                 used: 
%
%                 Order = 1 (TDT RX)
%                      [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6]
%
%                 Order = 2 (TDT RZ)
%                      [15 1 13 3 16 2 9 7 12 6 10 8 14 4 11 5] 
%
%   SPLoffset   : SPL offset to convert ATT to true SPL (dB)
%   ChanOffset  : OFfset for starting channel number (Default==0)
%
% RETURNED DATA
%
%	FTC16       : Tunning Curve Data Structure containg 16 channels
%
%                   FTC.Freq                - Frequency Axis
%                   FTC.Level               - Sound Level Axis (dB)
%                   FTC.data                - Data matrix
%                   FTC.NFTC                - Number of FTC repeats
%                   FTC.T1                  - FTC Window start time
%                   FTC.T2                  - FTC Window end time
%
%   (C) Monty A. Escabi, Feb 2012
%
function [FTC16] = ftcgenerate16(Data,T1,T2,Order,SPLoffset,ChanOffset)

%Input Arguments
if nargin<4 | isempty(Order)
    Order=1:16;
end
if nargin<5
    SPLoffset=0;
end
if Order==1
    Order=[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];    
end
if Order==2
    Order=[15 1 13 3 16 2 9 7 12 6 10 8 14 4 11 5];
end
if nargin<6
    ChanOffset=0;
end

%Generating FTC for 16 channels
for chan=1:16
    
    %Generating FTC
    [FTCtemp] = ftcgenerate(Data,T1,T2,chan+ChanOffset,SPLoffset);
           
    %Averaging Across Units
    for l=1:length(FTCtemp)
        FTC(l).data=FTCtemp(l).data;
        FTC(l).Freq=FTCtemp(l).Freq;
        FTC(l).Level=FTCtemp(l).Level;
        FTC(l).NFTC=FTCtemp(l).NFTC;
        FTC(l).T1=FTCtemp(l).T1;
        FTC(l).T2=FTCtemp(l).T2;
    end
    FTC16(chan)=FTC(1);
    clear FTC
end

%Plotting FTC Data
gcf=figure;
Pos=[1029 82 560 872];
set(gcf,'Position',Pos)
subplotorder=[1:2:16 2:2:16];
for chan=1:16
    ftcsubplot(FTC16(Order(chan)),[8 2 subplotorder(chan)]);
end