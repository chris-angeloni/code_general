function [ts,templateName,reps] = matchMessagesToTemplates(events,template,fn)

msgs = events.msgtext{2};
wavFiles = {template.name};

% for each message
cnt = 1;
while cnt <= length(msgs)
    
    % print all messages, marking the current one
    fprintf('\n\nBLOCK MESSAGES (%s)\n',fn)
    for i = 1:length(msgs)
        tag = '';
        if i == cnt
            tag = '*******';
        end
        fprintf('   %d: %s%s%s\n',i,tag,msgs{i},tag)
    end 
        
    % compute edit distance to template names
    for i = 1:length(wavFiles)
        ed(i) = EditDist(msgs{cnt},wavFiles{i});
    end
    
    % print the top 5 template names
    [sed,si] = sort(ed);
    fprintf('\n\nCLOSEST MATCHING TEMPLATE (press number to select choice)\n')
    for i = 1:5
        fprintf('   %d: %s (ed = %d)\n',i,wavFiles{si(i)},ed(si(i)))';
    end
    fprintf('   %d: Ignore block.\n',i+1);
    fprintf('   %d: Select another template.\n',i+2);  
    select = input('Template selection: ');
    
    % selection logic
    if select == 6
        reps(cnt) = nan;
        ts(cnt) = nan;
        templateName{cnt} = nan;
    elseif select == 7
        fprintf('\n\nSELECT TEMPLATE (press number to select choice)');
        for i = 1:length(wavFiles)
            fprintf('\t%d: %s\n',i,wavFiles{i});
        end
        select = input('Template selection: ');
        reps(cnt) = input('How many repeats?: ');
        ts(cnt) = events.msgtext{1}(cnt);
        templateName{cnt} = wavFiles{select};
    elseif select > 7 | select < 1
        fprintf('Must select a template or ignore block!\n');
        continue;
    else
        reps(cnt) = input('How many repeats?: ');
        ts(cnt) = events.msgtext{1}(cnt);
        templateName{cnt} = wavFiles{si(select)};
    end
   
    cnt = cnt + 1;
end

ts = (ts - events.recStart) / 30e3;

save(fn,'reps','ts','templateName');