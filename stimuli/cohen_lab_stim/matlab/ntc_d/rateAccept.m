function rateAccept

INCLUDE_DEFS;

global selectedRateInfo dataMat fMin nOctaves extAtten

[hobj, hfig] = gcbo;
[freqs, amps] = makeQuiverAxes(fMin, nOctaves, extAtten);
cf = getNewAttribute(CF);
x = abs(freqs - cf);
cfInd = min(find(min(x) == x));

hTCFig = findobj('tag','TuningCurveFig');

maxRate = max(max(dataMat));

maxRateAtCF = selectedRateInfo(7);
maxRateAtCFAmp = selectedRateInfo(6);

putNewAttribute(MAXRATE, maxRate);
putNewAttribute(MAXRATECF, maxRateAtCF);
putNewAttribute(MAXRATECFAMP, maxRateAtCFAmp);
putNewAttribute(RATESLOPE1, ...
              selectedRateInfo(3)/(selectedRateInfo(2)-selectedRateInfo(1)));
putNewAttribute(RATESLOPE2, ...
             (selectedRateInfo(5)-selectedRateInfo(3)) / ...
             (selectedRateInfo(4)-selectedRateInfo(2)));
putNewAttribute(RATETHRESH, selectedRateInfo(1));
putNewAttribute(AMPATTRANS, selectedRateInfo(2));
putNewAttribute(RATEATTRANS, selectedRateInfo(3));
putNewAttribute(AMPATFADE, selectedRateInfo(4));
putNewAttribute(NONMONOTONIC, 0);

set(gcbo, 'backgroundcolor', NORMBUTTONCOLOR);

return
