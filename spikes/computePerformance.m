function [hr,fa,dp,pc,goodIdx] = computePerformance(resp,ttype,crit)
    
%% function [hr,fa,dp,pc] = computePerformance(resp,ttype,truncate)
% 
% This function takes a vector of "yes/no" responses [resp] and a
% vector of "present/absent" trials [ttype] to compute the hit rate, false
% alarm rate, dprime index and overall percent correct. Optionally,
% if truncate is set to true, it attempts to remove trials in which
% the subject has stopped responding due to fatigue or satiety near
% the end of the run, by counting the number of responses from the
% end of the run and stopping when it hits a certain criterion lick
% count provided by [crit]
    
% Truncate based on responses to get rid of the end where mice
% doesn't lick
if nargin == 3
    startv = 10;
    count_back = sum(resp) - cumsum(resp);
    endnum = find(count_back == crit);
    endv = endnum(1);
    
    goodIdx = zeros(1,length(resp));
    goodIdx(startv:endv) = 1;
    
    resp = resp(startv:endv);
    ttype = ttype(startv:endv);
else
    goodIdx = ones(1,length(resp));
end

% Compute stats
pc = mean(resp == ttype);
hr = mean(resp(ttype==1));
fa = mean(resp(ttype==0));

% Correct for perfect hr/fa
hr1 = hr;
fa1 = fa;
if hr1 == 1
    hr1 = .999;
end
if fa1 == 0
    fa1 = .001;
end
dp = norminv(hr1) - norminv(fa1);