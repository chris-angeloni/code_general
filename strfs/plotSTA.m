function [s, STA] = plotSTA(t,f,STA,smth,clim)

%% function [s, STA] = plotSTA(t,f,STA,smth,clim)
% 
% plotSTA takes a spectrotemporal receptive field and plots it in
% the correct orientation
%
% INPUTS:
%  t = time bin centers
%  f = frequency bins
%  STA = spike triggered average (low-high freq x last to first time)
%  smth = smoothing kernel width in time-freq bins (optional)
%  clim = color limit for the plot (optional)
%
% OUTPUTS:
%  s = figure handle
%
% *** NOTE: because the stimulus matrix is typically constructed
% from low to high frequency, this means that the STA is computed
% such that the lowest frequency is the top row, and the highest
% frequency is the bottom row, reversed from how you would like to
% plot it (see flipud(f) below)

% smoothing
if exist('smth','var') & ~isempty(smth)
    STA = imgaussfilt(STA,smth);
end

% surf plot (note, imagesc does not plot correctly)
s = surf(t,flipud(f),STA);

% recale axis
if exist('clim','var')
    caxis(clim);
end

% make it look pretty
s.EdgeColor = 'none';
set(gca,'yscale','log')
axis tight
view(2)
xlabel('Time (ms)');
ylabel('Frequency (kHz)');