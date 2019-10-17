%
%function [Data]=mtfmodnoiseunifsamspet(DataTank,SoundParam)
%
%   FILE NAME       : MTF MOD NOISE UNIF SAMSPET
%   DESCRIPTION     : Extracts the SPET arrays and stores as a data structure
%                     for MTFMODNOISEUNIF sounds. These sounds are used to
%                     generate the modulation impulse response of a neuron and
%                     subsequent sounds are used for prediction.
%
%   DataTank        : Data tank from TDT. Contains spike event times, triggers,
%                     and sampling rate.
%   SoundParam      : Sound Paramter Data Structure
%
%RETURNED VARIABLE
%
%   Data            : Data structure containing
%
%       .Est.spet - spike event times for estimation segments
%       .Est.T    - duration in sec for estimation segments
%       .Est.Fs   - sampling rate for estimation segments
%       .Pre.spet - spike event time for prediction segment
%       .Pre.T    - duration in sec for prediction segment
%       .Pre.Fs   - sampling rate for prediction segment
%
% (C) Monty A. Escabi, January 2011
%
function [Data]=mtfmodnoiseunifsamspet(DataTank,SoundParam)

%Separating Pre and SAM Triggers
N1=length(SoundParam.FM1);
N2=length(SoundParam.FM2);
TrigSAM1=DataTank.Trig(1:N1);
TrigSAM2=DataTank.Trig(end-N2+1:end);
TrigSAM=[TrigSAM1 TrigSAM2];
Trig=DataTank.Trig(N1+1:end-N2);

%Assigning variables
Trig=[Trig Trig(end)+SoundParam.Tp+SoundParam.Tpause];
Trig=round(Trig*DataTank.Fs);
TrigSAM1=round(TrigSAM1*DataTank.Fs);
TrigSAM2=round(TrigSAM2*DataTank.Fs);
TrigSAM=round(TrigSAM*DataTank.Fs);
spet=round(DataTank.SnipTimeStamp*DataTank.Fs);
Npause=round(SoundParam.Tpause*DataTank.Fs);
FsE=SoundParam.Fs/SoundParam.DS;
T=SoundParam.T;
Tp=SoundParam.Tp;
FM1=SoundParam.FM1;
FM2=SoundParam.FM2;
FM=[FM1 FM2];
FMAxis=SoundParam.Fm;

%Extracting Spike Trains for Estimation and Prediction Trials
i=find(SoundParam.SoundOrder~='S');
Order=SoundParam.SoundOrder(i);
counte=1;
countp=1;
for k=1:length(Trig)-1
    
    %Finding spikes for each trigger
    i=find(spet>Trig(k) & spet<=Trig(k+1)-Npause);
    
    %Sorting into estimation and prediction segments
    if strcmp(Order(k),'E')
        Data.Est(counte).spet=spet(i)-Trig(k);
        Data.Est(counte).T=T;
        Data.Est(counte).Fs=DataTank.Fs;
        counte=counte+1;
    else
        Data.Pre(countp).spet=spet(i)-Trig(k);
        Data.Pre(countp).T=Tp;
        Data.Pre(countp).Fs=DataTank.Fs;
        countp=countp+1;
    end
    
end

%Modulation Frequencies
Data.SAM.FMAxis=FMAxis;

%Adding End Trigger
Trig=TrigSAM;
Trig=[Trig Trig(length(Trig))+mean(diff(Trig))];        %Adding End Trigger

%Isolating and Binning Data For Each FM
%Generates a RASTER Data Structure
N=length(FM)/length(FMAxis);
NSAM=SoundParam.Tsam.*DataTank.Fs;
for k=1:length(FMAxis)
    
    %Finding All instances of a given FM
    indexFM=find(FM==FMAxis(k));

    for n=1:N
        %Finding SPET for a given FM trial
        indexSPET=find(spet<Trig(indexFM(n))+NSAM & spet>Trig(indexFM(n)));
        Data.SAM.RASTER(n+(k-1)*N).spet=round( (spet(indexSPET)-Trig(indexFM(n))) );
        Data.SAM.RASTER(n+(k-1)*N).Fs=DataTank.Fs;   
        Data.SAM.RASTER(n+(k-1)*N).T=SoundParam.Tsam;
        Data.SAM.RASTER(n+(k-1)*N).Fm=FMAxis(k);
    end
end