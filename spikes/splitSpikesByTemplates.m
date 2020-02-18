function [block, cellInfo, labels] = splitSpikesByTemplates(root,templateDir,drift_correct)

%% load events and spikes from non-noise units
[spikes,events,fs,cellInfo,labels] = getSpikeEventsKS(root);
stimOn = events.times{1,1};
stimOff = events.times{1,2};
laserOn = events.times{4,1};
laserOff = events.times{4,2};

stim = sort([stimOn; stimOff]);
laser = sort([laserOn; laserOff]);

d{1} = round(diff(stim),3); % stim differences
d{2} = round(diff(laser),3); % laser differences

% load block templates
load(templateDir);

templateMatch = false;

cnt = 0;
for i = 1:length(template)
    
    %fprintf('Testing template %d/%d -- %s\n',i,length(template),template(i).name);
    
    % for stim and laser events
    for j = 1:2
        
        tmp{i}{j} = strfind(d{j}',template(i).diffs{j}');
        
    end
    
    % if there is at least one match to the template
    if ~all(cellfun('isempty',tmp{i}))
        
         % if there is more than one matching segment, duplicate
         % the template until there is only one match
        if any(cellfun(@length,tmp{i}) > 1)
           
            repCount = 1;
            
            while any(cellfun(@length,tmp{i}) > 1)
                
                repCount = repCount + 1;
                
                % to repeat the stimulus, you need to assume some
                % repetition of the structure... so you need to
                % know the duration of the last event
                % difference... this kinda sucks because it could
                % be impossible to know with some stimuli... for
                % now lets assume we know it
                newtemp = template(i).times;
                for ii = 1:repCount-1
                    newtemp{1} = [newtemp{1}; (template(i).stimLength-1) / template(i).fs + ...
                                  template(i).times{1}];
                    newtemp{2} = [newtemp{2}; (template(i).stimLength-1) / template(i).fs + ...
                                  template(i).times{2}];
                end
                
                newtemp{1} = round(diff(newtemp{1}),3);
                newtemp{2} = round(diff(newtemp{2}),3);
                
                for j = 1:2
                    
                    tmp{i}{j} = strfind(d{j}',newtemp{j}');
                    
                end
                
            end
            
            template(i).diffs = newtemp;
            
        end
       
        
        % check if there are supposed to be laser events, but
        % there are none in this template or vice versa
        stimI = stim(tmp{i}{1}:tmp{i}{1}+ ...
                     length(template(i).diffs{1}));
        laserI = laser(tmp{i}{2}:tmp{i}{2}+ ...
                     length(template(i).diffs{2}));
        
        if ~isempty(stimI) 
            if (sum(laser >= stimI(1) & laser <= stimI(end)) > 1 && ...
                isempty(laserI))
                %fprintf('\tLaser events detected, but none are in the template...\n\n');
                templateMatch = false;
            else
                templateMatch = true;
            end
            
        elseif ~isempty(laserI)
            if sum(stim >= laserI(1) & stim <= laserI(end)) > 1 && ...
                    isempty(stimI)
                %fprintf('\tStim events detected, but none are in the template...\n\n');
                templateMatch = false;
            else
                templateMatch = true;
            end
            
        else
            %fprintf('\tNo template match...\n\n')
            templateMatch = false;
            
        end
        
    else
        %fprintf('\tNo template match...\n\n')
        templateMatch = false;
        
    end
    
    if templateMatch
        %fprintf('\t*********Template matched!\n\n');
        cnt = cnt + 1;
        block(cnt).name = template(i).name;
        block(cnt).file = template(i).fileName;
        block(cnt).stimInfo = template(i).stimInfo;
        block(cnt).fs = template(i).fs;
        
        for j = 1:2
            block(cnt).startIndex{j} = tmp{i}{j};
            block(cnt).endIndex{j} = tmp{i}{j} + ...
                length(template(i).diffs{j});
            
        end
            
        if ~isempty(block(cnt).startIndex{1})
            stimI = stim(block(cnt).startIndex{1}: ...
                         block(cnt).endIndex{1});
            block(cnt).stimOn = stimOn(ismember(stimOn,stimI));
            block(cnt).stimOff = stimOff(ismember(stimOn,stimI));
        else
            block(cnt).stimOn = [];
            block(cnt).stimOff = [];
        end
        
        if ~isempty(block(cnt).startIndex{2})
            laserI = laser(block(cnt).startIndex{2}: ...
                         block(cnt).endIndex{2});
            block(cnt).laserOn = laserOn(ismember(laserOn,laserI));
            block(cnt).laserOff = laserOff(ismember(laserOn,laserI));
        else
            block(cnt).laserOn = [];
            block(cnt).laserOff = [];
        end
        
        block(cnt).start = min([stimI; laserI]);
        block(cnt).end = block(cnt).start + (template(i).stimLength ...
                                             / template(i).fs);
        
    end
    
end


fprintf('Found %d stim blocks for %s\n',length(block),root);

% for each block, get the spikes
for b = 1:length(block)
    
    fprintf('\tBlock %d: %s\n',b,block(b).name);
    
    if size(spikes.times,1) == 1
        spikes.times = spikes.times';
        spikes.clust = spikes.clust';
    end
    
    block(b).spikes = spikes.times(spikes.times > block(b).start & ...
                                   spikes.times < block(b).end);
    block(b).clust = spikes.clust(spikes.times > block(b).start & ...
                                  spikes.times < block(b).end);
    block(b).clustID = spikes.clustID;
    block(b).clustLabel = spikes.labels;
    
    % attempt drift correction
    if exist('drift_correct','var')
        
        if drift_correct
            
            % check stim events
            ev = block(b).stimOn;

            if isempty(ev)
                
                % check laser events if no stim events
                ev = block(b).laserOn;
                
            end
            
            de = round(diff(ev),3);
            
            if ~any(diff(de)>0)
                % observed clock events (x) to predict real time (y)
                x = [ones(size(ev)) ev];
                y = [0; cumsum(de)];
                
                beta = x\y;

                % scale times by the drift
                block(b).spikes = [ones(size(block(b).spikes)) block(b).spikes] * beta;
                if ~isempty(block(b).laserOn)
                    block(b).laserOn = [ones(size(block(b).laserOn)) block(b).laserOn] * beta;
                    block(b).laserOff = [ones(size(block(b).laserOff)) block(b).laserOff] * beta;
                end
                if ~isempty(block(b).stimOn)
                    block(b).stimOn = [ones(size(block(b).stimOn)) block(b).stimOn] * beta;
                    block(b).stimOff = [ones(size(block(b).stimOff)) block(b).stimOff] * beta;
                end
                
            else
                fprintf('\t\tNonhomogenous events in block %s... will not perform drift correction!\n',block(b).name);
                
            end
            
        end
        
    end
    
end

% sort blocks by start time
[~,sortI] = sort([block.start]);
block = block(sortI);