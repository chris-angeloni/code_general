function enterNewAtten

INCLUDE_DEFS;

global extAtten

[hobj, hfig] = gcbo;
if get(hobj,'tag') == 'AttenCEdit',
    extAtten = str2num(get(hobj,'string'));
  end

refreshDisplay;
set(hobj,'backgroundcolor',NORMCOLOR);

return
