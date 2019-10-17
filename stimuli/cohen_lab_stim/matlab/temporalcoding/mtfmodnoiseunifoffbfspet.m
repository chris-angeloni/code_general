%
%function [Data]=mtfmodnoiseunifoffbfspet(DataTank,SoundParam)
%
%   FILE NAME       : MTF MOD NOISE UNIF SPL SPET
%   DESCRIPTION     : Extracts the SPET arrays and stores as a data structure
%                     for MTFMODNOISEUNIF sounds. These sounds are used to
%                     generate the modulation impulse response for two
%                     frequency channels.
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
%
% (C) Monty A. Escabi, March 2011
%
function [Data]=mtfmodnoiseunifoffbfspet(DataTank,SoundParam)

%Assigning variables
Trig=[DataTank.Trig DataTank.Trig(end)+SoundParam.T+SoundParam.Tpause];
Trig=round(Trig*DataTank.Fs);
spet=round(DataTank.SnipTimeStamp*DataTank.Fs);
Npause=round(SoundParam.Tpause*DataTank.Fs);
FsE=SoundParam.Fs/SoundParam.DS;
T=SoundParam.T;

%Extracting Spike Trains for Estimation and Prediction Trials
Order=SoundParam.SoundOrder;
count=1;

for k=1:length(Trig)-1
    
    %Finding spikes for each trigger
    i=find(spet>Trig(k) & spet<=Trig(k+1)-Npause);
    
    %Sorting for different trials
    Data.Est(count).spet=spet(i)-Trig(k);
    Data.Est(count).T=T;
    Data.Est(count).Fs=DataTank.Fs;
    count=count+1;
    
end