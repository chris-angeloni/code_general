%
%function [spet]=spetaddjitterpanzeri(spet,Fs,T,sig)
%
%   FILE NAME   : SPET ADD JITTER PANZERI
%   DESCRIPTION : Adds spike timming jitter according to Panzeri et al.
%                 The jittered spike train is performed by shuffling the
%                 spike times within a window of sig msec.
%
%   spet        : Spike Event Time Array
%   Fs          : Sampling rate
%   T           : Spike train duration (sec)
%   sig         : Range of jitter distribution (ms).
%
%RETURNED VARIABLES
%
%   spet        : Shuffled Spike Event Time Array
%
%   (C) Monty A. Escabi, Oct 2012
%
function [spet]=spetaddjitterpanzeri(spet,Fs,T,sig)

%Adding Jitter
L=round(sig/1000*Fs);
M=floor(T*Fs);
spetN=[];
for k=1:floor(M/L)
    
    Shift=round(L*rand);
    i=find(spet>=(k-1)*L & spet<k*L);
    spett=mod(spet(i)-((k-1)*L+1)+Shift,L-1)+1;
    spetN=[spetN spett+(k-1)*L+1];
    
end
spet=spetN;