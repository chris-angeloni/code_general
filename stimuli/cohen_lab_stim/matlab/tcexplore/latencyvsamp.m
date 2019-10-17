% function latencyvsamp(savehandle)
%  Generates a plot of min latency vs amplitude for
%  the CF, the two neighboring frequencies, and for the
%  median of the three.

load temp.mat;
ui_handles = get (gcf, 'userdata');
CF = getatval(2);
blind_box = ui_handles(17);
bb = get(blind_box, 'value');
if CF ==0  %If there is no CF, then get one.
	disp('Click on CF of tuning curve.')
	point=ginput(1);
	disp(' ')
	disp('Ready. ')
	text(point(1), point(2), '.', 'color', 'k', 'horizontalalignment', 'left')
	haxis = ui_handles(8);
	cf_button = ui_handles(9);
	frequency = get (cf_button, 'userdata');
	amps = get (haxis, 'userdata');
	CF= min(frequency)*(2^((log2(max(frequency)/min(frequency))* (point(1,1)-1) /(length(frequency)-1))));
	Threshold= ((((max(amps) -min(amps))/(length(amps)-1)) *(point(1,2)-1)) +min(amps));
	put(CF, 2);
	put(Threshold, 3);
end

low = max(find(frequency<=CF));
high = min(find(frequency>=CF));
if (CF-frequency(low)) <= (frequency(high)-CF)
	C=low;	% C is the index of the frequency of interest.
else
	C=high;
end
st=get (ui_handles(2), 'value');
rn=get (ui_handles(5), 'value');
latencyampC=zeros((rn+1), length(amps));
latencyampCl=zeros((rn+1), length(amps));
latencyampCh=zeros((rn+1), length(amps));
st=floor(st);
for k=st:(st+rn)
	eval (['LC= t' num2str(k) '(:, C);']) 
	eval (['LCl= t' num2str(k) '(:, C-1);']) 
	eval (['LCh= t' num2str(k) '(:, C+1);']) 
	LC=(LC>0)*k;
	LCl=(LCl>0)*k;
	LCh=(LCh>0)*k;
		%L is a row where each spike is
	 	%replaced with the latency at which it
		%occurred 
	latencyampC((k-st+1), :) = LC';
	latencyampCl((k-st+1), :) = LCl';
	latencyampCh((k-st+1), :) = LCh';
	%latencyampC is a matrix of the latencies the spikes
	%that occurred in response to frequency C
end
z=find(latencyampC==0);
zl=find(latencyampCl==0);
zh=find(latencyampCh==0);
latencyampC(z)=inf*ones(size(z));
latencyampCl(zl)=inf*ones(size(zl));
latencyampCh(zh)=inf*ones(size(zh));
minlatencyampC = min(latencyampC);
minlatencyampCl = min(latencyampCl);
minlatencyampCh = min(latencyampCh);
med=[minlatencyampC; minlatencyampCl; minlatencyampCh];
med=median(med);
figure(2)
clf reset
plot(minlatencyampC, 'xg')
hold on
plot(minlatencyampCl, '+r')
plot(minlatencyampCh, '+r')
plot(med, '-y')
% add=[0]
% plot(add, 'k')
limy=[0 (st+rn)];
limx=[1 (length(amps))];
if bb==0
	title (['Latency at CF: ' num2str(CF) ' kHz'])
else
	title ('Latency at CF')
end
set(gca, 'ylim', limy, 'xlim', limx);
ylabel('Latency')
xlabel('Amplitude')
hold off
ofreq_button = uicontrol(gcf,...
	'style','push',...
	'position',[.8 .95 .2 0.05],...
	'units','normalized',...;
	'string','Other Frequency',...
	'callback', 'latencynotcf');
disp(' ')
disp('Click on Figure(2) to determine latency.')
pnt= ginput(1);
disp(' ')
disp('Ready.')
latency= pnt(1,2);
put(latency, 4);
figure(1)
