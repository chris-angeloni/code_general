function [ln] = predictLN(stimulus,spikes,ln,ops)

%% function [ln] = predictLN(stimulus,spikes,ln,ops)
%
% Tests a previously fitted linear-nonlinear model to spike data by
% using the model fit to the training data (lnr) to fit to held out
% test data, indexed in ops.index

if ~isfield(ops,'index') | isempty(ops.index)
    ops.index = ones(size(spikes));
end

% index the spikes and stimulus
spikes = spikes(ops.index);
stimulus = stimulus(:,ops.index);

if isempty(ops.index)
    fprintf('ERROR in predictLN.m: index is empty!\n');
    keyboard
end

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

% make the linear prediction
ylin = convStimSTA(stimulus,ln.sta,'full');

% transform by the nonlinearity fitted previously
yhat = ln.model(ln.ahat,ylin);

% limit to between 0 and max FR observed
mx = max(spikes);
yhat(yhat>mx) = mx;
yhat(yhat<0) = 0;


% make a shuffled prediction if selected
if isfield(ops,'shuffle') & ~isempty(ops.shuffle)
    
    yhatshuff = zeros(ops.shuffle,length(stimulus));
    mse = zeros(ops.shuffle,1);
    r = mse;
    for i = 1:ops.shuffle
        I = randperm(length(stimulus));
        ylinshuff = convStimSTA(stimulus(:,I),ln.sta,'full');
        yhatshuff(i,:) = ops.model(ln.ahat,ylinshuff);
        mse(i) = mean((spikes-yhatshuff(i,:)).^2);
        r(i) = corr(spikes',yhatshuff(i,:)');
        
    end

    ln.yhatshuff = yhatshuff;
    ln.MSEshuff = mse;
    ln.rshuff = r;
    
end

if isempty(yhat) | isempty(spikes)
    fprintf('ERROR in predictLN.m: prediction is empty!\n');
    keyboard
end

% results
ln.ylintest = ylin;
ln.yhat = yhat;
ln.y = spikes;
ln.MSE = mean((spikes-yhat).^2);
ln.r = corr(spikes',yhat');
ln.ops = ops;
