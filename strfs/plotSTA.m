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
% plot it

% smoothing
if exist('smth','var') & ~isempty(smth)
    STA = imgaussfilt(STA,smth.*[1 2]);
end

if any(t>0)
    t = fliplr(t);
end

% find even octave labels
octs = find(mod(f,1000)==0);

% plot with imagesc
s = imagesc(t,1:length(f),STA);
set(gca,'ydir','normal'); % flip it to match frequency order
set(gca,'ytick',octs);
set(gca,'yticklabels',num2str(f(octs)'/1000));


% recale color axis
if exist('clim','var')
    caxis(clim);
end

% make it look pretty
axis tight