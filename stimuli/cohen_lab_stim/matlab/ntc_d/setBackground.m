function setBackground(newColor)

hax = findobj('tag','TuningCurveAxes');
if ischar(newColor),
  switch newColor
    case {'white','black'},
      set(hax,'color', newColor);
    otherwise,
      error('Sorry, you can only choose white or black for this one...');
    end % (switch)
  else
    set(hax,'color', newColor);
  end % (if)

return
