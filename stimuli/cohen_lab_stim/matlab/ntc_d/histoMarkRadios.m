function histoMarkRadios

[hobj, hfig] = gcbo;

hPk1Pk = findobj(hfig, 'tag', 'Pk1PeakRadio');
hPk1En = findobj(hfig, 'tag', 'Pk1EndRadio');
hPk2St = findobj(hfig, 'tag', 'Pk2StartRadio');
hPk2En = findobj(hfig, 'tag', 'Pk2EndRadio');

set(hPk1Pk, 'value', 0);
set(hPk1En, 'value', 0);
set(hPk2St, 'value', 0);
set(hPk2En, 'value', 0);

axLim = axis;

set(hobj, 'value', 1);

return
