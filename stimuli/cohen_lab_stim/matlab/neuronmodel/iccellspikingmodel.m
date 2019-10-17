%
%function [S,Vm,Y,U,V,Im,In]=iccellspikingmodel(beta,X)
%
%   FILE NAME   : IC CELL SPIKING MODEL
%   DESCRIPTION : Non linear IC simulation. LNL Model followed by
%                 a temporal receptive field and integrate-and-fire neuron
%
%   beta        : Model parameter vector
%
%                 beta(1):  fc, center frequency (Hz)
%                 beta(2):  BW, bandwidth (Hz)
%                 beta(3):  Tau, synaptic time constant (msec)
%                 beta(4):  Tref, refractory period (msec)
%                 beta(5):  Vrest, Resting Potential (mVolts)
%                 beta(6):  Vtresh, Threshold potential (mVolts)
%                 beta(7):  Fs, sampling frequency (Hz)
%                 beta(8):  Gm, Signal current gain
%                 beta(9):  Gn, Noise current gain
%                 beta(10): TRF Response latency (msec)
%                 beta(11): TRF Rise time constant (msec)
%                 beta(12): TRF Decay time constant (msec)
%                 beta(13): TRF Best temporal modulation frequency (Hz)
%                 beta(14): TRF Temporal phase (0-2*pi)
%                 beta(15): detrendim, 1 or 0, 'y' or 'n'
%                 beta(16): detrendin, 1 or 0, 'y' or 'n'
%
%   X           : Acoustic waveform input
%
%RETURNED VARIABLES
%
%   S           : Output Spike Train
%   Vm          : Intracellular potential (with spiking)
%   Y           : Haircell Voltage Output (no spiking)
%   U           : Haircell ouput at nonlinear stage
%   V           : Haircell output at tunning stage
%   Im          : Intracellular input current to final IF neuron
%   In          : Intracellular noise current to final IF neuron
%
function [S,Vm,Y,U,V,Im,In]=iccellspikingmodel(beta,X)

%Ingtegrate and Fire parameters for Haircell
fc=beta(1);                 %Characteristic Frequency
BW=beta(2);                 %Haircell filter bandwidth
Tau=beta(3);                %Membrane time constant
Tref=beta(4);               %Refractory Period
Vrest=beta(5);              %Resting Potential
Vtresh=beta(6);             %Threshold Potential
Fs=beta(7);                 %Sampling Frequency
Gm=beta(8);                 %Input current gain
Gn=beta(9);                 %Noise current gain
betaalpha=[beta(10:14) 1];  %Alpha function model parameters
if beta(15)==1              %detrend for input
    detrendim='y';
else
    detrendim='n';
end
if beta(16)==1          %detrend for noise
    detrendin='y';      
else
    detrendin='n';
end

%Running Haircell Model for desired signal
[Y,V,U]=haircellmodel(X,fc,BW,Fs);

%Alpha function temporal receptive field
taxis=(0:ceil(Fs*0.1))/Fs*1000;
[TRF,E]=trfalphamodel(betaalpha,taxis);
TRF=TRF/std(TRF);
Im=conv(TRF,Y);

%Integrate and fire model
Im=Im*Gm;
In=randn(size(Im))*Gn;
[S,Vm]=ifneuron(Im,Tau,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin);