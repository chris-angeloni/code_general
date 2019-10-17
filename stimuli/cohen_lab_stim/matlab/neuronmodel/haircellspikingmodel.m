%
%function [Y,S,Vout,GTot]=haircellspikingmodel(beta,X)
%
%   FILE NAME   : HAIR CELL SPIKING MODEL
%   DESCRIPTION : Non linear hair cell simulation. LNL Model followed by
%                 an integrate-and-fire neuron
%
%   beta        : Model parameter vector
%
%                 beta(1):  fc, center frequency (Hz)
%                 beta(2):  Bandwidth, (Hz)
%                 beta(3):  Tau, synaptic time constant (msec)
%                 beta(4):  Tref, refractory period (msec)
%                 beta(5):  Vrest, Resting Potential (mVolts)
%                 beta(6):  Vtresh, Threshold potential (mVolts)
%                 beta(7):  Fs, sampling frequency (Hz)
%                 beta(8):  Gm, Signal current gain
%                 beta(9):  Gn, Noise current gain
%                 beta(10): detrendim, 'y' or 'n'
%                 beta(11): detrendin, 'y' or 'n'
%
%   X           : Acoustic waveform input
%
%RETURNED VARIABLES
%
%   Y           : Haircell Voltage Output (no spiking)
%   S           : Output Spike Train
%   Vm          : Intracellular potential (with spiking)
%
function [Y,S,V,U,Vm,Im,In]=haircellspikingmodel(beta,X)

%Ingtegrate and Fire parameters for Haircell
fc=beta(1);             %Characteristic Frequency
BW=beta(2);             %Haircell filter bandwidth
Tau=beta(3);            %Membrane time constant
Tref=beta(4);           %Refractory Period
Vrest=beta(5);          %Resting Potential
Vtresh=beta(6);         %Threshold Potential
Fs=beta(7)              %Sampling Frequency
Gm=beta(8)              %Input current gain
Gn=beta(9)              %Noise current gain
if beta(10)==1          %detrend for input
    detrendim='y';
else
    detrendim='n';
end
if beta(10)==2           %detrend for noise
    detrendin='y';      
else
    detrendin='n';
end

%Running Haircell Model for desired signal
[Y,V,U]=haircellmodel(X,fc,BW,Fs);
Im=Y*Gm;
In=randn(size(Y))*Gn;
[S,Vm]=ifneuron(Im,Tau,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin);