function firstSigSpikeTimes = firstSigSpikes
% function firstSigSpikeTimes = firstSigSpikes

global latencies extAtten nOctaves fMin NFREQS NAMPS

INCLUDE_DEFS;

histoTime = 100.0;          % total msec for histogram
binWidth = 1.0;             % msec
binTimes = (binWidth/2):binWidth:histoTime;  % in msec
filtSigma = 2.0;            % in units of binWidth, width of FIR Gaussian smoothing filter
filtTimes = -2:2;           % start/end of filter in units of binWidth (make this symmetric and odd length)

[freqs, amps] = makeQuiverAxes(fMin, nOctaves, extAtten);
cf = getNewAttribute(CF);
spontRate = getNewAttribute(SPONT_EST);
spontSTD = getNewAttribute(SPONT_STD);
xingLevel = (spontRate+spontSTD)*binWidth/1000.0;

x = abs(freqs - cf);
cfInd = min(find(min(x) == x));

cfLats = latencies(find(latencies(:,2)==cfInd),:);
if cfInd>1,
    cfLats = [latencies(find(latencies(:,2)==cfInd-1),:); cfLats];
  end % (if)
if cfInd<NFREQS,
    cfLats = [cfLats; latencies(find(latencies(:,2)==cfInd+1),:)];
  end % (if)

histMat = zeros(length(binTimes), NAMPS);
xingInds = zeros(NAMPS,1);
firstSigSpikeTimes = NaN*ones(NAMPS,1);

% smooth the histograms

gaussFilt = exp(-((filtTimes./filtSigma).^2)/2)/(filtSigma*sqrt(2*pi));
nToDrop = (length(filtTimes)-1)/2;

for iAmp = 1:NAMPS,
  newLats = cfLats(find(cfLats(:,3)==iAmp),1);
  if ~isempty(newLats),
      histMat(:,iAmp) = hist(newLats,binTimes)';
      tempVect = conv(histMat(:,iAmp), gaussFilt);
      histMat(:,iAmp) = tempVect((nToDrop+1):(end-nToDrop));
      xingInds(iAmp) = min([find(histMat(:,iAmp)>xingLevel);NaN]);
      firstSigSpikeTimes(iAmp) = ...
          min([newLats(newLats>=(xingInds(iAmp)*binWidth)); NaN]);
%      plot(iAmp*ones(size(newLats)), newLats,'o');
%      plot(iAmp, firstSigSpikeTime(iAmp),'rx');
    end % (if)
  end % (for)

return
