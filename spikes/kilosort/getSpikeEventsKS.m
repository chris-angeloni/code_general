function [spikes,events,fs,cellInfo,labels] = getSpikeEventsKS(root)

%% function [spikes,events,fs,cellInfo,labels] = getSpikeEventsKS(root);
%
% this function loads spikes, events, and other cell info from
% kilosort-sorted data recorded by open ephys. it assumes a folder
% structure specific to openEphys binary format aquisition:
%
% INPUTS:
%  root: the path to your data, eg. "~/data/kilosort/CA070/2018-08-08_10-21-04/experiment1/recording1"
%        the next folders after what you input as "root" should include "continuous" and "events"
%
% OUTPUTS:
%  spikes: a struct with spike data; 
%          .times = spike times for every spike in the recording
%          .clust = cluster id per spike found by kilosort and manually corrected
%          .clustID = list of unique clusters in the data
%          .labels = label of unit type for each cluster
%  events: a struct with event data; %
%          .times = event times for each channel; 1st dim = event channel and 2nd = on/off time
%                   eg. for channel 1 on times, I want events.times{1,1}
%          .allEv = original ev struct, just in case
%          .recStart = recording start time
%          .msgtext = struct with typed in messages and timestamps for each
%          .blockStart = a hold over from the loadEventData.m function, which will be the event
%                        time you selected when running that function
%  fs: recording sampling rate
%  cellInfo: cell array with information for each cell
%  labels: cell array with the labels for each column in cell info

% load events
[ev,blockStart,startTime,msgtext,fs,binFlag] = loadEventData(root,'recInfo.mat');

% assume 8 channels (max for openEphys)
for i = 1:8
    times{i,1} = ev.ts(ev.state == i);
    times{i,2} = ev.ts(ev.state == -i);
    
    if mod(startTime(1)*1e-3,1)
        times{i,1} = times{i,1} - startTime(1)/fs;
        times{i,2} = times{i,2} - startTime(1)/fs;
    end
end


%% load spikes
spks = double(readNPY(fullfile(root,'continuous','Rhythm_FPGA-100.0','spike_times.npy'))) / fs;
clust  = double(readNPY(fullfile(root,'continuous','Rhythm_FPGA-100.0','spike_clusters.npy')));

% load cluster groups
fid = fopen(fullfile(root,'continuous','Rhythm_FPGA-100.0','cluster_group.tsv'));
textscan(fid,'%s\t%s\n');     % header
dat = textscan(fid,'%d\t%s'); % data
fclose(fid);

% discard noise clusters
clustID = dat{1}(~contains(dat{2},'noise'));
labels = dat{2}(~contains(dat{2},'noise'));


% check for waveform files and load if present
waves = fullfile(root,'continuous','Rhythm_FPGA-100.0','mean_waveforms.mat');
if exist(waves,'file')
    spikes.waveforms = load(waves);
        
    spikes.waveforms.mw = spikes.waveforms.mw(~contains(dat{2},'noise'),:,:);
    spikes.waveforms.s95 = spikes.waveforms.s95(~contains(dat{2},'noise'),:,:,:);
    spikes.waveforms.sn = spikes.waveforms.sn(~contains(dat{2},'noise'));
    spikes.waveforms.sw = spikes.waveforms.sw(~contains(dat{2},'noise'),:,:);
    spikes.waveforms.mx = spikes.waveforms.mx(~contains(dat{2},'noise'),:);
    spikes.waveforms.snr = spikes.waveforms.snr(~contains(dat{2},'noise'),:);
else
    fprintf('No waveforms found!!!!\n');
end

events.allEv = ev;
events.times = times;
events.recStart = startTime;
events.msgtext = msgtext;
events.blockStart = blockStart;

spikes.times = spks;
spikes.clust = clust;
spikes.clustID = clustID;
spikes.labels = labels;

% make cell info matrix
fileChunks = strsplit(root,'/');
if ~any(contains(fileChunks,'~'))
    ind = [6 7];
else
    ind = [4 5];
end
labels = {'mouse','session','clustID','cellNum','unitType','unitType','meanFR'};
for i = 1:length(spikes.clustID)
    cellInfo{i,1} = fileChunks{ind(1)}; % mouse
    cellInfo{i,2} = fileChunks{ind(2)}; % session
    cellInfo{i,3} = spikes.clustID(i); % cluster ID
    cellInfo{i,4} = i; % unit number;
    cellInfo{i,5} = spikes.labels{i}; % unit type
    if strcmp(cellInfo{i,5},'good')
        cellInfo{i,6} = 1;
    elseif strcmp(cellInfo{i,5},'mua')
        cellInfo{i,6} = 2;
    end
    spks = spikes.times(spikes.clust == spikes.clustID(i));
    cellInfo{i,7} = length(spks) / (spks(end) - spks(1)); % mean fr
    
    if exist(waves,'file')
        [~,mi] = max(spikes.waveforms.snr(i,:));
        cellInfo{i,8} = mi;
        cellInfo{i,9} = squeeze(spikes.waveforms.mw(i,mi,:));
        cellInfo{i,10} = squeeze(spikes.waveforms.sw(i,mi,:));
        cellInfo{i,11} = spikes.waveforms.mx(i,mi);
        cellInfo{i,12} = spikes.waveforms.snr(i,mi);
        labels{8} = 'channel';
        labels{9} = 'waveform';
        labels{10} = 'waveformSEM';
        labels{11} = 'spikeAmp';
        labels{12} = 'spikeSNR';
    end
end
    
    


