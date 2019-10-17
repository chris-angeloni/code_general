function [sRaster, sTrials] = sortRaster(raster,trials,sortI)

%% function [sRaster, sTrials] = sortRaster(raster,trials,sortI)
%
% function for sorting a raster by a particular trial order
% INPUTS:
%  raster: spike times
%  trials: trial number for each spike time
%  sortI: a trial sorting index. trials should not contain values outside of this index
%
% OUTPUTS:
%  sRaster: sorted spike times
%  sTrials: sorted trials


% empty trials and rasters
sTrials = [];
sRaster = [];

for i = 1:length(sortI)
    
    % sort spikes for each trial
    ind = trials == sortI(i);
    sTrials = [strials ones(1,sum(ind))*i];
    sRaster = [sraster raster(ind)];
        
end
