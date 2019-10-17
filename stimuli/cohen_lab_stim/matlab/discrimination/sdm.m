%
%function [D]=sdm(spet1,spet2,Fs,Fsd,T,tc)
%
%       FILE NAME       : Spike Distance Metric
%       DESCRIPTION     : Computes the spike distance metric between two
%                         spike trains as described by Van Rossum, 1999
%
%       spet1           : Spike even times for spike train 1
%       spet2           : Spike even times for spike train 2
%       Fs              : Sampling rate (Hz)
%       Fsd             : Desired sampling rate (Hz)
%       T               : Spike train duration (sec)
%       tc              : Time constant (msec)
%
%RETURNED VARIABLES
%
%       D               : Spike distance metric
%
%       (C) Monty A. Escabi, March 2009
%
function [D]=sdm(spet1,spet2,Fs,Fsd,T,tc)

%Generating Kernel
tc=tc/1000;
time=(0:tc*Fsd*5)/Fsd;
G=exp(-time/tc);

%Converting SPET to impulse array
[X1]=spet2impulse(spet1,Fs,Fsd,T);
[X2]=spet2impulse(spet2,Fs,Fsd,T);

%Smoothing with kernel at resolution tc
%X1=conv(X1,G)/Fs;
%X2=conv(X2,G)/Fs;
%X12=X1-X2;
X12=conv(X1-X2,G)/Fs;       %Linearity allows me to subtract first and then convolve

%Spike Distance
D=1/tc*sum((X12).^2)/Fs;