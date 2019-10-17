function histogram(other)

%	function histogram(other)
%  Generates a PSTH using all of the frequency/amplitude combinations
%  within the tuning curve.  Spontaneous activity level is shown.
%  A little smoothing is done.

load temp.mat;
ui_handles = get (figure(1), 'userdata');
save_button = ui_handles(22);
haxis = ui_handles(8);
spon= get(ui_handles(15), 'userdata');
cf_button = ui_handles(9);
th=getatval(3);
cf=getatval(2);
l=max(find(amps<th));
g=min(find(amps>th));
if (th-amps(l))<(amps(g)-th)  %find the amp row that the threshold response is on
	amrow=l;
else
	amrow=g;
end

low = max(find(frequency<=cf));  % This section finds the freq column closest to the CF.
high = min(find(frequency>=cf));
if cf<frequency(1)
	cfcol=size(t1,2)/2;
elseif (cf-frequency(low)) <= (frequency(high)-cf)
	cfcol=low;	
else
	cfcol=high;
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

	l=max(find(amps<th+40));  %this sections finds the row that the Q value was obtained from.
	g=min(find(amps>th+40));
	if (th-amps(l))<(amps(g)-th)  %find the amp row that the threshold response is on
		row=l;
	else
		row=g;
	end
	top=th+40;
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

	l=max(find(amps<th+30));  %this sections finds the row that the Q value was obtained from.
	g=min(find(amps>th+30));
	if (th-amps(l))<(amps(g)-th)  %find the amp row that the threshold response is on
		row=l;
	else
		row=g;
	end
	top=th+30;
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

	l=max(find(amps<th+20));  %this sections finds the row that the Q value was obtained from.
	g=min(find(amps>th+20));
	if (th-amps(l))<(amps(g)-th)  %find the amp row that the threshold response is on
		row=l;
	else
		row=g;
	end
	top=th+20;
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

	l=max(find(amps<th+10));  %this sections finds the row that the Q value was obtained from.
	g=min(find(amps>th+10));
	if (th-amps(l))<(amps(g)-th)  %find the amp row that the threshold response is on
		row=l;
	else
		row=g;
	end
	top=th+10;
else
	acol=1;
	bcol=45;
	top=max(amps);
end

hmax=max(amps);
hmin=min(amps);
xmax=size(t1,2);
mleft=(cfcol-acol)/(top-amps(amrow));
xleft=(mleft*(hmax-(amps)))+acol;
mright=(cfcol-bcol)/(top-amps(amrow));
xright=(mright*(hmax-(amps)))+bcol;
th
top
amrow
for i=size(t1,1):-1:1
	t=xleft(1,i):xright(1,i);
	s(i, :)=[min(t), max(t)];
end
s=flipud(s);
g=find(s>size(t1, 2));
s(g)=ones(size(g))*size(t1, 2);
h=find(s<1);
s(h)=ones(size(h));
samples=sum(round(s(:, 2))-round(s(:,1)))

px=[(acol/xmax) (cfcol/xmax); (cfcol/xmax) (bcol/xmax)];
py=[top th; th top];
eval (['linehnd1=line(px, py, ''color'', ''r'');']);

%eval (['linehnd=line([' num2str(acol) '/45; ' num2str(bcol) '/45], [' num2str(th) ';' num2str(th) '], ''color'', ''r'');'])
figure(2)
clf reset
lat_button = uicontrol(gcf,...
	'style','push',...
	'position',[.1 .95 .2 0.05],...
	'units','normalized',...;
	'string','Choose Latency',...
	'callback', 'histogram2(1)');
secpeak_button = uicontrol(gcf,...
	'style','push',...
	'position',[.6, .95 .2 0.05],...
	'units','normalized',...;
	'string','Second Peak',...
	'callback', 'histogram2(3)');
endpeak_button = uicontrol(gcf,...
	'style','push',...
	'position',[.35, .95 .2 0.05],...
	'units','normalized',...;
	'string','End of Peak',...
	'callback', 'histogram2(2)');

st=get (ui_handles(2), 'value');
rn=get (ui_handles(5), 'value');
latencyampC=zeros((rn+1), length(amps));
latencyampCl=zeros((rn+1), length(amps));
latencyampCh=zeros((rn+1), length(amps));
st=floor(st);
rr=size(t1, 1)+1;
histo=zeros(1, duration);
for i=1:duration
	for j=1:size(s, 1)
		eval (['histo(' num2str(i) ') =histo(' num2str(i) ') +  sum(sum(full(t' num2str(i) '(rr-j, s((j), 1):s((j), 2)))));'])
	end
end

histo1=[0 histo]*.5;
histo2=[histo(2:length(histo)) 0 0]*.5;
histo=[histo 0];
histo=(histo+histo1+histo2)/2;
m=max(histo);
z=find(histo==m);
latency=z(1,1);
figure(2)
bar(histo)
ylabel('Percent of max')
xlabel('latency')
t=get(get(2, 'currentaxes'), 'ylim');
t=t(2);
x=get(get(2, 'currentaxes'), 'xlim');
spon = (spon/45)*samples;
line(x, [spon spon])
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
	drspikes=sum(histo(ll:endofpeak))/samples;
	put(drspikes, 40)
	disp(['Total driven spikes= ' num2str(drspikes)])
elseif other==3
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
else
	text(latency, t, 'O', 'color', 'r', 'HorizontalAlignment', 'center')
	put(latency, 34)
end

disp(' ')
disp('Ready.')
latency
figure(1)
%delete(linehnd)
delete(linehnd1)


