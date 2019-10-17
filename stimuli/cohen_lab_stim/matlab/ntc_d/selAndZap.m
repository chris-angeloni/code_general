function selAndZap

global latencies fMin nOctaves extAtten 

INCLUDE_DEFS;

[hobj,hfig] = gcbo;

hax = findobj(hfig,'tag', 'TuningCurveAxes');
axes(hax);

point1 = get(hax,'CurrentPoint');% button down detected
x = point1(1,1);          % extract x and y
y = point1(1,2);          % extract x and y

[dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
tFreqs = abs(x-dispFreqs);
tAmps = abs(y-dispAmps);

zapFreqInd = find(tFreqs == min(tFreqs));
zapAmpInd = find(tAmps == min(tAmps));
    
keepInds = ~ismember(latencies(:,2), zapFreqInd) | ...
           ~ismember(latencies(:,3), zapAmpInd);
          
latencies = latencies(keepInds,:);

hMessages = findobj(hfig,'tag','MessageText');
set(hMessages,'string',sprintf('freq: %5.2f   amp: %5.2f', ...
             dispFreqs(zapFreqInd), dispAmps(zapAmpInd)));
set(hMessages,'backgroundcolor', MESSAGECOLOR);

hRefresh = findobj(hfig,'tag','RefreshButton');
set(hRefresh,'backgroundcolor',WARNCOLOR);

% refreshDisplay;

return



