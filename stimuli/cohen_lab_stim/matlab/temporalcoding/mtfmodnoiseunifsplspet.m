%
%function [RASDataSPL,SoundEstimationEnvSPL,SoundParamSPL]=mtfmodnoiseunifsplspet(DataTank,SoundParam,SoundEstimationEnv)
%
%   FILE NAME       : MTF MOD NOISE UNIF SPL SPET
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
%   RASDataSPL      : Data structure containing
%
%       .Est.spet - spike event times for estimation segments
%       .Est.T    - duration in sec for estimation segments
%       .Est.Fs   - sampling rate for estimation segments
%       .Est.ATT  - Attenuation (dB)
%
% (C) Monty A. Escabi, March 2011
%
function [RASDataSPL,SoundEstimationEnvSPL,SoundParamSPL]=mtfmodnoiseunifsplspet(DataTank,SoundParam,SoundEstimationEnv)

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

for j=1:length(SoundParam.ATT)
    for k=1:length(SoundParam.ATTorder)/length(SoundParam.ATT)

        %Sorting different ATT
        n=find(SoundParam.ATTorder==SoundParam.ATT(j));
        
        %Finding spikes for each trigger
        i=find(spet>Trig(n(k)) & spet<=Trig(n(k)+1)-Npause);   
        RASDataSPL(j).Est(k*2-1).spet=spet(i)-Trig(n(k));
        RASDataSPL(j).Est(k*2-1).T=T;
        RASDataSPL(j).Est(k*2-1).Fs=DataTank.Fs;
        RASDataSPL(j).Est(k*2-1).ATT=SoundParam.ATTorder(k);

        RASDataSPL(j).Est(k*2).spet=spet(i)-Trig(n(k));
        RASDataSPL(j).Est(k*2).T=T;
        RASDataSPL(j).Est(k*2).Fs=DataTank.Fs;
        RASDataSPL(j).Est(k*2).ATT=SoundParam.ATTorder(k);

        %Sorting EstimationEnvelope
        SoundEstimationEnvSPL(j).SPL(k).Env=SoundEstimationEnv(n(k)).Env*10^(SoundParam.ATT(j)/20);
    end
    
    %Chaning Sound Parameters
    SoundParamSPL(j).Param=SoundParam;
    SoundParamSPL(j).Param.ATT=SoundParam.ATT(j);
    SoundParamSPL(j).Param.ATTorder=SoundParam.ATTorder(n);
    SoundParamSPL(j).Param.SoundOrder=SoundParam.SoundOrder(n);
end