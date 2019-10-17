%
%function [H]=gammatonefilter(N,b,fc,Fs)
%
%   FILE NAME       : GAMMA TONE FILTER
%   DESCRIPTION     : Impulse response of gammatone auditory filter
%
%   N               : Filter order
%   b               : Filter bandwidth
%	fc              : Filter characteristic frequency
%	Fs              : Sampling rate
%
%RETURNED VARIABLES
%
%	H               : Impulse Response
%
% (C) Monty A. Escabi, October 2006
%
function [H]=gammatonefilter(N,b,fc,Fs)

%REFERENCES:    Van Eemeerseel & Peeters, Axoustic Research Letters 2003
%               de Boer 1975 (First developed the GTF)

%Generating Impulse Response
P=0;
t=(0:.05*Fs)/Fs;
H=t.^(N-1).*exp(-2*pi*b*t).*cos(2*pi*fc*t+P);

%Normalizing For Unity Maximum Gain
A=max(abs(fft(H,1024*64)));
H=H/A;