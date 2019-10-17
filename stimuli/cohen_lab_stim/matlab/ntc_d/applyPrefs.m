function applyPrefs()

global ntcPrefs latencies extAtten selectedStimRange selectedSpontRange nOctaves fMin

INCLUDE_DEFS;

% hRB = findobj('tag','RefreshButton');
% set(hRB, 'backgroundcolor', WARNCOLOR);

prefValues = ntcPrefs(PREFVALUE);

[defAttC, rest] = strtok(prefValues.defaultAtten, '[, ]');
[defAttI, rest] = strtok(rest, '[, ]');
if isfinite(str2num(defAttI)),
    set(findobj('tag', 'AttenIEdit'), 'string', num2str(defAttI));
    extAtten = str2num(defAttI);
  end % (if)
if isfinite(str2num(defAttC)),
    set(findobj('tag', 'AttenCEdit'), 'string', num2str(defAttC));
    extAtten = str2num(defAttC);
  end % (if)
 
[dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
selectedStimRange = [dispFreqs([1 end]) dispAmps([1 end])];
selectedSpontRange = [dispFreqs([1 end]) dispAmps([1 1])];

if ~strcmp(prefValues.outputDir,'*'),
    set(findobj('tag','OutdirectoryText'),...
           'string',prefValues.outputDir);
  end % (if)

if ~strcmp(prefValues.outputFile,'*'),
    set(findobj('tag','OutfileText'),...
           'string',prefValues.outputFile);
  end % (if)
           
if ~strcmp(prefValues.dataDir,'*'),
    set(findobj('tag','InfileDirectoryText'),...
           'string',prefValues.dataDir);
  end % (if)
  
if ~strcmp(prefValues.dataFile,'*'),
    set(findobj('tag','InfileText'),...
           'string',prefValues.dataFile);
  end % (if)
  
trange = eval(prefValues.Time);
set(findobj('tag','RangeStartText'), ...
            'string', num2str(trange(1)));
set(findobj('tag','RangeEndText'), ...
            'string', num2str(trange(2)));
trange = eval(prefValues.axisHistogram);
set(findobj('tag','StartSlider'), ...
            'Max', trange(2));
set(findobj('tag','DurationSlider'), ...
            'Max', trange(2));
set(findobj('tag','StaticMaxTime'), ...
            'String', sprintf('%5.1f', trange(2)));

switch(prefValues.displayType),
  case 'PColor',
    setDisplayType(findobj('tag','PColorOption'));
  case 'Contour',
    setDisplayType(findobj('tag','ContourOption'));
  case 'Surface',
    setDisplayType(findobj('tag','SurfaceOption'));
  case 'RasterByFreq',
    setDisplayType(findobj('tag','FreqRasterOption'));
  case 'RasterByInt',
    setDisplayType(findobj('tag','IntRasterOption'));
  case 'TwoLines',
    setDisplayType(findobj('tag','Lines2Option'));
  otherwise,
    setDisplayType(findobj('tag','LinesOption'));
  end % (switch)
  
switch(prefValues.smoothType),
  case 'Smooth2',
    setSmoothing(findobj('tag','Smooth2Option'));
  case 'Smooth1',
    setSmoothing(findobj('tag','Smooth1Option'));
  case 'MedianSmooth',
    setSmoothing(findobj('tag','SmoothMOption'));
  otherwise,
    setSmoothing(findobj('tag','NoSmoothOption'));
  end % (switch)

yesno = {'yes','no'};
if ~strcmp(yesno(1+get(findobj('tag','BlindBox'),'value')), ...
           prefValues.blind),
    toggleBlind;
  end; % (if)

spPerc = round(eval(prefValues.spontPercent));
set(findobj('tag','PercentEdit'), 'string', num2str(abs(spPerc)));
if spPerc>0,
    set(findobj('tag','SpontBox'),'value',1);
  else
    set(findobj('tag','SpontBox'),'value',0);
  end;  % (if)

fxSize = eval(prefValues.fixedSize);  
set(findobj('tag','ScaleText'), 'string', num2str(abs(fxSize)));
if fxSize>0,
    set(findobj('tag','ScalePopup'),'value',1);
  else
    set(findobj('tag','ScalePopup'),'value',2);
  end;  % (if)
            
updateFromRange;
spontButton;
setScale;
setBackground(prefValues.background);

hHA = findobj('tag', 'LatencyAxes');
if ~isempty(hHA),
    set(hHA,'YLim', eval(prefValues.axisLatency));
  end
  
hHA = findobj('tag', 'HistogramAxes');
if ~isempty(hHA),
    set(hHA,'XLim', eval(prefValues.axisHistogram));
  end
  
return
