function rateMarkRadios

INCLUDE_DEFS;

global rateInfo

[hobj, hfig] = gcbo;

hRTR = findobj(hfig, 'tag', 'RateThreshRadio');
hRRR = findobj(hfig, 'tag', 'RateTransitionRadio');
hRER = findobj(hfig, 'tag', 'RateEndRadio');
hBAR = findobj(hfig, 'tag', 'BestAmplRadio');

set(hRTR, 'value', 0);
set(hRRR, 'value', 0);
set(hRER, 'value', 0);
set(hBAR, 'value', 0);

axLim = axis;

set(hobj, 'value', 1);

return
