%
%function []=spatiotemporalelectricalsparseindpulsefile(FileHeader,fm,PW,PulseType,ChArray,Lambda,Fs,M,MaxAmp,MaxdB,AmpDist,NB,seed)
%
%       FILE NAME       : SPATIO TEMPORAL ELECTRICAL SPARSE IND PULSE FILE
%       DESCRIPTION     : Spatio temporal electrical stimulation pattern
%                         across 16 channels. Uses sparse independent pulse
%                         sequence. Pulses trains are choosen to contain
%                         Lambda pulses per second on average. Pulses 
%                         always fall at intervals of 1/fm.
%
%       FileHeader      : File name header (No extension)
%       fm              : Maximum modulation rate (Hz)
%       PW              : Pulse width (micro sec)
%       PulseType       : Pulse type, MonoPhasic (1) or ByPhasic (2). If
%                         PulseType > 2 then the value designated the
%                         number of phases (3 for instance has a +,-1, and
%                         + phase).
%       ChArray         : Array containing the electrode channels to
%                         provide stimulation. "0" designates no
%                         stimulation while "1" designates stimulation is
%                         on.
%       Lambda          : Pulse rate (pulses / sec across all channels)
%       Fs              : Sampling Frequency for electrical stimulation
%                         signal (Hz)
%       M               : Number of time samples
%       MaxAmp          : Maximum voltage amplitude in Volts
%       MaxdB           : Used for 'Log' amp distribution. Peak to peak
%                         range in dB
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
% (C) Monty A. Escabi, March 2014
%
function []=spatiotemporalelectricalsparseindpulsefile(FileHeader,fm,PW,PulseType,ChArray,Lambda,Fs,M,MaxAmp,MaxdB,AmpDist,NB,seed)

%Input arguments
if nargin<10
    MaxdB=40;    %Not really used when nargin<6
end
if nargin<11
    AmpDist='Log';
end
if nargin<12
    NB=524288;
end
if nargin<13
    seed=0;
end

%Generating Pulse
PW=PW*1E-6;
NP=round(PW*Fs);
if PulseType==1
    P=[ones(1,NP)];                 %Monophasic
else
    P=[];
    for k=1:PulseType
        P=[P ones(1,NP)*(-1)^(k+1)];     %Byphasic (PulseType==2) or multiphasic (PulseType>2)
    end
end

%Force the stimulus length to be an integer multiple of the buffer
M=ceil(M/NB)*NB;

%Generating Electrical Stimulation Envelope
L=round(Fs/fm);
Nch=length(ChArray);
Esc=sparse(Nch,M);
OnChan=find(ChArray==1);
for k=1:floor(M/L)
    
    p=Lambda/fm/Nch;   %Probability of pulse for a given channel
    Esc(:,(k-1)*L+1)=bernoullirnd(p,Nch,1);     %Generating Sparse Envelope
    
end

%Adding Pulses and saving pulse sequence/envelope for each channel
for l=1:Nch

    %Adding Pulses to kth channel
    St=conv(full(Esc(l,:)),P);
    St=St(1:M);
    
    %Finding Sparse Chord Envelope for kth channel
    Et=Esc(l,:);
    
    %Saving to temporary files
    f=['save TEMPFILEChan' num2str(l) ' St Et' ];
    eval(f)
    
end

%Stimulus Parameters
ParamList.fm=fm;
ParamList.ChArray=ChArray;
ParamList.Lambda=Lambda;
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