function spontButton

hobj = findobj('tag','SpontBox');

hPercentSign = findobj('tag', 'PercentStaticText');
hPercentEdit = findobj('tag', 'PercentEdit');

if (get(hobj,'value') == 1),
    set(hPercentSign, 'enable', 'inactive');
    set(hPercentEdit, 'enable', 'on');
  else
    set(hPercentSign, 'enable', 'off');
    set(hPercentEdit, 'enable', 'off');
  end
  
return
