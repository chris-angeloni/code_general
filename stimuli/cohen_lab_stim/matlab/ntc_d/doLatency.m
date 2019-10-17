function doLatency

global selectedStimRange

INCLUDE_DEFS;

[hobj, hfig1] = gcbo;

cf = getNewAttribute(CF);
if (CF == 0) & isempty(selectedStimRange),
    hmessage = findobj(hfig1,'tag','MessageText');
    set(hmessage,'string','Mark CF or stimulus range first');
    set(hmessage,'backgroundcolor',WARNCOLOR);
  else
    nDoLatency;
    hfig2 = gcf;
    if ~isempty(selectedStimRange),
        hmessage3 = findobj(hfig2, 'tag', 'SelRangeEdit');
        set(hmessage3, 'string', sprintf(...
          '%5.2f - %5.2f', selectedStimRange(1:2)));
      end
    if cf ~= 0,
        hmessage2 = findobj(hfig2, 'tag', 'CFRangeEdit');
        set(hmessage2, 'string', sprintf('%5.2f', cf));
      else
        set(findobj(hfig2,'tag','CFRadio'),'value',0);
        set(findobj(hfig2,'tag','RangeRadio'),'value',1);
      end
    showLatencies2;
  end % (if)

return
