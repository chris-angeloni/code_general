function [sta,X] = nrcSTA(y,S,t,fps,norm)

%% function sta = genSTA(y,S,t,fps,norm);
% 
% This function generates an STRF using reverse correlation, either
% using a normalized or non-regularized method.
%
% INPUTS:
%  S = stimulus spectrogram
%  y = spike times, spike sample number, or spike vector
%  t = time bins for the strf
%  fps = stimulus frame rate (1 / chord length)
%  norm = if 'norm' then compute normalized STA
%  
% OUTPUTS:
%  sta = spike triggered average

% by default, start with the spectrogram as frequency x time
if size(S,2) < size(S,1)
    S = S';
end

% make the spike vector a column
if size(y,1) == 1
    y = y';
end

% make the design matrix based on window
% lag step in samples
lagStep = round(t * fps);
nlags = length(t);
nfs = size(S,1);

% make a design matrix (super simple, just frequency x lags)
X = zeros(nfs*nlags,length(S));
for i = 1:nlags
    rowI = (i-1)*nfs+1: i*nfs;
    X(rowI,:) = circshift(S,lagStep(i),2);
    
end

if exist('norm','var') & ~isempty(norm) & norm
    sta = inv(X*X')*X*y;
else
    sta = X * y;
end

sta = fliplr(reshape(sta,nfs,[]));