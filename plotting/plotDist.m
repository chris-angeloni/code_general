function [ph,pl,pe] = plotDist(x,y,colors,plotLines,err,stat,ERROR,varargin)

%% function [ph,pl,pe] = plotDist(x,y,colors,plotLines,err,stat,ERROR,varargin)
%
% Plots distributions of points using plotSpread
% package. optionally will plot lines connecting them and errorbars
% 
% x,y = x and y data points (x can be 1d, y should be column matrix
%       where error is computed over columns
% colors = colors for each column of y
% plotLines = if true plots lines if each column has same number of points
% err = error type if you want to plot errorbars
%       ('sem','std','prctile', default: 'sem')
% stat = stat type if you want to change measure of central
%        tendancy ('mean' or 'median', default: 'mean')
hold on

if nargin < 2
    y = x;
    x = 1:size(y,2);
end
if nargin < 3
    colors = 'k';
end
if nargin < 4
    plotLines = false;
end
if nargin < 5
    err = false;
end
if nargin < 6
    stat = false;
end
if nargin < 7
    ERROR = [];
end
if nargin < 8
    varargin = [];
end

if ~iscell(colors)
    colors = {colors};
end

% plot spread to get x values
%x = [1 2 3];
%y = {randn(100,1) randn(100,1)+2 randn(100,1)+4};
tmp = plotSpread(y,'xValues',x);

% only plot lines if data is same length (will not plot nans)
if iscell(y) 
    if ~any(diff(cellfun(@length,y))~=0)
        y = cat(2,y{:});
    else
        plotLines = false;
        warning('plotDist.m: can''t plot lines if data are different lengths!');
    end
end

% plot lines if specified
if plotLines
    xv = nan(size(y));
    for i = 1:numel(tmp{1})
        xv(~isnan(y(:,i)),i) = get(tmp{1}(i),'xdata');
    end
    pl = plot(xv',y','k','linewidth',.5);
else
    pl = [];
end

% plot spread for real
ph = plotSpread(y,'xValues',x,'distributionColors',colors);
for i = 1:numel(ph{1})
    set(ph{1}(i),'Marker','o','MarkerFaceColor','w', ...
                 'MarkerSize',4);
    if ~isempty(varargin)
        set(ph{1}(i),varargin{:});
    end
end



% overlay bar plot if specified
if err
    if ~stat
        stat = 'mean';
    end
    
    % compute mean
    if strcmp(stat,'mean')
        if ~iscell(y)
            my = mean(y,1,'omitnan');
        else
            my = cell2mat(cellfun(@(m) mean(m,1,'omitnan'),y,'UniformOutput',false));
        end
    elseif strcmp(stat,'median')
        if ~iscell(y)
            my = median(y,1,'omitnan');
        else
            my = cell2mat(cellfun(@(m) median(m,1,'omitnan'),y,'UniformOutput',false));
        end
    else
       if ~iscell(y)
            my = mean(y,1,'omitnan');
        else
            my = cell2mat(cellfun(@(m) mean(m,1,'omitnan'),y,'UniformOutput',false));
        end
        warning('plotDist.m: stat must be median or mean, using mean!');
    end
    
    % compute error
    if ~isempty(ERROR)
        erry = [ERROR; ERROR];
    else
        if strcmp(err,'sem')
            if ~iscell(y)
                tmp = std(y,0,1,'omitnan') ./ ...
                      sqrt(sum(~isnan(y),1));
            else
                tmp = cell2mat(cellfun(@(m) std(m,0,1,'omitnan')./sqrt(sum(~isnan(m),1)),...
                                       y,'UniformOutput',false));
            end
            erry = [tmp; tmp];    
        elseif strcmp(err,'prctile')
            if ~iscell(y)
                tmp = prctile(y,[2.5 97.5],1);
            else
                tmp = cell2mat(cellfun(@(m) prctile(m,[2.5 97.5],1),...
                                       y,'UniformOutput',false));
            end
            erry = [tmp(1,:)-my; tmp(2,:)-my];
        elseif strcmp(err,'std')
            if ~iscell(y)
                tmp = std(y,0,1,'omitnan');
            else
                tmp = cell2mat(cellfun(@(m) std(m,0,1,'omitnan'),...
                                       y,'UniformOutput',false));
            end
            erry = [tmp; tmp];
        else
            if ~iscell(y)
                tmp = std(y,0,1,'omitnan') ./ ...
                      sqrt(sum(~isnan(y),1));
            else
                tmp = cell2mat(cellfun(@(m) std(m,0,1,'omitnan')./sqrt(sum(~isnan(m),1)),...
                                       y,'UniformOutput',false));
            end
            erry = [tmp; tmp];
            warning('plotDist.m: err must be ''sem'' ''std'' or ''prctile'', using ''sem''!');
        end
    end
    pe = errorbar(x,my,erry(1,:),erry(2,:),...
                  'color','k','LineStyle','none','LineWidth',1.5,...
                  'Marker','o','MarkerFaceColor','w');
    
else
    pe = [];
end


hold off;
    




