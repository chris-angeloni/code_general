function h = barWithError(Y,label,colors,err)

%% function h = barWithError(Y,label,colors,err)
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

% by default, assume we're averaging over the columns
my = nanmean(Y,1);
if strcmp(err,'sem')
    erry = nanstd(Y,[],1) ./ sqrt(size(Y,1));
    y = [my+erry; my-erry];
elseif strcmp(err,'prctile')
    erry = prctile(Y,[.025 97.5],1);
    y = [erry(1,:); erry(2,:)];
end
x = 1:size(Y,2);

% plot
hold on
for i = 1:size(Y,2)
    h(i) = bar(x(i),my(i));
    h(i).FaceColor = colors(i,:);
    h(i).BarWidth = .5;
    plot([x(i) x(i)],[y(:,i) y(:,i)],'k',...
         'LineWidth',1.5);
end
xlim([x(1)-.5 x(end)+.5]);
set(gca,'xtick',x);
if exist('label','var') & ~isempty(label)
    set(gca,'XTickLabel',label);
end
    