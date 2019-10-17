%
%function [S,Smls]=spatiotemporalelectricalmls(fm,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)
%
%       FILE NAME       : SPATIO TEMPORAL ELECTRICAL MLS
%       DESCRIPTION     : Spatio temporal electrical stimulation pattern
%                         across 16 channels.Uses a maximum length sequence
%                         (MLS) for each channel.
%                  
%
%       fm              : Maximum electrical stimulation "modualtion"
%                         frequency (Hz)
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
%                         'Lin' - Linear uniformly distributed 
%                         'Log' - Log uniformly distributed (i.e., in dB)
%                         'Bin' - Binary 
%                         (Default == 'Bin')
%       seed            : Seed for random number generator
%                         (Default = 0)
%
%RETURNED VARIABLES
%
%       S               : Spatio temoral pulse train at Fs sampling rate
%       Smls            : Spatio temporal pulse train at 2*fm sampling rate
%
% (C) Monty A. Escabi, June 2011
%
function [S,Smls]=spatiotemporalelectricalmls(fm,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,seed)

%Input arguments
if nargin<6
    MaxdB=40;    %Not really used when nargin<6
end
if nargin<7
    AmpDist='Bin';
end
if nargin<8
    seed=0;
end

%Upsampling factor for M-sequence
UF=ceil(Fs/2/fm);

%MLS Number of bits, N
N=nextpow2(M/UF);

%Generating Electrical Stimulation Signal
for k=1:length(ChArray)
   
    if ChArray(k)==1
        %Generating spatiotemporal MLS sequence and interpolating to original sampling rate
        Smls(k,:)=(mls(N,seed+k)+1)/2;
        if strcmp(AmpDist,'Lin')
            Smls(k,:)=Smls(k,:).*rand(size(Smls(k,:)))*MaxAmp;
        elseif strcmp(AmpDist,'Log')
            Smls(k,:)=Smls(k,:).*10.^((MaxdB*rand(size(Smls(k,:)))-MaxdB)/20)*MaxAmp;
        elseif strcmp(AmpDist,'Bin')
            Smls(k,:)=Smls(k,:)*MaxAmp;
        end
 
        S(k,:)=upsample(Smls(k,:),UF);
        %L=length(Smls(k,:));
        %S(k,:)=interp1(1:L,Smls(k,:),1:1/UF:L,'nearest');
    end
    
end