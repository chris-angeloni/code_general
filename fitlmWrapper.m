function [b,p,xp,yp,ypci,mdl] = fitlmWrapper(X,y)

%% [b,p,xp,yp,ypci,mdl] = fitlmWrapper(X,y)
%
% wrapper for fitting basic linear model with one predictor, X
% contains predictor values (don't need to add column of ones, this
% is done in fitlm), and y are the values being predicted.
%
% outputs the fit coefficients (b), pvalue (p), fit line in the
% range of the data (xp,yp), error of the fit (ypci), and the whole
% model (mdl)
 
% clean up inputs
if size(X,1) == 1
    X = X';
end
if size(y,1) == 1
    y = y';
end

% fit the data
 mdl = fitlm(X,y);
 b = mdl.Coefficients.Estimate;
 p = mdl.Coefficients.pValue(2);
 
 % make fit prediction/error
 xp = linspace(min(X),max(X),100)';
 [yp,ypci] = predict(mdl,xp);