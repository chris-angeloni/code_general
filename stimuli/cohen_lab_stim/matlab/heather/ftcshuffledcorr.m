%
%function [Rab,Raa]=ftcshuffledcorr(Data,Fsd,T)
%
%   FILE NAME   : FTC SHUFFLED CORR
%   DESCRIPTION : Computes that auto and shuffled (across trials)
%                 correlation function for FTC data
%
%   Data        : TDT Data structure containg FTC data
%	Fsd         : Desired sampling Rate for correlation
%	T           : Correlation Temporal Lag (msec)
%	Disp		: Display : 'y' or 'n' (Default='n') 
%
function [R]=ftcshuffledcorr(Data,Fsd,T,Disp)

%Input Arguments
if nargin<4
    Disp='n';
end

%Number of Snips
Nsnips=max(Data.SortCode)+1;

%Removing Junk Data
index=find(Data.Attenuation>-500);
Data.Attenuation=Data.Attenuation(index);
Data.Frequency=Data.Frequency(index);
Data.EventTimeStamp=Data.EventTimeStamp(index);

%Generate Frequency Axis
FreqT=sort(Data.Frequency);
index=[1 1+find(diff(FreqT)>0)];
Freq=FreqT(index);

%Generate SPL Axis
LevelT=sort(Data.Attenuation);
index=[1 1+find(diff(LevelT)>0)];
Level=LevelT(index);
NFTC=round(length(LevelT)/length(Level)/length(Freq));   %Number of Tunning Curve Repeats

%Some Definitions
EventTS=[Data.EventTimeStamp max(Data.EventTimeStamp)+mean(diff(Data.EventTimeStamp))];
SnipsTS=Data.SnipTimeStamp;

%Finding Data from each trial
NEventsTrial=length(Level)*length(Freq);
for k=1:NFTC
   
    index=find(SnipsTS>EventTS(1+(k-1)*NEventsTrial) & SnipsTS<=EventTS(NEventsTrial+(k-1)*NEventsTrial));
    RASTER(k).spet=( SnipsTS(index)-EventTS(1+(k-1)*NEventsTrial) ) *Data.Fs;
    RASTER(k).Fs=Data.Fs;
    RASTER(k).T=EventTS(NEventsTrial)-EventTS(1);
end

%Computing AutoCorrealtion and shuffled correaltion
[R]=rastercircularxcorrfast(RASTER,Fsd,'y',500);

%Removing Zeroth Bin
index=find(R.Raa==max(R.Raa));
R.Raa(index)=0;

%Truncate Data For T seconds
NN=T/1000*Fsd;
R.Raa=R.Raa(index-NN:index+NN);
R.Rshuf=R.Rshuf(index-NN:index+NN);
R.RshufJt=R.RshufJt(:,index-NN:index+NN);
R.Rset=R.Rset(index-NN:index+NN);

%Define Delay Axis
R.Tau=(-NN:NN)/Fsd;