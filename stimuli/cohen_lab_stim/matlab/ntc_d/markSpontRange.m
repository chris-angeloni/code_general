function markSpontRange

global selectedSpontRange fMin nOctaves extAtten NAMPS NFREQS

INCLUDE_DEFS;

hTC = findobj('tag', 'TuningCurveAxes');
set(hTC, 'nextplot', 'add');

hrect = findobj('tag', 'spontRect');
if ~isempty(hrect),
    delete(hrect);
  end

% draw current spontaneous area
[dispFreqs, dispAmps] = makePColorAxes(fMin, nOctaves, extAtten);
xLow =  dispFreqs(max([find(dispFreqs<selectedSpontRange(1)) 1       ]));
xHigh = dispFreqs(min([find(dispFreqs>selectedSpontRange(2)) NFREQS+1]));
yLow =  dispAmps( max([find(dispAmps <selectedSpontRange(3)) 1       ]));
yHigh = dispAmps( min([find(dispAmps >selectedSpontRange(4)) NAMPS+1 ]));

x = [xLow xHigh xHigh xLow xLow];
y = [yLow yLow yHigh yHigh yLow];
hrect = plot(x,y,'g');		    
set(hrect, 'tag', 'spontRect');	

set(hTC, 'buttondownfcn', 'pickSpontRange');
hCh = get(hTC,'children');
for ii=1:length(hCh),
  set(hCh, 'buttondownfcn', 'pickSpontRange');
  end % (for)

hMessages = findobj('tag', 'MessageText');
set(hMessages, 'string', 'Drag out rectangle to mark range for spontaneous estimate');
set(hMessages, 'backgroundcolor', MESSAGECOLOR);
                          
return
