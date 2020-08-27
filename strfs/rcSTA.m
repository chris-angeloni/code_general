function sta = rcSTA(y,X,lags,norm)

%% function sta = genSTA(y,X,lags,norm);
% 
% This function generates an STRF using reverse correlation, either
% using a normalized or non-regularized method.
%
% INPUTS:
%  y = spike times, spike sample number, or spike vector
%  X = design matrix
%  lags = number of lags for window
%  norm = if 'norm' then compute normalized STA
%  
% OUTPUTS:
%  sta = spike triggered average

% by default, start with the design matrix as features x time
if size(X,2) < size(X,1)
    X = X';
end

% make the spike vector a column
if size(y,1) == 1
    y = y';
end

if exist('norm','var') & ~isempty(norm) & norm
    sta = inv(X*X')*X*y;
else
    sta = X * y;
end

sta = fliplr(reshape(sta,[],lags));