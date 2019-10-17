%
% function [faxis] = freqaxis(f1,f2,L,FSteps)
%
%	FILE NAME 	: FREQUENCY AXIS
%	DESCRIPTION : Generates an octave spaced frequency axis
%
%   f1          : Lower Frequency (Hz)
%   f2          : Upper Frequency (Hz)
%   L           : Number of Frequencies
%   FSteps      : Frequency steps ('Log' or 'Linear', Defauls=='Log')
%
% RETURNED DATA
%
%   faxis       : Frequency Axis
%
function [faxis] = freqaxis(f1,f2,L,FSteps)

%Input Arguments
if nargin<3
    FSteps='Log';
end

%Generating Frequency Axis
if strcmp(FSteps,'Log')
    alpha=2^( log2(f2/f1) / (L-1) );
    faxis=f1*alpha.^((0:L-1)');
else
    faxis=((0:L-1)/(L-1)*(f2-f1)+f1)';
end
