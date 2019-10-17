%
%function [spet]=shufflerandspet2(spet,Fs,refractory,T)
%
%   FILE NAME       : SHUFFLE RAND SPET
%   DESCRIPTION     : Shuffle a 'spet' variable with Poisson intervals
%                     and same number of spikes as the original spet.
%
%   spet            : Array of spike event times
%   Fs              : Sampling rate (Hz)
%   refractory      : Refractory period (msec)
%   T               : Duration for spike event time array
%
function [spet]=shufflerandspet2(spet,Fs,refractory,T)

%Generating Random SPET array 3 x the spike rate
L=3*length(spet)/T;
[spetT]=poissongenstat(L,T,Fs,refractory);
i=sort(randsample(length(spetT),length(spet)));
spet=spetT(i);