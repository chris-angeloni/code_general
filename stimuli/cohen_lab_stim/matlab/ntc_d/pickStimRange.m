function pickStimRange

global selectedStimRange
  
INCLUDE_DEFS;

hfig = gcf;
hax = findobj(hfig,'tag', 'TuningCurveAxes');
axes(hax);
hrect = findobj(hfig,'tag', 'selectedRect');
if ~isempty(hrect),
    delete(hrect);
  end
  
point1 = get(hax,'CurrentPoint');% button down detected
finalRect = rbbox;		 % return Figure units
point2 = get(hax,'CurrentPoint');% button up detected
point1 = point1(1,1:2);          % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);	 % calculate locations
offset = abs(point1-point2);	 % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];

% putting in the following plot command made matlab barf big time
%

set(hax,'nextplot','add');					      %
hrect = plot(x,y,'r');		    % redraw in dataspace units       %
set(hrect, 'tag', 'selectedRect');				      %
set(hrect, 'erasemode', 'xor'); 				      %

p2 = max(point1, point2);

hFR = findobj('tag','FreqRasterOption');
hIR = findobj('tag','IntRasterOption');
hRS = findobj('tag', 'RangeStartText');
hRE = findobj('tag', 'RangeEndText');

if strcmp(get(hFR,'checked'), 'on'),
    bndyTimes = round([p1(2) p2(2)]);
    messString = sprintf('Selected Time Range: %3d - %3d ms', bndyTimes);
    set(hRS,'string', num2str(bndyTimes(1)));
    set(hRE, 'string', num2str(bndyTimes(2)));
    updateFromRange;
  elseif strcmp(get(hIR,'checked'),'on'),
    bndyTimes = round([p1(1) p2(1)]);
    messString = sprintf('Selected Time Range: %3d - %3d ms', bndyTimes);
    set(hRS,'string', num2str(bndyTimes(1)));
    set(hRE, 'string', num2str(bndyTimes(2)));
    updateFromRange; 
  else
    selectedStimRange = [p1(1), p2(1), p1(2), p2(2)];
    messString = sprintf(...
        'Marked Range: frequency: %5.2f - %5.2f   amplitude: %5.2f - %5.2f', ...
        selectedStimRange);       
    hZapRange = findobj(hfig,'tag','ZapRangeButton');
    set(hZapRange,'enable','on');
  end % (if)
  
hMessages = findobj(hfig, 'tag', 'MessageText');
set(hMessages, 'string', messString);

return
