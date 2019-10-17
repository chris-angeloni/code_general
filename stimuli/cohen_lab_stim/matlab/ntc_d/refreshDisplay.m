function refreshDisplay

global latencies fMin nOctaves extAtten dataMat latencies2 dispFreqs2 dispAmps2

NORMBUTTONCOLOR = [0.7 0.7 0.7];


hax = findobj('tag','TuningCurveAxes');
axes(hax);

hmenu = findobj('tag','DisplayMenu');

hoptions = get(hmenu,'children');
dispType = get(hoptions(strcmp('on',get(hoptions,'Checked'))),'Tag');

minLatency = get(findobj('tag','RangeStartText'),'string');
minLatency = str2num(minLatency);
maxLatency = get(findobj('tag','RangeEndText'),'string');
maxLatency = str2num(maxLatency);
dataMat = makeDataMat(latencies, minLatency, maxLatency);

set(hax,'nextplot','replacechildren');

set(get(hax,'xlabel'), 'rotation', 0, ...
       'verticalalignment', 'cap');
set(get(hax,'ylabel'), 'rotation', 90, ...
       'verticalalignment', 'baseline');

view([0 90]);
switch dispType
  case 'ColorOption',
    [displayMat, dispFreqs, dispAmps] = ...
       makeDisplayMat(dataMat, extAtten, fMin, nOctaves);
    pcolorTimeSlice(displayMat, dispFreqs, dispAmps);
  case 'LinesOption',
    displayMat = dataMat;
    [dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
    quiverTimeSlice(displayMat, dispFreqs, dispAmps);
    latencies2 = latencies;
    dispFreqs2 = dispFreqs;
    dispAmps2 = dispAmps;
  case 'Lines2Option',
    displayMat = dataMat;
    [dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
    quiverTimeSlice(displayMat, dispFreqs, dispAmps);
    if ~isempty(latencies2),
        dataMat2 = makeDataMat(latencies2, minLatency, maxLatency);
        displayMat2 = dataMat2;
        addQuivers(displayMat2, dispFreqs2, dispAmps2, dispFreqs, dispAmps);
      end % (if)
  case 'ContourOption',
    displayMat = dataMat;
    [dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
    contourfTimeSlice(dispFreqs, dispAmps, displayMat');   
  case 'SurfaceOption',
    [displayMat, dispFreqs, dispAmps] = ...
       makeDisplayMat(dataMat, extAtten, fMin, nOctaves);
    surfTimeSlice(displayMat, dispFreqs, dispAmps);    
  case 'FreqRasterOption',
    [dataFreqs, tickFreqs] = makeDotAxes(fMin, nOctaves);
    dotHistogram(latencies, tickFreqs, dataFreqs);
  case 'IntRasterOption',
    [dataAmps, tickAmps] = makeDotIAxes(extAtten);
    dotHistogramI(latencies, tickAmps, dataAmps);
  otherwise,
    disp('say no more');
  end
  
hbl = findobj('tag', 'BlindBox');
if get(hbl, 'value') == 1,
    set(findobj(gcf,'tag','TuningCurveAxes'),'visible','off');
  end


set(findobj(gcf,'tag','RefreshButton'),'backgroundcolor',NORMBUTTONCOLOR);

return

%%%--------------------


function contourfTimeSlice(dispFreqs, dispAmps, displayMat);   

hax = findobj('tag','TuningCurveAxes');

axes(hax);
contourf(dispFreqs, dispAmps, displayMat);
set(gca,'yticklabelmode','auto');
set(gca,'ytickmode','auto');
set(gca,'yscale','linear');
set(gca,'xscale','log');
xlabel('frequency (kHz)');
ylabel('stimulus intensity (dB)');

hScalePopup = findobj('tag','ScalePopup');
if get(hScalePopup,'value') == 1,  % then fixed scale
    hScaleText = findobj('tag','ScaleText');
    scaleMax = str2num(get(hScaleText,'string'));
    if isempty(scaleMax),
        scaleMax = 1;
        set(hScaleText,'string',num2str(scaleMax));
      end
  else
    scaleMax = max(displayMat(:));
  end

caxis([0 scaleMax]);

ntcColorBar(scaleMax);

dullButtons;

return

%%%-------------------------


function dotHistogram(latencies, tickFreqs, dataFreqs)
% function dotHistogram(latencies, tickFreqs, dataFreqs)

global NFREQS NAMPS ntcPrefs

INCLUDE_DEFS;

axPrefLim = eval(ntcPrefs(PREFVALUE).axisHistogram);
tMin = axPrefLim(1);
tMax = axPrefLim(2);

hax = findobj('tag','TuningCurveAxes');

axes(hax);
cla
set(gca,'nextplot','add');  % like 'hold on'

if get(hax,'color') == [1 1 1],   % (white background, so plot blue)
    dotStr = '.b';
  else                            % (black background, so plot yellow?)
    dotStr = '.y';
  end

for ii=1:length(tickFreqs),
    plot(tickFreqs([ii ii]), [tMin tMax], 'r');
  end
  
set(gca,'xscale', 'log');
set(gca,'yscale', 'linear');

set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');

axis([tickFreqs([1 end]) tMin tMax]);

plot(dataFreqs((latencies(:,2)-1)*NAMPS+latencies(:,3)),...     
     latencies(:,1), ...
     dotStr, 'markersize',8);
     
xTickPos = makeFreqTicks(dataFreqs);
set(gca,'xtick', xTickPos);

set(gca,'xtickmode','manual');

ylabel('time (msec)');
xlabel('stimulus frequency (kHz)');

set(gca,'nextplot','replacechildren');  % keep axes, but not figure

ntcDotBar;

dullButtons;

return

%%%------------------


function dotHistogramI(latencies, lineAmps, dataAmps)
% function dotHistogramI(latencies, lineAmps, dataAmps)

global extAtten NFREQS NAMPS ntcPrefs

INCLUDE_DEFS;

axPrefLim = eval(ntcPrefs(PREFVALUE).axisHistogram);
tMin = axPrefLim(1);
tMax = axPrefLim(2);

hax = findobj('tag','TuningCurveAxes');

axes(hax);

if get(hax,'color') == [1 1 1],   % (white background, so plot blue)
    dotStr = '.b';
  else
    dotStr = '.y';                % (for black background, plot yellow)
  end

cla
set(gca,'nextplot','add');  % like 'hold on'

for ii=1:length(lineAmps),
    plot([tMin tMax], lineAmps([ii ii]), 'r');
  end
  
set(gca,'yscale', 'linear');
set(gca,'xscale', 'linear');

axis([tMin tMax lineAmps([1 end])]);


plot(latencies(:,1), ...
      dataAmps((latencies(:,3)-1)*NFREQS+latencies(:,2)),dotStr,...     
     'markersize',8);
     
tickAmps = makeAmps + 30 - extAtten;
set(gca,'ytick', tickAmps);
set(gca,'yticklabel', num2str(tickAmps','%4.1f'));


set(gca,'ytickmode','manual');
set(gca,'xtickmode','auto');

xlabel('time (msec)');
ylabel('stimulus intensity (dB)');

set(gca,'nextplot','replacechildren');  % keep axes, but not contents

ntcDotBar;

dullButtons;

return

%%%--------------------------


function [dataAmps, tickAmps] = makeDotIAxes(extAtten);
% function [dataAmps, tickAmps] = makeDotIAxes(extAtten);

global NFREQS NAMPS

INCLUDE_DEFS;

% these amplitudes are
%   NOT the real stimulus amplitudes, but are one half-step off.

% dispAmps = DEFAULT_AMPS;
% if isfinite(extAtten),
%   dispAmps = dispAmps + (30 - extAtten);
%   end

if ~isfinite(extAtten),
    extAtten = 0;
  end

tAmps = makeAmps;
ampMax = tAmps(NAMPS) + 30 - extAtten;
ampMin = tAmps(1) + 30 - extAtten;

step = (ampMax-ampMin)/(NAMPS-1);
dispAmps = linspace(ampMin-step/2, ampMax+step/2, NAMPS*(NFREQS+1)+1);

tickAmpInd = 1:(NFREQS+1):(NAMPS*(NFREQS+1)+1);
dataAmpInd = ones((NAMPS*(NFREQS+1)+1),1);
dataAmpInd(tickAmpInd) = 0;

tickAmps = dispAmps(tickAmpInd);
dataAmps = dispAmps(logical(dataAmpInd));

return

%%%--------------


function pcolorTimeSlice(displayMat, dispFreqs, dispAmps);
% function pcolorTimeSlice(displayMat, dispFreqs, dispAmps);

hax = findobj('tag','TuningCurveAxes');
axes(hax);

pcolor(dispFreqs,dispAmps,displayMat');
shading flat;
set(gca,'xscale','log');
set(gca,'yscale','linear');
set(gca,'tickdir','out');
set(gca,'ytickmode','auto');
set(gca,'yticklabelmode','auto');
xlabel('frequency (kHz)');
ylabel('stimulus intensity (dB)');


xTickPos = makeFreqTicks(dispFreqs);
% set(gca,'xtickmode','auto');
set(gca,'xtick', xTickPos);
% set(gca,'xticklabelmode','manual');
set(gca,'nextplot', 'replacechildren');

scaleMax = max(displayMat(:));

hScalePopup = findobj('tag','ScalePopup');
if get(hScalePopup,'value') == 1,  % then fixed scale
    hScaleText = findobj('tag','ScaleText');
    scaleMax = str2num(get(hScaleText,'string'));
    if isempty(scaleMax),
        scaleMax = 1;
        set(hScaleText,'string',num2str(scaleMax));
      end
  end

caxis([0 scaleMax]);

ntcColorBar(scaleMax);
dullButtons;

return

%%%-----------------------


function quiverTimeSlice(displayMat, dispFreqs, dispAmps)

hax = findobj('tag','TuningCurveAxes');
axes(hax);


if get(hax,'color') == [1 1 1],   % (white background, so plot blue)
    lineStr = '.-b';
    dotStr = '.-w';
  else
    lineStr = '.-y';              % (for black background, plot yellow)
    dotStr = '.-k';
  end

hColorScale = findobj('tag','ScalePopup');
if get(hColorScale,'value') == 1,                    % then fixed scale
    hScaleText = findobj('tag','ScaleText');
    scaleMax = str2num(get(hScaleText,'string'));
    deltaAmp = dispAmps(2)-dispAmps(1);
    quiver(dispFreqs, dispAmps ,zeros(size(displayMat')),...
        deltaAmp/(scaleMax+1)*min(scaleMax,displayMat'), 0, lineStr);
  else                                               % floating scale
    scaleMax = max(displayMat(:));
    if scaleMax == 0,
        quiver(dispFreqs, dispAmps ,zeros(size(displayMat')),...
            displayMat', 0, lineStr);
      else
        quiver(dispFreqs, dispAmps ,zeros(size(displayMat')),...
            displayMat', lineStr);
      end
  end

xlabel('frequency (kHz)');
ylabel('stimulus intensity (dB)');

xTickPos = makeFreqTicks(dispFreqs);
nFreqs = length(dispFreqs);
fMin = dispFreqs(1);
nOctaves = log2(dispFreqs(end)/dispFreqs(1));
axXLim = [fMin*2^(-nOctaves/nFreqs/2) fMin*2^nOctaves*2^(nOctaves/nFreqs/2)];
axYLim = dispAmps([1 end]) + [-0.1 1.1]*(dispAmps(end)-dispAmps(end-1));

set(hax,'grid','none', ...
        'tickdir','out', ...
        'xlim', axXLim, ...
        'xscale','log', ...
        'yscale','linear', ...
        'xtick', xTickPos, ...
        'ylim', axYLim, ...
        'ytickmode','auto', ...
        'yticklabelmode','auto');


% the following is an evil, but effective, way to get rid of the little
%   zero-length dots that quiver plots
%
set(hax,'nextplot','add');

hqd = quiver(dispFreqs, dispAmps , ...
       ones(size(displayMat')),zeros(size(displayMat')), .00001, dotStr);
if get(findobj('tag','BlindBox'),'value')==1,
    set(hqd,'color',[0.8 0.8 0.8]);      % the default background gray color
  end % (if)
set(hax,'nextplot', 'replacechildren');

ntcQuiverBar(scaleMax);

dullButtons;

return

%%%---------------------


function addQuivers(displayMat2, dispFreqs2, dispAmps2, dispFreqs, dispAmps)

dispFreqs2 = 2^(0.33*log2(dispFreqs2(2)/dispFreqs2(1)))*dispFreqs2;

hax = findobj('tag','TuningCurveAxes');
axes(hax);
set(hax, 'nextplot', 'add');

lineStr = '.-r';
if get(hax,'color') == [1 1 1],   % (white background)
    dotStr = '.-w';
  else
    dotStr = '.-k';
  end

hColorScale = findobj('tag','ScalePopup');
if get(hColorScale,'value') == 1,                    % then fixed scale
    hScaleText = findobj('tag','ScaleText');
    scaleMax = str2num(get(hScaleText,'string'));
    deltaAmp = dispAmps2(2)-dispAmps2(1);
    quiver(dispFreqs2, dispAmps2 ,zeros(size(displayMat2')),...
        deltaAmp/(scaleMax+1)*min(scaleMax,displayMat2'), 0, lineStr);
  else                                               % floating scale
    quiver(dispFreqs2, dispAmps2 ,zeros(size(displayMat2')),...
        displayMat2', lineStr);
  end

nFreqs = length(dispFreqs2);
fMinLo = min([dispFreqs2(1) dispFreqs(1)]);
fMinHi = max([dispFreqs2(1) dispFreqs(1)]);
nOctaves = log2(dispFreqs2(end)/dispFreqs2(1));
axXLim = [fMinLo*2^(-nOctaves/nFreqs/2) fMinHi*2^nOctaves*2^(nOctaves/nFreqs/2)];

minAmp = min([dispAmps2(:); dispAmps(:)]);
maxAmp = max([dispAmps2(:); dispAmps(:)]);
ampInc = dispAmps(end)-dispAmps(end-1);
axYLim = [minAmp maxAmp] + [-0.1 1.1]*(ampInc);

set(hax, 'xlim', axXLim, ...
         'ylim', axYLim);

set(hax,'nextplot','add');
quiver(dispFreqs2, dispAmps2 , ...
       ones(size(displayMat2')),zeros(size(displayMat2')), .00001, dotStr);
set(hax,'nextplot', 'replacechildren');

return 

%%%---------------------

function surfTimeSlice(displayMat, dispFreqs, dispAmps);
% function surfTimeSlice(displayMat, dispFreqs, dispAmps);


hax = findobj('tag','TuningCurveAxes');
axes(hax);

surf(dispFreqs,dispAmps,displayMat');
shading interp;

xTickPos = makeFreqTicks(dispFreqs);
dispMin = min(displayMat(:));
dispMax = max(displayMat(:));
set(hax,'grid','none', ...
        'tickdir','out', ...
        'xlim', dispFreqs([1 end]), ...
        'xscale','log', ...
        'yscale','linear', ...
        'xtick', xTickPos, ...
        'ylim', dispAmps([1 end]), ...
        'ytickmode','auto', ...
        'yticklabelmode','auto', ...
        'zlim', [dispMin-(dispMax-dispMin) dispMax+2*(dispMax-dispMin)]);
view([10 30]);
xlabel('frequency (kHz)','rotation', -3, ...
       'verticalalignment', 'bottom');
ylabel('stimulus intensity (dB)','rotation', 67.5, ...
       'verticalalignment','bottom');
zlabel('response amplitude','rotation', 90, ...
       'verticalalignment','middle');

hScalePopup = findobj('tag','ScalePopup');
if get(hScalePopup,'value') == 1,  % then fixed scale
    hScaleText = findobj('tag','ScaleText');
    scaleMax = str2num(get(hScaleText,'string'));
    if isempty(scaleMax),
        scaleMax = 1;
        set(hScaleText,'string',num2str(scaleMax));
      end
  else
    scaleMax = max(displayMat(:));
  end

caxis([0 scaleMax]);

ntcColorBar(scaleMax);

dullButtons;

return

%%%-----------------------

function hcolorbar = ntcColorBar(scaleMax)

hcolorbar = findobj('tag','ColorBar');

axes(hcolorbar);
cbMax = ceil(scaleMax);
cbLabelPos = (0:cbMax)+0.5;
hColorScale = findobj('tag','ScalePopup');
if get(hColorScale,'value') == 1,                    % then fixed scale
    cbLabels = num2str([(0:cbMax-1) cbMax-1]');
    cbLabels = [[' '*ones(cbMax,1); '>'] cbLabels];
  else
    cbLabels = num2str((0:cbMax)');
  end % (if)
caxis([0 cbMax]);
axis([-1 1 0 cbMax+1]);
pcolor([-1 1], [0:cbMax+1], [(0:cbMax)'; cbMax] * [1 1]);
shading flat;
set(hcolorbar,'ytick',cbLabelPos, ...
              'yticklabel', cbLabels);

set(hcolorbar,'visible','on');
return


%%%-----------------------

function hcolorbar = ntcQuiverBar(scaleMax)

scaleMax = max(1,scaleMax);

hcolorbar = findobj('tag','ColorBar');
axes(hcolorbar);

hColorScale = findobj('tag','ScalePopup');
if get(hColorScale,'value') == 1,                    % then fixed scale
    axis([-1 1 0 scaleMax]);
    set(hcolorbar,'ytick', [0 scaleMax]);
    set(hcolorbar,'yticklabel', [[' '; '>'] num2str([0;(scaleMax-1)])]);
  else                                               % floating scale
    axis([-1 1 0 scaleMax]);
    set(hcolorbar,'ytick', [0 scaleMax]);
    set(hcolorbar,'yticklabel', num2str([0;scaleMax]));
  end

set(hcolorbar,'visible','on');
set(get(hcolorbar,'children'),'visible','off');

return

%%%-----------------------


function hcolorbar = ntcDotBar();

hcolorbar = findobj('tag','ColorBar');
set(hcolorbar,'visible','off');
set(get(hcolorbar,'children'),'visible','off');

return

%%%-----------------------

