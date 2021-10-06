function cmap = zeroCMap(data,ind,topColor,indexColor,bottomColor)

%% function cmap = zeroCMap(data,ind,topColor,indexColor,bottomColor)
%
% this function creates a custom color map that transitions between
% three colors, one at the max, one at the min, and one in
% between. crucially, this map is customized to the data, such that
% the middle color is specified to be at a fixed value in the data
% (median by default)
%
% INPUTS:
%  data: values of data to map to
%  ind: reference value in the data (median by default)
%  topColor: RGB value for the color of max(data)
%  indexColor: RGB value for the color of the reference value
%  bottomColor: RGB value for the color of min(data)
%
% example usage:
% tmp = randn(100,100);
% cmap = zeroCMap(tmp,0);
% colormap(cmap);
% imagesc(cmap); colorbar;

data = data(:);

if ~exist('ind','var') | isempty(ind)
    ind = median(data);
end
if ~exist('topColor','var') | isempty(topColor)
    topColor = [1 0 0]; %[239 138 98]./255;
end
if ~exist('indexColor','var') | isempty(indexColor)
    indexColor = [1 1 1];
end
if ~exist('bottomColor','var') | isempty(bottomColor)
    bottomColor = [0 0 1]; %[103 169 207]./255;
end

L = numel(data);

% Calculate where proportionally indexValue lies between minimum and
% maximum values
largest = max(data);
smallest = min(data);

% if specified ind falls outside the range, remap to the extreme values
if smallest >= ind
    bottomColor = indexColor;
    ind = smallest;
elseif largest <= ind
    topColor = indexColor;
    ind = largest;
end

% range for the data, relative to the ind value
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