function [firstSig, sigMat, spikeMat] = poisSigSpikes(sigPVal, halfWidth)
%function [firstSig, sigMat, spikeMat] = poisSigSpikes(sigPVal, halfWidth)
%
% find the time of the first 'non-random' spike for each intensity near CF
%
% assumes each stimulus presentation results in an independent Poisson process
% with rate equal to the total number of spikes for that stimulus divided by
% the recording time or the spontaneous rate as determined by the main program
% (it chooses the larger of these two as the Poisson rate, lambda)
%
% this uses ntcPrefs.axisHistogram to choose which spikes to use and to compute
%   spike rates
%
% halfWidth:  half of time window width around spike to find spikes in
%               neighboring stimuli, in msec
% sigPVal:    cutoff probability determining significance
%
% firstSig:   vector of times of first 'significant' spike for each intensity
% sigMat:     3D matrix of 'significant' spike times for each intensity at 
%               CF +/-1 bin
% spikeMat:   3D matrix of spike times for each intensity at CF +/-1 bin
%

global latencies extAtten nOctaves fMin NFREQS NAMPS ntcPrefs

INCLUDE_DEFS;

[freqs, amps] = makeQuiverAxes(fMin, nOctaves, extAtten);

latRange = eval(ntcPrefs(PREFVALUE).axisHistogram);
latencyDur = latRange(2)-latRange(1);

avgRate = getNewAttribute(SPONT_EST);

cf = getNewAttribute(CF);
x = abs(freqs - cf);
cfInd = min(find(min(x) == x));

% make a matrix containing spike times for CF +/- 1 bin and all intensities
rates = zeros(5,NAMPS);
kk=0;
for iFreq=cfInd-2:cfInd+2,
  kk = kk+1;
  for iAmp=1:NAMPS,
    rates(kk,iAmp) = sum(latencies(:,1)>=latRange(1) & ...
                         latencies(:,1)< latRange(2) & ...
                         latencies(:,2)==iFreq & ...
                         latencies(:,3)==iAmp);
    end % (for)
  end % (for)
maxNumSpikes = max(max(rates));

spikeMat = NaN*ones(5,NAMPS,maxNumSpikes);
kk = 0;
for iFreq=cfInd-2:cfInd+2,
  kk = kk+1;
  for iAmp=1:NAMPS,
    spikeInd = find(latencies(:,1)>=latRange(1) & ...
                    latencies(:,1)< latRange(2) & ...
                    latencies(:,2)==iFreq & ...
                    latencies(:,3)==iAmp);
    if ~isempty(spikeInd),
        spikeMat(kk,iAmp,1:length(spikeInd)) = latencies(spikeInd,1);
      end % (if)
    end % (for)
  end % (for)

% add planes of NaN to start and end of spikeMat to make indexing simpler
% (we'll only use the inside of spikeMat for determining importance...)
NaNPlane = NaN*ones(size(spikeMat(:,1,:)));
spikeMat = cat(2,NaNPlane,spikeMat);
spikeMat = cat(2,spikeMat,NaNPlane);

% it might be better to use only the average rate here, but the following line
%   might be able to compensate for 'bursts'...  this technique almost surely
%   adds bias to the estimates
rates = max(rates/latencyDur*1000.0, avgRate);
rates = [zeros(5,1) rates zeros(5,1)];

% for each spike, figure out whether there are also spikes in adjacent 
% intensity and/or frequency bins (8 nearest neighbors), and using 'rates',
% compute the probability that these 9 process samples had the number of spikes
% that were found in the analysis window (halfWidth before & after spike time)
pValMat = NaN*ones(size(spikeMat));
for iFreq=2:4,
  for iAmp=1+(1:NAMPS),
    miniSpikeMat = spikeMat(((iFreq-1):(iFreq+1)),...
                             (iAmp-1):(iAmp+1),...
                             :);
    miniRates = rates((iFreq-1):(iFreq+1),...
                      (iAmp-1):(iAmp+1));                 
    miniPVals = exp(-miniRates*2*halfWidth/1000.0);
    for iSpike=1:maxNumSpikes,
      thisTime = spikeMat(iFreq,iAmp,iSpike);
      if ~isnan(thisTime),
          anySpikeMat = zeros(3,3);
          [iiFreq, iiAmp, iiSpike] = ...
              ind2sub(size(miniSpikeMat),...
                      find(miniSpikeMat <  (thisTime+halfWidth) & ...
                           miniSpikeMat >= (thisTime-halfWidth)));
          for kSpike=1:size(iiFreq,1),
            anySpikeMat(iiFreq(kSpike), iiAmp(kSpike)) = 1;
            end % (for kSpike)
          pValMat(iFreq,iAmp,iSpike) = prod(prod(...
                   anySpikeMat.*(1-miniPVals)+(1-anySpikeMat).*miniPVals));
        end % (if ~isnan)
      end % (for iSpike)
    end % (for iAmp)
  end % (for iFreq)
  
% get rid of the planes corresponding to the augmentation done earlier
spikeMat = spikeMat(2:(end-1),2:(end-1),:);      
pValMat = pValMat(2:(end-1),2:(end-1),:);      

% figure out which spikes excede the criterion for significance, set by sigPVal
sigMat = NaN*ones(size(spikeMat));
xx = find(pValMat<sigPVal);
sigMat(xx) = 1;
sigMat = sigMat.* spikeMat;

% find the first significant spike for each stimulus intensity
for ii=1:15,
  firstSig(ii) = min(min(squeeze(sigMat(:,ii,:))));
  end
  
return

% mark all the spikes with circles, and the 'significant' ones with pluses
clf
hold on
for ii=1:3,
  plot(amps,squeeze(spikeMat(ii,:,:)),'o');
  end
for ii=1:3,
  plot(amps,squeeze(sigMat(ii,:,:)),'+');
  end

plot(amps, firstSig, 'k*');
