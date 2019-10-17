function [auc,p,dp,aucShuff,aucPct,hits,fas] = bootROC(nSpks,sSpks,n);

% for now, just analyze signal and noise trials so that we have
% enough reps
[hits, fas, auc, dp] = computeROC(nSpks,sSpks);

% bootstrapped simulation
iterations = 2000;
if ~exist('n','var')
    n(1) = length(nSpks);
    n(2) = length(sSpks);
else
    n(1) = n;
    n(2) = n;
end

crits = linspace(min([nSpks; sSpks]),max([nSpks; sSpks]),100);
for i = 1:iterations
    nSamp = randsample(nSpks,n(1),true);
    sSamp = randsample(sSpks,n(2),true);
    [tp(i,:),fp(i,:),aucShuff(i)] = computeROC(nSamp,sSamp,crits);
end

% compute percentile
% p = 1 - sum(auc>aucShuff) / iterations;
idx = find(sort(aucShuff) > .5,1,'first');
if isempty(idx)
    p = 1;
else
    p = idx / iterations;
end

% compute 95% confidence interval
aucPct = prctile(aucShuff,[2.5 97.5]);