%
%function [] = readtankstimall(TankFileName,BlockNumber,ServerName)
%
%	FILE NAME 	: READ TANK STIM ALL
%	DESCRIPTION : Reads a specific set of block from a data tank file for
%                 electrical stimulation and stores to file
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Array of Block Numbers
%   ServerName      : Tank Server (Default=='Local')
%
% RETURNED DATA
%
%	Data stored to file. See READTANKSTIM for format.
%
% (C) Monty A. Escabi, April 2012
%
function [] = readtankstimall(TankFileName,BlockNumber,ServerName)

%Input Args
if nargin<3
    ServerName='Local';
end

%Reading Blocks and saving to file
for k=1:length(BlockNumber)
    
    clc
    disp(['Reading and Saving Block ' int2str(BlockNumber(k))])
    [Data] = readtankstim(TankFileName,BlockNumber(k),0,0,'Local');
    f=['save ' TankFileName '_Block' int2strconvert(BlockNumber(k),3) ' Data'];
    eval(f)
    clear Data
    
end
