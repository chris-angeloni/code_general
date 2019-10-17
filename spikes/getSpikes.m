function [spikeData, info] = getSpikes(mouse, session, inDir, outDir, fn, stimDur)

% function [spikeData, info] = getSpikes(mouse, session, inDir,
% outDir, stimDur)
%
% RECEIVES
% mouse   : mouse ID (eg. 'CA018')
% session : session ID, usually in date form (eg. '161005')
% inDir   : directory where the spike.mats are
% outDir  : directory where we want to save out our single file
% fn      : name for file (optional)
% stimDur : duration of the stimulus in seconds (optional if you've
%          filled out the StimInfo event numbers in analysis
%
% RETURNS
% spikeData: struct for each cell containing fr trace for each
%            repeat, in a matrix, a vector called t that gives the time for
%            each PSTH bin, and vectors containing spike times and their
%            corresponding trials
% info     : struct containing binSize, and other info about cells

addpath(genpath('~/chris-lab/projects/util'));

%% IO
%mouse = 'CA018';
%session = '161005';
%inDir = ['~/data/var_noise' filesep mouse filesep session filesep 'spike_data'];
%outDir = [inDir filesep '..'];


% Get cells and reps
files = dir([inDir filesep '*.mat']);
if length(files) == 0
    disp('No files found');
    keyboard;
end
for i = 1:length(files)
    k = strfind(files(i).name,'-');
    tmp(i,:) = files(i).name(1:k(end));
end
cellIDs = unique(tmp,'rows');
nCells = size(cellIDs,1);
nReps = length(tmp) / nCells;

% Deal with arguments
if nargin < 6
    load([inDir filesep files(1).name]);
    stimDur = StimInfo.nEv;
    if nargin < 5
        fn = [mouse '-' session '-spikeData.mat'];
    end
end

%% EXTRACT SPIKE INFO
binSize = .005;
% preallocate
stimDurInSecs = stimDur;
cellInfo = [];
% for each cell
for i = 1:nCells
    % for each stimulus
    spikes = [];
    trial = [];
    events = [];
    fr = zeros(nReps,stimDurInSecs/binSize);
    for j = 1:nReps
        fprintf('Cell %02d - run %02d\n',i,j);
        load([inDir filesep cellIDs(i,:) sprintf('%02d',j) '.mat']);
        
        % Concatenate cell info
        if j == 1
            cellInfo = [cellInfo; CellInfo];
        end
        
        % Concatenate spikes, along with the corresponding repeat
        spikes = [spikes SpikeData(2,:)];
        trial = [trial ones(1,length(SpikeData))*j];
        
        % Calculate PSTH over this trial and add to FR mat
        edges = 0:binSize:stimDurInSecs;
        t = edges(1:end-1) + binSize/2;
        nSpikes = histcounts(SpikeData(2,:),edges);
        fr(j,:) = SmoothGaus(nSpikes./binSize,2);
        
        
        % Timestamped events and spike times for good measure
        % spikeData(i).events(j,:) = Events;
    end
    spikeData(i).fr = fr;
    spikeData(i).t = t;
    spikeData(i).spikes = spikes;
    spikeData(i).trial = trial;
    spikeData(i).cellInfo = CellInfo;
end

info.fn = fn;
info.cellInfo = cellInfo;
info.cellIDs = cellIDs;
info.nCells = nCells;
info.nReps = nReps;
info.binSize = binSize;

if exist('outDir','var') 
    save([outDir filesep fn],'spikeData','info');
end
