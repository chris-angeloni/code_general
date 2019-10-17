function f = bumpFitMinFun(P, x, y)

% function f = bumpFitMinFun(P, x, y)
% this function is used in a call to fmins to fit a peak with a
%   difference of two logistic functions (bilogist)

% the function to minimize
f = norm(y-bilogist(x, P));

return

% to use constr, need to return g (constraints) as well.  
% each must be < 0 (...so P1, P2 are > 0)
% g = [-P(1) -P(2) -1 P(4) -P(5)];

