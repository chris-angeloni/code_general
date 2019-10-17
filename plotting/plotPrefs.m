function plotPrefs
set(gca,'TickDir','out');
%set(gca,'FontSize',12);
set(gca,'LineWidth',1);
set(groot,{'DefaultAxesXColor','DefaultAxesYColor', ...
         'DefaultAxesZColor'},{'k','k','k'})
set(gca,'FontName','Arial')
set(gca, 'Layer', 'top');
grid off;
