function doRate

global selectedRateInfo dataMat

INCLUDE_DEFS;

[hobj,hfig] = gcbo;

cf = getNewAttribute(CF);
if (cf == 0),
    hmessages = findobj(hfig,'tag','MessageEdit');
    set(hmessages,'backgroundcolor', ERRORCOLOR);
    set(hmessages,'string', 'Need to set CF first');
  else
    putNewAttribute(MAXRATE, max(max(dataMat)));
    selectedRateInfo = zeros(1,7);
    nDoRate;
    showRate;
  end
  
return

