function ratenotcf(a)
ui_handles = get(figure(1), 'userdata');
haxis = ui_handles(8);
cf_button = ui_handles(9);
save_button = ui_handles(22);
file_name = get(ui_handles(23), 'userdata');
hp_handle = ui_handles(24);
display=get(hp_handle, 'userdata');
attributes = get(save_button, 'userdata');
disp(' ')
disp('Click on frequency to analyze.')
point=ginput(1);
disp(' ')
disp('Ready.')
haxis = ui_handles(8);
cf_button = ui_handles(9);
frequency = get (cf_button, 'userdata');
amps = get (haxis, 'userdata');
fre= min(frequency)*(2^((log2(max(frequency)/min(frequency))* (point(1,1)-1) /(length(frequency)-1))));

freq=floor(point(1,1));
figure(2);
clf;
med=mean([display(:, freq)'; display(:, freq+1)'; display(:, freq-1)']);
plot(display(:, freq), 'xy');
hold on;
plot(med, ':r')
plot(display(:, freq));
plot(display(:, freq+1), '+r');
plot(display(:, freq-1), '+r');
set(gca, 'ylim', [0 max(max(display))])
xlabel('Amplitude');
ylabel('Number of Spikes');
blind_box = ui_handles(17);
bb = get(blind_box, 'value');
if bb==0
	title(['Rate-Level Function at ' num2str(fre) ' kHz'])
else
	title ('Rate-Level Function')
end
orate_button = uicontrol(gcf,...
	'style','push',...
	'position',[.8 .95 .2 0.05],...
	'units','normalized',...;
	'string','Other Frequency',...
	'callback', 'ratenotcf');
hold off;
figure(1);