function showRate
    
global selectedRateInfo extAtten fMin nOctaves ntcPrefs selectedStimRange dataMat NFREQS NAMPS
    
INCLUDE_DEFS;
    
hRA = findobj('tag','RateAxes');
axes(hRA(1));
hCF = findobj('tag','RateCFRadio');

hmessages = findobj('tag','RateMessages');
if ~isempty(selectedStimRange),
    hMarked = findobj('tag','RateMarkedRadio');
    set(hMarked, 'enable', 'on');
  end

global latencies

prefValues = ntcPrefs(PREFVALUE);

if strcmp(prefValues.rateRawOnly,'yes'),
    lDataMat = makeRawDataMat;
  else
    lDataMat = dataMat;
  end % (if)

[freqs, amps] = makeQuiverAxes(fMin, nOctaves, extAtten);
  
hold on;
    
if get(hCF, 'value') == 1,
    cla;
    cf = getNewAttribute(CF);
    hFreqEdit = findobj('tag','RateFreqEdit');
    set(hFreqEdit,'string',num2str(cf));
    x = abs(freqs - cf);
    cfInd = min(find(min(x) == x));
    switch cfInd,
      case 1, ...
              rateVect = lDataMat(1:3,:)';
              plot(amps, rateVect(:,1),'bx');
              hold on
              plotSize(amps, rateVect(:,2:3),'ro');
              maxRateAtCF = max(rateVect(:,1));
      case NFREQS, ...
              rateVect = lDataMat(NFREQS+(-2:0),:)';
              plot(amps, rateVect(:,3),'bx');
              hold on
              plotSize(amps, rateVect(:,1:2),'ro');
              maxRateAtCF = max(rateVect(:,2));
      otherwise, ...
              rateVect = lDataMat(cfInd+(-1:1),:)';
              plot(amps, rateVect(:,2),'bx');
              hold on
              plotSize(amps, rateVect(:,[1 3]),'ro');
              maxRateAtCF = max(rateVect(:,3));
      end % (switch)
      
    plot(amps, median(rateVect'), 'b');
    
  else
    cla;
    freqInds = ...
        find(freqs > selectedStimRange(1) & freqs < selectedStimRange(2));
    rateVect = lDataMat(freqInds,:)';
    plotSize(amps, rateVect, 'ro');
    hold on
    plot(amps, median(rateVect'), 'r');
  end

axis('auto');
axLim = axis;
axis([axLim(1:2) 0 axLim(4)]);

hbb = findobj('tag','BlindBox');
if get(hbb,'value') == 1,
    set(gca,'visible', 'off');
  else
    xlabel('stimulus intensity (dB)');
    ylabel('spikes in window');
  end

set(hRA,'buttondownfcn','pickRate');
set(get(hRA,'children'),'buttondownfcn','pickRate');

messString = [];
messColor = NORMCOLOR;
if ~strcmp(prefValues.rateRawOnly,'yes'),
    hSm = findobj('tag','NoSmoothOption');
    if strcmp('off',get(hSm,'Checked')),
        messString = [messString 'Smoothed     '];
        messColor = WARNCOLOR;
      end % (if)
    hSp = findobj('tag','SpontBox');
    if get(hSp,'value') == 1,
        messString = [messString 'Spontaneous removed  '];
        messColor = WARNCOLOR;
      end % (if)
  end % (if)
hmessages = findobj('tag','RateMessages');
set(hmessages,'backgroundcolor', messColor);
set(hmessages,'string', messString);
  
return
      
%%%----------------------

function plotSize(rowTick, rowMat, symbol, mkScale)
% function plotSize(rowTick, rowMat, symbol, mkScale)

if nargin<4,
    mkScale = 6;   % (6 is the default size)
  end % (if)
if nargin<3,
    symbol = 'ro';
  end % (if)

nRows = size(rowMat,1);

tVect = rowMat(1,:);
uniqSizes = unique(tVect);
for kk=1:length(uniqSizes),
  mkSize = mkScale*sqrt(sum(tVect==uniqSizes(kk)));
  plot(rowTick(1), uniqSizes(kk), symbol, 'markersize', mkSize);
  end % (for)

if nRows>1,
    for jj=2:nRows,
      tVect = rowMat(jj,:);
      uniqSizes = unique(tVect);
      for kk=1:length(uniqSizes),
  	    mkSize = mkScale*sqrt(sum(tVect==uniqSizes(kk)));
  	    plot(rowTick(jj), uniqSizes(kk), symbol, 'markersize', mkSize);
  	    end % (for)
      end % (for)
   end % (if)

return 
      
%%%----------------------


function dataMat = makeRawDataMat()

global NFREQS NAMPS latencies

hRST = findobj('tag','RangeStartText');
hRET = findobj('tag','RangeEndText');
minLatency = str2num(get(hRST,'string'));
maxLatency = str2num(get(hRET,'string'));

inRange = find(latencies(:,1)<=maxLatency);
inRange = find(minLatency<=latencies(inRange,1));

numInRange = length(inRange);
dataMat = zeros(NFREQS,NAMPS);

for ii=1:numInRange,
  dataMat(latencies(inRange(ii),2),latencies(inRange(ii),3)) = ...
     dataMat(latencies(inRange(ii),2),latencies(inRange(ii),3)) + 1;
  end

return

