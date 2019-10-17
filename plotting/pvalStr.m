function sym = pvalStr(p);

for i = 1:length(p)
    if p(i) >.05
        sym{i} = 'ns';
    end
    if p(i) <= .05
        sym{i} = '*';
    end
    if p(i) <= .01
        sym{i} = '**';
    end
    if p(i) <= .001
        sym{i} = '***';
    end
    if p(i) <= .0001
        sym{i} = '****';
    end
end
