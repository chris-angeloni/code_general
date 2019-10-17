%
% function [] = ildnoisewavgenerate(filename,ILD,NTrials,Order,StimRate,RiseTime,StimDuration,Fs)
%
%	FILE NAME 	: ILD NOISE WAV GENERATE
%	DESCRIPTION : Generates an FTC 4 channel wav file used with the TDT.
%                 Channels are arranged as:
%
%   filename    : Output WAV filename (.wav extension not necessary)
%   ILD         : Vector of desired ILD values
%   NTrials     : Number of repetition trials for sequence
%   Order       : Presentation Order 
%                 'rand'        = random
%                 'trialrand'   = trial randomized
%                 'seq'         = sequential
%   StimRate    : Stimulus Presentation Rate (Hz)
%   RiseTime    : Stimulus Rise Time (msec)
%   StimDuration: Tone-Pip Duration (msec)
%   Fs          : Sampling Frequency (Hz)
%
% RETURNED DATA
%
% (C) Monty A. Escabi, May 2008
%
function [] = ildnoisewavgenerate(filename,ILD,NTrials,Order,StimRate,RiseTime,StimDuration,Fs)

%Genrating ILD List
L=length(ILD);
List.ILD=[];
if strcmp(Order,'rand')
    for k=1:NTrials
        List.ILD=[List.ILD ILD(randsample(L,L))];
    end
elseif strcmp(Order,'trialrand')
    List.ILD=[];
    ILD=ILD(randsample(L,L));
    for k=1:NTrials
        List.ILD=[List.ILD ILD];
    end
else
    List.ILD=[];
    for k=1:NTrials
        List.ILD=[List.ILD sort(ILD)];
    end
end

%Generagin Envelope / Window
NB=nextpow2(StimDuration/1000*Fs)-1;
[W]=window(Fs,3,2,RiseTime);
W=W(1:floor(length(W)/2));
NW=length(W);

%Generagin Trigger Pulse
N=round(Fs/StimRate);
Trigger=[ones(1,1000) zeros(1,N-1000)];

%Generating Continuous Sound 
X1=[];
X2=[];
Trig=[];
for k=1:length(List.ILD)
    
    %Displaying Progressing 
    clc,disp(['Generating Sound: ' num2str(round(k/length(List.ILD)*100),3) '% Done'])
 
    %Generatign  MLS
    XX=mls(NB,0);
    XX(1:NW)=XX(1:NW).*W;
    XX(2^NB-1:-1:2^NB-1-NW+1)=XX(2^NB-1:-1:2^NB-1-NW+1).*W; 
    X=zeros(1,N);   
    X(1:length(XX))=XX;
    
    %Generating Continuous Sound
    X1=[X1 10.^(List.ILD(k)/2/20).*X];
    X2=[X2 10.^(-List.ILD(k)/2/20).*X];
    
    %Gerating Triggers
    Trig=[Trig Trigger];    
end

%Saving Parameter Files
f=['save ' filename '_Param.mat List NTrials Order StimRate RiseTime StimDuration Fs'];
eval(f)

%Writting Sound
wavwrite([X1' X2' Trig' Trig'],Fs,32,filename)
%wavwri(XX,Fs,32,2,filename);