function [x,y,mdl,ahat,mfit] = estNL_minfun(x,y,ops);

%% function [x,y,mdl,ahat,mfit] = estNL_minfun(x,y,ops);
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
    a0 = [min(yf) .01 .01 mean(x)]';
    
elseif strcmp(ops.model,'sigmoid')
    % sigmoid model
    mdl = @(a,x)(a(1) + a(2) ./ (1 + exp(-(x-a(4)).*a(3))));
    
    % starting parameters
    a0 = [min(yf) .01 .01 mean(x)]';
    
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
    [ahat,fval,err] = minFunc(@(a)(norm(yf'-mdl(a,xf'))),a0,options);
                
    
end



