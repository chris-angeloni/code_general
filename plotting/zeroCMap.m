function cmap = zeroCMap(data,topColor,indexColor,bottomColor,ind)

%% function cmap = zeroCMap(data,topColor,indexColor,bottomColor,ind)
%
% this function creates a custom color map that transitions between
% three colors, one at the max, one at the min, and one in
% between. crucially, this map is customized to the data, such that
% the middle color is specified to be at a fixed value in the data
% (median by default)

data = data(:);

if ~exist('ind','var') | isempty(ind)
    ind = median(data);
end

if ~exist('topColor','var') | isempty(topColor)
    topColor = [1 0 0];
end
if ~exist('indexColor','var') | isempty(indexColor)
    indexColor = [1 1 1];
end
if ~exist('bottomColor','var') | isempty(bottomColor)
    bottomColor = [0 0 1];
end

L = numel(data);

% Calculate where proportionally indexValue lies between minimum and
% maximum values
largest = max(data);
smallest = min(data);
index = L*abs(ind-smallest)/(largest-smallest);

% Create color map ranging from bottom color to index color
% Multipling number of points by 100 adds more resolution
customCMap1 = [linspace(bottomColor(1),indexColor(1),100*index)',...
            linspace(bottomColor(2),indexColor(2),100*index)',...
            linspace(bottomColor(3),indexColor(3),100*index)'];

% Create color map ranging from index color to top color
% Multipling number of points by 100 adds more resolution
customCMap2 = [linspace(indexColor(1),topColor(1),100*(L-index))',...
            linspace(indexColor(2),topColor(2),100*(L-index))',...
            linspace(indexColor(3),topColor(3),100*(L-index))'];
cmap = [customCMap1;customCMap2];  % Combine colormaps
