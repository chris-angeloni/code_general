function setDisplayType(hobj)

if nargin<1,
    [hobj,hfig] = gcbo;
  end % (if)
  
hmenu = get(hobj, 'parent');

hoptions = get(hmenu,'children');

set(hoptions,'checked','off');
set(hobj,'checked', 'on');

set(hmenu, 'label', get(hobj,'label'));

return
