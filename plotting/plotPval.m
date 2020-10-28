function h = plotPval(p,x,y)

YL = ylim;
y = y + range(YL)*.1

hold on;
[psym,pval] = pvalStr(p);
h = text(x,y,sprintf('p=%s %s',pval,psym),...
         'units','normalized','horizontalAlignment','center');
hold off;