%
%function [spet]=spetremoveburst(spet,Tburst,Fs)
%
%   FILE NAME   : SPET REMOVE BURST
%   DESCRIPTION : Removes secondary burst spikes froma spet array.
%
%   spet        : Spike Event Time Array
%   Tburst      : Window for defining bursts. Spikes within Tburst (msec)
%                 are removed.
%   Fs          : Sampling frequency of spike train.
%
%RETURNED VARIABLES
%
%   spet        : Returned spet with burst removed
%
%   (C) Monty A. Escabi, Nov 2010
%
function [spet]=spetremoveburst(spet,Tburst,Fs)

%Finding ISI and removing burst spikes
ISI=diff(spet)/Fs;
i=find(ISI>Tburst/1000);
spet=spet(i);