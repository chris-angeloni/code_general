% function latencynotcf
%  Generates a plot of min latency vs amplitude for
%  the any freq, the two neighboring frequencies, and for the
%  median of the three.

load temp.mat;
ui_handles = get (figure(1), 'userdata');
save_button = ui_handles(22);

figure(1)
disp('Choose frequency.')
point=ginput(1);
haxis = ui_handles(8);
cf_button = ui_handles(9);
frequency = get (cf_button, 'userdata');
amps = get (haxis, 'userdata');
fre= min(frequency)*(2^((log2(max(frequency)/min(frequency))* (point(1,1)-1) /(length(frequency)-1))));
	

low = max(find(frequency<=fre));
high = min(find(frequency>=fre));
if (fre-frequency(low)) <= (frequency(high)-fre)
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
plot(minlatencyampC, 'xg')
hold on
plot(minlatencyampCl, '+r')
plot(minlatencyampCh, '+r')
plot(med, '-y')
% add=[0]
% plot(add, 'k')
limy=[0 (st+rn)];
limx=[1 (length(amps))];
blind_box = ui_handles(17);
bb = get(blind_box, 'value');
if bb==0
	title (['Latency at: ' num2str(fre) ' kHz'])
else
	title ('Latency')
end
set(gca, 'ylim', limy, 'xlim', limx);
ylabel('Latency')
xlabel('Amplitude')
hold off

disp(' ')
disp('Click on Figure(2) to determine latency.')
pnt= ginput(1);
latency= pnt(1,2)
disp(' ')
disp('Ready.')
figure(1)