function h = cateyePlot(Y,yr,col,lw,alpha)

%% function h = cateyePlot(Y,yr,col,lw,alpha)
%
% This function plots a symmetrical distribution of the data in Y
% using a kernel density estimate.
% 
% optional inputs yr, col, lw, alpha, control the limits, color,
% linewidth and transparency of the plot, respectively.


if ~exist('yr','var') | isempty(yr)
    yr = [-1 1];
elseif length(yr) == 1
    yr = [-abs(yr) abs(yr)];
end
if ~exist('col','var') | isempty(col)
    col = [.5 .5 .5];
end
if ~exist('lw','var') | isempty(lw)
    lw = .5;
end
if ~exist('alpha','var') | isempty(alpha)
    alpha = .5;
end

% kernel function
[dn, dx] = ksdensity(Y, min(Y):range(Y)/100:max(Y));

% plotting variables
dy = [dn -fliplr(dn)];
xn = [dx fliplr(dx)];

% normalize to the y range
yn = (dy - min(dy)) / (max(dy) - min(dy));
yn = (yn * diff(yr)) + yr(1);

% plot it
hold on
h(1) = patch(xn,yn,col)
h(1).LineWidth = lw;
h(1).FaceAlpha = alpha;

% find and plot median
mi = median(Y);
[~,md] = min(abs(xn-mi))
xi = dx(md);
yi = [yn(md) yn(length(dn)+(length(dn)-md+1))];
h(2) = plot([xi xi],yi,'k','LineWidth',lw)
hold off
