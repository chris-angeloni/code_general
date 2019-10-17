%
% function [] = ftcwavgenerate(f1,f2,L,ATT,NTrials,Order,FSteps)
%
%	FILE NAME 	: FTC WAV GENERATE
%	DESCRIPTION : Generates an FTC 4 channel wav file used with the TDT.
%                 Channels are arranged as:
%
%                 chan1: Sound 1
%                 chan2: Sound 2
%                 chan3: Trigger Pulses
%                 chan4: Trigger Pulses
%
%   f1          : Lower Frequency (Hz)
%   f2          : Upper Frequency (Hz)
%   L           : Number of frequncies
%   ATT         : Attenuation array (positive attenuations! Units of dB)
%   NTrials     : Number of trials to run
%   Order       : Presentation Order 
%                 'rand'        = random
%                 'trialrand'   = trial randomized
%                 'seq'         = sequential
%   FSteps      : Frequency steps ('Log' or 'Linear')
%   StimRate    : Stimulus Presentation Rate (Hz)
%   RiseTime    : Stimulus Rise Time (msec)
%   StimDuration: Tone-Pip Duration (msec)
%   Fs          : Sampling Frequency (Hz)
%   Aural       : Aural stimulus configuration
%                 'CH1'   : Channel 1 only
%                 'CH2'   : Channel 2 only
%                 'CH12'  : Channel 1 and 2 (Diotic, Default)
%
% RETURNED DATA
%
% (C) Monty A. Escabi, February 2008
%
function [Y] = ftcwavgenerate(filename,f1,f2,L,ATT,NTrials,Order,FSteps,StimRate,RiseTime,StimDuration,Fs,Aural)

%Input Args
if nargin<12
    Aural='CH12';
end

%Generating Stimulus List
[List] = ftclist(f1,f2,L,ATT,NTrials,Order,FSteps);
Faxis=sort(List.faxis);
i=find(diff(Faxis)>0);
i=[1 i'+1];
Faxis=Faxis(i);

%Generating Window - 3rd order B-spline
[W]=window(Fs,3,StimDuration,RiseTime);
NW=length(W);

%Genrating Tone Pips
N=round(Fs/StimRate);
for k=1:length(Faxis)
    TonePip(k).Y=[W.*sin(2*pi*Faxis(k)*(1:NW)/Fs) zeros(1,N-NW)];
end

%Generagin Trigger Pulse
Trigger=[ones(1,1000) zeros(1,N-1000)];

%Generating Continuous Sound 
%Y=[];
%Trig=[];
Y=zeros(1,length(List.faxis).*length(Trigger));
Trig=zeros(1,length(List.faxis).*length(Trigger));
for k=1:length(List.faxis)
    
    %Displaying Progressing 
    clc,disp(['Generating Sound: ' num2str(round(k/length(List.faxis)*100),3) '% Done'])
    
    %Selecting Frequency
    findex=find(List.faxis(k)==Faxis);
    
    %Generating Continuous Sound
    G=List.gain(k);
    N=length(TonePip(findex).Y);
    Y((k-1)*N+1:k*N)=G.*TonePip(findex).Y;
    Trig((k-1)*N+1:k*N)=Trigger;
    %Y=[Y  G.*TonePip(findex).Y];
    %Trig=[Trig Trigger];
    
end

%Normalizing Sounds

%Writting Sound
%filename='test.wav';
if strcmp(Aural,'CH1')
    i=findstr('.wav',filename);
    wavwrite([Trig'],Fs,32,[filename(1:i-1) '_Trig.wav']);
    clear Trig
    wavwrite([zeros(size(Y))' Y'],Fs,32,filename);
elseif strcmp(Aural,'CH2')
    i=findstr('.wav',filename);
    wavwrite([Trig'],Fs,32,[filename(1:i-1) '_Trig.wav']);
    clear Trig
    wavwrite([Y' zeros(size(Y))' Trig' Trig'],Fs,32,filename);
else %Default is Diotic
    i=findstr('.wav',filename);
    wavwrite([Trig'],Fs,32,[filename(1:i-1) '_Trig.wav']);
    clear Trig
    wavwrite([Y' Y'],Fs,32,filename);
end

%Saving Parameters
f=['save ' filename(1:i-1) '_Param.mat List f1 f2 L ATT NTrials Order FSteps StimRate RiseTime StimDuration Fs Aural'];
eval(f)