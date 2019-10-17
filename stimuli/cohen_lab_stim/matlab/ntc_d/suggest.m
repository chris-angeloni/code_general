function [edges, edgeAmps] = suggest()
%function [edges edgeAmps] = suggest
%
% suggest bandedges for tuning curve

global dataMat fMin nOctaves extAtten

INCLUDE_DEFS;

% edgeThresh is the threshold for the edge of the tuning curve (in spikes)
edgeThresh = EDGE_DETECT_THRESH;

% CF must be set before calling this routine
thresh = getNewAttribute(THRESHOLD);
logCF = log10(getNewAttribute(CF));

% determine levels at which to estimate edges
[dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
edgeAmps = ((thresh+10):10:min(thresh+40,dispAmps(end)))';
numLevels = length(edgeAmps);

% set up stuff to interpolate data at appropriate levels 
logFreqs = log10(dispFreqs);

[X,Y] = meshgrid(dispFreqs,dispAmps);
Z = dataMat';
XI = dispFreqs;
YI = edgeAmps;
[XI,YI] = meshgrid(XI,YI);

% and interpolate away...
ZI = interp2(X,Y,Z, XI,YI)';

logEdges = zeros(numLevels,2);
logMiddleGuess = logCF;
for ii=1:numLevels,
  % first fit data to a difference of two logistic functions
  [ZIFx PValsx] = bumpFit(logFreqs, ZI(:,ii), logMiddleGuess);
  % make an initial guess at where the left edge should be based on 
  %   the left logistic function
  xStart = fzero(...
      ['logist(x, [' num2str(PValsx(1:3)) '])-' num2str(edgeThresh)], ...
        PValsx(3));
  % and now zero in on the edge using the full difference of two logistic fcn's
  logEdges(ii,1) = fzero(...
      ['bilogist(x, [' num2str(PValsx) '])-' num2str(edgeThresh)], ...
        xStart)
  % now do the same procedure for the right edge...
  xStart = fzero(...
      ['logist(x, [' num2str([PValsx(1) PValsx(4) PValsx(3)+PValsx(5)]) ...
         '])-' num2str(edgeThresh)], ...
        PValsx(3)+PValsx(5));
  logEdges(ii,2) = fzero(...
      ['bilogist(x, [' num2str(PValsx) '])-' num2str(edgeThresh)], ...
        xStart)
  logMiddleGuess = mean(logEdges(ii,:));
  end % (for)

% clip guess for edges at edge of display (i.e., don't extrapolate beyond data)
logEdges(:,1) = max([logEdges(:,1) logFreqs(ones(numLevels,1),1)],   [], 2);
logEdges(:,2) = min([logEdges(:,2) logFreqs(ones(numLevels,1),end)], [], 2);
edges = 10 .^ logEdges;

% plot the edges on the axes
htc=findobj('tag','TuningCurveAxes');
axes(htc)
hold on

plotEdges = [edges(end:-1:1,2); 10^logCF; edges(:,1)]
plotAmps = [YI(end:-1:1,1); thresh; YI(:,1)]
plot(plotEdges, plotAmps, 'mx');

return
