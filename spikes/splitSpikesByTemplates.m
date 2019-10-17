function [block, cellInfo, labels] = splitSpikes1(root,templateDir,drift_correct)

%% load events and spikes from non-noise units
[spikes,events,fs,cellInfo,labels] = getSpikeEventsKS(root);
stimOn = events.times{1,1};
stimOff = events.times{1,2};
laserOn = events.times{4,1};
laserOff = events.times{4,2};
ds = round(diff(stimOn)*1000) / 1000; % stim differences
dl = round(diff(laserOn)*1000) / 1000; % laser differences
ld = round((laserOff - laserOn)*1000) / 1000; % laser durations

% load block templates
load(templateDir);

cnt = 0;
for i = 1:length(template)
    
    if i < 7
        

        
        % search laser duration
        tmp = strfind(ld',template{i});
        for j = 1:length(tmp)
            cnt = cnt + 1;
                                                
            block(cnt).index = tmp(j);
            block(cnt).n = length(template{i});
            block(cnt).dtMax = max(round(diff(laserOn(tmp(j):(tmp(j)+block(cnt).n-1)))*1e4)/1e4);
            block(cnt).start = laserOn(tmp(j));
            block(cnt).end = laserOn(tmp(j) + block(cnt).n-1) + block(cnt).dtMax; % assumes there is no event for stim end 
            block(cnt).evType = 'laser';
            block(cnt).name = templateStr{i};
            block(cnt).laserOn = laserOn(tmp(j):(tmp(j)+block(cnt).n-1));
            block(cnt).laserOff = laserOff(tmp(j):(tmp(j)+block(cnt).n-1));
            block(cnt).stimOn = stimOn(stimOn >= block(cnt).start & stimOn <= block(cnt).end);
            block(cnt).stimOff = stimOff(stimOff >= block(cnt).start & stimOff <= block(cnt).end);
            
        end
        
    else
        
        if i == 8
            % alt contrast, with sync
            n = length(template{i})-1;
        else
            % alt contrast, without sync
            n = length(template{i});
        end
        

        % search stim event differences
        tmp = strfind(ds',template{i});
        if diff(tmp) == 1
            warning('Likely nested blocks detected, check for event counts that are 1 off!');
            continue;
        end
        for j = 1:length(tmp)
            cnt = cnt + 1;
            
            block(cnt).index = tmp(j);
            block(cnt).n = n;
            block(cnt).dtMax = max(round(diff(stimOn(tmp(j):(tmp(j)+block(cnt).n)))*1e4)/1e4);
            block(cnt).start = stimOn(tmp(j));
            block(cnt).end = stimOn(tmp(j) + block(cnt).n) + block(cnt).dtMax; % assumes there is no event for stim end
            block(cnt).evType = 'stim';
            block(cnt).name = templateStr{i};
            block(cnt).laserOn = laserOn(laserOn >= block(cnt).start & laserOn <= block(cnt).end);
            block(cnt).laserOff = laserOff(laserOff >= block(cnt).start & laserOff <= block(cnt).end);
            block(cnt).stimOn = stimOn(tmp(j):(tmp(j)+block(cnt).n));
            block(cnt).stimOff = stimOff(tmp(j):(tmp(j)+block(cnt).n));
            
            
        end
    end
end

fprintf('Found %d stim blocks for %s:\n',length(block),root);

% for each block, get the spikes
for b = 1:length(block)
   
    fprintf('\tBlock %d: %s\n',b,block(b).name);
    
    block(b).spikes = spikes.times(spikes.times > block(b).start & ...
        spikes.times < block(b).end);
    block(b).clust = spikes.clust(spikes.times > block(b).start & ...
        spikes.times < block(b).end);
    block(b).clustID = spikes.clustID;
    block(b).clustLabel = spikes.labels;
    
    % attempt drift correction
    if exist('drift_correct','var')
        
        if drift_correct
            
            % only drift correct if all of the events have an even
            % difference, down to 1 ms
            if strcmp(block(b).evType,'stim')
                ev = block(b).stimOn;
            else
                ev = block(b).laserOn;
            end
            
            de = round(diff(ev) * 1e3) / 1e3;
            if ~any(diff(de)>0)
                % observed clock events (x) to predict real time (y)
                x = [ones(size(ev)) ev];
                y = [0; cumsum(de)];
                                
                beta = x\y;

                % scale times by the drift
                block(b).spikes = [ones(size(block(b).spikes)) block(b).spikes] * beta;
                block(b).laserOn = [ones(size(block(b).laserOn)) block(b).laserOn] * beta;
                block(b).laserOff = [ones(size(block(b).laserOff)) block(b).laserOff] * beta;
                block(b).stimOn = [ones(size(block(b).stimOn)) block(b).stimOn] * beta;
                block(b).stimOff = [ones(size(block(b).stimOff)) block(b).stimOff] * beta;
            
            else
                fprintf('\t\tNonhomogenous events in block %s... will not perform drift correction!\n',block(b).name);
            
            end
            
        end
        
    end
    
end