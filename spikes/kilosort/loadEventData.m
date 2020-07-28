function [ev,blockStart,startTime,msgtext,fs,binFlag] = loadEventData(root,recInfo)

%% function [ev,blockStart,startTime,msgtext,fs,binFlag] = loadEventData(root,recInfo)
%
% This function is used to extract events from openEphys data sets. It is
% designed to work whether the data set is in openEphys format, or in flat
% binary (there are slight differences in how each encodes events)
% 
% INPUTS:
%  root    = root directory of the recording, ie. the one that contains the
%            continuous/events folders, or in the case of openEphys formatted data,
%            the one that contains all the data.
%  recInfo = filename to save event info to (if it exists, it won't get rec
%            info)
%
% OUTPUTS:
%  ev         = event structure containing .states (ie. channel up or channel
%               down) and .ts (timestamps for each state change)
%  blockStart = starting time in seconds for the beginning of a selected
%               block of data
%  startTime  = the start time of the recording in samples (this is
%               necessary because the events are clocked from the start of 
%               acquisition, while the spikes are relative to when the 
%               recording started)
%  msgtext    = if present, recording messages typed into the system and
%               their timestamps (***needs some work***)
%  fs         = recording sample rate
%  binflag    = 1 if flat binary recording, 0 if openEphys format

eventsDir = fullfile(root,'events');

% load event times
d = dir(eventsDir);
if sum([d.isdir]) > 2
    % if there are folders, look for events folders
    
    % load ttl events
    ttlEvents = fullfile(eventsDir,'Rhythm_FPGA-100.0','TTL_1');
    if exist(ttlEvents,'dir')
        ev.state = double(readNPY(fullfile(ttlEvents,'channel_states.npy')));
        ev.ts = double(readNPY(fullfile(ttlEvents,'timestamps.npy')));
    end
    binFlag = true;
else
    % if there are no folders, look for events files    

    addpath(genpath('~/gits/analysis-tools'));
    
    % load ttl events
    [data,ev.ts,info] = load_open_ephys_data(fullfile(root,...
        'events','all_channels.events'));
    binFlag = false;
    
    % remove message events (ttl events == 3, message events == 5)
    I = info.eventType == 3;
    data = data(I);
    ev.ts = ev.ts(I);
    info.eventId = info.eventId(I);
    
        
    
    % format event times
    ev.state = zeros(length(ev.ts),1);
    uEvents = unique(data);
    for i = 1:length(uEvents)
        ev.state(info.eventId == 1 & data == i-1) = i;
        ev.state(info.eventId == 0 & data == i-1) = -i;
    end
    
    
    % % plotting
    % hold on
    % stimOn = ev.ts(ev.state == 1);
    % lickOn = ev.ts(ev.state == 2);
    % plot(stimOn(2:end),diff(stimOn),'.k')
    % plot(lickOn(2:end),diff(lickOn),'.r')
    % hold off
end

% flag for when the right message isn't found
noMsgFlag = false;

% check for a recording info file
recInfo = fullfile(root,'recInfo.mat');
if ~exist(recInfo,'file')
    
    % get the recording start time and sample rate
    if binFlag
        % if its a binary recording
        fn = [root filesep 'sync_messages.txt'];
        [startTime, fs] = getRecInfo(fn);
        
    else
        % if its openEphys format
        fn = fullfile(root,'messages.events');
        fid = fopen(fn,'r');
        messages_text = textscan(fid,'%d %s', 'delimiter',{'\n'});
        fclose(fid);
        sIdx = contains(messages_text{2},'start time');
        startTime = double(messages_text{1}(sIdx));
        fsIdx = contains(messages_text{2},'Processor');
        s = strfind(messages_text{2}(fsIdx),'@');
        fs = vertcat(messages_text{2}{fsIdx});
        fs = str2num(fs(1,s{1}+1:end-2));
        
        
        % print messages and timestamps
        for i = 1:length(messages_text{2})
            fprintf('\t%d %d %s\n',i,messages_text{1}(i),messages_text{2}{i});
        end
        ind = input(sprintf('\tEnter the index of the desired start event: '));
        blockStart = messages_text{1}(ind) / fs;
        msgtext = messages_text;
        
    end

    if binFlag
        % text messages... need to extract from binary, its a pain...
        msgPath = [root filesep 'events' filesep 'Message_Center-904.0'];
        msgDir = dir([msgPath filesep '*TEXT*']);
        if strcmp(msgDir.name,'TEXT_group_1')
            % if manual events were actually written, extract them
            d = fullfile(msgPath,msgDir.name);
            fnm = fullfile(d,'text.npy');
            fnt = fullfile(d,'timestamps.npy');
            [msgtxt, ts] = getRecMessages(fnm,fnt);
            tss = ts / fs;
            ind = input(...
                sprintf('\tEnter the index of the desired start event\n(press ESC if not displayed): '));
            if ~isempty(ind)
                blockStart = tss(ind);
                msgtext{1}(:) = ts;
                msgtext{2} = msgtxt;
            else
                noMsgFlag = true;
            end
        end
            
        if ~strcmp(msgDir.name,'TEXT_group_1') | noMsgFlag
            % messages were not recorded, manually specify event index to
            % use
            f = figure;
            hold on
            lickOns = ev.ts(ev.state==2)/fs;
            plot(lickOns(1:end-1),diff(lickOns),'r.');
            stimOns = ev.ts(ev.state==1)/fs;
            plot(stimOns(1:end-1),diff(stimOns),'k.');
            %set(gca,'yscale','log');
            %set(gca,'ytick',logspace(0,log10(ceil(max(diff(stimOns)/10))*10),10))
            hold off
                        
            fprintf('Click the first event and press enter to select...\n');
            
            dcm_obj = datacursormode(f);
            while 1
                set(dcm_obj,'DisplayStyle','datatip',...
                            'SnapToDataVertex','off','Enable','on');
                w = waitforbuttonpress;
                key = get(gcf,'currentcharacter');
                if key == 13
                    c_info = getCursorInfo(dcm_obj);
                    ind = c_info.DataIndex;
                    break;
                end
            end
            blockStart = stimOns(ind);
            close(f);
            msgtext = [];
        end
    end
    if ~isempty(blockStart);
        save(recInfo,'blockStart','startTime','fs','msgtext');
    else
        error('Didn''t get the block start');
    end
else
    load(recInfo);
end

% convert to seconds if binary file
if binFlag
    ev.ts = ev.ts/fs;
end