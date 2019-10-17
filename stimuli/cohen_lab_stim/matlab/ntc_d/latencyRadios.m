function latencyRadios

[hobj,hfig] = gcbo;

hCF = findobj(hfig, 'tag','CFRadio');
hRange = findobj(hfig,'tag', 'RangeRadio');

if hobj == hCF,
    set(hCF,'value', 1);
    set(hRange, 'value', 0);
  else
    set(hCF, 'value', 0);
    set(hRange, 'value', 1);
  end
 
showLatencies2;

return
