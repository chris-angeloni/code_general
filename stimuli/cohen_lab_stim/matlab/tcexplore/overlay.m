ST_SLIDER	= 2; % st value
ST_TEXT		= 4; % needed in callback
RN_SLIDER	= 5; % rn value
RN_TEXT		= 7; % needed in callback

CF_BUTTON	= 9; % frequencies
MEASURE_BUTTON	= 15; % spontaneous activity rate
CONTOUR_BUTTON	= 16; % raw_data

SMOOTH_BOX	= 20; % need to read these true/false values to build screen
SPONTANEOUS_BOX	= 21;
PERCENT_SPONT	= 27;
LINE_BOX	= 25;
INTERPOLATE_BOX	= 18;
BLIND_BOX	= 17;

ATTRIBUTES	= 26;
SAVE_BUTTON	= 22;
EXP_TEXT	= 19;
FILENAME_TEXT	= 23; % full file_name with extension

H_AXIS		= 8; % amps
ui_handles = get(gcf,'userdata'); % get handles to all objects
	% get all handles, as image_sc will erase user_data later on
	st_slider = ui_handles(ST_SLIDER);
	st_text = ui_handles(ST_TEXT);
	rn_slider = ui_handles(RN_SLIDER);
	rn_text = ui_handles(RN_TEXT);
	cf_button = ui_handles(CF_BUTTON);
	measure_button = ui_handles(MEASURE_BUTTON);
	contour_button = ui_handles(CONTOUR_BUTTON);
	smooth_box = ui_handles(SMOOTH_BOX);
	spontaneous_box = ui_handles(SPONTANEOUS_BOX);
	percent_spont_text = ui_handles(PERCENT_SPONT);
	line_box = ui_handles(LINE_BOX);
	interpolate_box = ui_handles(INTERPOLATE_BOX);
	blind_box = ui_handles(BLIND_BOX);
	attributes_button = ui_handles(ATTRIBUTES);
	save_button = ui_handles(SAVE_BUTTON);
	exp_text = ui_handles(EXP_TEXT);
	filename_text = ui_handles(FILENAME_TEXT);

	st = floor(get(st_slider,'value'));
	rn = floor(get(rn_slider,'value'));
	smooth = get(smooth_box, 'value');
	spontaneous = get(spontaneous_box, 'value');
	interpolate = get(interpolate_box, 'value');
	blind = get(blind_box, 'value');
	exp = get(exp_text, 'string');
	attributes = get(save_button, 'userdata');
	percent_spontaneous = get(percent_spont_text, 'string');
file=get(filename_text, 'string');
fs=size(file, 2);
filepath=['../' file(1:fs-2) '.mat'];
disp(['Loading ' filepath '.'])
eval(['load ' filepath])
atc=zeros(size(t1));
for i=st:st+rn
	eval(['atc=atc+t' num2str(i) ';'])
end
rm_display=atc;
display_freqs = [0 1]; % display scaled from 0 to 1 to allow fake log scaling
display_amps = fliplr(amps); % y axis must be descending for proper imagsc orientation
xlab=display_freqs;
ylab=display_amps;
rm_display=atc;
xlo = min(xlab); xhi = max(xlab);
ylo = min(ylab); yhi = max(ylab);
xstep = (xhi-xlo)/(size(rm_display,2)-1);
ystep = (yhi-ylo)/(size(rm_display,1)-1);
xticks = xlo:xstep:xhi;
yticks = ylo:ystep:yhi;
[r c]=find(rm_display); % r,c are row and column vectors for each non-zero point in rm_display
i = find(rm_display); % index into all non-zeros points
h = rm_display(i)'; % value of each non-zero point in same coordinates as r,c
x = [xticks(c); xticks(c)]; % x coordinates for all vertical lines
h = h * ystep / 10; % scale h
y = [yticks(r) + ystep/2; yticks(r) + ystep/2 - h];
line(x+.005,y, 'color','b')


