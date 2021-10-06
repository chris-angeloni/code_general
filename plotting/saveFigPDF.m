function saveFigPDF(h,sz,savepath,tickl);

% function saveFigPDF(h,sz,savepath);
% saves a figure as a PDF with (h) being the figure handle, (sz) being the
% size in pixels [width x height], (savepath) being the filename
% optional [tickl] specifies the tick length in mm

if size(sz,1) == 2
    sz = sz';
end

set(groot,{'DefaultAxesXColor','DefaultAxesYColor', ...
           'DefaultAxesZColor'},{'k','k','k'})
set(h,'PaperPositionMode','auto');         
set(h,'PaperOrientation','landscape');

if ~isempty(sz)
    if any(sz < 20)
        set(h,'PaperUnits','inches');
        set(h,'Units','inches');
        set(h,'PaperSize',sz);
        set(h,'Position',[0 0 sz]);
    else
        set(h,'PaperUnits','points');
        set(h,'Units','points');
        set(h,'PaperSize',sz);
        set(h,'Position',[0 0 sz]);
    end
end

% make nice ticks
if exist('tickl','var');
    a = get(h);
    for i = 1:length(a.Children)
        ax = a.Children(i);

        if contains(class(a.Children(i)),'Axes')
            ax.Units = 'centimeters';
            ax.TickLength(1) = (tickl/2) / max(ax.Position(3:4));
            ax.TickLength(2) = tickl / max(ax.Position(3:4));
        end
    end
end

if exist('savepath','var') & ~isempty(savepath)
    print(h,savepath,'-dpdf','-r300','-painters');
end




