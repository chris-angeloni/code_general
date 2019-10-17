%
% [FTCn] = ftcgenerateecogn(Data,T1,T2,DFECoG,f1,f2,Order,SPLoffset,shuffle)
%
%	FILE NAME 	: FTC GENERATE ECOG N
%	DESCRIPTION : Generates a frequency tunning curve on the TDT system
%                 using ECoG Data. Generates data for N channels.
%                 Determines the number of channels from the data structure
%                 Data. 
%
%	Data        : Data structure obtained using "READTANKSTIM"
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
%   T1          : FTC window start time (msec)
%   T2          : FTC window end time (msec)
%   DFECoG      : Downsampling factor for ECoG
%   f1, f2      : Upper and lower cutoff frequencies for data (Hz)
%                 (Optional, Default == 1-250 Hz)
%                 If f1==0 & f2==inf then no filtering is performed
%   Order       : Channel order matrix for plotting (Optional, 
%                 Default or [] = no mapping. Typically the channel order
%                 is a matrix/vector containing the map for the
%                 channel ordering. The following special cases can be
%                 used: 
%
%   SPLoffset   : SPL offset to convert ATT to true SPL (dB). Default == 0.
%   shuffle     : Shuffles/randomizing the phase spectrum - used for
%                 significance testing
%
% RETURNED DATA
%
%	FTCn      : Tunning Curve Data Structure matrix containing N channels
%
%                   FTC.Freq                - Frequency Axis (M elements)
%                   FTC.Level               - Sound Level Axis (dB, N elements)
%                   FTC.Ravg                - Matrix containgin average
%                                             responses (M x N x L). L is
%                                             the number of time samples.
%                   FTC.Rtrial              - Multidimensional matrix
%                                             containing the trial
%                                             responses (MxN X L X NFTC)
%                   FTC.Rpp                 - Response peak-to-peak
%                   FTC.pc1                 - First principle component
%                   FTC.pc2                 - Second principle component
%                   FTC.pc1v                - First principle component
%                                             vecotrs 
%                   FTC.pc2v                - Second principle component
%                                             vectors
%                   FTC.NFTC                - Number of FTC repeats
%                   FTC.T1                  - FTC Window start time
%                   FTC.T2                  - FTC Window end time
%
%   (C) Monty A. Escabi, Jan 2012
%
function [FTCn] = ftcgenerateecogn(Data,T1,T2,DFECoG,f1,f2,Order,SPLoffset,shuffle)

%Input Args
if nargin<5
    f1=1;
end
if nargin<6
    f2=250;
end
if nargin<7 | isempty(Order)
    %Order=[1:max(Data.ChannelNumber)];
    %Order=[1 8 2 7 3 6 4 5; 9 16 10 15 11 14 12 13; 24 17 23 18 22 19 21 20; 32 25 31 26 30 27 29 28];
    Order=[17 24 19 22 21 20 23 18; 1 8  3  6  5  4  7  2 ; 15 10 13 12 11 14 9  16; 31 26 29 28 27 30 25 32];
end
if nargin<8
    SPLoffset=0;
end
if nargin<9
    shuffle='n';
end

%Computing N ECoG FTCs
for k=1:size(Order,1)
    for l=1:size(Order,2)
    
        %Generating FTC 
        clc
        disp(['Generating FTC channel : ' num2str(l+(k-1)*(size(Order,2))) ' of ' num2str(numel(Order))])
        [FTCn(k,l)] = ftcgenerateecog(Data,T1,T2,Order(k,l),DFECoG,f1,f2,SPLoffset,shuffle);
    
    end
end