function measure(m_or_cf);
% function measure(m_or_cf)
% m_or_cf = 0 : just measures and prints the point
%         = 1 : saves cf, threshold with put.m

ui_handles = get (gcf, 'userdata');
haxis = ui_handles(8);
cf_button = ui_handles(9);

frequency = get (cf_button, 'userdata');
amps = get (haxis, 'userdata');

disp(' ')
if m_or_cf == 0
	disp('Click on any point to measure.')
else
	disp('Click on CF of the tuning curve.')
end

point=ginput(1);
disp(' ')
text(point(1), point(2), '.', 'color', 'k', 'horizontalalignment', 'left')

Frequency = min(frequency) * 2^(point(1)*log2(max(frequency)/min(frequency)));
Amplitude = point(2);

if m_or_cf == 1
	put(Frequency,2);
	put(Amplitude,3);
else
	Frequency
	Amplitude
end

disp('Ready.')
