function showFileNums

global allAttributes

INCLUDE_DEFS;

hfig = figure('units', 'points', 'menubar', 'none');
listString = num2str(allAttributes(:,1));
listSize = [55, 12.3*30];
hlist = uicontrol('style','listbox',...
                  'units','points', ...
                  'fontname','fixed', ...
                  'string', listString, ...
                  'position',[8 5 215 470]);
set(hlist,'position', [8 5 listSize(1:2)]);
set(hfig, 'position', [355 20 listSize(1)+10 listSize(2)+10]);

return
