function e = sem(x,dim)
%Calculates standard error of the mean for x.
%This is across rows in x. For columns transpose.

if ~exist('dim','var') | isempty('dim')
    dim = 1;
end

e = sqrt(nanvar(x,[],dim)./sum(~isnan(x)));
