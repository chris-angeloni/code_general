function [respFit, P] = bumpFit(logFreqs, respVals, logCF);
%function [respFit P] = bumpFit(logFreqs, respVals, logCF);
% fit data as the difference of two logistic functions

nFreqs = length(logFreqs);
deltaLogFreq = logFreqs(2)-logFreqs(1);
guessMax = max(respVals);

% interpolate sample points -- this seems to work better for narrow peaks
logFreqs2 = interp1(1:nFreqs, logFreqs, 1:0.5:nFreqs);
respVals2 = interp1(1:nFreqs, respVals, 1:0.5:nFreqs);

% set up default and initial values
options = foptions;
% options(14) = 200;
P0 =  [guessMax 10 logCF-deltaLogFreq -10 2*deltaLogFreq];

% now do the actual curve fitting...
P = fmins('bumpFitMinFun', P0, options, [], logFreqs2, respVals2);
% P = constr('bumpFitMinFun', P0, options, [],[],[], logFreqs2, respVals2);

% compute the fit at the appropriate sample points
respFit = bilogist(logFreqs, P);

return
