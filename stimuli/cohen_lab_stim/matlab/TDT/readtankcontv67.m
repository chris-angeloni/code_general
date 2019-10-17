%
%function [Data] = readtankcontv67(TankFileName,BlockNumber,ChannelNumber,ServerName)
%
%	FILE NAME 	: READ TANK CONT V67
%	DESCRIPTION : Reads a specific block from a data tank file
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   ChannelNumber   : Channel Number (Default == 0, i.e. "AllChannels" )
%   ServerName      : Tank Server (Default=='Puente')
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
%           Data.Frequency1         - Event Frequency for chan 1
%           Data.Frequency1         - Event Frequency for chan 2
%           Data.ToneLevel1         - Tone level for chan 1
%           Data.ToneLevel2         - Tone level for chan 2
%           Data.NoiseLevel1        - Noise level for chan 1
%           Data.NoiseLevel2        - Noise level for chan 2
%           Data.Delay1             - Delay for chan 1
%           Data.ModFrequency1      - Mod Frequency for chan 1
%           Data.ModIndex1          - Mod index for chan 1
%           Data.StimOff            - Stimulus off time
%           Data.StimOn             - Stimulus on time
%           Data.StimSweep          - Stim weep number
%           Data.EventTimeStanp     - Event Time Stamp
%           Data.ContWave           - Continuous waveforms
%           Data.FsCont             - Sampling rate for ContWave
%
% (C) Monty A. Escabi, Edit Oct 2010
%
function [Data] = readtankcontv67(TankFileName,BlockNumber,ChannelNumber,ServerName)

%Choosign Default Server
if nargin<3
   ChannelNumber=0; 
end
if nargin<4
   ServerName='Puente'; 
end

%Open A Dummy Figure
figure, set(gcf,'visible','off');

%Extantiate a variable for the ActiveX wrapper interface
TTX = actxcontrol('TTank.X');

%Connect to a server.
invoke(TTX,'ConnectServer', ServerName, 'Me');

%Open Desired tank for reading.
invoke(TTX,'OpenTank',TankFileName,'R');

%Allow Epoch Indexing
invoke(TTX,'CreateEpocIndexing');

% Select the block to access
invoke(TTX,'SelectBlock', ['Block-' num2str(BlockNumber)]);

% Get all of the Snips across all time for All 16 channels
N = invoke(TTX, 'ReadEventsV', 10000000, 'Snip', ChannelNumber, 0, 0.0, 0.0, 'ALL');
Data.Snips = invoke(TTX, 'ParseEvV', 0, N);

%Get Sampling Rate
Data.Fs = invoke(TTX, 'ParseEvInfoV', 0, 1, 9);

% Get Snip Timestamps
Data.SnipTimeStamp = invoke(TTX, 'ParseEvInfoV', 0, N, 6);

% Get Sort Code
Data.SortCode = invoke(TTX, 'ParseEvInfoV', 0, N, 5);

% Get ChannelNumber
Data.ChannelNumber = invoke(TTX, 'ParseEvInfoV', 0, N, 4);

% Get Triggers - if available
NTrig=invoke(TTX,'ReadEventsV',10000,'ETri',0,0,0.0,0.0,'ALL');
Data.Trig=invoke(TTX, 'ParseEvInfoV', 0, NTrig, 6);

% Get Attenuation Level
N = invoke(TTX, 'ReadEventsV', 10000, 'Levl', 0, 0, 0.0, 0.0, 'ALL');
Data.Attenuation = invoke(TTX, 'ParseEvV', 0, N);

% Get Frequency
N = invoke(TTX, 'ReadEventsV', 10000, 'Freq', 0, 0, 0.0, 0.0, 'ALL');
TempFrequency = invoke(TTX, 'ParseEvV', 0, N); % change 0 to 1 or 2 to get channels 1 and 2.
Data.Frequency1=TempFrequency(1:2:length(TempFrequency));
Data.Frequency2=TempFrequency(2:2:length(TempFrequency));

% Get Tone Attenuation Level Ch 1
N = invoke(TTX, 'ReadEventsV', 10000, 'TLv1', 0, 0, 0.0, 0.0, 'ALL');
Data.ToneLevel1 = invoke(TTX, 'ParseEvV', 0, N);

% Get Tone Attenuation Level Ch2
N = invoke(TTX, 'ReadEventsV', 10000, 'TLv2', 0, 0, 0.0, 0.0, 'ALL');
Data.ToneLevel2 = invoke(TTX, 'ParseEvV', 0, N);

% Get Noise Attenuation Level Ch 1
N = invoke(TTX, 'ReadEventsV', 10000, 'NLv1', 0, 0, 0.0, 0.0, 'ALL');
Data.NoiseLevel1 = invoke(TTX, 'ParseEvV', 0, N);

% Get Noise Attenuation Level Ch2
N = invoke(TTX, 'ReadEventsV', 10000, 'NLv2', 0, 0, 0.0, 0.0, 'ALL');
Data.NoiseLevel2 = invoke(TTX, 'ParseEvV', 0, N);

% Get Mod Index Ch1
N = invoke(TTX, 'ReadEventsV', 10000, 'Ind1', 0, 0, 0.0, 0.0, 'ALL');
Data.ModIndex1 = invoke(TTX, 'ParseEvV', 0, N);

% Get Delay 1
N = invoke(TTX, 'ReadEventsV', 10000, 'Dly1', 0, 0, 0.0, 0.0, 'ALL');
Data.Delay1 = invoke(TTX, 'ParseEvV', 0, N);

% Get Mod Frequency 2
N = invoke(TTX, 'ReadEventsV', 10000, 'MdF2', 0, 0, 0.0, 0.0, 'ALL');
Data.ModFrequency2 = invoke(TTX, 'ParseEvV', 0, N);

% Get Stimulus On and OFF times
N = invoke(TTX, 'ReadEventsV', 10000, 'StOf', 0, 0, 0.0, 0.0, 'ALL');

%Data.StimOff = invoke(TTX, 'ParseEvV', 0, N);
Data.StimOff = invoke(TTX, 'ParseEvInfoV', 0, N, 6);
N = invoke(TTX, 'ReadEventsV', 10000, 'Stim', 0, 0, 0.0, 0.0, 'ALL');

%Data.StimOn = invoke(TTX, 'ParseEvV', 0, N);
Data.StimOn = invoke(TTX, 'ParseEvInfoV', 0, N, 6);

%Get Stimulus Sweep
N = invoke(TTX, 'ReadEventsV', 10000, 'Swee', 0, 0, 0.0, 0.0, 'ALL');
Data.StimSweep = invoke(TTX, 'ParseEvV', 0, N);

% Get Event Timestamps
Data.EventTimeStamp = invoke(TTX, 'ParseEvInfoV', 0, N, 6);

%Get Cont wave
N = invoke(TTX, 'ReadEventsV', 1000000, 'sWav', ChannelNumber, 0, 0.0, 0.0, 'ALL');
Data.ContWave = invoke(TTX, 'ParseEvV', 0, N); 
Data.FsCont = invoke(TTX, 'ParseEvInfoV', 0, 1, 9);
if ChannelNumber~=0
    Data.ContWave = reshape(Data.ContWave,1,numel(Data.ContWave));    
end

% Close the tank when your done
invoke(TTX, 'CloseTank');
invoke(TTX,'ReleaseServer');

%Closing Figure
close;