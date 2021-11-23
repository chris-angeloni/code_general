function [block, cellInfo, labels, spikes, events, fs] = splitSpikesByTemplates_MSE(root,template,drift_correct,NLX)

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

d{1} = round(diff(stim),3); % stim differences
d{2} = round(diff(laser),3); % laser differences

% load block templates
%load(templateDir);

figure(999); clf; hold on;
scatter(stim(1:end-1),diff(stim),10,'k.','markeredgealpha',.2)
scatter(laser(1:end-1),diff(laser),10,'kx','markeredgealpha',.2)
set(gca,'yscale','log')

templateMatch = false;

cnt = 0;
for i = 1:length(template)
    
    %fprintf('Testing template %d/%d -- %s\n',i,length(template),template(i).name);
    
    % for stim and laser events
    for j = 1:2
        
        tmp{i}{j} = strfind(d{j}',template(i).diffs{j}');
        
        % sweep the template across the observed events, computing
        % MSE each sweep
        MSE = [];
        for ii = 1:length(d{j})-length(template(i).diffs{j})+1
            ind = ii:ii+length(template(i).diffs{j})-1;
            MSE(ii) = mean((d{j}(ind) - template(i).diffs{j}).^2);
        end
        
        tmp{i}{j} = find(MSE < .001);

    end
    
    if i== 12
        %keyboard
    end
    
    % if there is at least one match to the template
    if ~all(cellfun('isempty',tmp{i}))
        
        repCount = 1;       
        
        % if there is more than one matching segment, duplicate
        % the template until it covers all of the different blocks
        if any(cellfun(@length,tmp{i}) > 1)
            
            
            while 1
                
                repCount = repCount + 1;
                
                % repeat the stimulus given the stimulus length
                newtemp = template(i).times;
                for ii = 1:repCount-1
                    newtemp{1} = [newtemp{1}; (template(i).stimLength-1)*ii / template(i).fs + ...
                                  template(i).times{1}];
                    newtemp{2} = [newtemp{2}; (template(i).stimLength-1)*ii / template(i).fs + ...
                                  template(i).times{2}];
                end
                
                newtemp{1} = round(diff(newtemp{1}),3);
                newtemp{2} = round(diff(newtemp{2}),3);
                
                % look for matches again
                for j = 1:2
                    
%                      MSE = [];
%                      for ii = 1:length(d{j})-length(newtemp{j})+1
%                          ind = ii:ii+length(newtemp{j})-1;
%                          MSE(ii) = mean((d{j}(ind) - newtemp{j}).^2);
%                      end
%                      
%                      [~,match{i}{j}] = find(MSE == min(MSE));
                    
                    match{i}{j} = strfind(d{j}',newtemp{j}');
                    
                end
                
                % check for multiple blocks
                if any(cellfun(@length,match{i}) > 1)
                    
                    % if it still finds more than one block, check
                    % if the block onsets are equal to the number
                    % of events, if so, we need to keep replicating
                    if ~any(diff(match{i}{1}) == length(template(i).times{1})) & ...
                            ~any(diff(match{i}{2}) == length(template(i).times{2}))
                        
                        % if they're not equal to the number of the
                        % events check that the blocks are well seperated
                        if ~any(diff(match{i}{1}) == 2) & ~any(diff(match{i}{2}) == 2)
                            templateMatch = true;
                            break;
                            
                        end
                        
                    end
                    
                elseif all(cellfun('isempty',match{i}))
                    % if it doesn't find any matches after
                    % replicating, check for well separated blocks
                    if any(diff(tmp{i}{1}) > 30) | any(diff(tmp{i}{2}) > 30)
                        for j = 1:2
                            newtemp{j} = template(i).diffs{j};
                        end
                        repCount = repCount - 1;
                        templateMatch = true;
                        break;
                    else
                        templateMatch = false;
                        break;
                    end
                    
                elseif any(cellfun(@length,match{i}) == 1)
                    % otherwise, if it found only 1 match for stim and
                    % laser, so it is a match;
                    templateMatch = true;
                    break;
                    
                end
                
            end
            
            template(i).diffs = newtemp;
            
        end
        
        
        % check if there are supposed to be laser events, but
        % there are none in this template or vice versa
        stimI = stim(tmp{i}{1}:tmp{i}{1}+ ...
                     min([length(template(i).diffs{1}) length(tmp{i}{1})]));
        laserI = laser(tmp{i}{2}:tmp{i}{2}+ ...
                        min([length(template(i).diffs{2}) length(tmp{i}{2})]));
        
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
        
        for ii = 1:max(cellfun(@length,tmp{i}))
            cnt = cnt + 1;
            block(cnt).name = template(i).name;
            block(cnt).file = template(i).fileName;
            block(cnt).stimInfo = template(i).stimInfo;
            block(cnt).fs = template(i).fs;
            block(cnt).nreps = repCount;
            
            if ~isempty(tmp{i}{1})
                block(cnt).startIndex{1} = tmp{i}{1}(ii);
                block(cnt).endIndex{1} = tmp{i}{1}(ii) + ...
                    length(template(i).diffs{1});
                stimI = stim(block(cnt).startIndex{1}: ...
                             block(cnt).endIndex{1});
                block(cnt).stimOn = stimOn(ismember(stimOn,stimI));
                block(cnt).stimOff = stimOff(ismember(stimOn,stimI));
            else
                block(cnt).stimOn = [];
                block(cnt).stimOff = [];
                block(cnt).startIndex{1} = [];
                block(cnt).endIndex{1} = [];
            end
            
            if ~isempty(tmp{i}{2})
                block(cnt).startIndex{2} = tmp{i}{2}(ii);
                block(cnt).endIndex{2} = tmp{i}{2}(ii) + ...
                    length(template(i).diffs{2});
                laserI = laser(block(cnt).startIndex{2}: ...
                               block(cnt).endIndex{2});
                block(cnt).laserOn = laserOn(ismember(laserOn,laserI));
                block(cnt).laserOff = laserOff(ismember(laserOn,laserI));
            else
                block(cnt).laserOn = [];
                block(cnt).laserOff = [];
                block(cnt).startIndex{2} = [];
                block(cnt).endIndex{2} = [];
            end
            
            % template number
            block(cnt).template = i;

            % start and end times
            block(cnt).start = min([stimI; laserI]);
            block(cnt).end = block(cnt).start + ...
            ((template(i).stimLength * block(cnt).nreps) / template(i).fs);
        
        all_l = sort([block(cnt).laserOn; block(cnt).laserOff]);
        scatter(all_l(1:end-1),diff(all_l));
        
        end
        
    end
    
end

% sort blocks by start time
[~,sortI] = sort([block.start]);
block = block(sortI);

% interactive more for blocks that match more than one template
if any(diff([block.start])==0)
        
    I = find(diff([block.start])==0,1,'first');
    while ~isempty(I)
        
        cnt = 1;
        
        fprintf('\nFound blocks matched with more than one template!\n')
        fprintf('Check your recording notes to see which was the correct stimulus, maybe these event messages will help:\n')
        for j = 1:length(events.msgtext{2})
            fprintf('\t%s\n',events.msgtext{2}{j})
        end
        fprintf('\n');
        
        fprintf('\nPress [%d] to keep block %d or [%d] to keep block %d:\n\n',...
                I,I,I+1,I+1)
        fprintf('\tBlock %d: %s -- %d reps\n',I,block(I).name, ...
                block(I).nreps);
        fprintf('\tBlock %d: %s -- %d reps\n',I+1,block(I+1).name, ...
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
                


fprintf('Found %d stim blocks for %s\n',length(block),root);

% for each block, get the spikes
for b = 1:length(block)
    
    fprintf('\tBlock %d: %s -- %d reps\n',b,block(b).name,block(b).nreps);
    
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
                fprintf('\t\tNonhomogenous events in block %s... will not perform drift correction!\n',block(b).name);
                
            end
            
        end
        
    end
    
end