function dullButtons
% function dullButtons
%
%  set user interface buttons active/inactive as appriate to display type

hmenu = findobj('tag','DisplayMenu');

hoptions = get(hmenu,'children');
dispType = get(hoptions(strcmp('on',get(hoptions,'Checked'))),'Tag');

switch dispType
  case {'ColorOption','LinesOption','ContourOption','Lines2Option'},
    dullDir1 = 'on';
    dullDir2 = 'on';
    set(findobj('Tag','markOrZoomRadio'), 'enable','on');
    set(findobj('Tag','ZapButton'), 'enable','on');
    set(findobj('Tag','PointButton'),'enable','on');
  case 'SurfaceOption',
    dullDir1 = 'off';
    dullDir2 = 'on';
    set(findobj('Tag','markOrZoomRadio'), 'enable','off');
    set(findobj('Tag','ZapButton'), 'enable','off');
    set(findobj('Tag','PointButton'),'enable','off');
  case {'FreqRasterOption','IntRasterOption'},
    dullDir1 = 'off';
    dullDir2 = 'off';
    set(findobj('Tag','markOrZoomRadio'), 'enable','on');
    set(findobj('Tag','ZapButton'), 'enable','on');
    set(findobj('Tag','PointButton'),'enable','on');
 otherwise,
  end;
  
% set enable for measure-tuning type buttons
set(findobj('Tag','CFButton'),'enable',dullDir1);
set(findobj('Tag','Q10Button'),'enable',dullDir1);
set(findobj('Tag','Q20Button'),'enable',dullDir1);
set(findobj('Tag','Q30Button'),'enable',dullDir1);
set(findobj('Tag','Q40Button'),'enable',dullDir1);
set(findobj('Tag','AllButton'),'enable',dullDir1);

% set enable for display-time-slice type buttons
set(findobj('Tag','BlindBox'),'enable',dullDir2);
set(findobj('Tag','ReverseButton'),'enable',dullDir2);
set(findobj('Tag','HalfReverseButton'),'enable',dullDir2);
set(findobj('Tag','ForwardButton'),'enable',dullDir2);
set(findobj('Tag','HalfForwardButton'),'enable',dullDir2);
set(findobj('Tag','RangeStartText'),'enable',dullDir2);
set(findobj('Tag','RangeEndText'),'enable',dullDir2);
set(findobj('Tag','StartText'),'enable',dullDir2);
set(findobj('Tag','StartSlider'),'enable',dullDir2);
set(findobj('Tag','DurationSlider'),'enable',dullDir2);
set(findobj('Tag','DurationText'),'enable',dullDir2);
set(findobj('Tag','MoviePopup'),'enable',dullDir2);
set(findobj('Tag','SpontBox'),'enable',dullDir2);
set(findobj('Tag','ScalePopup'),'enable',dullDir2);


  

if strcmp(dullDir2,'on'),
    if get(findobj('Tag','SpontBox'),'value') == 1,
        dullDir3 = 'on';
      else
        dullDir3 = 'off';
      end % (if)
    set(findobj('Tag','PercentEdit'),'enable',dullDir3);
    if get(findobj('tag','ScalePopup'),'value') == 1,
        dullDir4 = 'on';
      else
        dullDir4 = 'off';
      end % (if)
    set(findobj('Tag','ScaleText'),'enable',dullDir4);
  else
    set(findobj('Tag','PercentEdit'),'enable','off');
    set(findobj('Tag','ScaleText'),'enable','off');
  end % (if)
      
return


