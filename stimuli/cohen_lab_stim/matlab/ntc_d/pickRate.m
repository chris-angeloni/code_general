function pickRate

global fMin nOctaves extAtten selectedRateInfo

INCLUDE_DEFS;

hfig = gcf;

point1 = get(gca,'CurrentPoint');% button down detected
point1 = point1(1,1:2);          % extract x and y
x = point1(1);
y = point1(2);

hRTR = findobj(hfig, 'tag', 'RateThreshRadio');
hRRR = findobj(hfig, 'tag', 'RateTransitionRadio');
hRER = findobj(hfig, 'tag', 'RateEndRadio');
hBAR = findobj(hfig, 'tag', 'BestAmplRadio');

axLim = axis;

if get(hRTR, 'value') == 1,
    selectedRateInfo(1) = x;
    set(hRTR, 'value', 0);
    set(hRRR, 'value', 1);
  elseif get(hRRR, 'value') == 1, 
    selectedRateInfo(2) = x;
    selectedRateInfo(3) = y;
    set(hRRR, 'value', 0);
    set(hRER, 'value', 1);
  elseif get(hRER, 'value') == 1,
    selectedRateInfo(4) = x;
    selectedRateInfo(5) = y;
    set(hRER, 'value', 0);
    set(hBAR, 'value', 1);
  elseif get(hBAR, 'value') == 1, 
    selectedRateInfo(6) = x;
    selectedRateInfo(7) = y;
    set(hBAR, 'value', 0);
    set(hRTR, 'value', 1);
  else
  end % (if)
  
x = selectedRateInfo([1 2 4]);
y = [0 selectedRateInfo([3 5])];

hMR = findobj(hfig, 'tag', 'ModelRate');
if ~isempty(hMR),
    delete(hMR);
  end
hBR = findobj(hfig, 'tag', 'BestAmp');
if ~isempty(hBR),
    delete(hBR);
  end
     
% plot(x,y,'k', 'erasemode', 'xor', 'tag', 'ModelRate');
% plot(selectedRateInfo(6), selectedRateInfo(7), 'ko', ...
%        'erasemode', 'xor', 'tag', 'BestAmp');
plot(x,y,'k', 'tag', 'ModelRate', 'buttondownfcn', 'pickRate');
plot(selectedRateInfo(6), selectedRateInfo(7), 'ko', ...
       'tag','BestAmp', 'buttondownfcn','pickRate');

hAccButton = findobj(hfig,'tag','RateAcceptButton');
set(hAccButton,'backgroundcolor',WARNCOLOR);
% hMessages = findobj(hfig,'tag','RateMessages');
% set(hMessages,'string','accept or be destroyed -- resistance is futile');
% set(hMessages,'backgroundcolor', WARNCOLOR);

return
