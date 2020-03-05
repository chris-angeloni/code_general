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


if isempty(ops.index) | ~isfield(ops,'index')
    ops.index = ones(size(spikes));
end

% index the spikes and stimulus
spikes = spikes(ops.index);
stimulus = stimulus(:,ops.index);

% if no sta
if isempty(ops.sta) | ~isfield(ops,'sta')
    
    keyboard
    
    % check for sta parameters
    if (isempty(ops.fs) | ~isfield(ops,'fs'))
        ops.fs = 1000;
    end
    if (isempty(ops.w) | ~isfield(ops,'w'))
        ops.w = .1;
        ops.t = (-ops.w:1/ops.fs:0) * 1000;
    end
    if (isempty(ops.f) | ~isfield(ops,'f'))
        ops.f = [];
        warning('No frequency (ops.f) specified for the STA!');
    end

    % make sta
    STA = genSTA(find(spikes>0),stimulus,ops.w,ops.fs);
    STA = STA - mean(STA(:));
    STA = STA ./ sqrt(sum(STA(:).^2));
    ops.sta = STA;
end

% check nonlinearity parameters
if (isempty(ops.nbins) | ~isfield(ops,'nbins'))
    ops.nbins = 50;
end
if (isempty(ops.weight) | ~isfield(ops,'weight'))
    ops.weight = false;
end

% check for spike smoothing
if ~(isempty(ops.sigma) | isfield(ops,'sigma'))
    
    % check for sample rate
    if (isempty(ops.fs) | ~isfield(ops,'fs'))
        error('To smooth, provide a sample rate in ops.fs!');;
    end
    
    tmp = conv(spikes,...
               normpdf(-6*ops.sigma*ops.fs:6*ops.sigma*ops.fs,0,ops.sigma*ops.fs) * ops.fs,'full');
    tmp = tmp(1:length(spikes));
    spikes = tmp;
else
    spikes = spikes * ops.fs;
end


% make a linear prediction
ylin = convStimSTA(stimulus,ops.sta,'full');

% fit the nonlinearity
[x1,y1,nmdl,ahat] = estNLFR(spikes,ylin,ops.nbins,ops.weight,ops.modelType,ops.includeZeros);

% outputs
ln.sta = ops.sta;
ln.xy = [x1' y1'];
ln.ahat = ahat;
ln.spikes = spikes;
ln.ylin = ylin;

ops.model = nmdl;






