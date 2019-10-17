%
%function [eSPLmax,sSPL]=calibinearspl(ProbeData,CalibData,MicGain,MicSensitivity,f1,f2)
% 	
%   FILE NAME   : CALIB IN EAR SPL
% 	DESCRIPTION : Computes the maximum and rms SPL at the animals ear when
%                 measuring with a probe microphone. Takes the recorded
%                 sound at the probe end and removes the probe transfer
%                 function via deconvolution in order to estimate the SPL
%                 at the animals ear.
%
%   ProbeData   : Data structure containg input output data for probe
%                 measurements. The recorded output (Y) is performed at the
%                 probe microphone in is reflected back using deconvolution
%                 to the animals ear position.
%   CalibData   : Data structure containging the probe transfer function
%                 (Hprobe) and the probe inverse inpulse response
%                 (hproveinv). This data structure is obtained from either
%                 CALIBFIRPROBE1 or CALIBFIRPROBE2.
%   MicGain     : Microphone Gain (dB)
%   MicSensitivity: Microphone Sensitivity (mv/pa) 
%   f1          : Lower frequency for calibration filter (Hz)
%   f2          : Upper frequency for calibration filter (Hz)
%
%RETURNED VARIABLES
%
%   eSPL        : RMS SPL at the animal's ear (re 2.2E-5 pa)
%   eSPLmax     : Maxiumum SPL at the animal's ear (re 2.2E-5 pa)
%   eSPL        : Same as above except measured for chirp over filter
%                 frequencies
%   eSPLmax     : Same as above except measured for chirp over filter
%                 frequencies
% (C) Monty A. Escabi, Feb 2016
%
function [eSPL,eSPLmax,eSPLf1f2,eSPLmaxf1f2]=calibinearspl(ProbeData,CalibData,MicGain,MicSensitivity,f1,f2)

%Estimating sound at the animal's ear
NB=length(ProbeData.Y);
L=length(CalibData.hprobeinv);
Y=conv(ProbeData.Y,CalibData.hprobeinv);
Y=Y(L+1:length(Y)-L);

%Computing Max and RMS SPL at the animal's ear
Gain=10^(MicGain/20);               %Microphone Amplifier Gain
Sensitivity=MicSensitivity/1000;    %Volts/Pascals
Po=2.2E-5;                          %Threshold of hearing in Pascals
eSPL=20*log10(std(Y(10000:NB-10000))/Gain/Sensitivity/Po);
eSPLmax=20*log10(max(abs(Y(10000:NB-10000)-mean(Y(10000:NB-10000))))/Gain/Sensitivity/Po);

%Computing SPL over duration of Chirp and filter
LL=floor(0.5*ProbeData.Fs);
faxis=(1:NB-2*LL)/(NB-2*LL)*ProbeData.Fs/2;
i1=min(find(faxis>f1));
i2=max(find(faxis<f2));
eSPLf1f2=20*log10(std(Y(LL+i1:LL+i2))/Gain/Sensitivity/Po);
eSPLmaxf1f2=20*log10(max(abs(Y(LL+i1:LL+i2)-mean(Y(LL+i1:LL+i2))))/Gain/Sensitivity/Po);

