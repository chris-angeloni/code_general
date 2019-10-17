function zapStimPoint

INCLUDE_DEFS;

[hobj, hfig] = gcbo;
hAxes = findobj(hfig, 'tag', 'TuningCurveAxes');
hCh = get(hAxes,'children');
for ii=1:length(hCh),
  set(hCh, 'buttondownfcn', 'selAndZap');
  end % (for)

hMessages = findobj(hfig, 'tag', 'MessageText');
set(hMessages, 'string', 'click on points to zap');
set(hMessages, 'backgroundcolor', MESSAGECOLOR);
                          
return
