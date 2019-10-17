function xTickPos = makeFreqTicks(dispFreqs)
% function xTickPos = makeFreqTicks(dispFreqs)
% 
% figure out a good set of values to use as frequency tickmarks for plot
%   (i.e., frequencies will be 1,2,5,20,50, etc.)

tickRange = 10.^(floor(log10(dispFreqs(1))):floor(log10(dispFreqs(end))));
xTickPos = [1 2 5]'*tickRange;
xTickPos = [xTickPos(:); 10*tickRange(end)];
ii = find(xTickPos>dispFreqs(1) & xTickPos<dispFreqs(end));
xTickPos = xTickPos(ii);

return
