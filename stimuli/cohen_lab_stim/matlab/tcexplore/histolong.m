function [snr, sp]=histogr (other)

%	function histogram(other)
%  Generates a PSTH using all of the frequency/amplitude combinations
%  within the tuning curve.  Spontaneous activity level is shown.
%  A little smoothing is done.
%
% If other=10 make nice figure.

% Updated: 1/29/97 mpk

load temp.mat;
ui_handles = get (figure(1), 'userdata');
save_button = ui_handles(22);
haxis = ui_handles(8);
spon= get(ui_handles(15), 'userdata');
sp=spon*1000/size(t1, 2);
put(sp, 38);
cf_button = ui_handles(9);
th=getatval(3);
l=max(find(amps<th));
g=min(find(amps>th));
if (th-amps(l))<(amps(g)-th)  %find the amp row that the threshold response is on
	amrow=l;
else
	amrow=g;
end
a40=getatval(22);
a30=getatval(17);
a20=getatval(12);
a10=getatval(7);
if a40 ~= 0
	a=a40;
	b=getatval(23);
	low = max(find(frequency<=a));
	high = min(find(frequency>=a));
	if a<frequency(1)
		acol=1;
	elseif (a-frequency(low)) <= (frequency(high)-a)
		acol=low;	
	else
		acol=high;
	end
	low = max(find(frequency<=b));
	high = min(find(frequency>=b));
	if b>frequency(45)
		bcol=45;
	elseif (b-frequency(low)) <= (frequency(high)-b)
		bcol=low;	
	else
		bcol=high;
	end
elseif a30 ~= 0
	a=a30;
	b=getatval(18);
	low = max(find(frequency<=a));
	high = min(find(frequency>=a));
	if a<frequency(1)
		acol=1;
	elseif (a-frequency(low)) <= (frequency(high)-a)
		acol=low;	
	else
		acol=high;
	end
	low = max(find(frequency<=b));
	high = min(find(frequency>=b));
	if b>frequency(45)
		bcol=45;
	elseif (b-frequency(low)) <= (frequency(high)-b)
		bcol=low;	
	else
		bcol=high;
	end
elseif a20 ~= 0
	a=a20;
	b=getatval(13);
	low = max(find(frequency<=a));
	high = min(find(frequency>=a));
	if a<frequency(1)
		acol=1;
	elseif (a-frequency(low)) <= (frequency(high)-a)
		acol=low;	
	else
		acol=high;
	end
	low = max(find(frequency<=b));
	high = min(find(frequency>=b));
	if b>frequency(45)
		bcol=45;
	elseif (b-frequency(low)) <= (frequency(high)-b)
		bcol=low;	
	else
		bcol=high;
	end
elseif a10 ~= 0
	a=a10;
	b=getatval(8);
	low = max(find(frequency<=a));
	high = min(find(frequency>=a));
	if a<frequency(1)
		acol=1;
	elseif (a-frequency(low)) <= (frequency(high)-a)
		acol=low;	
	else
		acol=high;
	end
	low = max(find(frequency<=b));
	high = min(find(frequency>=b));
	if b>frequency(45)
		bcol=45;
	elseif (b-frequency(low)) <= (frequency(high)-b)
		bcol=low;	
	else
		bcol=high;
	end
else
	acol=1;
	bcol=45;
end
eval (['linehnd=line([' num2str(acol/size(t1,2)) '; ' num2str(bcol/size(t1,2)) '], [' num2str(th) ';' num2str(th) '], ''color'', ''r'');'])
figure(2)
clf reset
lat_button = uicontrol(gcf,...
	'style','push',...
	'position',[.02 .95 .2 0.05],...
	'units','normalized',...;
	'string','Choose Latency',...
	'callback', 'histogram(1);');
secpeak_button = uicontrol(gcf,...
	'style','push',...
	'position',[.77, .95 .2 0.05],...
	'units','normalized',...;
	'string','Second Peak',...
	'callback', 'histogram(3); histogram(4);');
endpeak_button = uicontrol(gcf,...
	'style','push',...
	'position',[.27, .95 .2 0.05],...
	'units','normalized',...;
	'string','End of Peak',...
	'callback', 'histogram(2);');
secpeakon_button = uicontrol(gcf,...
	'style','push',...
	'position',[.52, .95 .2 0.05],...
	'units','normalized',...;
	'string','Second Onset',...
	'callback', 'histogram(3);');

st=get (ui_handles(2), 'value');
rn=get (ui_handles(5), 'value');
latencyampC=zeros((rn+1), length(amps));
latencyampCl=zeros((rn+1), length(amps));
latencyampCh=zeros((rn+1), length(amps));
st=floor(st);
%if duration>250, duration=248;, end % This makes histogram run faster.
for i=1:duration
	eval (['histo(' num2str(i) ') = sum(sum(full(t' num2str(i) '(amrow:15, acol:bcol))));'])
end
confactor=(15-amrow+1)*(bcol-acol+1);

histo1=[0 histo]*.5;
histo2=[histo(2:length(histo)) 0 0]*.5;
histo=[histo 0];
histo=(histo+histo1+histo2)/2;
histo(1, 1)=sp*confactor/1000; % eliminates glich at 1msec latency.
m=max(histo);
z=find(histo==m);
latency=z(1,1);
figure(2)
bar(histo*(1000/confactor))
ylabel('Firing Rate')
xlabel('Latency')
t=get(get(2, 'currentaxes'), 'ylim');
t=t(2);
x=get(get(2, 'currentaxes'), 'xlim');
set(gca, 'xtick', [0:20:x(2)])
%spon = (spon/45)*(16-amrow)*(1+bcol-acol);
line(x, [sp sp], 'color', 'r')
line([st st+rn], [sp sp], 'color', 'b', 'linewidth', 3)
line(x, [sp sp], 'color', 'r', 'linestyle', '-')
set(gca, 'xlim', [0 duration])
if other ==1
	disp(' ')
	disp('Click on Figure(2) to determine peak latency.')
	pnt= ginput(1);
	latency= pnt(1,1);
	spikes=pnt(1,2);
	if pnt(1,1)<0
		disp(' ')
		disp('Warning - latency was less than zero.')
		disp(' ')
		spikes=0;
		latency=0;
	end
	text(latency, t, '*', 'color', 'r', 'HorizontalAlignment', 'center')
	put(latency, 34)
elseif other==2
	disp(' ')
	disp('Click on Figure(2) to mark end of response.')
	pnt2= ginput(1);
	if pnt2(1,1)<0
		disp(' ')
		disp('Warning - end of response was less than zero.')
		disp(' ')
		spikes=0;
		pnt2(1,1)=0;
	end
	endofpeak=pnt2(1,1)
	put(pnt2(1,1), 35)
	put(latency, 34)
	ll=getatval(26);
	if ll==0
		ll=mean([6 latency]);
		disp([num2str(ll) ' msec was used as the onset latency.'])
	end
	drspikes=(sum(histo(ll:endofpeak))/confactor)*1.5;% Increased bec retangle is used instead of a triangle.
	put(drspikes, 40)
	disp(['Estimated average driven spikes= ' num2str(drspikes)])
elseif other==3
	disp(' ')
	disp('Click on Figure(2) to mark onset of second peak.')
	pnt2= ginput(1);
	if pnt2(1,1)<0
		disp(' ')
		disp('Warning - second peak was less than zero.')
		disp(' ')
		spikes=0;
		pnt2(1,1)=0;
	end
	onsetsecondpeak=pnt2(1,1)
	put(pnt2(1,1), 39)
	put(latency, 34)
elseif other==4
	disp(' ')
	disp('Click on Figure(2) to mark second peak.')
	pnt2= ginput(1);
	if pnt2(1,1)<0
		disp(' ')
		disp('Warning - second peak was less than zero.')
		disp(' ')
		spikes=0;
		pnt2(1,1)=0;
	end
	secondpeak=pnt2(1,1)
	put(pnt2(1,1), 36)
	put(latency, 34)
elseif other ==10 %This makes a nice figure for a poster.
	figure(3)
	bar(histo*(1000/confactor))
	ylabel('Firing Rate')
	xlabel('Latency')
	t=get(get(2, 'currentaxes'), 'ylim');
	t=t(2);
	x=get(get(2, 'currentaxes'), 'xlim');
	set(gca, 'xtick', [0:20:x(2)])
	line(x, [sp sp], 'color', 'r')
else
	text(latency, t, 'O', 'color', 'r', 'HorizontalAlignment', 'center')
	put(latency, 34)
end
snr=max(histo*1000/confactor)/sp;
put(snr, 37);
latency
disp(' ')
disp('Ready.')
figure(1)
delete(linehnd)
if strcmp(computer, 'SGI')==1
   if other==0, vfvf=(fliplr((sin(0:.3:1500))+(sin(0:.3*.99:1500*.99)) +(sin(0:.3*1.01:1500*1.01))));, sound(vfvf(1, 110:3600), 44100), end
end
