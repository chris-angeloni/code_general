%
% function [Trig] = tdt2trig(Data)
%
%	FILE NAME 	: TDT 2 TRIG
%	DESCRIPTION : Extracts Triggers from a TDT Tank Data Structure
%
%	Data	        : Data structure
%
%RETURNED VARIABLES
%
%   Trig            : Trigger Array
%
function [Trig] = tdt2trig(Data)

%Converting Data to TRIG
Trig=round(Data.Fs*Data.Trig);
    