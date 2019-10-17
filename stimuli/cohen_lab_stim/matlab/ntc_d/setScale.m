function setScale

INCLUDE_DEFS;

hobj = findobj('tag','ScalePopup');

hScale = findobj('tag', 'ScaleText');
hSpikes = findobj('tag', 'StaticTextSpikes');

if get(hobj, 'value') == 1, 
    set(hScale, 'enable', 'on');
    set(hSpikes, 'enable', 'on');
  else
    set(hScale, 'enable', 'off');
    set(hSpikes, 'enable', 'off');
  end

return
