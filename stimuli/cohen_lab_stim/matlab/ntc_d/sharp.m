function sharp;
% function sharp

INCLUDE_DEFS;

[hobj, hfig] = gcbo;
buttonString = get(hobj, 'string');

hmessageText = findobj(hfig,'tag','MessageText');
cf = getNewAttribute(CF);
threshold = getNewAttribute(THRESHOLD);

if buttonString == 'All',
    measure;
    cf = getNewAttribute(CF);
    threshold = getNewAttribute(THRESHOLD);
    infoStart = INFO10;
    lineAmp = threshold+10;
    measBW(cf, infoStart, lineAmp, hmessageText);
    infoStart = INFO20;
    lineAmp = threshold+20;
    measBW(cf, infoStart, lineAmp, hmessageText);
    infoStart = INFO30;
    lineAmp = threshold+30;
    measBW(cf, infoStart, lineAmp, hmessageText);
    infoStart = INFO40;
    lineAmp = threshold+40;
    measBW(cf, infoStart, lineAmp, hmessageText);
  elseif (cf==0),
    set(hmessageText, 'backgroundcolor', WARNCOLOR);
    set(hmessageText, 'string', 'First identify CF');
  else
    axes(findobj(hfig,'tag','TuningCurveAxes'));
    switch buttonString
      case 'Q10', 
        infoStart = INFO10;
        lineAmp = threshold+10;
        measBW(cf, infoStart, lineAmp, hmessageText);
      case 'Q20',
        infoStart = INFO20;
        lineAmp = threshold+20;
        measBW(cf, infoStart, lineAmp, hmessageText);
      case 'Q30',
        infoStart = INFO30;
        lineAmp = threshold+30;
        measBW(cf, infoStart, lineAmp, hmessageText);
      case 'Q40',
        infoStart = INFO40;
        lineAmp = threshold+40;
        measBW(cf, infoStart, lineAmp, hmessageText);
      otherwise,
      end % (case)
  end % (if)
  
return

  
function measBW(cf, infoStart, lineAmp, hmessageText)
 
INCLUDE_DEFS;

freqRange = axis;  
ampRange = freqRange(3:4);  
freqRange = freqRange(1:2);
    
if (ampRange(1)<=lineAmp & lineAmp<=ampRange(2)),
    set(hmessageText, 'backgroundcolor', MESSAGECOLOR);
    set(hmessageText, 'string', ...
        'Mark left then right edge of tuning curve at the red line');    
    hline = plot(freqRange, [lineAmp lineAmp], 'r');
    
    edgeA = ginputUsingArrow(1);
    edgeA = edgeA(1);
    if edgeA<freqRange(1),
        edgeA = -Inf;
      elseif edgeA>freqRange(2),
        edgeA = Inf;
      end % (if)
    if isfinite(edgeA),
        plot(edgeA, lineAmp, 'mo');
      end % (if)
      
    edgeB = ginputUsingArrow(1);
    edgeB = edgeB(1);
    if edgeB<freqRange(1),
        edgeB = -Inf;
      elseif edgeB>freqRange(2),
        edgeB = Inf;
      end % (if)
    if isfinite(edgeB),
        plot(edgeB, lineAmp, 'mo');
      end % (if)
    
    if edgeB<edgeA,
        edgeB = NaN;
        edgeA = NaN;
      end % (if)
      
    qVal = cf/(edgeB - edgeA);
    wierdBW = log2(edgeB/edgeA);
    wierdAsym = log2(edgeB/cf) - log2(cf/edgeA);
    
    putNewAttribute(infoStart+OFFSETQ, qVal);
    putNewAttribute(infoStart+OFFSETA, edgeA);
    putNewAttribute(infoStart+OFFSETB, edgeB);
    putNewAttribute(infoStart+OFFSETBW, wierdBW);
    putNewAttribute(infoStart+OFFSETASYM, wierdAsym);
    
    set(hmessageText, 'string', sprintf(...
'Amp: %5.2f   Low Edge: %5.2f   High Edge: %5.2f   Q: %5.2f   BW: %5.2f   Asym: %5.2f', ...
       lineAmp, edgeA, edgeB, qVal, wierdBW, wierdAsym));
      
    delete(hline);
  else
    % line will be out of range of the plot, so skip it...
    set(hmessageText, 'backgroundcolor', MESSAGECOLOR);
    set(hmessageText, 'string', ...
        sprintf('Amplitude out of range for plot (%5.1f dB)', lineAmp));    
  end % (if)   

  return
  

