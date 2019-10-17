%
%function [DataCorr]=xcorrspike16(Data,Fsd,T,NTrig,Order,Zero,Mean,Disp)
%
%       FILE NAME       : XCORR SPIKE 16
%       DESCRIPTION     : 16 channel spike x-correlation
%
%       Data            : TDT 16 channel data structure
%       Fsd             : Desired sampling rate for x-correlation
%       T               : Cross Correlation Lag (sec)
%       NTrig           : Total number of Triggers
%       Zero            : Correct the Zeroth Bin when computing
%                         autocorrelation: spet1==spet2
%                         Default: 'y'
%       Mean            : Remove Mean Value
%                         Default: 'n'
%       Disp            : Display corrlation while processing: 'y' or 'n'
%                         Default: 'y'
%
%   (C) Monty A. Escabi, November 2005
%
function [DataCorr]=xcorrspike16(Data,Fsd,T,NTrig,Order,Zero,Mean,Disp)

%Check Input Arguments
if nargin<5
    Order=[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];    
end
if nargin<6
    Zero='y';
end
if nargin<7
    Mean='n';
end
if nargin<8
    Disp='y';
end

%Checking Triggers
%Default for new ICC data: NTrig=1799
TrigTimes=round(Data.Fs*Data.Trig);
[TrigA,TrigB]=trigfixstrf2(TrigTimes,400,NTrig);

%Spike Event Times
for k=1:16
    index=find(Data.ChannelNumber==k);
    spet=round(Data.Fs*Data.SnipTimeStamp(index));
    indexA=find(spet>min(TrigA) & spet<max(TrigA));
    SPET(k).spetA=spet(indexA)-min(TrigA);
    indexB=find(spet>min(TrigB) & spet<max(TrigB));
    SPET(k).spetB=spet(indexB)-min(TrigB);
end

%Computing Cross Correlation for all channels
count=1;
for k=1:16
    for l=1:k
        
        %Computing Correlations & shuffled correlations
        DataCorr(count).Raa=xcorrspike(SPET(k).spetA,SPET(l).spetA,Data.Fs,Fsd,T,Zero,Mean,Disp);
        DataCorr(count).Rbb=xcorrspike(SPET(k).spetB,SPET(l).spetB,Data.Fs,Fsd,T,Zero,Mean,Disp);
        DataCorr(count).Rab=xcorrspike(SPET(k).spetA,SPET(l).spetB,Data.Fs,Fsd,T,Zero,Mean,Disp);
        DataCorr(count).Rba=xcorrspike(SPET(k).spetB,SPET(l).spetA,Data.Fs,Fsd,T,Zero,Mean,Disp);
        DataCorr(count).ch1=k;
        DataCorr(count).ch2=l;
        DataCorr(count).N1=[length(SPET(k).spetA) length(SPET(k).spetB)];                                       %Number of Spikes
        DataCorr(count).N2=[length(SPET(l).spetA) length(SPET(l).spetB)];
        DataCorr(count).lambda1=[length(SPET(k).spetA) length(SPET(k).spetB)]/(max(TrigA)-min(TrigA))*Data.Fs;  %Spike Rates
        DataCorr(count).lambda2=[length(SPET(l).spetA) length(SPET(l).spetB)]/(max(TrigA)-min(TrigA))*Data.Fs;
        
        %Counter
        count=count+1;
        pause(0)
        
    end
end