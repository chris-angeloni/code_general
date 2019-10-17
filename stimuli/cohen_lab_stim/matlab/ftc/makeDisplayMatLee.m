function [displayMat] = makeDisplayMatLee(latencies,minlat,maxlat,NFREQS,NAMPS)
%
%	DESCRIPTION:	From an ntc.mat file, prepare display matrix for pcolor.
%
%	[displayMat] = makeDisplayMatLee(latencies,minlat,maxlat,NFREQS,NAMPS)
%

inRange = find(latencies(:,1)<=maxlat);
inRange = find(minlat<=latencies(inRange,1));

numInRange = length(inRange);
dataMat = zeros(NFREQS,NAMPS);

for ii=1:numInRange,
   dataMat(latencies(inRange(ii),2),latencies(inRange(ii),3)) = ...
      dataMat(latencies(inRange(ii),2),latencies(inRange(ii),3)) + 1;
end
% pcolor, doesn't use the last row and column of the 
%    matrix for plotting, so add on extra ones.

displayMat = [dataMat, dataMat(:,NAMPS); ...
             dataMat(NFREQS,:), dataMat(NFREQS,NAMPS)];

displayMat = smoothDisplay(displayMat);


clear dataMat
