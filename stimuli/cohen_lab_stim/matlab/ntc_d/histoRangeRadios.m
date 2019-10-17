function histoRangeRadios

global nOctaves fMin extAtten selectedStimRange

INCLUDE_DEFS;

[hobj, hfig] = gcbo;

[dispFreqs, dispAmps] = makeQuiverAxes(fMin, nOctaves, extAtten);

hHistoAll = findobj(hfig, 'tag', 'HistoAllRadio');
hHistoMarked = findobj(hfig, 'tag', 'HistoMarkedRadio');
hHistoAmpEdit = findobj(hfig, 'tag', 'HistoAmpEdit');
hHistoFreqEdit = findobj(hfig, 'tag', 'HistoFreqEdit');

if hobj == hHistoAll,
    dispAmpString = sprintf('%5.1f - %5.1f dB', dispAmps([1 end]));
    dispFreqString = sprintf('%5.1f - %5.1f kHz', dispFreqs([1 end]));
    set(hHistoAll, 'value', 1, ...
                   'foregroundcolor',[0 0 0]);
    set(hHistoMarked, 'value', 0, ...
                   'foregroundcolor',[0 .3 0]);
    
  else
    dispAmpString = sprintf('%5.1f - %5.1f dB', selectedStimRange(3:4));
    dispFreqString = sprintf('%5.1f - %5.1f kHz', selectedStimRange(1:2));
    set(hHistoAll, 'value', 0, ...
                   'foregroundcolor',[0 .3 0]);
    set(hHistoMarked, 'value', 1, ...
                   'foregroundcolor',[0 0 0]);
  end
  
set(hHistoAmpEdit, 'string', dispAmpString);
set(hHistoFreqEdit, 'string', dispFreqString);

showHist;
histoMarkPk1st;
  
return

%%%--------------------

function histoMarkPk1st

[hobj, hfig] = gcbo;

hPk1Pk = findobj(hfig, 'tag', 'Pk1PeakRadio');
hPk1En = findobj(hfig, 'tag', 'Pk1EndRadio');
hPk2St = findobj(hfig, 'tag', 'Pk2StartRadio');
hPk2En = findobj(hfig, 'tag', 'Pk2EndRadio');

set(hPk1Pk, 'value', 1);
set(hPk1En, 'value', 0);
set(hPk2St, 'value', 0);
set(hPk2En, 'value', 0);

return
