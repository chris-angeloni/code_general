function [X] = shiftDesignMatrix(S,t,fps)

%% function sta = genSTA(S,t,fps);
% 
% This function makes a temporally shifted design matrix for STA fitting
%
% INPUTS:
%  S = stimulus spectrogram
%  t = time bins for the strf
%  fps = stimulus frame rate (1 / chord length)
%  
% OUTPUTS:
%  X = design matrix

% by default, start with the spectrogram as frequency x time
if size(S,2) < size(S,1)
    S = S';
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