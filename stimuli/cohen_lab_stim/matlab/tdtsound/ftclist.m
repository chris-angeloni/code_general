%
% function [List] = ftclist(f1,f2,L,ATT,NTrials,Order,FSteps)
%
%	FILE NAME 	: FTC LIST
%	DESCRIPTION : Generates an FTC list that is read by the TDT
%                 system. See also FTCLISTFILE.
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
%
% RETURNED DATA
%
%   List.faxis     : Frequency array
%   List.gain      : Gain array (dB)
%   List.Trials    : Number of trials array
%
% (C) Monty A. Escabi, Sept 2007
%
function [List] = ftclist(f1,f2,L,ATT,NTrials,Order,FSteps)

%Generating Frequency Axis
[Freq] = freqaxis(f1,f2,L,FSteps);

%Generating List
faxis=[];
gain=[];
for k=1:length(ATT)
    faxis=[faxis ; round(Freq)];
    gain=[gain; -ones(L,1)*ATT(k)-.1];
end

%Converting from dB to Magnitude
gain=10.^(gain/20);

%Initializing Random Generator State
rand('state',0);

%Creating Trials
List.faxis=[];
List.gain=[];
for k=1:NTrials

    if strcmp(Order,'trialrand')
        index=randperm(length(faxis));
        List.faxis=[List.faxis; faxis(index)];
        List.gain=[List.gain; gain(index)];
    else
        List.faxis=[List.faxis; faxis];
        List.gain=[List.gain; gain];
    end

end

%Randomizing All Trials
if strcmp(Order,'rand')
    index=randperm(length(List.faxis));
    List.faxis=[List.faxis(index)];
    List.gain=[List.gain(index)];
end

%Number of Trials
List.NTrials=NTrials;