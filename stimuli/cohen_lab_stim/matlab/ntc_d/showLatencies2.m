function showLatencies

global latencies extAtten nOctaves fMin selectedStimRange ntcPrefs NFREQS NAMPS
global selectedLatency

INCLUDE_DEFS;

hLA = findobj('tag','LatencyAxes');
axes(hLA(1));
hfig = gcf;

hCF = findobj(hfig, 'tag','CFRadio');

[freqs, amps] = makeQuiverAxes(fMin, nOctaves, extAtten);

if get(hCF, 'value') == 1,           % for CF +/- one bin
    cla;
    hold on;
    cf = getNewAttribute(CF);
    latencyVect = NaN*ones(NAMPS,1);
    x = abs(freqs - cf);
    cfInd = min(find(min(x) == x));
    if (cfInd > 1),
        latencyVect = [NaN*ones(NAMPS,1), latencyVect];
        latencyInd = find(latencies(:,2) == cfInd-1);
        for ii = length(latencyInd):-1:1,
          latencyVect(latencies(latencyInd(ii),3),1) = ...
              latencies(latencyInd(ii),1);
          plot(amps(latencies(latencyInd(ii),3)),...
                    latencies(latencyInd(ii),1),'r+');
          end
      end
      
    latencyInd = find(latencies(:,2) == cfInd);
    for ii = length(latencyInd):-1:1,
      latencyVect(latencies(latencyInd(ii),3),end) = ...
          latencies(latencyInd(ii),1);
      end
      
    if (cfInd < NFREQS),
        latencyVect = [latencyVect, NaN*ones(NAMPS,1)];
        latencyInd = find(latencies(:,2) == cfInd+1);
        for ii = length(latencyInd):-1:1,
            latencyVect(latencies(latencyInd(ii),3),end) = ...
                latencies(latencyInd(ii),1);
          plot(amps(latencies(latencyInd(ii),3)),...
              latencies(latencyInd(ii),1),'g+');
          end
      end

    plot(amps, nanMed(latencyVect'),'m');

    latencyInd = find(latencies(:,2) == cfInd);
    for ii = length(latencyInd):-1:1,
      plot(amps(latencies(latencyInd(ii),3)),...
          latencies(latencyInd(ii),1),'bx');
      end

  else
    cla;
    hold on;
    freqInds = find(freqs > selectedStimRange(1) & freqs < selectedStimRange(2));
    latencyVect = NaN * ones(NAMPS, length(freqInds));
    for freqNum = 1:length(freqInds),
      freqInd = freqInds(freqNum);
      latencyInd = find(latencies(:,2) == freqInd);
      for ii = length(latencyInd):-1:1,
        latencyVect(latencies(latencyInd(ii),3), freqNum) = ...
            latencies(latencyInd(ii),1);
        plot(amps(latencies(latencyInd(ii),3)),...
            latencies(latencyInd(ii),1),'r+');
       end
      end % (for freqNum)
    plot(amps, nanMed(latencyVect'), 'm');
  end
  
axPrefLim = eval(ntcPrefs(PREFVALUE).axisLatency);
axis([amps(1) amps(end) axPrefLim]);

% take a shot at figuring out what the latency is... CF must be set for this
%  to work properly
sigPVal = eval(ntcPrefs(PREFVALUE).sigProb);
halfWidth = eval(ntcPrefs(PREFVALUE).halfWidth);
firstSig = poisSigSpikes(sigPVal, halfWidth);
y = min(firstSig);
selectedLatency = y;
hline = plot(amps([1 end]), [y y], 'b'); 
set(hline, 'tag', 'selectedLatency');
% set(hline, 'erasemode', 'xor');

hbb=findobj('tag','BlindBox');
if (get(hbb,'value') == 1),
    set(hLA, 'visible','off');
  else
    xlabel('stimulus intensity (dB)');
    ylabel('latency (ms)');
  end

set(hLA,'buttondownfcn','pickLatency');
hch = get(hLA, 'children');
for ii=1:length(hch),
    set(hch(ii),'buttondownfcn','pickLatency');
  end % (for)

hmessages = findobj(hfig, 'tag','LatencyMessage');
set(hmessages,'backgroundcolor', MESSAGECOLOR);
set(hmessages,'string', 'Accept or click on new latency');

return
  

