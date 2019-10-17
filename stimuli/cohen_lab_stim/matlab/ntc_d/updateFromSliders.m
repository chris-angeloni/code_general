function updateFromSliders

WARNCOLOR = [1 0.8 0.4];

[hobj,hfig] = gcbo;
startVal = get(findobj(hfig,'tag','StartSlider'),'value');
duration = get(findobj(hfig,'tag','DurationSlider'),'value');
startVal = round(startVal*10)/10;
duration = round(duration*10)/10;
set(findobj(hfig,'tag','StartSlider'),'value', startVal);
set(findobj(hfig,'tag','DurationSlider'),'value', duration);

set(findobj(hfig,'tag','StartText'),'string', num2str(startVal));
set(findobj(hfig,'tag','DurationText'),'string', num2str(duration));

set(findobj(hfig,'tag','RangeStartText'),'string', num2str(startVal));
set(findobj(hfig,'tag','RangeEndText'),'string', num2str(startVal+duration));

return
