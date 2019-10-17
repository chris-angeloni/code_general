function measure;
% function measure

INCLUDE_DEFS;

[hobj, hfig] = gcbo;

hmessagetext = findobj(hfig,'tag','MessageText');
set(hmessagetext, 'backgroundcolor', MESSAGECOLOR);


if ((findobj(hfig, 'tag', 'CFButton') == hobj) | ...
    (findobj(hfig, 'tag', 'AllButton') == hobj)),
    set(hmessagetext, 'string', 'click on CF at threshold in plot');
  else
    set(hmessagetext, 'string', 'click on point in plot');
  end % (if)
  
hax = findobj(hfig,'tag','TuningCurveAxes'); 
axes(hax);
set(hax, 'nextplot','add');

mpoint = ginputUsingArrow(1);
if ((findobj(hfig, 'tag', 'CFButton') == hobj) | ...
    (findobj(hfig, 'tag', 'AllButton') == hobj)),
    plot(mpoint(1), mpoint(2), 'co');
    putNewAttribute(CF, mpoint(1));
    putNewAttribute(THRESHOLD, mpoint(2));
  else
    plot(mpoint(1), mpoint(2), 'mo');
  end % (if)
  
hmenu = findobj('tag','DisplayMenu');
hoptions = get(hmenu,'children');
dispType = get(hoptions(strcmp('on',get(hoptions,'Checked'))),'Tag');

switch dispType
  case {'ColorOption','LinesOption','Lines2Option','ContourOption'},
    set(hmessagetext, 'string', ...
      sprintf('frequency: %5.2f   amplitude: %5.2f', mpoint(1),mpoint(2)));
  case {'FreqRasterOption'},
    set(hmessagetext, 'string', ...
      sprintf('approximate frequency: %5.2f   time: %5.2f', mpoint(1),mpoint(2)));
  case 6,
  case {'IntRasterOption'},
    set(hmessagetext, 'string', ...
      sprintf('time: %5.2f   approximate intensity: %5.2f', mpoint(1),mpoint(2)));
  otherwise,
  end % (switch)  

return
