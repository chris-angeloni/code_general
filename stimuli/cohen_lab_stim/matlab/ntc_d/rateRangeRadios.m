function rateRangeRadios

INCLUDE_DEFS;

global extAtten fMin nOctaves selectedStimRange

[hobj, hfig] = gcbo;

[dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);

hRateCF = findobj(hfig, 'tag', 'RateCFRadio');
hRateMarked = findobj(hfig, 'tag', 'RateMarkedRadio');
hRateFreq = findobj(hfig, 'tag', 'RateFreqEdit');

if hobj == hRateCF,
    set(hRateCF, 'value', 1);
    set(hRateMarked, 'value', 0);
    dispFreqString = sprintf('%5.1f kHz', getNewAttribute(CF));
  else
    set(hRateCF, 'value', 0);
    set(hRateMarked, 'value', 1);
    dispFreqString = sprintf('%5.1f - %5.1f kHz', selectedStimRange(1:2));
  end % 
  
set(hRateFreq, 'string', dispFreqString);

showRate;

return
