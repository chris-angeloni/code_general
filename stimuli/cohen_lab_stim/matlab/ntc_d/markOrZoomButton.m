function markOrZoomButton

INCLUDE_DEFS;

[hobj,hfig] = gcbo;
hax = findobj(hfig, 'tag', 'TuningCurveAxes');
axes(hax);

if get(hobj, 'value') == 1,  % is mark
    zoom off;
    markStimRange;
  else  % is zoom
    hCh = get(hax,'children');
    for ii=1:length(hCh),
      set(hCh, 'buttondownfcn', '');
      end % (for)
    set(hax, 'buttondownfcn', '');
    zoom on
    hmsg = findobj('tag','MessageText');
    set(hmsg,'string', ...
    '***WARNING*** After zooming on log scale, tick marks will be incorrect (matlab bug)');
    set(hmsg,'backgroundcolor',WARNCOLOR);
  end %   (if)
  
return
