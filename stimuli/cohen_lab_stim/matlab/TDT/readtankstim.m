%
%function [Data] = readtanstim(TankFileName,BlockNumber,SnipChanNumber,ECoGChanNumber,ServerName)
%
%	FILE NAME 	: Read Tank Stim
%	DESCRIPTION : Reads a specific block from a data tank file for
%                 electrical stimulation
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   SnipChanNumber  : Snip channels vector (Default == 0, i.e. "All
%                     Channels", assumes 16 channels )
%   ECoGChanNumber  : ECoG Channel Vector (Default == 0, i.e. 
%                     "AllChannels", assumes 32 channels )
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
%           Data.Frequency          - Event Frequency 
%           Data.StimOff            - Stimulus off time
%           Data.StimOn             - Stimulus on time
%           Data.StimSweep          - Stim weep number
%           Data.EventTimeStanp     - Event Time Stamp
%           Data.ContWave           - Continuous waveforms
%           Data.FsCont             - Sampling rate for ContWave
%
% (C) Monty A. Escabi, Edit Dec 2011
%
function [Data] = readtankstim(TankFileName,BlockNumber,SnipChanNumber,ECoGChanNumber,ServerName)

%Choosign Default Server
if nargin<3
    SnipChanNumber=0;
end
if nargin<4
   ECoGChanNumber=0; 
end
if nargin<5
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
N = invoke(TTX, 'ReadEventsV', 10000000, 'Snip', SnipChanNumber, 0, 0.0, 0.0, 'ALL');
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

%Getting Electrical Stimulation Trigger
TTX.CreateEpocIndexing;
STrig=TTX.GetEpocsV('STri',0,0,1000);
if ~isempty(STrig) & ~isnan(STrig)
    Data.ElectricalStimTrig = STrig(2,:);
else
    Data.ElectricalStimTrig=[];
end

%Get Cont wave
if ECoGChanNumber==0
    ECoGChanNumber=1:32;    %Assumes 32 channels by default
end
for k=1:length(ECoGChanNumber)
    N = invoke(TTX, 'ReadEventsV', 1000000, 'cWav', ECoGChanNumber(k), 0, 0.0, 0.0, 'ALL');
    Data.ECoGContWave(k).X = invoke(TTX, 'ParseEvV', 0, N);
    Data.ECoGContWave(k).X = reshape(Data.ECoGContWave(k).X,1, numel(Data.ECoGContWave(k).X));
end
%Get ECoG RMS
 N = invoke(TTX, 'ReadEventsV', 1000000, 'Prms', 1, 0, 0.0, 0.0, 'ALL');
 RMS = invoke(TTX, 'ParseEvV', 0, N); 
 Data.ECoGRMS = reshape(RMS,1,numel(RMS));
 
 N = invoke(TTX, 'ReadEventsV', 1000000, 'Prms', 2, 0, 0.0, 0.0, 'ALL');
 RMS = invoke(TTX, 'ParseEvV', 0, N); 
 Data.ECoGRMSRef = reshape(RMS,1,numel(RMS));
 
 %Feedback Gain
 N = invoke(TTX, 'ReadEventsV', 1000000, 'Gain', 0, 0, 0.0, 0.0, 'ALL');
 Gain = invoke(TTX, 'ParseEvV', 0, N); 
 Data.Gain = reshape(Gain,1,numel(Gain));

%Get Cont wave
N = invoke(TTX, 'ReadEventsV', 1000000, 'sWav', SnipChanNumber, 0, 0.0, 0.0, 'ALL');
Data.ContWave = invoke(TTX, 'ParseEvV', 0, N); 

%Getting Electrical Stimulation Index
%LEFT FOR DEBUGGING PURPOSES - TEST CIRCUIT
% N = invoke(TTX, 'ReadEventsV', 10000000, 'Indx', 0, 0, 0.0, 0.0, 'ALL');
% z = invoke(TTX, 'ParseEvV', 0, N);
% z=z(:,1:16:end);
% Data.ElecStimIndex = reshape(z,1,numel(z));

%Getting Electrical Stimulation Trigger
%LEFT FOR DEBUGGING PURPOSES - TEST CIRCUIT
%N=invoke(TTX,'ReadEventsV',10000,'STri',0,0,0.0,0.0,'ALL');
%Data.ElecStimTrig=invoke(TTX, 'ParseEvInfoV', 0, N, 6);

% Close the tank when your done
invoke(TTX, 'CloseTank');
invoke(TTX,'ReleaseServer');

%Closing Figure
close;