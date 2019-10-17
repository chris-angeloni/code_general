function updateFromSliderText

INCLUDE_DEFS;

[hobj,hfig] = gcbo;
startVal = str2num(get(findobj(hfig,'tag','StartText'),'string'));
duration = str2num(get(findobj(hfig,'tag','DurationText'),'string'));

set(findobj(hfig,'tag','RangeStartText'),'string', num2str(startVal));
set(findobj(hfig,'tag','RangeEndText'),'string', num2str(startVal+duration));

set(findobj(hfig,'tag','StartSlider'),'value', startVal);
set(findobj(hfig,'tag','DurationSlider'),'value', duration);

return
