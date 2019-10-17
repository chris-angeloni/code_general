function [PSTH,PSTHsm,time] = convRaster(raster,trials,Sigma,bin,range,nTrials)

%% function [PSTH,time] = convRaster(raster,trials,Sigma,bin,range,nTrials)

% this function takes a spike raster and convolves each trial with
% a gaussian kernel of window length [window] (in secs)

% INPUTS:

% raster: spike times
% trials: a vector the same length as spike times indicating the
%         trial number
% Sigma: the sd of the gaussian kernel (in s)
% bin: resolution (in s) at which spikes will be binned before the
%      convolution
% range: range of time values to use for PSTH binning
% nTrials: total number of expected trials in the PSTH

% build the kernel
fs = 1/bin;
x = -6*Sigma:bin:6*Sigma;
kernel = normpdf(x,0,Sigma);
kernel = kernel ./ sum(kernel) ./ fs;

if ~exist('range','var')
    edges = [floor(min(raster)/bin)*bin:bin:ceil(max(raster)/bin)*bin];
else
    if ~isempty(range)
        edges = [range(1):bin:range(2)];
    else
        edges = [floor(min(raster)/bin)*bin:bin:ceil(max(raster)/bin)*bin];
    end
end

if ~exist('nTrials','var')
    uT = unique(trials,'stable');
else
    uT = 1:nTrials;
end

PSTH = zeros(length(uT),length(edges)-1);
PSTHsm = zeros(length(uT),length(edges)-1);
for i = 1:length(uT)
    
    % extract spikes and make a PSTH
    spks = raster(trials == i);
    PSTH(i,:) = histcounts(spks,edges);
    PSTHsm(i,:) = SmoothGaus(PSTH(i,:),Sigma); % conv(PSTH(i,:),kernel,'same');
    
end

time = edges(2:end) - mean(diff(edges))/2;

%  subplot(2,1,1)
%  scatter(raster,trials,10,'.k');
%  xlim([time(1) time(end)])
%  subplot(2,1,2)
%  imagesc(time,1:length(uT),PSTH);
%  set(gca,'ydir','normal');
%  xlim([time(1) time(end)])

