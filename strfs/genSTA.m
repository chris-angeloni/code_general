function [sta, nSpikes] = genSTA(spikes,S,w,fps,norm)

%% function [sta nSpikes] = genSTA(spikes,S,w,fps);
% 
% This function generates a spike-triggered average
% spikes = spike times (needs to be in seconds from the start of
% the stimulus
%
% INPUTS:
%  S = stimulus spectrogram of m frequencies by n time bins
%  w = length of the stimulus window to consider for the STA (how
%      far back in time do you want your STA to go)
%  fps = stimulus frame rate (1 / chord length)
%  norm = if 'norm' then normalize by mean and sum of squares
%  
% OUTPUTS:
%  sta = spike triggered average
%  nSpikes = total spike count

if ~all(mod(spikes,1)) == 0
    
    % convert spike times to stim bins
    spikes = ceil(spikes*fps);
    
end

sta = zeros(size(S,1),w/(1/fps)+1);
for i = 1:length(spikes)
    
    if spikes(i) > w*fps && spikes(i) <= length(S)
        
        spikeStim = S(:,spikes(i) - ((w*fps)):spikes(i));
        sta = sta + spikeStim;
        
    end
    
end

nSpikes = length(spikes);
sta = sta / nSpikes;

% normalize
if exist('norm','var') & ~isempty(norm)
    sta = sta - mean(sta(:));
    sta = sta ./ sqrt(sum(sta(:).^2));
end