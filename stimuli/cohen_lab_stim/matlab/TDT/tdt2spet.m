%
% function [Unit] = tdt2spet(Data)
%
%	FILE NAME 	: TDT 2 SPET
%	DESCRIPTION : Converts a TDT Tank File to Spet
%
%	Data	        : Data structure
%
%RETURNED VARIABLES
%
%   Unit            : Unit Data Structure Array
%                     Unit.spet = Spike Times
%                     Unit.SpikeWave = Spike Waveform
%
%
function [Unit] = tdt2spet(Data)

%Converting Data to SPET
N=max(Data.SortCode)+1;
for k=1:N
    
    i=find(Data.SortCode==k-1);
    Unit(k).spet=round(Data.Fs*Data.SnipTimeStamp(i));
    Unit(k).SpikeWave=Data.Snips(:,i);
    
end





