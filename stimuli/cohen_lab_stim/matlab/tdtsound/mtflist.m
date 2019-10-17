%
% function [List] = mtflist(fm1,fm2,L,MI1,MI2,M,NTrials,Order,FSteps,MISteps)
%
%	FILE NAME 	: MTF LIST
%	DESCRIPTION : Generates an MTF list that is read by the TDT
%                 system. Varies Modulation Frequency and Modulation Index.
%                 See also MTFLISTFILE.
%
%   fm1         : Lower Modulation Frequency (Hz)
%   fm2         : Upper Modulation Frequency (Hz)
%   L           : Number of frequncies
%   MI1         : Lower Modulation Index
%   MI2         : Upper Modulation Index
%   M           : Number of Modulation Indeces
%   NTrials     : Number of trials to run
%   Order       : Presentation Order 
%                 'rand'        = random
%                 'trialrand'   = trial randomized
%                 'seq'         = sequential
%   FSteps      : Frequency steps ('Log' or 'Linear')
%   MISteps     : Modulation Index steps ('Log' or 'Linear')
%
% RETURNED DATA
%   List.ModFreq    : Modulation Frequency array
%   List.ModIndex   : Modulation Index Array
%   List.Trials     : Number of trials array
%
% (C) Monty A. Escabi, Sept 2007
%
function [List] = mtflist(fm1,fm2,L,MI1,MI2,M,NTrials,Order,FSteps,MISteps)

%Generating Frequency Axis
[fmaxis] = freqaxis(fm1,fm2,L,FSteps);

%Generating Modulation Index
[MI] = freqaxis(MI1,MI2,M,MISteps);

%Generating List
ModFreq=[];
ModIndex=[];
for k=1:length(MI)
    ModFreq=[ModFreq ; round(fmaxis)];
    ModIndex=[ModIndex; ones(L,1)*MI(k)];
end

%Initializing Random Generator State
rand('state',0);

%Creating Trials
List.ModFreq=[];
List.ModIndex=[];
for k=1:NTrials

    if strcmp(Order,'trialrand')
        index=randperm(length(faxis));
        List.ModFreq=[List.ModFreq; ModFreq(index)];
        List.ModIndex=[List.ModIndex; ModIndex(index)];
    else
        List.ModFreq=[List.ModFreq; ModFreq];
        List.ModIndex=[List.ModIndex; ModIndex];
    end

end

%Randomizing All Trials
if strcmp(Order,'rand')
    index=randperm(length(List.ModFreq));
    List.ModFreq=[List.ModFreq(index)];
    List.ModIndex=[List.ModIndex(index)];
end

%Number of Trials
List.NTrials=NTrials;