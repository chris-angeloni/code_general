function STA = normSTA(sta)

%% function STA = normSTA(sta)
%
% Normalizes a spike triggered average by subtracting the mean and
% normalizing such that the sum of squares == 1
% 
% STA = sta;
% STA = STA - mean(STA(:));
% STA = STA ./ sqrt(sum(STA(:).^2));

STA = sta;
STA = STA - mean(STA(:));
STA = STA ./ sqrt(sum(STA(:).^2));