function selectLatency

global selectedLatency

INCLUDE_DEFS;

[hobj, hfig] = gcbo;

putNewAttribute(LATENCY, selectedLatency);

hMessages = findobj(hfig, 'tag', 'LatencyMessage');
messString = sprintf('latency: %5.2f ms', selectedLatency);
set(hMessages, 'string', messString);
set(hMessages, 'backgroundcolor', NORMCOLOR);

hSelButton = findobj(gcf, 'tag', 'MarkLatencyButton');
set(hSelButton, 'backgroundcolor', NORMBUTTONCOLOR);
                          
return
