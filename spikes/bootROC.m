function [auc,p,dp,aucShuff,aucPct,hits,fas,sig] = bootROC(nSpks,sSpks,n,its);

%% function [auc,p,dp,aucShuff,aucPct,hits,fas,sig] = bootROC(nSpks,sSpks,n,its);
%
% computes a bootstrapped estimate of the areau under the ROC curve

% base ROC value
[hits, fas, auc, dp] = computeROC(nSpks,sSpks);

% bootstrapped simulation
if ~exist('its','var') | isempty(its)
    its = 1000;
end

if ~exist('n','var')
    n(1) = length(nSpks);
    n(2) = length(sSpks);
else
    n(1) = n;
    n(2) = n;
end

crits = linspace(min([nSpks; sSpks]),max([nSpks; sSpks]),100);
for i = 1:its
    nSamp = randsample(nSpks,n(1),true);
    sSamp = randsample(sSpks,n(2),true);
    [tp(i,:),fp(i,:),aucShuff(i)] = computeROC(nSamp,sSamp,crits);
end

% compute percentile of chance in the shuffled distribution
% p = 1 - sum(auc>aucShuff) / iterations;
p = getPercentile(aucShuff,.5);

% compute 95% confidence interval
aucPct = prctile(aucShuff,[2.5 97.5]);

% compute significance (ie. if the shuffled distribution includes
% chance below 95%)
sig = ~(.5 >= aucPct(1) & .5 <= aucPct(2));











function x = getPercentile(data,val)

%% function x = getPercentile(data,val)
%
% returns percentile of value in distribution data

perc = prctile(data,0:.01:100);
[c index] = min(abs(perc'-val));
x = (index + 1) / 10000;