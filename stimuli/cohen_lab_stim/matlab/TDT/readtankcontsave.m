%
%function [] = readtankcontsave(Outfile,TankFileName,BlockNumber,ChannelNumber,ServerName)
%
%	FILE NAME 	: READ TANK CONT SAVE
%	DESCRIPTION : Reads a specific block from a data tank file and saves
%                 the data to a file
%
%   Outfile         : Output File Header
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   ChannelNumber   : Channel Number (Default == 0, i.e. "AllChannels" )
%   ServerName      : Tank Server (Default=='Local')
%
% RETURNED DATA
%
%	The Data is saved to a File
%
% (C) Monty A. Escabi, October 2016
%
function [] = readtankcontsave(Outfile,TankFileName,BlockNumber,ChannelNumber,ServerName)

%Input Arguments
if nargin<5 | isempty(ChannelNumber)
    ChannelNumber=0;
end
if nargin<5 | isempty(ServerName)
    ServerName='Local';
end

%Reading Tank Data
[Data] = readtankcontv66direct(TankFileName,BlockNumber,ChannelNumber,ServerName);

%Saving Data to File
Filename=[Outfile 'TankBlock' int2strconvert(BlockNumber,3) 'Chan' int2strconvert(ChannelNumber,3)];
save(Filename,'Data');



