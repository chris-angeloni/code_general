%
% function [Table] = ftctable(f1,f2,L,ATT,NTrials)
%
%	FILE NAME 	: FREQUENCY AXIS
%	DESCRIPTION : Generates an octave spaced frequency axis
%
%   f1          : Lower Frequency (Hz)
%   f2          : Upper Frequency (Hz)
%   L           : Number of frequncies
%   ATT         : Attenuation array
%   NTrials     : Number of trials to run
%
% RETURNED DATA
%
%   Table.faxis     : Frequency array
%   Table.Gain      : Gain array (dB)
%   Table.Trials    : Number of trials array
%
function [Table] = ftctable(f1,f2,L,ATT,NTrials)

%Generating Frequency Axis
[faxis] = freqaxis(f1,f2,L);

%Generating Table
Table.faxis=[];
Table.Gain=[];
for k=1:length(ATT)
    Table.faxis=[Table.faxis ; round(faxis)];
    Table.Gain=[Table.Gain; -ones(L,1)*ATT(k)-.1];
end
Table.Trials=ones(size(Table.faxis))*NTrials;




