function [X] = makeDesignMatrix(S,lags,spikeI)

%% function [X] = makeDesignMatrix(S,lags,spikeI)
% 
% This function makes a temporally shifted design matrix for STA fitting
%
% INPUTS:
%  S = stimulus spectrogram
%  lags = number of lags to shift
%  spikeI = (optional) index of spike data that will be used, 
%           so we can use real stimulus values when available
%  
% OUTPUTS:
%  X = design matrix

% by default, start with the spectrogram as frequency x time
if size(S,2) < size(S,1)
    S = S';
end

% make the design matrix based frequency features
nfs = size(S,1);

% spike index check
if ~exist('spikeI','var') | isempty(spikeI)
    
    % check if the stimulus is padded
    if ~all(sum(S(:,1:lags-1)) == 0)
        
        % shift the index by the padding
        index = [1:length(S)] + lags-1;
        
        % pad the stim
        S = [zeros(size(S,1),lags-1) S];
        
    else
        
        % shift the index, but trim the end to match the 'unpadded'
        % stim length
        index = lags:length(S);
        
    end
    
else
    % convert logical to subscript
    index = find(spikeI);
    
end

% preallocate X
X = zeros(nfs*lags,length(index));

% shift the index for each lag
for i = 1:lags
    I = index-(i-1);
    rowI = (i-1)*nfs+1:i*nfs;
    X(rowI,:) = S(:,I);
    
end