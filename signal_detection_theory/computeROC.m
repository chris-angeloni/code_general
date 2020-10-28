function [hits, fas, AUC, dp] = computeROC(noise,signal,crits)

if ~exist('crits','var')
    crits = linspace(min([noise(:); signal(:)]),max([noise(:);signal(:)]),100);
end
for i = 1:length(crits)
    hits(i) = sum(signal > crits(i)) / length(signal);
    fas(i) = sum(noise > crits(i)) / length(noise);
end
hits = [1 hits 0];
fas = [1 fas 0];
AUC = -trapz(fas,hits);

% compute dprime within limits
if AUC > .999
    AUC = .999;
elseif AUC < .001
    AUC = .001;
end
dp = norminv(AUC)*sqrt(2);