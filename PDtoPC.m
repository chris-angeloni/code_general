function pc = PDtoPC(hr,fa)

%% function pc = PDtoPC(hr,fa)
%
% This function converts performance in terms of p(detect) or
% p(respond) to percent correct (pc), by normalizing d'.
% 
% pc = normcdf( (norminv(hr) - norminv(fa)) ./ sqrt(2) );

pc = normcdf( (norminv(hr) - norminv(fa)) ./ sqrt(2) );