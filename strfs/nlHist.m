function [x,y,n] = nlHist(x,y,ops);

%% function [x,y,n] = nlHist(x,y,ops);
%
% this function bins a response prediction (x) by ops.nbins
% (default 50), and finds the firing rate in those bins from
% observed spikes (y)

% check for inputs
if ~isfield(ops,'fs') | isempty(ops.fs)
    error('Must supply sampling rate in ops.fs!');
end
if ~isfield(ops,'nbins') | isempty(ops.nbins)
    ops.nbins = 50;
end
if ~isfield(ops,'includeZero') | isempty(ops.includeZero)
    ops.includeZero = true;
end

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

% remove nans
x(isnan(y)) = [];
n(isnan(y)) = [];
y(isnan(y)) = [];