%
%function [Y,V,U,Ha,Hb]=haircellmodel(X,fc,BW,Fs)
%
%   FILE NAME   : HAIR CELL MODEL
%   DESCRIPTION : Non linear hair cell simulation. LNL Model.
%
%   X           : Acoustic waveform input
%   fc          : Filter characteristic frequency (Hz)
%   BW          : Bandwidth (Hz)
%   Fs          : Sampling rate (Hz)
%
%RETURNED VARIABLES
%
%   Y           : Membrane voltage output (no spiking)
%   V           : Output at nonlinear stage
%   U           : Output at tunning stage
%   Ha          : Auditory tuning filter impulse response
%   Hb          : Synaptic / membrane filter impulse response
%
% (C) Monty A. Escabi, October 2006
%
function [Y,V,U,Ha,Hb]=haircellmodel(X,fc,BW,Fs)

%Auditory Haircell Tuning Impulse Response
Ha=gammatonefilter(4,BW,fc,Fs);
i=find(Ha>max(abs(Ha))*0.00001);
Ha=Ha(1:max(i));

%Synaptic Filter impulse response
Hb=lowpass(1250,250,Fs,50,'n');
Na=(length(Ha)-1)/2;
Nb=(length(Hb)-1)/2;

%Applying sandwich model
%X=X/std(X);
U=conv(X,Ha);
V=hcnl(U,1,1E-20,.5,15);
Y=conv(V,Hb);

%Truncating Output Length and removing group delay
%Y=Y(2*Na+2*Nb+1:length(Y)-2*Na-2*Nb-1);
%V=V(2*Na+2*Nb+1:length(Y)-2*Na-2*Nb-1);
%U=U(2*Na+2*Nb+1:length(Y)-2*Na-2*Nb-1);