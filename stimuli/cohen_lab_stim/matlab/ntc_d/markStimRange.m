function markStimRange

global selectedStimRange fMin nOctaves extAtten NAMPS NFREQS

INCLUDE_DEFS;

hTC = findobj('tag', 'TuningCurveAxes');
set(hTC, 'nextplot', 'add');

hrect = findobj('tag', 'selectedRect');
if ~isempty(hrect),
    delete(hrect);
  end

% draw current spontaneous area
[dispFreqs, dispAmps] = makePColorAxes(fMin, nOctaves, extAtten);
xLow =  dispFreqs(max([find(dispFreqs<selectedStimRange(1)) 1       ]));
xHigh = dispFreqs(min([find(dispFreqs>selectedStimRange(2)) NFREQS+1]));
yLow =  dispAmps( max([find(dispAmps <selectedStimRange(3)) 1       ]));
yHigh = dispAmps( min([find(dispAmps >selectedStimRange(4)) NAMPS+1 ]));

x = [xLow xHigh xHigh xLow xLow];
y = [yLow yLow yHigh yHigh yLow];
hrect = plot(x,y,'r');		    
set(hrect, 'tag', 'selectedRect');	

set(hTC, 'buttondownfcn', 'pickStimRange');
hCh = get(hTC,'children');
for ii=1:length(hCh),
  set(hCh, 'buttondownfcn', 'pickStimRange');
  end % (for)

hMessages = findobj('tag', 'MessageText');
set(hMessages, 'string', 'Drag out rectangle to mark stimulus range ');
set(hMessages, 'backgroundcolor', MESSAGECOLOR);
                          
return
