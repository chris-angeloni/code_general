function zapStimRange

global latencies fMin nOctaves extAtten selectedStimRange

[dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);

zapFreqInds = ...
    find(dispFreqs > selectedStimRange(1) & dispFreqs < selectedStimRange(2));
zapAmpInds = ...
    find(dispAmps > selectedStimRange(3) & dispAmps < selectedStimRange(4));
    
keepInds = ~ismember(latencies(:,2), zapFreqInds) | ...
           ~ismember(latencies(:,3), zapAmpInds);
          
latencies = latencies(keepInds,:);

refreshDisplay;

return
