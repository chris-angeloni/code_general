function [displayMat, dispFreqs, dispAmps] = makeDisplayMat(...
                   dataMat, extAtten, fMin, nOctaves);
% function [displayMat, dispFreqs, dispAmps] = ...
%           makeDisplayMat(dataMat, ...
%           extAtten, fMin, nOctaves);
% 
% figure out which spikes should be displayed for this timeslice
%    delimited by min- and maxLatency
%

%--------------------------
%

global NFREQS NAMPS

%--------------------------

% pcolor, doesn't use the last row and column of the 
%    matrix for plotting, so add on extra ones.

displayMat = [dataMat, dataMat(:,NAMPS); ...
              dataMat(NFREQS,:), dataMat(NFREQS,NAMPS)];

[dispFreqs, dispAmps] = makePColorAxes(fMin, nOctaves, extAtten);

return
  
%%%---------------------

