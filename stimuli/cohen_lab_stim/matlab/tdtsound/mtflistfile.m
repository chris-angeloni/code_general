%
% function [] = mtflistfile(modfreqfile,modindexfile,fm1,fm2,L,MI1,MI2,M,NTrials,Order,FSteps,MISteps)
%
%	FILE NAME 	: MTF LIST FILE
%	DESCRIPTION : Generates an MTF list fiel that is read by the TDT
%                 system. Varies Modulation Frequency and Modulation Index. 
%                 See also FTCLIST.
%
%   modfreqfile : Output modulation frequency list file name
%   modindexfile: Output modulation index list file name
%   fm1         : Lower Modulation Frequency (Hz)
%   fm2         : Upper Modulation Frequency (Hz)
%   L           : Number of frequncies
%   MI          : Modulation Index Array
%   NTrials     : Number of trials to run
%   Order       : Presentation Order 
%                 'rand'        = random
%                 'trialrand'   = trial randomized
%                 'seq'         = sequential
%   FSteps      : Frequency steps ('Log' or 'Linear')
%   MISteps     : Modulation Index steps ('Log' or 'Linear')
%
% RETURNED DATA
%
% (C) Monty A. Escabi, Sept 2007
%
function [] = mtflistfile(modfreqfile,modindexfile,fm1,fm2,L,MI1,MI2,M,NTrials,Order,FSteps,MISteps)

%Generating FTC List
[List] = mtflist(fm1,fm2,L,MI1,MI2,M,NTrials,Order,FSteps,MISteps);

%Writing Output
ModFreq=List.ModFreq;
ModIndex=List.ModIndex;
f=['save ' modindexfile ' -ascii ModIndex'];
eval(f)
f=['save ' modfreqfile ' -ascii ModFreq'];
eval(f)