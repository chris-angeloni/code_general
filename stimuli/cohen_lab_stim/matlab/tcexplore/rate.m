function rate(a)

ui_handles = get(figure(1),'userdata');
blind_box = ui_handles(17);
bb = get(blind_box, 'value');
haxis = ui_handles(8);
cf_button = ui_handles(9);
save_button = ui_handles(22);
file_name = get(ui_handles(23), 'userdata');
contour_button = ui_handles(16);
display=get(contour_button, 'userdata');
CF = getatval(2);
frequency = get (cf_button, 'userdata');
amps = get (haxis, 'userdata');

if CF == 0
	disp('Click on CF of tuning curve.')
	point=ginput(1)
	text(point(1), point(2), '.', 'color', 'k', 'horizontalalignment', 'left')
	disp(' ')
	disp('Ready. ')
	haxis = ui_handles(8);
	cf_button = ui_handles(9);
	CF= min(frequency)* (2^((log2(max(frequency) /min(frequency)) * (point(1,1)))));
	Threshold= point(1,2);
	put(CF, 2);
	put(Threshold, 3);
	freq=point(1,1);
else
	freq=(log2(CF/min(frequency))/(log2(max(frequency)/(min(frequency)))));
	
end

freq=ceil((freq)*length(frequency));
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
if bb==0
	title(['Rate-Level Function at CF: ' num2str(CF) ' kHz'])
else
	title ('Rate-Level Function at CF')
end
orate_button = uicontrol(gcf,...
	'style','push',...
	'position',[.8 .95 .2 0.05],...
	'units','normalized',...;
	'string','Other Frequency',...
	'callback', 'ratenotcf');
Nonmono_button = uicontrol(gcf,...
	'style','push',...
	'position',[.8 0 .2 0.05],...
	'units','normalized',...;
	'string','Non-monotonic?',...
	'callback', 'put(1, 32)');
bamp_button = uicontrol(gcf,...
	'style','push',...
	'position',[0 0 .2 0.05],...
	'units','normalized',...;
	'string','Best Amplitude',...
	'callback', 'bamp');
hold off;
% Measurements
disp(' ')
disp('Click on Threshold.')
[a1, r1] =ginput(1);
disp(' ')
disp('Click on Transition Point.')
[a2, r2] =ginput(1);
disp(' ')
disp('Click on End Point.')
[a3, r3] =ginput(1);
disp(' ')
disp('Ready.')
line([a1 a2 a3], [r1 r2 r3], 'color', 'g', 'linestyle', '--');
slope1 = 1/((a2-a1) * (amps(4)-amps(3)));
slope2 = (r3-r2)/((r2-r1)*(a3-a2) * (amps(4)-amps(3)));
mrate = max(max(display));
put(mrate, 27);
mratecf = max(display(:, freq));
mrca= find(display(:, freq) == mratecf);
mrca=min(mrca);
mratecfamp = amps(mrca);
amptrans=amps(a2);
%put(mratecf, 28);    %Best Amplitude (bamp) now defines this.
%put(mratecfamp, 29); %Best Amplitude (bamp) now defines this.
put(slope1, 30);
put(slope2, 31);
put(amptrans, 33);
figure(1);
