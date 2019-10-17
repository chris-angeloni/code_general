function pickLatency

global fMin nOctaves extAtten selectedLatency

INCLUDE_DEFS;

hfig = gcf;

hline = findobj(gcf,'tag', 'selectedLatency');
if ~isempty(hline),
    delete(hline);
  end

[freqs, amps] = makeQuiverAxes(fMin, nOctaves, extAtten);

point1 = get(gca,'CurrentPoint');% button down detected
point1 = point1(1,1:2);          % extract x and y

y = point1(2);

hline = plot(amps([1 end]), [y y], 'b');   % redraw in dataspace units 
set(hline, 'tag', 'selectedLatency', 'buttondownfcn','pickLatency');
% set(hline, 'erasemode', 'xor');

selectedLatency = y;

hMessages = findobj(hfig, 'tag', 'LatencyMessage');
messString = sprintf('Accept (%5.2f ms) or click on new latency', y);
set(hMessages, 'string', messString);
set(hMessages, 'backgroundcolor', MESSAGECOLOR);

hSelButton = findobj(gcf, 'tag', 'MarkLatencyButton');
set(hSelButton, 'backgroundcolor', WARNCOLOR);
set(hSelButton, 'callback', 'selectLatency');
  
return
