function updateFromRange

INCLUDE_DEFS;

startVal = str2num(get(findobj('tag','RangeStartText'),'string'));
endVal = str2num(get(findobj('tag','RangeEndText'),'string'));

duration = endVal - startVal;

set(findobj('tag','StartSlider'),'value', startVal);
set(findobj('tag','StartText'),'string', num2str(startVal));
set(findobj('tag','DurationSlider'),'value', duration);
set(findobj('tag','DurationText'),'string', num2str(duration));

return
