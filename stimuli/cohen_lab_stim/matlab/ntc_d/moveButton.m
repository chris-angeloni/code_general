function moveButton
[hobj, hfig] = gcbo;

hStart = findobj(hfig,'tag','RangeStartText');
hEnd = findobj(hfig,'tag','RangeEndText');

startVal = str2num(get(hStart,'string'));
endVal = str2num(get(hEnd,'string'));

durVal = endVal - startVal;

switch get(hobj, 'tag') 
  case 'ForwardButton',
         deltaVal = durVal;
  case 'HalfForwardButton',
         deltaVal = durVal/2;
  case 'ReverseButton',
         deltaVal = -durVal;
  case 'HalfReverseButton',
         deltaVal = -durVal/2;
  otherwise,
  end % (switch)

set(hStart, 'string', num2str(startVal+deltaVal));
set(hEnd, 'string', num2str(endVal+deltaVal));

updateFromRange;
refreshDisplay;

return
