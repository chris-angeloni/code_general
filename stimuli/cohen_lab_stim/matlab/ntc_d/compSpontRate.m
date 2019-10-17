function spontRate = compSpontRate

global NFREQS NAMPS fMin nOctaves extAtten selectedSpontRange latencies

INCLUDE_DEFS;

[dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);
fMinInd = min(find(dispFreqs>=selectedSpontRange(1)));
fMaxInd = max(find(dispFreqs<=selectedSpontRange(2)));
aMinInd = min(find(dispAmps>=selectedSpontRange(3)));
aMaxInd = max(find(dispAmps<=selectedSpontRange(4)));

spontLatInd = find(latencies(:,3)>=aMinInd & latencies(:,3)<=aMaxInd & ...
               latencies(:,2)>=fMinInd & latencies(:,2)<=fMaxInd);
spontCount = length(spontLatInd);

spontDataMat = zeros(fMaxInd-fMinInd+1, aMaxInd-aMinInd+1);
for ii=1:spontCount,
  spontDataMat(latencies(spontLatInd(ii),2)-fMinInd+1, ...
               latencies(spontLatInd(ii),3)-aMinInd+1) = ...
      spontDataMat(latencies(spontLatInd(ii),2)-fMinInd+1, ...
                   latencies(spontLatInd(ii),3)-aMinInd+1) +1;
  end  % (for)
  
% normalize  by longest latency spike
spontRate = mean(spontDataMat(:)) / latencies(end,1) * 1000.0; 
spontSTD = std(spontDataMat(:)) / latencies(end,1) * 1000.0;

putNewAttribute(SPONT_EST, spontRate);
putNewAttribute(SPONT_STD, spontSTD);

return
