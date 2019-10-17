%
%function [spet]=spetaddjitterpanzericycle(spet,Fs,T,sig)
%
%   FILE NAME   : SPET ADD JITTER PANZERI CYCLE
%   DESCRIPTION : Adds spike timming jitter according to Panzeri et al. for
%                 a cycle spet. 
%
%                 The jittered spike train is performed by shuffling the
%                 spike times within a window of sig msec.
%
%                 Note: the procedure does NOT preserve the ISI
%                 distribution. Thus, if Fs is very high (>1000 Hz) then
%                 you could potentially genearte spikes outside the
%                 refractory period.
%
%   spet        : Spike Event Time Array - one cycle
%   Fs          : Sampling rate
%   T           : Cycle period (ms) or equivalently spike train duration
%   sig         : Range of jitter distribution (ms). Spikes are shuffled /
%                 jittered within a window of duration sig msec.
%
%                 Note: T should be an integer multiple of sig. In other
%                 words, T/sig = integer value. If this is not the case, 
%                 the algorithms finds the closest value of sig so that 
%                 T/sig=int holds.
%
%RETURNED VARIABLES
%
%   spet        : Shuffled Spike Event Time Array
%   sig         : Actual resolution used for shuffling spets (msec)
%
%   (C) Monty A. Escabi, Oct 2012
%
function [spet,sig]=spetaddjitterpanzericycle(spet,Fs,T,sig)

%Checking and make sure that T/sig=int
M=ceil(T/sig);
sig=T/M;
M=T/sig;        %number of sig segments in one period
sig=sig/1000;   %units of sec
T=T/1000;       %units of sec

%Shuffling spikes within each window of sig msec
spetN=[];
N=round(Fs*T);          %Maximum number of samples in one period
for k=1:M
    i=find(spet/Fs>(k-1)*sig & spet/Fs<k*sig);
    L=length(i);        %Number of spikes
    index=randperm(floor(N/M));
    spetN=[spetN sort(round(index(1:L)+sig*(k-1)*Fs))];
end

%Returned variables
spet=spetN;
sig=sig*1000;