function [hr,fa,dp,pc,goodIdx,hr1,fa1] = computePerformance(resp,ttype,crit)
    
%% function [hr,fa,dp,pc,goodIdx,hr1,fa1,] = computePerformance(resp,ttype,crit)
% 
% This function takes a vector of "yes/no" responses [resp] and a
% vector of "present/absent" trials [ttype] to compute the hit rate, false
% alarm rate, dprime index and overall percent correct. Optionally,
% if truncate is set to true, it attempts to remove trials in which
% the subject has stopped responding due to fatigue or satiety near
% the end of the run, by counting the number of responses from the
% end of the run and stopping when it hits a certain criterion lick
% count provided by [crit]
%
% The last two outputs are corrected versions of the hit rate and
% false alarm rate, in the case that they are equal to 0 or 1.
    
% Truncate based on responses to get rid of the end where mice
% doesn't lick
if nargin == 3
    startv = 1;
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
% Correct for perfect hr/fa (from:
% http://www.kangleelab.com/sdt-d-prime-calculation---other-tips.html)
hr1 = hr;
fa1 = fa;
nt = sum(ttype>0);
nn = sum(ttype==0);
if hr == 1
    hr1 = 1-(1/(2*nt));
end
if hr == 0
    hr1 = 1/(2*nt);
end
if fa == 0
    fa1 = 1/(2*nn);
end
if fa == 1
    fa1 = 1-(1/(2*nn));
end

dp = norminv(hr1) - norminv(fa1);