function toggleBlind

INCLUDE_DEFS

if (get(findobj('tag','BlindBox'),'value') == 1)
    set(findobj('tag','TuningCurveAxes'),'visible','off');
  else
    set(findobj('tag','TuningCurveAxes'),'visible','on');
  end

refreshDisplay;

return
