function s = getPvalSymbol(p)

s = [];

if p > .05
    s = 'NS';
elseif p < .05 & p > .01
    s = '*';
elseif p < .01 & p > .001
    s = '**';
elseif p < .001 & p > .0001
    s = '***';
elseif p < .0001
    s = '****';
end
        