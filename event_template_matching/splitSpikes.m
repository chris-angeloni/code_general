function [block, cellInfo,labels] = splitSpikes(root,blockStart,blockN,blockDT,blockName,drift_correct)

if ~exist('blockName','var')
    blockName = cell(1,length(blockStart));
end

%% load events and spikes from non-noise units
[spikes,events,fs,cellInfo,labels] = getSpikeEventsKS(root);

stimOn = events.times{1,1};
stimOff = events.times{1,2};
laserOn = events.times{4,1};
laserOff = events.times{4,2};

% split out spikes
for b = 1:length(blockStart)
    
    % block structure
    block(b).name = blockName{b};
    block(b).start = blockStart(b);
    block(b).n = blockN(b);
    block(b).dt = blockDT(b);
    block(b).end = block(b).start + (block(b).n * block(b).dt);
    
    % find events (pad with .1s to account for clock drift and make
    % sure to grab every event)
    block(b).laserOn = laserOn(laserOn >= block(b).start & laserOn <= block(b).end);
    block(b).laserOff = laserOff(laserOff >= block(b).start & laserOff <= block(b).end+.1);
    block(b).stimOn = stimOn(stimOn >= block(b).start & stimOn <= block(b).end);
    block(b).stimOff = stimOff(stimOff >= block(b).start & stimOff <= ...
        block(b).end+.1);
    
    % split spikes
    dt = block(b).dt;
    block(b).spikes = spikes.times(spikes.times > block(b).start & ...
        spikes.times < block(b).end+dt);
    block(b).clust = spikes.clust(spikes.times > block(b).start & ...
        spikes.times < block(b).end+dt);
    block(b).clustID = spikes.clustID;
    block(b).clustLabel = spikes.labels;

    % perform drift correction if specified
    if exist('drift_correct','var')

        if drift_correct
            
            % observed events (x) and real time (y)
            x = [ones(size(block(b).stimOn)) block(b).stimOn];
            y = 0:block(b).dt:(block(b).n*block(b).dt)-1;
            
            beta = x\y';
            
            % scale times by the drift
            block(b).spikes = [ones(size(block(b).spikes)) block(b).spikes] * beta;
            block(b).laserOn = [ones(size(block(b).laserOn)) block(b).laserOn] * beta;
            block(b).laserOff = [ones(size(block(b).laserOff)) block(b).laserOff] * beta;
            block(b).stimOn = [ones(size(block(b).stimOn)) block(b).stimOn] * beta;
            block(b).stimOff = [ones(size(block(b).stimOff)) block(b).stimOff] * beta;
            
        end
        
    end
    
end