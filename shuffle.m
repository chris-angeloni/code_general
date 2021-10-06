function y = shuffle(x);

ind = randperm(numel(x));
y = x(ind);