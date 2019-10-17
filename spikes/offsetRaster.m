function [offRaster, offPSTH] = offsetRaster(raster,trials,offset,edges,smth)

%% function offsetRaster(raster,trials,offset,edges,smth)
%
% takes a spike raster and offsets each trial by a specified vector
% or single value (faster), and will optionally make a PSTH based
% on this new offset, with optional smoothing
%
% INPUTS:
%  raster: spike times
%  trials: trial index for each spike
%  offset: either a scalar, or vector specifying a constant offset 
%          for all trials or a specific offset for each trial, respectively
%  edges:  (OPTIONAL) edge variable to make a PSTH
%  smth:   (OPTIONAL) smoothing kernel width to make a PSTH
%
% OUTPUTS:
%  offRaster


% preallocate if necessary
if exist('edges','var')
    offPSTH = zeros(length(offset),length(edges)-1);
else
    offPSTH = [];
end

offRaster = zeros(size(raster));


if length(offset) == 1
    
    % for a constant offset across all trials:
    offRaster = raster - offset;
    
    % make PSTH if asked
    if exist('edges','var')
        
        for i = 1:max(trials)
            
            offPSTH(i,:) = histcounts(raster(trials==i),edges);
            
            % smooth
            if exist('smth','var')
                
                offPSTH(i,:) = SmoothGaus(offPSTH(i,:),smth);
                
            end
            
        end
        
    end
    
else
    % for a specific offset for each trial
    for i = 1:length(offset)
        
        % offset current trial
        ind = trials == i;
        offRaster(ind) = raster(ind) - offset(i);
        
        % make a PSTH if asked
        if exist('edges','var')
            
            offPSTH(i,:) = histcounts(raster(trials==i),edges);
            
            % smooth
            if exist('smth','var')
                
                offPSTH(i,:) = SmoothGaus(offPSTH(i,:),smth);
                
            end
            
        end
        
    end
               
end

