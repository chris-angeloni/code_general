function [psym, pval] = pvalStr(p);

%% function [psym, pval] = pvalStr(p);
%
% This function takes a pvalue and formats two strings, the first
% of which is a significance symbol, and second is a formatted
% string of the value itself.

for i = 1:length(p)
    if p(i) >.05
        sym{i} = 'ns';
        valstr{i} = sprintf('%4.3f',p(i));
    end
    if p(i) <= .05
        sym{i} = '*';
        valstr{i} = sprintf('%4.3f',p(i));
    end
    if p(i) <= .01
        sym{i} = '**';
        valstr{i} = sprintf('%4.3f',p(i));
    end
    if p(i) <= .001
        sym{i} = '***';
        valstr{i} = sprintf('%3.2e',p(i));
    end
    if p(i) <= .0001
        sym{i} = '****';
        valstr{i} = sprintf('%3.2e',p(i));
    end
end

% take out of cell array if only 1 value
if length(p) == 1
    psym = sym{1};
    pval = valstr{1};
else
    psym = sym;
    pval = valstr;
end
