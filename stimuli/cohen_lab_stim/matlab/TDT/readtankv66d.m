%
%function [Data] = readtank(TankFileName,BlockNumber,ChannelNumber,ServerName)
%
%	FILE NAME 	: Read Tank
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
%           Data.SnipsTimeStamp     - Snipet Time Stamps
%           Data.SortCode           - Sort Code for the Snipets
%           Data.ChannelNumber      - Channel Number for the Snipets
%           Data.Attenuation        - Event Attenuation Level
%           Data.Frequency          - Event Frequency 
%           Data.EventTimeStanp     - Event Time Stamp
%
function [Data] = readtankv66d(TankFileName,BlockNumber,ChannelNumber,ServerName)

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
Data.Frequency = invoke(TTX, 'ParseEvV', 0, N);

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


% Close the tank when your done
invoke(TTX, 'CloseTank');

%Closing Figure
close;