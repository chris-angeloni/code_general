function [block, cellInfo, labels, spikes, events, fs] = splitSpikesByTemplates_allev(root,template,drift_correct,NLX)

%% load events and spikes from non-noise units
if exist('NLX','var') & ~isempty(NLX)
    [spikes,events,fs,cellInfo,labels] = getSpikeEventsNLX(root);
else
    [spikes,events,fs,cellInfo,labels] = getSpikeEventsKS(root);
end
stimOn = events.times{1,1};
stimOff = events.times{1,2};
laserOn = events.times{4,1};
laserOff = events.times{4,2};

stim = sort([stimOn; stimOff]);
laser = sort([laserOn; laserOff]);

allev = [stimOn; stimOff; laserOn; laserOff];
allind = [repmat(1,length(stimOn),1); repmat(-1,length(stimOff),1); ...
          repmat(2,length(laserOn),1); repmat(-2,length(laserOff),1)];
alld = round(diff(sort(allev)),3);
[allevSort,allevSortI] = sort(allev);
allindSort = allind(allevSortI);

d{1} = round(diff(stim),3); % stim differences
d{2} = round(diff(laser),3); % laser differences




%%%%%%%%%%%%%%%%%%%%
%% TEMPLATE MATCHING

templateMatch = false;

cnt = 0;
for i = 1:length(template)
    
    %fprintf('Testing template %d/%d --
    %%s\n',i,length(template),template(i).name);
    
    % dt for all events in this template
    [tmp_times,sortI] = sort([template(i).times{1};template(i).times{2}]);
    tmp_ind = [repmat(1,length(template(i).times{1}),1); ...
               repmat(2,length(template(i).times{2}),1)];
    tmp_ind = tmp_ind(sortI);
    alltmpdt = round(diff(tmp_times),3);

    % find matches
    tmp{i} = strfind(alld',alltmpdt');
    
    if i == 8
    end
    
    % if there is at least one match to the template
    if ~isempty(tmp{i})
        
        repCount = 1;       
        
        % if there is more than one matching segment, duplicate
        % the template until it covers all of the different blocks
        if length(tmp{i}) > 1
            
            
            while 1
                
                repCount = repCount + 1;
                
                % repeat the stimulus given the stimulus length
                newtemp = tmp_times;
                newtimes = tmp_times;
                newind = tmp_ind;
                for ii = 1:repCount-1
                    newtemp = [newtemp; (template(i).stimLength-1)*ii / template(i).fs + ...
                               tmp_times];       
                    newtimes = [newtimes; (template(i).stimLength-1)*ii / template(i).fs + ...
                               tmp_times];
                    newind = [newind; tmp_ind];
                end
                newtemp = round(diff(newtemp),3);
                
                % check matches again
                match = strfind(alld',newtemp');               
                
                % check for multiple blocks
                if length(match) > 1
                    
                    % if it still finds more than one block, check
                    % if the block onsets are equal to the number
                    % of events, if so, we need to keep replicating
                    if ~any(diff(match) == length(tmp_times))
                        
                        % if they're not equal to the number of the
                        % events check that the blocks are
                        % separated by more than the number of
                        % events in a block
                        if ~any(diff(match) <  length(newtemp))
                            templateMatch = true;
                            break;
                               
                        end
                        
                    end
                    
                elseif isempty(match)
                    % if it doesn't find any matches after
                    % replicating, check for well separated blocks
                    if diff(tmp{i}) > 30
                        match = tmp{i};
                        newtemp = alltmpdt;
                        newind = tmp_ind;
                        repCount = repCount - 1;
                        templateMatch = true;
                        break;
                    else
                        templateMatch = false;
                        break;
                    end
                    
                elseif length(match) == 1
                    % otherwise, if it found only 1 match for stim and
                    % laser, so it is a match;
                    templateMatch = true;
                    break;
                    
                end
                
            end
                        
        elseif length(tmp{i}) == 1
            match = tmp{i};
            newtimes = tmp_times;
            newtemp = round(diff(newtimes),3);
            newind = tmp_ind;
            templateMatch = true;
            
        else
            %fprintf('\tNo template match...\n\n')
            templateMatch = false;

        end
        
    else
        templateMatch = false;
        
    end
    
    if i == 8
    end
    
    
    if templateMatch
        %fprintf('\t*********Template matched!\n\n');
                
        for ii = 1:length(match)
            cnt = cnt + 1;
            block(cnt).name = template(i).name;
            block(cnt).file = template(i).fileName;
            block(cnt).stimInfo = template(i).stimInfo;
            block(cnt).fs = template(i).fs;
            block(cnt).nreps = repCount;
            block(cnt).startIndex = match(ii);
            block(cnt).endIndex = match(ii) + ...
                length(newtemp);
            
            % pull out event times
            evT = allevSort(block(cnt).startIndex:block(cnt).endIndex);
            
            % event times
            if sum(newind==1) > 0
                ev = evT(newind==1);
                block(cnt).stimOn = stimOn(ismember(stimOn,ev));
                block(cnt).stimOff = stimOff(ismember(stimOff,ev));
            else
                block(cnt).stimOn = [];
                block(cnt).stimOff = [];
            end
            if sum(newind==2) > 0
                ev = evT(newind==2);
                block(cnt).laserOn = laserOn(ismember(laserOn,ev));
                block(cnt).laserOff = laserOff(ismember(laserOff,ev));
            else
                block(cnt).laserOn = [];
                block(cnt).laserOff = [];
            end

            % template number
            block(cnt).template = i;

            % start and end times
            block(cnt).start = evT(1);
            block(cnt).end = block(cnt).start + ((template(i).stimLength * block(cnt).nreps) ...
                                                 / template(i).fs);
        
        
        end
        
    end
    
end

if ~exist('block','var')
    keyboard
end







%%%%%%%%%%%%%%%%
%% BLOCK CLEANUP

% sort blocks by start time
[~,sortI] = sort([block.start]);
block = block(sortI);

in = [];
% interactive more for blocks that match more than one template
if any(diff([block.start])==0)
        
    I = find(diff([block.start])==0,1,'first');
    while ~isempty(I)
        
        cnt = 1;
        
        fprintf('\n\tFound blocks matched with more than one template!\n')
        fprintf('\tCheck your recording notes to see which was the correct stimulus, maybe these event messages will help:\n')
        for j = 1:length(events.msgtext{2})
            fprintf('\t%s\n',events.msgtext{2}{j})
        end
        fprintf('\n');
        
        fprintf('\n\tPress [%d] to keep block %d or [%d] to keep block %d:\n\n',...
                I,I,I+1,I+1)
        fprintf('\t\tBlock %d: %s -- %d reps\n',I,block(I).name, ...
                block(I).nreps);
        fprintf('\t\tBlock %d: %s -- %d reps\n',I+1,block(I+1).name, ...
                block(I+1).nreps);
        
        in = input('');
        if in == I
            block(I+1) = [];
            I = find(diff([block.start])==0,1,'first');
        elseif in == I+1
            block(I) = [];
            I = find(diff([block.start])==0,1,'first');
        else
            fprintf(['no blocks selected, keeping all of them...\' ...
                     'n']);
        end
    end
    
end
                


fprintf('\tFound %d stim blocks for %s\n',length(block),root);

% for each block, get the spikes
for b = 1:length(block)
    
    fprintf('\t\tBlock %d: %s -- %d reps\n',b,block(b).name,block(b).nreps);
    
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
            
            % testing code for a specific stimulus
            if strcmp(block(b).name, ...
                      'behaviorPsychWithLaserPulse.wav')
                
                stimLength = (template(block(b).template).stimLength-1)/template(block(b).template).fs;
                
                ev = sort([block(b).stimOn; block(b).stimOff]);
                
                ev_actual = template(block(b).template).times{1};
                for i = 1:block(b).nreps-1
                    ev_actual = [ev_actual; ...
                                 stimLength * i + template(block(b).template).times{1}];
                end
                
                x = [ones(size(ev)) ev];
                y = ev_actual;
                
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
                
            end

            
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
                fprintf('\t\t\tNonhomogenous events in block %s... will not perform drift correction!\n',block(b).name);
                
            end
            
        end
        
    end
    
end