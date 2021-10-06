function h = barWithError(Y,label,colors,err,varargin)

%% function h = barWithError(Y,label,colors,err,varargin)
%
% plots a bar graph with error bars
% Y: data to be plotted (will average over columns)
% label: (optional) labels for each bar
% colors: (optional) colors for each bar
% err: (optional) error calculation specification (either 'sem' or
% 'prctile')

if ~exist('err','var') || isempty(err)
    err = 'sem';
end
if ~exist('colors','var') || isempty(colors)
    colors = repmat([.5 .5 .5],size(Y,2),1);
end

% check if the input data is a cell
if iscell(Y)
    
    for i = 1:size(Y,2)
        my(i) = nanmean(Y{i});
        if strcmp(err,'sem')
            erry = nanstd(Y{i}) ./ sqrt(length(Y{i}));
            y(:,i) = [my(i)+erry; my(i)-erry];
        elseif strcmp(err,'prctile')
            y(:,i) = prctile(Y{i},[2.5 97.5]);
        end
    end
    
else

    % by default, assume we're averaging over the columns
    my = nanmean(Y,1);
    if strcmp(err,'sem')
        erry = nanstd(Y,[],1) ./ sqrt(size(Y,1));
        y = [my+erry; my-erry];
    elseif strcmp(err,'prctile')
        erry = prctile(Y,[2.5 97.5],1);
        y = [erry(1,:); erry(2,:)];
    end
    
end

% plot
hold on
x = 1:size(Y,2);
for i = 1:size(Y,2)
    h(i) = bar(x(i),my(i),varargin{:});
    if ~iscell(colors)
        h(i).FaceColor = colors(i,:);
    else
        h(i).FaceColor = colors{i};
    end
    h(i).BarWidth = .5;
    plot([x(i) x(i)],[y(:,i) y(:,i)],'k',...
         'LineWidth',1.5);
end
xlim([x(1)-.5 x(end)+.5]);
set(gca,'xtick',x);
if exist('label','var') & ~isempty(label)
    set(gca,'XTickLabel',label);
end
