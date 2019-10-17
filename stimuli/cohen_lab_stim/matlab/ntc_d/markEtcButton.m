function markEtcButton

INCLUDE_DEFS;

[hobj,hfig] = gcbo;
hbut = findobj('tag','markEtcRadio');
hmsg = findobj('tag','MessageText');
hax = findobj(hfig, 'tag', 'TuningCurveAxes');
axes(hax);

switch get(hobj, 'value'),  % is mark
  case 1,                        % is mark
    zoom off;
    markStimRange;
    set(hbut, 'foregroundcolor', [.5 0 0]);
  case 2,                        % is zoom
    hCh = get(hax,'children');
    for ii=1:length(hCh),
      set(hCh, 'buttondownfcn', '');
      end % (for)
    set(hax, 'buttondownfcn', '');
    zoom on
    set(hmsg,'string', ...
    '***WARNING*** After zooming on log scale, tick marks will be incorrect (matlab bug)');
    set(hmsg,'backgroundcolor',WARNCOLOR);
    set(hbut, 'foregroundcolor', [0 0 0]);
  otherwise,                     % is mark range for spontaneous-rate estimate
    zoom off;
    markSpontRange;
    set(hbut, 'foregroundcolor', [0 .5 0]);
  end %   (switch)
  
return
