%function [Data] = readtanktetro(TankFileName,BlockNumber,ServerName)
%
%	FILE NAME 	: Read Tank
%	DESCRIPTION : Reads 16  channels of data tetrode configuration
%
%              
%                3          4           10          16  
%              6   2      5   8       9   12      15  11
%                1          7           13          14
%
%
% Order=[1 6 3 2 7 5 4 8 13 9 10 12 14 15 16 11];               
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   ServerName      : Tank Server (Default=='Puente')
%
% RETURNED DATA
%
%	Data	: Data Structure (16)
%             Channels are ordered in groups of 4 per each tetrode
%             
%           Data.Snips              - Snipet Waveforms
%           Data.SnipsTimeStamp     - Snipet Time Stamps
%           Data.SortCode           - Sort Code for the Snipets
%           Data.ChannelNumber      - Channel Number for the Snipets
%           Data.Attenuation        - Event Attenuation Level
%           Data.Frequency          - Event Frequency 
%           Data.EventTimeStanp     - Event Time Stamp
%
function [Data] = readtanktetrov66(TankFileName,BlockNumber,ServerName)
Order=[1 6 3 2 7 5 4 8 13 9 10 12 14 15 16 11];  
    for chan=1:16
        [Dataraw] = readtankv66(TankFileName,BlockNumber,Order(chan),ServerName);
        Data(chan)=Dataraw;
        clc
        disp(chan)
        clear Dataraw;
    end
