function [h1,h2,h3] = plotlmWrapper(xp,yp,ypci,color)

%% [h1,h2,h3] = plotlmWrapper(xp,yp,ypci,color)
%
% plots linear regression results, using xp and yp as fit line x
% and y values, ypci are the confidence intervals in y, with
% optional color
%
% returns plot handles for fit line, error patch and CI lines

if ~exist('color','var')
    color = [.5 .5 .5];
end

if size(xp,1) == 1
    xp = xp';
end
if size(yp,1) == 1
    yp = yp';
end
if size(ypci,1) == 2
    ypci = ypci';
end


hold on
h1 = patch([xp' fliplr(xp')],[ypci(:,1)' fliplr(ypci(:,2)')],1);
h1.FaceColor = color;
h1.FaceAlpha = .25;
h1.EdgeAlpha = 0;

h2 = plot(xp,yp,'Color',color,'LineWidth',1);
h3 = plot(repmat(xp,1,2),ypci,'--','Color',color,'LineWidth',1);
