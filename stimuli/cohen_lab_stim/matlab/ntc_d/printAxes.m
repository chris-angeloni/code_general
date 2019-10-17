function printAxes()

hax=findobj('type','axes');
hch=get(gcf,'children');
hhd=setdiff(hch,hax);

set(gcf,'units','normal');
set(hax,'units','normal');
printdlg(gcf,[0 0 1 1], [0 0 1 1], hhd);
set(gcf,'units','points');
set(hax,'units','points');

return

