function [ln,ops] = fitLN(stimulus,spikes,ops)

%% function ln = fitLN(stimulus,spikes,ops)
%
% Fits a linear-nonlinear model to spike data by making a linear
% convolution of the spike triggered average with the stimulus,
% then using histogram equalization (sort of) of the predicted
% response to the observed spike rates to estimate the neural
% nonlinearities.
%
% INPUTS:
%  stimulus: stimulus matrix sampled to the model sample rate (nFreqs x nTimes)
%  spikes:   spike vector sampled to the model sample rate
%  ops:      options structure, see notes below
%
%  ops.fs = 1000;      % model sample rate (only needed if no sta provided)
%  ops.w = .1;         % sta window (only needed if no sta provided)
%  ops.f = f;          % sta frequencies (only needed if no sta provided)
%  ops.t = t;          % sta time (only needed if no sta provided)
%  ops.nbins = 50;     % number of histogram bins for nonlinearity
%  ops.weight = false; % weighted fit of nonlinearity
%  ops.sigma = .0025;  % smoothing parameter for the spike vector (optional)
%  ops.index = index;  % index to use for fitting
%  ops.sta = sta;      % spike triggered average (optional, if not provided will make one)
%  opa.modelType = []; % 'exponential' or 'sigmoid'
%
% OUTPUTS:
%  ln: a struct with the model components (see below)
%  ops: return of the ops struct, if empty entries were changed
%
%  ln.sta = sta;          % spike triggered average used
%  ln.xy = [x1' y1'];     % x and y values for fitting the nonlinearity
%  ln.model = nmdl;       % model fit for nonlinearity
%  ln.ahat = ahat;        % fit parameters
%  ln.spikes = spikes;    % spikes used (indexed)
%  ln.ylin = ylin;        % linear prediction used (indexed)


if ~isfield(ops,'index') | isempty(ops.index)
    ops.index = ones(size(spikes));
end

% index the spikes
spikes = spikes(ops.index);

% if no sta
if ~isfield(ops,'sta') | isempty(ops.sta)
    
    error('NO FILTER PROVIDED!')
    
end

% check nonlinearity parameters
if ~isfield(ops,'nbins') | isempty(ops.nbins)
    ops.nbins = 50;
end
if ~isfield(ops,'weight') | isempty(ops.weight)
    ops.weight = false;
end

% check for spike smoothing
if isfield(ops,'sigma') & ~isempty(ops.sigma)
        
    % check for sample rate
    if ~isfield(ops,'fs') | isempty(ops.fs)
        error('To smooth, provide a sample rate in ops.fs!');;
    end
    
    % make the smoothing kernel
    kernel = normpdf(-6*ops.sigma*ops.fs:6*ops.sigma*ops.fs,0, ...
                       ops.sigma*ops.fs) * ops.fs;
    
    % smooth
    tmp = conv(spikes,kernel,'full');
    
    % take only valid portion
    if mod(length(kernel),2)
        tmp = tmp(floor(length(kernel)/2)+1:...
                  end-floor(length(kernel)/2));
    else
        tmp = tmp(floor(length(kernel)/2):...
                  end-floor(length(kernel)/2));
    end
    spikes = tmp;
    
else
    spikes = spikes * ops.fs;
end

% if the sta is all nans, use a random sta
if any(isnan(ops.sta))
    ops.sta = rand(size(ops.sta));
    ops.sta = normSTA(ops.sta);
end

% make a linear prediction for the whole stimulus, then index
ylin = convStimSTA(stimulus,ops.sta,'full');
ylin = ylin(ops.index);

% fit the nonlinearity
[x1,y1,nmdl,ahat] = estNL_minfun(ylin,spikes/ops.fs,ops); 
%[x1,y1,nmdl,ahat] = estNL(ylin,spikes/ops.fs,ops);

% outputs
ln.sta = ops.sta;
ln.xy = [x1' y1'];
ln.ahat = ahat;
ln.model = nmdl;
ln.spikes = spikes;
ln.ylin = ylin;

ops.model = nmdl;






