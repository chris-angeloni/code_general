%
%
%function [S,E]=spatiotemporalelectricalammod(Lambda,fm,PulseJitter,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)
%
%       FILE NAME       : SPATIO TEMPORAL ELECTRICAL AM MOD
%       DESCRIPTION     : Spatio temporal electrical stimulation pattern
%                         across 16 channels.Uses  quasi-periodic or 
%                         periodic pulse train for each channel and 
%                         modulates the amplitude of the pulse seqeunce. 
%
%       Lambda          : Average pulese rate (Hz)
%       fm              : Maximum modulation rate (Hz)
%       PuleseJitter    : Pulse Jitter - percent of period (0 - 100)
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
%       MaxdB           : UModulation range expressed in dB (i.e., Peak-to-peak
%                         range). Can be converted to modulation index using
%                         MaxdB=-20*log10(1-Beta)
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
% (C) Monty A. Escabi, November 2013
%
function [S,E]=spatiotemporalelectricalammod(Lambda,fm,PulseJitter,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)

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
         
        %Generating spatiotemporal pulse train sequence
        T=M/Fs;
        dN=round(1/Lambda*Fs);
        spet=(0:dN:M);
        L=length(spet);      
        spet=spet+round(rand(1,L)*dN*PulseJitter/100);          %Adding Jitter if desired
        St=spet2impulse(spet,Fs,Fs,T)/Fs;
        Et=noiseunifh(0,fm,Fs,M,seed+k+length(ChArray));
        if strcmp(AmpDist,'Lin')
            Beta=1-10^(-MaxdB/20);
            Et=(Et*Beta+(1-Beta))*MaxAmp;
            St=St.*Et;
        elseif strcmp(AmpDist,'Log')
            Et=10.^((MaxdB.*Et-MaxdB)/20)*MaxAmp;
            St=St.*Et;
        end      

        %Adding Pulse
        St=conv(St,P);
        S(k,:)=St(1:M);
        E(k,:)=Et(1:M);
        
    else
        %Channel is off
        St(k,:)=zeros(1,M);
        Et(k,:)=zeros(1,M);
    end
    
    
end