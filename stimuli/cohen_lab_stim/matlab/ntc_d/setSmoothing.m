function setSmoothing(hobj)

INCLUDE_DEFS;

if nargin<1,
    [hobj,hfig] = gcbo;
  end; % (if)
  
hmenu = get(hobj, 'parent');

hoptions = get(hmenu,'children');

set(hoptions,'checked','off');
set(hobj,'checked', 'on');

set(hmenu, 'label', get(hobj,'label'));
if strcmp('NoSmoothOption',get(hobj,'tag')),
    set(hmenu, 'foregroundcolor', 'k');
  else
    set(hmenu, 'foregroundcolor', 'r');
  end; % (if)

return
