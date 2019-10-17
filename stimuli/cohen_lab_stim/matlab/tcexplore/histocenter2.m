function [histo, sp]=histocenter
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
top=amrow+4;
if round(top)<16
	a=a20*17/16; %narrows by 1/16 of an octave
	b=getatval(13)*(15/16); %narrows by 1/16 of an octave
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

	xbox=[acol/size(t1,2), bcol/size(t1,2), bcol/size(t1,2), acol/size(t1,2), acol/size(t1,2)];
	ybox=[th+20 th+20 th+40 th+40 th+20];
	linehnd=line(xbox, ybox, 'color', 'r');
	figure(2)
	st=get (ui_handles(2), 'value');
	rn=get (ui_handles(5), 'value');
	latencyampC=zeros((rn+1), length(amps));
	latencyampCl=zeros((rn+1), length(amps));
	latencyampCh=zeros((rn+1), length(amps));
	st=floor(st);
	for i=1:duration
		eval (['histo(' num2str(i) ') = sum(sum(full(t' num2str(i) '(amrow:amrow+4, acol:bcol))));'])
	end

	confactor=(5)*(bcol-acol+1);

	histo1=[0 histo]*.5;
	histo2=[histo(2:length(histo)) 0 0]*.5;
	histo=[histo 0];
	histo=(histo+histo1+histo2)/2;
	histo(1, 1)=sp*confactor/1000; % eliminates glich at 1msec latency.
	m=max(histo);
	z=find(histo==m);
	latency=z(1,1);
	snr=max(histo*1000/confactor)/sp;
	delete(linehnd)
	histo=histo*(1000/confactor);
	disp(['confactor: ' num2str(confactor)])
	if confactor<20, histo=[], end
	if max(histo)/sp<2, histo=[], end
	disp(' ')
else
	disp('Data not within range')
end
