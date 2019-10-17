%
%
%function []=spatiotemporalelectricalammodfile(FileHeader,Lambda,fm,PulseJitter,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,NB,seed)
%
%       FILE NAME       : SPATIO TEMPORAL ELECTRICAL AM MOD
%       DESCRIPTION     : Spatio temporal electrical stimulation pattern
%                         across 16 channels.Uses periodic or quasi periodic 
%                         pulse train for each channel and modulates the 
%                         amplitude of the pulse seqeunce. 
%
%       FileHeader      : File name header (No extension)
%       Lambda          : Average pulese rate (Hz). 
%       fm              : Maximum modulation rate (Hz)
%       PulseJitter     : Pulse Jitter - percent of period (0 - 100)
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
%       MaxdB           : Modulation range expressed in dB (i.e., Peak-to-peak
%                         range). Can be converted to modulation index using
%                         MaxdB=-20*log10(1-Beta) 
%                        (Default MaxdB == 40 dB)
%       AmpDist         : Pulse amplitude distribution 
%                        'Lin' - Linear uniformly distributed 
%                        'Log' - Log uniformly distributed (i.e., in dB)
%                        (Default == 'Log')
%       NB              : Buffer size. Used to segment the files for double
%                         buffering on the TDT system (IZ2-32) 
%                         (Default = 524288)
%       seed            : Seed for random number generator
%                         (Default = 0)
%
% (C) Monty A. Escabi, November 2013
%
function []=spatiotemporalelectricalammodfile(FileHeader,Lambda,fm,PulseJitter,PW,PulseType,ChArray,Fs,M,MaxAmp,MaxdB,AmpDist,NB,seed)

%Input arguments
if nargin<11
    MaxdB=40;    %Not really used when nargin<6
end
if nargin<12
    AmpDist='Log';
end
if nargin<13
    NB=524288;
end
if nargin<14
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

%Force the stimulus length to be an integer multiple of the buffer
M=ceil(M/NB)*NB;

%Generating Electrical Stimulation Signal
for k=1:length(ChArray)
   
    if ChArray(k)==1
        %Removing to allocate memory 
        clear Et St
        
        %Generating spatiotemporal Poisson sequence
        T=M/Fs;
        Et=noiseunifh(0,fm,Fs,M,seed+k+length(ChArray));
        dN=round(1/Lambda*Fs);
        spet=(0:dN:M);
        L=length(spet);      
        spet=spet+round(rand(1,L)*dN*PulseJitter/100);          %Adding Jitter if desired
        St=spet2impulse(spet,Fs,Fs,T)/Fs;
        
        %Moduylating Pulse Train
        if strcmp(AmpDist,'Lin')
            Beta=1-10^(-MaxdB/20);
            Et=(Et*Beta+(1-Beta))*MaxAmp;
            St=St(1:M).*Et(1:M);
        elseif strcmp(AmpDist,'Log')
            Et=10.^((MaxdB.*Et-MaxdB)/20)*MaxAmp;
            St=St(1:M).*Et(1:M);
        end
        
        %Adding Pulse
        St=conv(St,P);
        St=St(1:M);
        
    else
        %Channel is off
        St=zeros(1,M);
        Et=zeros(1,M);
    end
    
    %Saving to temporary files
    f=['save TEMPFILEChan' num2str(k) ' St Et' ];
    eval(f)
    
end

%Stimulus Parameters
ParamList.Lambda=Lambda;
ParamList.fm=fm;
ParamList.PulseJitter=PulseJitter;
ParamList.ChArray=ChArray;
ParamList.Fs=Fs;
ParamList.M=M;
ParamList.MaxAmp=MaxAmp;
ParamList.MaxdB=MaxdB;
ParamList.AmpDist=AmpDist;
ParamList.NB=NB;
ParamList.seed=seed;

%Segmenting into stimulus blocks half the buffer size
N=NB/2;         %Half the buffer size
L=M/N;          %Number of buffer segments
for l=1:L
   
    for k=1:length(ChArray)
        
        %Loading channel array
        f=['load TEMPFILEChan' num2str(k)];
        eval(f)
        
        %Segenting stimulus into buffer blocks
        S(k,:)=St(N*(l-1)+(1:N));
        E(k,:)=Et(N*(l-1)+(1:N));
        
    end
    
    %Saving data for each block
    S=sparse(S);
    f=['save ' FileHeader '_Block' int2strconvert(l,4) ' S E ParamList' ];
    eval(f)
end

%Removing Temporary Files
if isunix
    !rm TEMPFILE*.mat
else
    !del TEMPFILE*.mat
end