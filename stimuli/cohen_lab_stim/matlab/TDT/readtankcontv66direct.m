%
%function [Data] = readtankcontv66direct(TankFileName,BlockNumber,ChannelNumber,ServerName)
%
%	FILE NAME 	: READ TANK CONT V66 DIRECT
%	DESCRIPTION : Reads a specific block from a data tank file. Performs a
%                 direct read of the data and Bypasses the Tank server
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   ChannelNumber   : Channel Number (Default == 0, i.e. "AllChannels" )
%   ServerName      : Tank Server (Default=='Local')
%
% RETURNED DATA
%
%	Data	: Data Structure containing all relevant data
%
%           Data.Snips              - Snipet Waveforms
%           Data.Fs                 - Sampling rate for snips
%           Data.SnipsTimeStamp     - Snipet Time Stamps
%           Data.SortCode           - Sort Code for the Snipets
%           Data.ChannelNumber      - Channel Number for the Snipets
%           Data.Trig               - Triggers from RME
%           Data.Attenuation        - Event Attenuation Level
%           Data.Frequency          - Event Frequency 
%           Data.StimOff            - Stimulus off time
%           Data.StimOn             - Stimulus on time
%           Data.StimSweep          - Stim weep number
%           Data.EventTimeStanp     - Event Time Stamp
%           Data.ContWave           - Continuous waveforms
%           Data.FsCont             - Sampling rate for ContWave
%           Info                    - Experiment Metadata
%
% (C) Monty A. Escabi,F. Khatami, Nov 2016
%
function [Data] = readtankcontv66direct(TankFileName,BlockNumber,ChannelNumber,ServerName)

%Choosign Default Server
if nargin<3 | isempty(ChannelNumber)
   ChannelNumber=0; 
end
if nargin<4 | isempty(ServerName)
   ServerName='Local'; 
end

%Reading Data
Block=['block-' int2str(BlockNumber)];
if ChannelNumber==0
    data = TDT2mat(TankFileName,Block,'SERVER',ServerName);
else 
    data = TDT2mat(TankFileName,Block,'CHANNEL',ChannelNumber,'SERVER',ServerName); 
end

%Converting Data Format
Data.Snips=data.snips.Snip.data';
Data.Fs=data.snips.Snip.fs;
Data.SnipTimeStamp=data.snips.Snip.ts;
Data.SortCode=data.snips.Snip.sortcode;
Data.ChannelNumber=data.snips.Snip.chan;
if isfield(data.scalars,'Etrig')
    Data.Trig=data.scalars.ETri.ts;
end
Data.Attenuation=data.scalars.Levl.data;
Data.Frequency=data.scalars.Freq.data;
Data.StimOff=data.scalars.StOf.ts;
Data.StimOn=data.scalars.Stim.ts;
Data.StimSweep=data.scalars.Swee.data;
Data.EventTimeStamp=data.scalars.Swee.ts
Data.ContWave=data.streams.sWav.data;
Data.FsCont=data.streams.sWav.fs;
Data.Info=data.info;
