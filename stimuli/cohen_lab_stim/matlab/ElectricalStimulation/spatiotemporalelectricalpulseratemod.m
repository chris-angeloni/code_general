%
%
%function [S,E]=spatiotemporalelectricalpulseratemod(LambdaMax,fm,Trefractory,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)
%
%       FILE NAME       : SPATIO TEMPORAL ELECTRICAL PULSE RATE MOD
%       DESCRIPTION     : Spatio temporal electrical stimulation pattern
%                         across 16 channels. Uses poisson pulse rate
%                         modulated impulse train for each channel.
%
%       LambdaMax       : Maximum pulese rate (Hz)
%       fm              : Maximum modulation rate (Hz)
%       Trefractory     : Refractory interval for pulse train (msec)
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
function [S,E]=spatiotemporalelectricalpulseratemod(LambdaMax,fm,Trefractory,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)

%Input arguments
if nargin<10
    MaxdB=40;
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
        
        %Generating spatiotemporal envelope
        T=M/Fs;
        Et=noiseunifh(0,fm,Fs,M,seed+k+length(ChArray));
 
        %Choosing amplitude distribution
        if strcmp(AmpDist,'Lin')
            E(k,:)=Et*LambdaMax;
        elseif strcmp(AmpDist,'Log')
            E(k,:)=10.^((MaxdB.*Et-MaxdB)/20)*LambdaMax;
        end

        %Pulse rate modulation
        spet=poissongen(E(k,:),Fs,Fs,Trefractory,seed+k);
        s=spet2impulse(spet,Fs,Fs,T)/Fs*MaxAmp;
        s=conv(s,P);
        S(k,:)=s(1:M);
    end
    
end