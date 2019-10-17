function [ev,blockStart,startTime,msgtext,fs,binFlag] = loadEventDataAcute(root,recInfo)

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
    [data,ev.ts,info] = load_open_ephys_data([eventsDir filesep ...
                        'all_channels.events']);
    binFlag = false;
    
    
    % find event onsets
    onsets = find(diff(data)==1) + 1;
    ev.state = zeros(length(ev.ts),1);
    ev.state(info.eventId == 1 & data == 0) = 1;
    ev.state(info.eventId == 1 & data == 1) = 2;
    %ev.state(onsets) = 1;
    %ev.state(ev.state == 1 & data == 2) = 2;
    
    
    % % plotting
    % hold on
    % stimOn = ev.ts(ev.state == 1);
    % lickOn = ev.ts(ev.state == 2);
    % plot(stimOn(2:end),diff(stimOn),'.k')
    % plot(lickOn(2:end),diff(lickOn),'.r')
    % hold off
end

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
        fn = fullfile(eventsDir,'messages.events');
        fid = fopen(fn,'r');
        messages_text = textscan(fid,'%d %s', 'delimiter',{'\n'});
        fclose(fid);
        sIdx = contains(messages_text{2},'start time');
        startTime = double(messages_text{1}(sIdx));
        fsIdx = contains(messages_text{2},'Processor');
        s = strfind(messages_text{2}(fsIdx),'@');
        fs = str2num(messages_text{2}{fsIdx}(s{1}+1:end-2));
        
        % print messages and timestamps
        for i = 1:length(messages_text{2})
            fprintf('%d %d %s\n',i,messages_text{1}(i),messages_text{2}{i});
        end
        ind = input('Enter the index of the desired start event: ');
        blockStart = messages_text{1}(ind) / fs;
        msgtext = messages_text{2};
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
            fprintf('RECORDING MESSAGES:\n');
            [msgtext, ts] = getRecMessages(fnm,fnt);
            tss = ts / fs;
            ind = input('Enter the index of the desired start event: ');
            blockStart = tss(ind);
        else
            % messages were not recorded, manually specify event index to
            % use
            f = figure;
            hold on
            stimOns = ev.ts(ev.state==4);
            plot(stimOns(2:end),diff(stimOns),'k.');
            axis tight
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
            blockStart = stimOns(ind+1)/fs;
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