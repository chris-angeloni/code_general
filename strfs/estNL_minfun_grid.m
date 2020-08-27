function [x,y,mdl,ahat,mfit] = estNL_minfun_grid(x,y,ops);

%% function [x,y,mdl,ahat,mfit] = estNL_minfun_grid(x,y,ops);
%
% this function fits an exponential to predicted versus measured
% firing rates to estimate a neurons nonlinearity using grid search
% and minfun (fast compiled fitting tool)
%
% INPUT:
%  x: linear convolution prediction
%  y: actual spike histogram (** NEEDS TO BE IN SPIKE COUNTS **)
%  ops: struct with fitting options
%  ops.nbins: number of histogram bins to use
%  ops.fs: sampling rate
%  ops.weighting: weighted fit or not (true/false)
%  ops.model: model type ('exponential','sigmoid')
%  ops.includeZero: include bins with 0 fr in fit (true/false)
%
% OUTPUT:
%  x: prediction bins
%  y: binned fr
%  mdl: function handle for exponential
%  ahat: model parameters from fitting
%  mfit: minfunc fit

warning off
x0 = x;
y0 = y;

% check for inputs
if ~isfield(ops,'fs') | isempty(ops.fs)
    error('Must supply sampling rate in ops.fs!');
end
if ~isfield(ops,'nbins') | isempty(ops.nbins)
    ops.nbins = 50;
end
if ~isfield(ops,'weighting') | isempty(ops.weighting)
    ops.weighting = true;
end
if ~isfield(ops,'model') | isempty(ops.model)
    ops.model = 'exponential';
end
if ~isfield(ops,'includeZero') | isempty(ops.includeZero)
    ops.includeZero = true;
end

%% histogram eq
% bin the linear prediction with default binning
[n,edges,bins] = histcounts(x,ops.nbins);

% count spikes in each bin
nl = zeros(1,max(bins));
for i = 1:length(nl)
    nl(i) = sum(y(bins == i));
end

% total time for each bin
bt = (1/ops.fs) * n;

% firing rate per bin (nspikes / bin time)
y = nl ./ bt;

% bin centers
x = edges(1:end-1) - diff(edges)/2;

% if specified, remove values above the mean that are 0
if ~ops.includeZero
    y(y==0 & x>0) = nan;
end

% force weights with no values to 1
n(n==0) = 1;

% remove nans
x(isnan(y)) = [];
n(isnan(y)) = [];
y(isnan(y)) = [];

if ~logical(ops.weighting)
    % if we're not weighting, set all the weights to be the same
    n = ones(size(n));
    xf = x; yf = y;
else
    % otherwise, weight everything by repmatting
    xf = []; yf = [];
    for i = 1:length(n)
        xf = [xf; repmat(x(i),n(i),1)];
        yf = [yf; repmat(y(i),n(i),1)];
    end
end


%% model setup
if strcmp(ops.model,'exponential')
    % exponential model
    mdl = @(a,x)(a(1) + a(2)*exp((x-a(4))*a(3)));
    
    % starting parameters
    a0 = [repmat(min(yf),5,1) linspace(10,.001,5)' linspace(1,.01,5)' repmat(mean(xf),5,1)];
    
elseif strcmp(ops.model,'sigmoid')
    % sigmoid model
    mdl = @(a,x)(a(1) + a(2) ./ (1 + exp(-(x-a(4)).*a(3))));
    
    % starting parameters
    a0 = [repmat(min(yf),5,1) linspace(max(yf),min(yf),5)' linspace(2,.01,5)' repmat(mean(xf),5,1)];
    
end

if isempty(yf) | isempty(xf)
    error('x or y is empty!');
    
elseif any(isnan([yf(:); xf(:)]))
    fprintf('Found nan!')
    keyboard
    
else
    
    % fit using minfun
    options = [];
    options.display = 'none';
    options.numDiff = 1;
            
    % unique parameter grid
    u1 = unique(a0(:,1));
    u2 = unique(a0(:,2));
    u3 = unique(a0(:,3));
    u4 = unique(a0(:,4));

    
    % try fmincon grid search
    try
        
        % grid search
        clear ah fv ef o;
        for i = 1:length(u1)
            for j = 1:length(u2)
                for k = 1:length(u3)
                    for ii = 1:length(u4)
                        
                        if strcmp(ops.model,'exponential')
                            p0 = [a0(i,1) a0(j,2) a0(k,3) a0(ii,4)]';
                        else
                            p0 = [a0(i,1) a0(j,2) a0(k,3) a0(ii,4)]';
                        end
                        [ah(:,i,j,k,ii),fv(i,j,k,ii),ef(i,j,k,ii)] = ...
                            minFunc(@(a)(norm(yf'-mdl(a,xf'))),p0,options);
                        
                    end
                end
            end
        end
                
        % find starting parameters yielding the best fit
        [~,mi] = min(fv(:));
        [i,j,k,ii] = ind2sub(size(fv),mi);
        
        % failure case
        if sum(ef(:)>0) == 0
            fprintf(['Grid search failed to converge... fit using ' ...
                     'basic params']);
             
            if strcmp(ops.model,'exponential')
                a0 = [min(y); .5; .1; 0];
            else
                a0 = [min(y); .5; .01; 0];
            end
            
            % fit using minFunc
            options = [];
            options.display = 'none';
            options.numDiff = 1;
            [ahat,f,exitflag,output] = minFunc(@(a)(norm(yf'-mdl(a,xf'))), ...
                                               a0,options);
            
            if exitflag < 1
                fprintf('Ugh, still not fit... use current ahat...\n');
                
            else
                fprintf('it worked!\n');
                
            end
            
        else
            % output parameters
            ahat = ah(:,i,j,k,ii);
            
        end
        
        
        
    catch ME
        rethrow(ME);
        keyboard
        
    end
    
end



