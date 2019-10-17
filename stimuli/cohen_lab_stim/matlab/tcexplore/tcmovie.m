function tcmovie(crap)
% function tcmovie(crap)
% rev 0.1 hwm 26sep

load temp.mat
ui_handles = get (figure(1), 'userdata');
st = get (ui_handles(4), 'userdata');
rn = get (ui_handles(7), 'userdata');

%htemp = figure; % open temporary window for movie
figure(2)
clf reset;
duration;
numframes = floor((duration-st)/rn);
cs = st;
maxlvl = 0;
[r,c] = size(t1);
addarow = zeros(1,c);
addacol = zeros(r+1,1);

for k=1:numframes
	eval(['display = t' num2str(cs) ';'])
	for j=(cs+1):(cs+rn-1)
		eval(['display = display + t' num2str(j) ';'])
	end
	cs = cs+rn;
	display = [addarow; display]; % pcolor bugfix
	display = [display addacol]; 
	if maxlvl < max(max(display)) % keep running max for caxis constancy
		maxlvl = full(max(max(display)));
	end
	eval(['display' num2str(k) '= display;'])
end

m = moviein(numframes);
for k=1:numframes
	eval(['hp = pcolor(full(display' num2str(k) '));'])
	caxis([0 maxlvl])
	colormap(jet)
	m(:,k) = getframe;
	title(num2str((rn*(k-1))+st), 'fontsize', 35, 'units', 'normalized', 'position', [.5 .96])
	pause(.1)
end

ha = get(hp,'parent');
axis_pos = get(ha,'position');
p_l = axis_pos(1); p_b = axis_pos(2); p_w = axis_pos(3); p_h = axis_pos(4); % coordinates for the plot axes

rate_text = uicontrol(gcf,...
	'style','edit',...
	'position',[p_l+p_w/5 0.01, p_w/5, 0.05],...
	'units','normalized',...
	'string',2,...
	'userdata',2,...
	'callback','tcmovie_cb(1)');
fwd = uicontrol(gcf,...
	'style','push',...
	'position',[p_l+2*p_w/5 0.01 p_w/5 0.05],...
	'units','normalized',...;
	'string','forward',...
	'userdata',m,...
	'callback',['tcmovie_cb(2)']);
fwd1 = uicontrol(gcf,...
	'style','push',...
	'position',[p_l+3*p_w/5 0.01 p_w/5 0.05],...
	'units','normalized',...;
	'string','forward once',...
	'userdata',m,...
	'callback',['tcmovie_cb(4)']);
rev = uicontrol(gcf,...
	'style','push',...
	'position',[p_l 0.01 p_w/5 0.05],...
	'units','normalized',...;
	'string','reverse',...
	'callback',['tcmovie_cb(3)']);

set(gcf,'userdata',[rate_text fwd rev])

title(' ')
