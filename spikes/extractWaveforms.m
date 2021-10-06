function wave = extractWaveforms(root);

% waveform data
waveFile = fullfile(root,'mean_waveforms.mat');

% label data
labelFile = fullfile(root,'cluster_group.tsv');
if ~exist(labelFile)
    labelFile = fullfile(root,'cluster_groups.csv');
    if ~exist(labelFile)
        labelFile = fullfile(root,'cluster_KSLabel.tsv');
        warning(['No curated data found, type dbcont to use continue with kilosort ' ...
                 'clusters...']);
        keyboard
        if ~exist(labelFile)
            error('No sorted data found!');
        end
    end
end

if contains(labelFile,'.tsv')
    tmp = importdata(labelFile,'\t');
elseif contains(labelFile,'.csv')
    tmp = importdata(labelFile,',');
end

% index cells that aren't noise
labels = tmp(2:end);
q = ~contains(labels,'noise');

% assume fs is 30000Hz
params.fs = 30e3;

if exist(waveFile)
    
    fprintf('\tAdding waveforms!\n'); 
    
    % load waveforms
    wv = load(waveFile);
    
    % unit index
    I = q>0;
    
    % add indexed vars to data structure
    if isfield(wv,'chanMap')
        data.wave.chanMap = wv.chanMap;
    else
        data.wave.chanMap =[];
    end
    data.wave.waveform = wv.mw(I,:,:);
    data.wave.max = wv.mx(I,:);
    data.wave.noise_level = wv.noise_level;
    data.wave.percentile95 = wv.s95(I,:,:,:);
    data.wave.spkcount = wv.sn(I)';
    data.wave.snr = wv.snr(I,:);
    data.wave.stddev = wv.sw(I,:,:);
    data.wave.peak = max(abs(data.wave.waveform),[],3);
    [~,data.wave.peakchan] = max(data.wave.peak,[],2);
    for i = 1:size(data.wave.waveform,1)
        
        % waveform
        mxwave = squeeze(data.wave.waveform(i,data.wave.peakchan(i),:));
        
        % interpolate
        t0 = (1:length(mxwave)) / params.fs;
        t1 = linspace(t0(1),t0(end),1000);
        mxwave1 = interp1(t0,mxwave,t1,'pchip');
        
        % get the trough, post-spike peak, post-spike inflection
        [trVal,trI] = min(mxwave1);
        tmp = mxwave1; tmp(1:trI) = nan;
        [pkVal,pkI] = max(tmp);
        tmp = mxwave1; tmp(1:pkI) = nan;
        [infVal,infI] = min(abs(tmp-0));
        
        % full width half min
        hm = trVal / 2;
        tmp = mxwave1-hm; tmp(1:trI) = nan;
        [~,hI(1)] = min(abs(tmp-0));
        tmp = mxwave1-hm; tmp(trI:end) = nan;
        [~,hI(2)] = min(abs(tmp-0));
        
        data.wave.peakwaveform(i,:) = mxwave;
        data.wave.trough_peak(i,1) = (t1(pkI) - t1(trI));
        data.wave.peak_inflect(i,1) = (t1(infI) - t1(pkI));
        data.wave.FWHM(i,1) = abs(diff(t1(hI(1:2))));
        data.wave.fs = params.fs;
        
    end
    
    
else
    
    nu = sum(q>0);
    
    fprintf('\tNo waveforms...\n');
    data.wave.chanMap = [];
    data.wave.waveform = [];
    data.wave.max = [];
    data.wave.noise_level = [];
    data.wave.percentile95 = [];
    data.wave.spkcount = nan(nu,1);
    data.wave.snr = [];
    data.wave.stddev = [];
    data.wave.peak = [];
    data.wave.peakchan = nan(nu,1);
    data.wave.peakwaveform = nan(nu,63);
    data.wave.trough_peak = nan(nu,1);
    data.wave.peak_inflect = nan(nu,1);
    data.wave.FWHM = nan(nu,1);
    data.wave.fs = nan(1,1);

    
end

wave = data.wave;
