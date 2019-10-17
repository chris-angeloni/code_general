function [spikes,events,fs,cellInfo,labels] = getSpikeEventsNLX(root)

% need to be in the data directory
cd(root);

%% events
% load events
[evTS, evIDs, evTTLs, ~, evStr, header] = ...
    Nlx2MatEV_v3('Events.nev', [1 1 1 1 1], 1, 1, [] );

% load time stamps for the raw files
[rTS, Header] = ...
    Nlx2MatCSC_v3('CSC1.ncs', [1 0 0 0 0], 1, 1, [] );

% get sample rate from header
tmp = strsplit(Header{contains(Header,'-SamplingFrequency')});
fs = str2num(tmp{2});

% convert nlx times to samples from recording start
recSN = (0:length(rTS)-1)*512;
ev = interp1(rTS,recSN,evTS);
evTS = ev / fs;

% get all event types (for now, just stim and laser)
% binarize events
binTTL = fliplr(dec2bin(evTTLs,3)-'0');

for i = 1:2
    times{i,1} = evTS(find(diff(binTTL(:,i))==1) + 1);
    times{i,2} = evTS(find(diff(binTTL(:,i))==-1) + 1);
end

events.allEv = evTS;
events.times = times;

%% spikes
spks = double(readNPY(fullfile(root,'spike_times.npy'))) / fs;
clust  = double(readNPY(fullfile(root,'spike_clusters.npy')));

% load cluster groups
fid = fopen(fullfile(root,'cluster_group.tsv'));
textscan(fid,'%s\t%s\n');     % header
dat = textscan(fid,'%d\t%s'); % data
fclose(fid);

clustID = dat{1};
labels = dat{2};

spikes.times = spks;
spikes.clust = clust;
spikes.clustID = clustID;
spikes.labels = labels;

fileChunks = strsplit(root,'/');
if ~any(contains(fileChunks,'~'))
    ind = [6 7];
else
    ind = [4 5];
end

% make cell info
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
    
end

