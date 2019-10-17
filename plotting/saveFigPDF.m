function saveFigPDF(h,sz,savepath);

% function saveFigPDF(h,sz,savepath);
% saves a figure as a PDF with (h) being the figure handle, (sz) being the
% size in pixels [width x height], (savepath) being the filename

if size(sz,1) == 2
    sz = sz';
end

set(groot,{'DefaultAxesXColor','DefaultAxesYColor', ...
           'DefaultAxesZColor'},{'k','k','k'})
set(h,'PaperPositionMode','auto');         
set(h,'PaperOrientation','landscape');
set(h,'PaperUnits','points');
if ~isempty(sz)
    set(h,'PaperSize',sz);
    set(h,'Position',[0 0 sz]);
end
print(h,savepath,'-dpdf','-r300','-painters');



