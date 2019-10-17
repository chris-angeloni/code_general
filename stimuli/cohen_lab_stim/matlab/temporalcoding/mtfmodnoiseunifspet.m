%
%function [Data]=mtfmodnoiseunifspet(DataTank,SoundParam)
%
%   FILE NAME       : MTF MOD NOISE UNIF SPET
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
function [Data]=mtfmodnoiseunifspet(DataTank,SoundParam)

%Assigning variables
Trig=[DataTank.Trig DataTank.Trig(end)+SoundParam.Tp+SoundParam.Tpause];
Trig=round(Trig*DataTank.Fs);
spet=round(DataTank.SnipTimeStamp*DataTank.Fs);
Npause=round(SoundParam.Tpause*DataTank.Fs);
FsE=SoundParam.Fs/SoundParam.DS;
T=SoundParam.T;
Tp=SoundParam.Tp;

%Extracting Spike Trains for Estimation and Prediction Trials
Order=SoundParam.SoundOrder;
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