%
% function [] = ftclistfile(freqfiel,levelfile,f1,f2,L,ATT,NTrials,Order,FSteps)
%
%	FILE NAME 	: FTC LIST FILE
%	DESCRIPTION : Generates an FTC list file that is read by the TDT
%                 system. See also FTCLIST.
%
%   freqfile    : Output frequency list file name
%   levelfile   : Output sound level list file nam
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
% (C) Monty A. Escabi, Sept 2007
%
function [] = ftclistfile(freqfile,levelfile,f1,f2,L,ATT,NTrials,Order,FSteps)

%Generating FTC List
List=ftclist(f1,f2,L,ATT,NTrials,Order,FSteps);

%Writing Output
freq=List.faxis;
level=List.gain;
f=['save ' levelfile ' -ascii level'];
eval(f)
f=['save ' freqfile ' -ascii freq'];
eval(f)