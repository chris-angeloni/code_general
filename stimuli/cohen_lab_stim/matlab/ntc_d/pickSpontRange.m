function pickSpontRange

global selectedSpontRange 
  
INCLUDE_DEFS;

hfig = gcf;
hax = findobj(hfig,'tag', 'TuningCurveAxes');
axes(hax);
hrect = findobj(hfig,'tag', 'spontRect');
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
hrect = plot(x,y,'g');		    % redraw in dataspace units       %
set(hrect, 'tag', 'spontRect');				      %
set(hrect, 'erasemode', 'xor'); 				      %

p2 = max(point1, point2);

selectedSpontRange = [p1(1), p2(1), p1(2), p2(2)];

spontRate = compSpontRate;

messString = sprintf(...
    ['Spontaneous estimate: %.2f spikes/sec in the region %.2f - %.2f kHz by ',  ... 
     '%.2f - %.2f dB'], spontRate, selectedSpontRange);       

hMessages = findobj(hfig, 'tag', 'MessageText');
set(hMessages, 'string', messString);

return
