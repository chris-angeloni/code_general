%
%function []=ratelevelenvelopefile(FileHeader,T,Tpause,CurrentAmp,Order,M,Fs,rt,p,seed)
%
%       FILE NAME       : COMOD ENVELOPE FILE
%       DESCRIPTION     : Generates an envelope used to modulation
%                         electrical stimulation signals. Three types of
%                         commodulation signals can be generated. 
%
%       FileHeader      : File name header (No extension)
%       T               : On time for each stimulus  (msec)
%       Tpause          : Pause time between stimuli (msec)
%       CurrentAmp      : Vector containing the desired current amplitudes
%                         (micro Amps)
%       Order           : Ordering for stimulus presentation
%                         'rand'        = random
%                         'trialrand'   = trial randomized
%                         'seq'         = sequential
%       M               : Number of samples
%       Fs              : Sampling Rate (Hz, Default=12207.03125)
%       rt              : Rise time for 'sqr' and 'mls' (ms, optional, 
%                         default==5). Not used for 'sin' option.
%       p               : Bslpline order for rise time (Default==5). Not
%                         used for 'sin' option
%       seed            : Seed for random number generator
%                         (Default = 0)
%        
%RETURNED VARIABLES
%
%       No returned values. Saves data to file.
%
% (C) Monty A. Escabi, Jan 2012
%
function []=ratelevelenvelopefile(FileHeader,T,Tpause,CurrentAmp,Order,M,Fs,rt,p,seed)

%Input Args
if nargin<7
    Fs=12207.03125;
end
if nargin<8
    rt=5;
end
if nargin<9
    p=5;
end
if nargin<10
    seed=0;    
end

%Generating Envelope for one sound
[W]=window(Fs,p,T,rt);
Xpause=zeros(1,round(Fs*Tpause/1000));
Xenv=[W Xpause]/max(W);

%Generating Envelope Sequence
Ntrials=floor(M/(length(CurrentAmp)*length(Xenv)));
CurrentAmpList=[];
for k=1:Ntrials

    if strcmp(Order,'trialrand')
        index=randperm(length(CurrentAmp));
        CurrentAmpList=[CurrentAmpList CurrentAmp(index)];
    else
        CurrentAmpList=[CurrentAmpList CurrentAmp];
    end

end

%Randomizing All Trials
if strcmp(Order,'rand')
    index=randperm(length(CurrentAmpList));
    CurrentAmpList=[CurrentAmpList(index)];
end

%Generating Envelope
X=[];
Ec=[];
for k=1:length(CurrentAmpList)
   Ec=[Ec Xenv*CurrentAmpList(k)]; 
end
Ec=[Ec zeros(1,M-length(Ec))];

%Parameters
Param.seed=seed;
Param.Fs=Fs;
Param.W=W;
Param.Xpause=Xpause;
Param.T=T;
Param.Tpause=Tpause;
Param.rt=rt;
Param.p=p;
Param.Order=Order;
Param.CurrentAmp=CurrentAmp;
Param.CurrentAmpList=CurrentAmpList;

%Saving Envelope to File
f=['save ' FileHeader 'Env Ec Param'];
eval(f)