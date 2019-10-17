%
%
%function [S]=spatiotemporalelectricalpoisson(Lambda,Trefractory,PW,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)
%
%       FILE NAME       : SPATIO TEMPORAL ELECTRICAL POISSON
%       DESCRIPTION     : Spatio temporal electrical stimulation pattern
%                         across 16 channels.Uses poisson pulse train for
%                         each channel.
%
%       Lambda          : Average pulese rate (Hz)
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
%                         range in dB
%       AmpDist         : Pulse amplitude distribution 
%                        'Lin' - Linear uniformly distributed 
%                        'Log' - Log uniformly distributed (i.e., in dB)
%                        'Bin' - Binary 
%                        (Default == 'Bin')
%       seed            : Seed for random number generator
%                         (Default = 0)
%
% (C) Monty A. Escabi, June 2011
%
function [S]=spatiotemporalelectricalpoisson(Lambda,Trefractory,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)

%Input arguments
if nargin<9
    MaxdB=40;    %Not really used when nargin<6
end
if nargin<10
    AmpDist='Bin';
end
if nargin<11
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
        %Generating spatiotemporal POISSON sequence
        T=M/Fs;
        spet=poissongenstat(Lambda,T,Fs,Trefractory,seed+k);
        s=spet2impulse(spet,Fs,Fs,T)/Fs;
        
        %Changing Amplitude distribution
        if strcmp(AmpDist,'Lin')
            s=s.*rand(size(s))*MaxAmp;
        elseif strcmp(AmpDist,'Log')
            s=s.*10.^((MaxdB*rand(size(s))-MaxdB)/20)*MaxAmp;
        elseif strcmp(AmpDist,'Bin')
            s=s*MaxAmp;
        end

    end

    %Adding Pulse
    s=conv(s,P);
    S(k,:)=s(1:M);
    
end