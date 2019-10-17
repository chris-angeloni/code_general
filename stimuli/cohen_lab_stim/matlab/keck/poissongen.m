%
%function [spet]=poissongen(L,Fs,Fsd,dT,seed)
%
%       FILE NAME       : POISSON GEN
%       DESCRIPTION     : Generalized Poison Spike Train Generator
%			              For Stationary or Non-Stationary Rate
%			              Function : L(T)
%
%                         Note: Refractory period is imposed at 1/Fsd 
%                               resolution
%
%	L   		: Lambda.  Can be a constant or a time 
%   			  varying waveform sampled at Fs
%	    		  Must satisfy:  L(T) > 0
%	Fs		    : Sampling Rate of L ( Fs>=Fsd )
%	Fsd		    : Sampling Rate for X
%   dT          : Refractory period (msec)
%                 Note: No refractory period imposed if dT<1000/Fs 
%	seed		: Starting seed for random number generator (Optional)
%
%RETURNED VARIABLES
%
%   spet        : Spike event time  (sampled at Fsd)
%                 (imposed refractory period of dT)
%   X           : Spike rate signal (sampled at Fs)
%                 No refractory period imposed!!!
%
% (C) Monty A. Escabi, Feb. 2005 (Edit Aug 2009)
%
function [spet,X]=poissongen(L,Fs,Fsd,dT,seed)

%Input Arguments
if nargin<4
    dT=1/Fsd;
end
if nargin==5
	rand('seed',seed);
end

%Refractory Period
dTMin=dT/1000;

%Finding Necessary Spike Rate to account for Refractory
% Note that if you add a refractory period naively, the effective
% spike rate goes down. Given a desired spike rate, LD, and 
% refractory period, RP, the spike rate for exponentially distributed
% spike event times with parameter lambda, L, is related to LD by
%
%	Mean Interevent Time = 1/LD = 1/L + RP 
%
% We need to solve for L
%
Lmean=1/(1/mean(L)-dTMin);      %(Added, Escabi Jul 2011)
L=L/mean(L)*Lmean;

%Nonhomogeneous Rate Function
dt=1/Fs;
M=intfft(L)*dt;
M=M(1:length(L));
M=M(2:length(M))-M(1:length(M)-1);  %Computing m(t+T)-m(t)

%Generating Spike Train/Rate Function
X=poissrnd(M)/dt;

hist(X,20)
max(X)
min(X)
length(find(isnan(X)))
length(X)
length(find(X/Fs==1))
length(find(X/Fs>1))

%Refractory Period in Samples
dN=round(dT/1000*Fs);
index=find(X~=0);

%Removing Spikes within Refractory Period
for k=1:length(index)
    if X(index(k))~=0 & index(k)+dN<length(X)

        X(index(k)+1:index(k)+dN)=zeros(1,dN);

    end
end

%Remove spikes falling within the same sample (Added, Escabi Jul 2011)
i=find(X>Fs);
X(i)=Fs*ones(1,length(i));

%Converting Impulse Spike Train to SPET at Fs
[spet]=impulse2spet(X,Fs,Fsd);

%Resampling SPET at Fsd
spet=round(spet/Fs*Fsd);