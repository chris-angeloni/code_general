function showHist

global latencies fMin nOctaves extAtten selectedStimRange ntcPrefs NFREQS NAMPS
global selectedHistos

INCLUDE_DEFS;

axPrefLim = eval(ntcPrefs(PREFVALUE).axisHistogram);
tMin = axPrefLim(1);
tMax = axPrefLim(2);
binTime = (tMax-tMin)/101;
histBins = tMin:binTime:tMax;

hfig = gcf;

hHistoAllRadio = findobj(hfig, 'tag', 'HistoAllRadio');

cla;

[freqVals, amps] = makeQuiverAxes(fMin, nOctaves, extAtten);

spikesInTimeRange = latencies(:,1)<=tMax & latencies(:,1)>=tMin;

[n, x] = hist(latencies(spikesInTimeRange,1),histBins);
lInd = selectedStimRange(1) <= freqVals(latencies(:,2)) & ...
        freqVals(latencies(:,2)) <= selectedStimRange(2) & ...
        selectedStimRange(3) <= amps(latencies(:,3)) & ...
        amps(latencies(:,3)) <= selectedStimRange(4) & ...
        spikesInTimeRange';
[m,y] = hist(latencies(lInd,1),histBins);

meanSpont = getNewAttribute(SPONT_EST);
stdSpont = getNewAttribute(SPONT_STD);

if get(hHistoAllRadio, 'value') == 1,
    plotSpontLev = (NFREQS*NAMPS*binTime/1000.0)*(meanSpont+stdSpont);
    hfill = fill([tMin tMax tMax tMin tMin], ...
          [0 0 plotSpontLev plotSpontLev 0], ...
          'c', 'edgecolor','none');
    hold on
    plot([tMin tMax], (NFREQS*NAMPS*binTime/1000.0)*[meanSpont,meanSpont], 'b');
    stairs(y,m,'g');
    hst=stairs(x,n);  set(hst,'color',[0.5 0.5 0.5]);
    m = conv(m,[0.25 0.5 0.25]);
    n = conv(n,[0.25 0.5 0.25]);
    plot(y,m(2:end-1),'color',[0.25 0.75 0.25]);
    plot(x,n(2:end-1),'k');
    maxInd = find(n(2:end-1)==max(n(2:end-1)));
    latMax = x(maxInd);
    minInds = find((n(2:end-1)<plotSpontLev & (n(3:end)-n(2:end-1))>0) | ...
                   n(2:end-1)==0);
    minInd = min(minInds(minInds>maxInd));
    latMin = x(minInd);
  else
    nlFreqs = sum(selectedStimRange(1)<=freqVals & ...
                  freqVals <= selectedStimRange(2));
    nlAmps =  sum(selectedStimRange(3)<=amps & ...
                  amps < selectedStimRange(4));
    plotSpontLev = (nlFreqs*nlAmps*binTime/1000.0)*(meanSpont+stdSpont);
    hfill = fill([tMin tMax tMax tMin tMin], ...
                 [0 0 plotSpontLev plotSpontLev 0], ...
                 'c', 'edgecolor','none');
    hold on
    plot([tMin tMax], (nlFreqs*nlAmps*binTime/1000.0)*...
        [meanSpont,meanSpont], 'b');

    hst = stairs(y,m);  set(hst,'color',[0.5 0.5 0.5]);
    stairs(x,n, 'g');
    m = conv(m,[0.25 0.5 0.25]);
    n = conv(n,[0.25 0.5 0.25]);
    plot(x,n(2:end-1),'color',[0.25 0.75 0.25]);
    plot(y,m(2:end-1),'k');
    maxInd = max(find(m(2:end-1)==max(m(2:end-1))));
    latMax = y(maxInd);
    minInds = find((m(2:end-1)<plotSpontLev & (m(3:end)-m(2:end-1))>0) | ...
                    m(2:end-1)==0);
    minInd = min(minInds(minInds>maxInd));
    latMin = y(minInd);
  end
          
xlabel('time (ms)');
ylabel('spikes');
grid on;
  
axis auto;
axLim = axis;
axis([axPrefLim 0 axLim(4)]);

peak1Peak = getNewAttribute(PK1PK);
peak1End = getNewAttribute(PK1END);
peak2Start = getNewAttribute(PK2START);
if (peak1Peak==0 & peak1End ==0), 
    if ~isempty(latMax),
        peak1Peak = latMax;
      else
        peak1Peak = 0;
      end % (if)
    if ~isempty(latMin),
        peak1End = latMin;
      else
        peak1End = 0;
      end %
    selectedHistos(1) = peak1Peak;
    selectedHistos(2) = peak1End;
    hButt = findobj('tag', 'HistoAcceptButton');
    set(hButt, 'backgroundcolor', WARNCOLOR);
  end % (if)

hold on
%h = plot(peak1Peak*ones(1,2), axLim(3:4), 'r', 'erasemode', 'xor');
h = plot(peak1Peak*ones(1,2), axLim(3:4), 'r');
set(h, 'tag', 'Pk1PkLine');
%h = plot(peak1End*ones(1,2), axLim(3:4), 'b', 'erasemode', 'xor');
h = plot(peak1End*ones(1,2), axLim(3:4), 'b');
set(h, 'tag', 'Pk1EndLine');
%h = plot(peak2Start*ones(1,2), axLim(3:4), 'm', 'erasemode', 'xor');
h = plot(peak2Start*ones(1,2), axLim(3:4), 'm');
set(h, 'tag', 'Pk2StLine');

set(gca, 'ButtonDownFcn', 'pickHist');
set(get(gca,'children'),'buttondownfcn','pickHist');

hmessages = findobj('tag','HistoMessages');

if (size(latencies,1) ~= sum(spikesInTimeRange)),
    messString = 'WARNING: one or more spikes outside displayed time range';
    messColor = WARNCOLOR;
  else
    messString = [];
    messColor = NORMCOLOR;
  end % (if)
  
set(hmessages,'backgroundcolor', messColor);
set(hmessages,'string', messString);

return
