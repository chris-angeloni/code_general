function [ln,ops] = testLN(stimulus,spikes,ln,ops)

%% function [ln,ops] = testLN(stimulus,spikes,ln,ops)
%
% Tests a previously fitted linear-nonlinear model to spike data by
% using the model fit to the training data (lnr) to fit to held out
% test data, indexed in ops.index

if isempty(ops.spikeIndex) | ~isfield(ops,'spikeIndex')
    ops.spikeIndex = ones(size(spikes));
end

if isempty(ops.stimIndex) | ~isfield(ops,'stimIndex')
    keyboard
    ops.stimIndex = ops.spikeIndex;
end

% index the spikes and stimulus
spikes = spikes(ops.spikeIndex);
stimulus = stimulus(:,ops.stimIndex);

% check for spike smoothing
if ~(isempty(ops.sigma) | ~isfield(ops,'sigma'))
    
    % check for sample rate
    if (isempty(ops.fs) | ~isfield(ops,'fs'))
        error('To smooth, provide a sample rate in ops.fs!');;
    end
    
    % smoothing kernel
    kernel = normpdf(-6*ops.sigma*ops.fs:6*ops.sigma*ops.fs,0, ...
                       ops.sigma*ops.fs) * ops.fs;
    
    % smooth
    tmp = conv(spikes,kernel,'full');
    
    % take only valid portion
    tmp = tmp(floor(length(kernel)/2):end-floor(length(kernel)/2)-1);
    spikes = tmp;
    
else
    spikes = spikes * ops.fs;
    
end



% make the linear prediction
ylin = convStimSTA(stimulus,ln.sta,'full');

% transform by the nonlinearity fitted previously
yhat = ops.model(ln.ahat,ylin);

% limit to max FR observed
mx = max(spikes);
yhat(yhat>mx) = mx;


% make a shuffled prediction if selected
if ~(isempty(ops.shuffle) | ~isfield(ops,'shuffle'))
    
    yhatshuff = zeros(ops.shuffle,length(stimulus));
    for i = 1:ops.shuffle
        I = randperm(length(stimulus));
        ylinshuff = convStimSTA(stimulus(:,I),ln.sta,'full');
        yhatshuff(i,:) = ops.model(ln.ahat,ylinshuff);
        
    end

    ln.yhatshuff = yhatshuff;
    
end

% results
ln.ytest = ylin;
ln.yhat = yhat;
ln.y = spikes;
