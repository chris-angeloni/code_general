function x = getPercentile(data,val)

%% function x = getPercentile(data,val)
%
% returns percentile of value in distribution data

perc = prctile(data,0:.01:100);
[c index] = min(abs(perc'-val));
x = (index + 1) / 10000;