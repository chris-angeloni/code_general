function [PSTH,raster,trials,PSTHsm] = makePSTH(spikes,triggers,edges,smth)

%% function [PSTH,raster,trials,PSTHsm] = makePSTH(spikes,triggers,edges,smth)
% this function makes a PSTH and a spike raster given spike times,
% trigger times, bin edges, and will optionally output a smoothed PSTH

if size(spikes,1) == 1
    spikes = spikes';
end

raster = [];
trials = [];
PSTH = zeros(length(triggers),length(edges)-1);
PSTHsm = zeros(length(triggers),length(edges)-1);

% for each trigger
for i = 1:length(triggers)
    
    % align spikes to each trigger
    spks = spikes - triggers(i);
    
    % extract spikes within the PSTH window only
    spks = spks(spks > edges(1) & spks < edges(end));
    
    % raster
    raster = [raster spks'];
    trials = [trials ones(1,length(spks))*i];
    
    % psth
    PSTH(i,:) = histcounts(spks,edges) ./ mode(diff(edges));
    
    % smoothed PSTH (optional)
    if exist('smth','var') & ~isempty(smth)
        PSTHsm(i,:) = SmoothGaus(PSTH(i,:),smth);
    else
        PSTHsm = [];
    end
    
end

    
    