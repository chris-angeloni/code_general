%
%function [] = tdt2spiker(Data,Wavefile,Timestampfile,channel)
%
%	FILE NAME 	: TDT 2 Spiker
%	DESCRIPTION : Converts a TDT matlab data structure to SPIKER format for
%	              offline spike sorting.
%
%   Data            : TDT Data structure
%	Wavefile    	: Data Tank File Name
%	Timestampfile   : Time Stamp File Name
%   channel         : Electrode channel number
%
% RETURNED DATA
%
% (C) Monty A. Escabi, November 2005 
%
function [] = tdt2spiker(Data,Wavefile,Timestampfile,channel)

%Extracting Spike Waveforms and Time Stamps
index=find(Data.ChannelNumber==channel);
TimeStamp=1000*(Data.SnipTimeStamp(index))';
Waveform=1000*double(Data.Snips(:,index)');

%Saving to SPIKER File Format
f=['save ' Wavefile ' Waveform -ascii'];
eval(f)
f=['save ' Timestampfile ' TimeStamp -ascii'];
eval(f)