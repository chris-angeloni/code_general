function makeBlockTemplates(stimDir)
%% format for a block template
%
% template{n}{1} = stimEvent differences, rounded to the nearest ms
% template{n}{2} = laserEvent differences, rounded to the nearest
% ms

%% wav file list

if nargin < 1
    stimDir = '~/chris-lab/projects/stimuli/_forTemplates/';
end
fileList = dir(fullfile(stimDir,'*.wav'));

for i = 1:length(fileList)
    fprintf('Making template %d/%d %s\n',i,length(fileList),fileList(i).name);
    
    % file stuff
    template(i).fileName = fullfile(fileList(i).folder, ...
                                    fileList(i).name);
    template(i).name = fileList(i).name;
    
    % load stim info if present
    [fp, fn] = fileparts(template(i).fileName);
    fnStimInfo1 = fullfile(fp,[fn '_stimInfo.mat']);
    fnStimInfo2 = fullfile(fp,[fn '-stimInfo.mat']);
    if exist(fnStimInfo1,'file')
        stimInfo = load(fnStimInfo1);
    elseif exist(fnStimInfo2,'file')
        stimInfo = load(fnStimInfo2);
    else
        stimInfo = [];
    end
    template(i).stimInfo = stimInfo;
    
    % load wav file, and get diffs for stim and laser events
    [s,fs] = audioread(template(i).fileName);
    template(i).fs = fs;
    
    % get time to each event
    s = [zeros(1,size(s,2)); s];
    ts = find(diff(s(:,2))~=0) / fs;
    
    % stim diffs, rounded to the nearest ms
    ds = round(diff(ts),3);
    
    % laser diffs, if present
    if size(s,2) == 3
        tl = find(diff(s(:,3))~=0) / fs;
        dl = round(diff(tl),3);
    else
        tl = [];
        dl = [];
    end
    
    % mark whether this includes stim and laser events
    template(i).presentStim = [~isempty(ds) ~isempty(dl)];
    
    % mark total stim length for making repeats
    template(i).stimLength = length(s);
        
    % write out events
    template(i).times{1} = ts;
    template(i).times{2} = tl;
    template(i).diffs{1} = ds;
    template(i).diffs{2} = dl;
    
end

currPath = which('makeBlockTemplates.m');
strs = strsplit(currPath,filesep);
currPath = strjoin(strs(1:end-1),filesep);
templateDir = fullfile(currPath,'blockTemplates.mat');
save(templateDir,'template');




%  %% optotag pulses, 100 reps
%  templateStr{1} = 'optoTag1ms';
%  template{1}{1} = [];
%  template{1}{2} = ones(1,100) * .001;
%  
%  templateStr{2} = 'optoTag2ms';
%  template{2}{1} = [];
%  template{2}{2} = ones(1,100) * .002;
%  
%  templateStr{3} = 'optoTag5ms';
%  template{3}{1} = [];
%  template{3}{2} = ones(1,100) * .005;
%  
%  templateStr{4} = 'optoTag10ms';
%  template{4}{1} = [];
%  template{4}{2} = ones(1,100) * .010;
%  
%  templateStr{5} = 'optoTag25ms';
%  template{5}{1} = [];
%  template{5}{2} = ones(1,100) * .025;
%  
%  templateStr{6} = 'optoTag100ms';
%  template{6}{1} = [];
%  template{6}{2} = ones(1,100) * .100;
%  
%  
%  %% alternating contrast, no laser
%  templateStr{7} = 'altContrast';
%  template{7}{1} = ones(1,1199) * 3.0;
%  template{7}{2} = [];
%  
%  templateStr{8} = 'altContrast_sync';
%  template{8}{1} = ones(1,1200) * 3.0;
%  template{8}{2} = [];
%  
%  %% alternating contrast, with laser
%  templateStr{9} = 'altContrast_pulsed_laser_2rep';
%  template{9}{1} = ones(1,599) * 3.0;
%  template{9}{2} = ones(1,14999) * 0.04;
%  template{9}{2}(75:75:14925) = 6.04;
%  
%  
%  %% ripples
%  % are annoying, forget them for now
%  
%  
%  %% clicks with laser (10 powers, from 0-5, 20 reps)
%  templateStr{10} = 'clicksLaser_10pow_0-5V_20rep';
%  template{10}{1} = ones(1,199) * 2;
%  template{10}{2} = ones(1,179) * 2; 
%  template{10}{2}([4 5 15 16 33 37 38 42 46 53 59 77 90 101 109 120 ...
%                   137 141 169]) = 4;
%  
%  %% contrastTargets
%  templateStr{11} = 'contrastTargets';
%  template{11}{1} = ds4'; % see code below
%  template{11}{2} = [];
%  
%  templateDir = '~/chris-lab/code_general/blockTemplates.mat';
%  
%  save(templateDir,'template','templateStr');









%  %% code to find some values
%  root = '/Users/chris/data/kilosort/CA116/2020-02-11_14-01-27/experiment1/recording1';
%  [ev,blockStart,startTime,msgtext,fs,~] = ...
%               loadEventData(root,'recInfo.mat');
%  laserOn = ev.ts(ev.state == 4) - startTime/fs;
%  stimOn = ev.ts(ev.state == 1) - startTime/fs;
%  
%  stim = ev.ts(ev.state == 1 | ev.state == -1) - startTime/fs;
%  laser = ev.ts(ev.state == 4 | ev.state == -4) - startTime/fs;
%  
%  ds = round(diff(stim),3);
%  dl = round(diff(laser),3);

%  
%  stimDur = ev.ts(ev.state == -1) - ev.ts(ev.state == 1);
%  blockI = find(round(stimDur,1)==.1);
%  
%  dl = round(diff(laserOn),3);
%  ds = round(diff(stimOn),3);
%  
%  % clicks w. laser
%  block2I = laserOn>stimOn(blockI(2)) & laserOn<stimOn(blockI(3));
%  block2IStim = stimOn>stimOn(blockI(2)) & stimOn<stimOn(blockI(3));
%  ds2 = round(diff(stimOn(block2IStim)),3);
%  dl2 = round(diff(laserOn(block2I)),3);
%  
%  strfind(dl',template{10}{2})
%  strfind(ds',template{10}{1})
%  
%  % two contrast blocks with laser
%  block3I = laserOn>stimOn(blockI(3)) & laserOn<stimOn(blockI(4));
%  block3IStim = stimOn>stimOn(blockI(3)) & stimOn<stimOn(blockI(4));
%  ds3 = round(diff(stimOn(block3IStim)),3);
%  dl3 = round(diff(laserOn(block3I)),3);
%  
%  strfind(dl',template{9}{2})
%  strfind(ds',template{9}{1})
%  
%  % contrast targets
%  block4I = stimOn>stimOn(blockI(5));
%  ds4 = round(diff(stimOn(block4I)),3);
%  
%  strfind(dl',template{11}{2})
%  strfind(ds',template{11}{1})


