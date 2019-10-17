function [dataFreqs, tickFreqs] = makeDotAxes(fMin, nOctaves);
% function [dataFreqs, tickFreqs] = makeDotAxes(fMin, nOctaves);

global NFREQS NAMPS

INCLUDE_DEFS;

% these frequencies are
%   NOT the real stimulus frequencies, but are one half-step off.

fmmax = fMin*(2^((nOctaves*(NFREQS-0.5))/(NFREQS-1)));
fmmin = fMin*(2^(nOctaves*(-0.5)/(NFREQS-1)));

dispFreqs = logspace(log10(fmmin), log10(fmmax),NFREQS*(NAMPS+1)+1);
 
tickFreqInd = 1:(NAMPS+1):(NFREQS*(NAMPS+1)+1);
dataFreqInd = ones((NFREQS*(NAMPS+1)+1),1);
dataFreqInd(tickFreqInd) = 0;

tickFreqs = dispFreqs(tickFreqInd);
dataFreqs = dispFreqs(logical(dataFreqInd));
 

return

