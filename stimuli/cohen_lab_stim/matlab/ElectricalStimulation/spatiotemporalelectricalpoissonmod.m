%
%
%function [S,E]=spatiotemporalelectricalpoissonmod(Lambda,fm,Trefractory,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)
%
%       FILE NAME       : SPATIO TEMPORAL ELECTRICAL POISSON MOD
%       DESCRIPTION     : Spatio temporal electrical stimulation pattern
%                         across 16 channels.Uses poisson pulse train for
%                         each channel and modulates the amplitude of the
%                         pulse seqeunce. If Trefractory=1/Lambda then the
%                         program uses a fixed pulse rate sequence with
%                         intervals precisely Trefractory (Conventional AM)
%
%       Lambda          : Average pulese rate (Hz)
%       fm              : Maximum modulation rate (Hz)
%       Trefractory     : Refractory interval for pulse train (msec). If
%                         Trefractory==Lambda then a fixed pulse rate is
%                         used where the inter-pulse spacing is exactly
%                         Trefractory. This corresponds to a conventional
%                         AM scheme.
%       PW              : Pulse width (micro sec)
%       PulseType       : Pulse type, MonoPhasic (1) or ByPhasic (2)
%       ChArray         : Array containing the electrode channels to
%                         provide stimulation. "0" designates no
%                         stimulation while "1" designates stimulation is
%                         on.
%       Fs              : Sampling Frequency for electrical stimulation
%                         signal (Hz)
%       M               : Number of time samples
%       MaxAmp          : Maximum voltage amplitude in Volts
%       MaxdB           : Used for 'Log' amp distribution. Peak to peak
%                         range in dB (Default = 40 dB)
%       AmpDist         : Pulse amplitude distribution 
%                        'Lin' - Linear uniformly distributed 
%                        'Log' - Log uniformly distributed (i.e., in dB)
%                        (Default == 'Log')
%       seed            : Seed for random number generator
%                         (Default = 0)
%
%RETURNED VARIABLES
%
%       S               : Spatio temoral pulse train at Fs sampling rate
%       E               : Spatio temporal envelope used to generate S
%
% (C) Monty A. Escabi, June 2011
%
function [S,E]=spatiotemporalelectricalpoissonmod(Lambda,fm,Trefractory,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)

%Input arguments
if nargin<10
    MaxdB=40;    %Not really used when nargin<6
end
if nargin<11
    AmpDist='Log';
end
if nargin<12
    seed=0;
end

%Generating Pulse
PW=PW*1E-6;
NP=round(PW*Fs);
if PulseType==1
    P=[ones(1,NP)];                 %Monophasic
else
    P=[ones(1,NP) -ones(1,NP)];     %Byphasic
end

%Generating Electrical Stimulation Signal
for k=1:length(ChArray)
   
    if ChArray(k)==1
        %Generating spatiotemporal Poisson sequence
        T=M/Fs;
        if 1/Lambda*1000==Trefractory
            dN=round(Trefractory/1000*Fs);
            spet=(0:dN:M);
        else
            spet=poissongen(Lambda*ones(1,M),Fs,Fs,Trefractory,seed+k);
        end
        St=spet2impulse(spet,Fs,Fs,T)/Fs;
        Et=noiseunifh(0,fm,Fs,M,seed+k+length(ChArray));
        
        if strcmp(AmpDist,'Lin')
            E(k,:)=Et*MaxAmp;
            St=St.*E(k,:);
        elseif strcmp(AmpDist,'Log')
            E(k,:)=10.^((MaxdB.*Et-MaxdB)/20)*MaxAmp;
            St=St.*E(k,:);
        end
    end
    
    %Adding Pulse
    St=conv(St,P);
    S(k,:)=St(1:M);
end