function tcexplore(file_name,action);

%
%	This program accepts tuning curve data in several formats:
%.dtc, u2m, and .mat
%.	Type tcexplore('Enter your filename here') to use
%the program.  The files must be in the present working directory.
%(Type pwd to see the directory you are in, and use cd to change 
%directories). This program allows the user to visualize
%tuning curve properties and allows for measurements of the 
%tuning curve parameters.  
%	Spike number is displayed as the color of the point.
%The color bar at the right explains the scaling.  NOTE: the
%colorscale rescales to make use of the entire range of color.
%Thus red can represent very different numbers of spikes.
%	Blind, Shade, Raw and Spon buttons determine 
%how the data is displayed.  When Blind is selected (box is
%black), frequency and amplitude data are not displayed on the
%screen.  When Shade is selected the data is interpolated
%linearly to fill in the data using a matlab interpolation.
%When Raw is selected the raw data is displayed.  When Raw is
%not selected the data is locally averaged and spontaneous
%activity is removed.  If Spon is selected spontaneous activity
%is not removed.  When Raw is selected the state of Spon has
%no effect.
%	The latency sliders at the bottom of the figure determine 
%the range of spikes that will be displayed and analyzed.  The range 
%is shown at the top of the figure.  It may be important to examine 
%the turning curve at more than one latency range.  After any display 
%format is changed the display button must be pressed to see the new 
%display.  
%	The fwd and rev buttons allow the user to easily step through 
%time as the tuning curve unfolds.  fwd increases the latency range 
%by the value of the range slider and displays the data.  rev decreases 
%the latency range by the same amount.  The half buttons do the same 
%thing but adjust the latencies by half the value of range.  This 
%allows the user to look at overlapping steps through time.  This 
%command is generally most useful when the range is a fairly low 
%number (like 10).
%	CF allows the user to set the CF point.  A small 
%black dot is placed at the point to remind the user of
%its location.  The Q buttons allow the user to analyze 
%the sharpness of tuning at 10, 30, and 40 dB above 
%threshold.  The user is required to click on two points
%at the edges of the tuning curve on the line drawn 10, 30, 
%or 40 dB above threshold.  The lefthand point should be
%clicked first, followed by the righthand point.  The command
%line in the matlab window provides instruction for how
%to use all buttons.  'Ready' indicates that the user
%may select a new function.
%	Lat plots latency versus amplitude for the isofrequency
%line at the CF.  The user is then required to click on the 
%latency that is representative of that unit.  If the user
%wants to see latency information for other frequencies, the
%'Other Frequency' button is pressed and a frequency is selected
%from the tuning curve.
%	Rate plots number of spikes versus amplitude for the
%isofrequency line at the CF.  The user then must click on
%three points: first the threshold point, second the
%transition point, third the end point.  The two lines are
%then plotted and the slopes of the lines are saved as
%percent of response at transition point per dB.
%	Histo shows a histogram of all of the spikes within the 
%responsive part of the tuning curve (from the threshold to the 
%max amplitude and from the lowest to the highest frequencies
%marked using the Q buttons.  The histogram is smoothed by adding
%each millisecond bin to half the values of its neighbors and 
%dividing by two.  Histo automatically records the time to max 
%response.  The value can be changed by pressing the 'Choose 
%Latency' button and selecting a latency.  The 'End of Peak'
%button records the time to the end of the first peak of activity.
%The ' Second Peak' button can record the latency of a second
%peak if one exists.
%	The 'All' button selects all of the 'Q' buttons, the 
%'Histo' button and the 'End of Peak' button with one button press.
%	The values of all of the parameters determined can be
%seen by pressing the attr button.  The file index is the
%last four numbers of the filename with letters in the last 
%place turned into numbers (a->1, b->2, c->3, etc.).  All of the
%parameters found by pressing the attr button is written over when
%data is entered again.  For example if after entering a Q10 one 
%wishes to change the value simply pressing Q10 and reentering
%the data updates the Q10 parameters.  All other attributes work
%the same way.  One can also go back to a file done earlier and 
%replace attribute values in the same way so long as the data has 
%not been saved.  If the data is shown when the attr button is
%pressed the data has not yet been save and can be updated.  
%	Once the save button has been pressed the attribute values 
%are written to a file and cannot be changed.  This is useful for two
%reasons: first it prevents one from accidentally writing over or 
%erasing data (this can happen by accidentally pressing one of the 
%buttons or closing the figure),second this allows multiple data sets 
%to be collected on the same tuning curve.  For example it is possible 
%to determine tuning curve attributes at two or more latency ranges.  
%If one enters data for a tuning curve, presses save, and reenters more 
%data on that tuning curve and saves again, there will be two rows for 
%that tuning curve in the final data matrix.  The data set entered first 
%will appear first in the matrix.  
%	The editable text above the save button is the name of the
%file that is created when the data is saved (the extension .mat is
%added).  Do not put other extensions in the filename.  Both the Save
%button and the File Title will be blue if a title has not been entered.
%	Type `help put' to see how to add additional attriubte values 
%not specifically used in tcexplore to the data matrix.
%	Transferring matlab data files to spreadsheet format:
%Type - load (name of the matlab data file)
%Type - save (name of the spreadsheet file) data -ascii -double -tabs
%The new file will be tab delineated ascii text which can be opened
%with most spreadsheets.  Import the data into the tcexplore Excel 
%template to have the columns labeled (see Ralph).
%	Troubleshooting:  Try clearing the workspace variables by 
%typing clear on the command line.  Make sure that you have provided 
%the information the program wants.  Read the instructions in the 
%matlab window.  If it does not say ready you probably need to enter 
%some value.  Control-C will interupt the program at anytime.  
%	When all else fails try closing all the figures.  In 
%matlab the program runs in the figures.  Closing them is the only 
%way to be sure you are starting from scratch.  This will delete the
%attributes if they have not been saved.
%	Files required to run tcexplorenewer.m:
%rmbkgnd.m, reaxis.m, tcexp_cb.m, sharp.m, rate.m, saveattrib.m,
%dispattrib.m, cfset.m, measure.m, getatval.m, latency.m,
%put.m, tccnewer.m, and condtc.m
% 
%Version 1.5 HWM Dec 15, 1995
%
%			Written by M. Kilgard and H.W. Mahncke
%

%defines
%name, number in ui_handle, data contained in userdata field
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

str_quote = ''''; % this is equivalent to a single quote mark. useful in callback statements requiring quotes

figure(1)

if ~exist('action') % if action doesn't exist, this was called by the user from the command line and all variables must be initialized
	action = 1;
end

if action == 1 % load file and initialize all variables
	if ~exist(file_name), disp('file not found'), break, end

	ext = file_name(findstr(file_name,'.')+1:length(file_name));
	if ext == 'mat'
		eval(['load ' file_name]);
		%The following is a crappy repair for a bug that introduces a 17th row and/or makes t500 filled with ones.
		eval(['klu=t' num2str(duration) ';'])
		if size(find(klu), 1)>300, 
			klu=zeros(size(t1));
			eval(['t' num2str(duration) '=sparse(klu);'])
		end
		fff=[];
		for ggg=1:duration
			eval(['fff=[fff; size(t' num2str(ggg) ', 1)];'])
		end 
		jjj=find(fff>size(t1,1));
		for ppp=jjj'
			eval(['t' num2str(ppp) '=t' num2str(ppp) '(1:' num2str(size(t1,1)) ', 1:' num2str(size(t1,2)) ');']) 
			aaa=['Error in t' num2str(ppp)];
			disp(aaa)
		end
		% End of debug routine.
		save temp
	elseif ext == 'dtc'
		condtc(file_name) % converts a .dtc file to a .mat file saved as temp.mat
		load temp
	elseif ext == 'uff'
		t2m(file_name) % converts a .uff file to a .mat file saved as temp.mat, requires a .dat file to be present
		load temp
	else
		disp(['unrecognized extention: ' ext]), break
	end

	ui_handles = get(gcf,'userdata');
	scratch = isempty(ui_handles);
	if scratch == 1 % start from scratch
		st = 16;
		rn = 24;
		smooth = 0;
		spontaneous = 0;
		line = 1;
		interpolate = 0;
		blind = 1;
		exp = 'Untitled';
		attributes=[];
		percent_spontaneous = '1';
	end
end

if action == 2 | scratch == 0 % if callback or called from command line but window has previously been initialized
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
	line = get(line_box, 'value');
	interpolate = get(interpolate_box, 'value');
	blind = get(blind_box, 'value');
	exp = get(exp_text, 'string');
	attributes = get(save_button, 'userdata');
	percent_spontaneous = get(percent_spont_text, 'string');

	if action == 2 % only need to load this if not loaded during initialization step above
		load temp.mat
	end
end

raw_display = zeros(size(t1));
[namps,nfreqs] = size(raw_display);

while (st+rn > duration) % ensure that range does not extend past the last time point
	rn = rn - 1;
end

for k=st:(st+rn)
	eval(['raw_display = raw_display + t' num2str(k) ';'])
end
display = raw_display; % all modifications performed on display

if smooth == 1 % smooth the data
	display = smooth_display(display);
end

if spontaneous == 1 % remove spontaneous activity
	total = t1; % total is used to evaluate the spontaneous activity across the duration of the trial
	for k=2:duration
		eval(['total = total + t' num2str(k) ';']);
	end
	spon = full(sum(total(1,:)))/duration; % note that this is per millisecond, across all frequencies at 0 amplitude
	spont = (spon*rn*(str2num(percent_spontaneous)));
	display = rmbkgnd(display,spont);
else
	total = t1; % total is used to evaluate the spontaneous activity across the duration of the trial
	for k=2:duration
		eval(['total = total + t' num2str(k) ';']);
	end
	spon = full(sum(total(1,:)))/duration; % note that this is per millisecond, across all frequencies at 0 amplitude	
end
	
display_freqs = [0 1]; % display scaled from 0 to 1 to allow fake log scaling
display_amps = fliplr(amps); % y axis must be descending for proper imagsc orientation

if line == 1

	h_plot = imagesc(display_freqs,display_amps,display); % note that this overwrites the userdata field for gcf
	set(h_plot,'visible','off')
	h_cbar = colorbar;
	set(h_cbar,'visible','off')
	linedraw(display_freqs,display_amps,display)
else
	if interpolate == 1 % interpolate the data the give a false sense of confidence
		%for k=1:size(display,1)
		%	i_display(k,:) = interp(display(k,:),16); % 16x oversampling
		%end
		%for k=1:size(i_display,2)
		%	ii_display(:,k) = interp(i_display(:,k),16); % 16x oversampling
		%end
		%display = ii_display;
	end

	h_plot = imagesc(display_freqs,display_amps,display); % note that this overwrites the userdata field for gcf
	h_cbar = colorbar;
	colormap(jet)
end

x_tick_labels(1,:) = sprintf('%5.0f',frequency(1));
x_tick_labels(2,:) = sprintf('%5.0f',frequency((length(frequency)/2)+0.5)); % assumes an odd number of frequencies
x_tick_labels(3,:) = sprintf('%5.0f',frequency(length(frequency)));
set(gca,'XTick',[0 0.5 1]);
set(gca,'XTickLabels',x_tick_labels);


if blind == 1 % remove axis labels if evaluation is being done blind
	set(gca, 'visible', 'off')
end

bar_pos = get(h_cbar,'position');
bar_pos(1) = bar_pos(1) -.03;
bar_pos(3) = bar_pos(3) -.01;
set(h_cbar,'position', bar_pos);

set(gca, 'fontsize', 10);

h_axis = gca;
set(h_axis, 'userdata', amps)

% establish some anchor points on the axis and colorbars to align all other objects

h_axis = get(h_plot,'parent');
axis_pos = get(h_axis,'position');
plot_left = axis_pos(1); plot_bottom = axis_pos(2); plot_width = axis_pos(3); plot_height = axis_pos(4); 
bar_left = bar_pos(1); bar_width = bar_pos(3);

slider_height = 0.03;
standard_height = 0.05;

analyze_left = 0.01;
analyze_width = 0.07;

box_left = bar_left + 0.09;
box_width = 0.1;

if strcmp(exp, 'Untitled') == 1
	save_color = [0 .5 .6];
else
	save_color = [.7 .7 .2];
end

% tools that set the data range displayed
st_slider = uicontrol(gcf,...
	'style','slider',...	
	'max',duration-1,...
	'min',1,...
	'position',[plot_left 0.04 plot_width/2 slider_height],...
	'units','normalized',...
	'value',st,...
	'userdata',duration-1,...
	'callback','tcexp_cb(2)');
st_label = uicontrol(gcf,...
	'style','text',...
	'position',[plot_left 0.01, plot_width/4, slider_height],...
	'units','normalized',...
	'string','start');
st_text = uicontrol(gcf,...
	'style','edit',...
	'position',[plot_left+plot_width/4 0.01, plot_width/4, slider_height],...
	'units','normalized',...
	'string',num2str(st),...
	'userdata',st,...
	'callback',['tcexp_cb(4),tcexplore(' str_quote file_name str_quote ',2)']);
rn_slider = uicontrol(gcf,...
	'style','slider',...
	'max',duration-st,...
	'min',0,...
	'position',[plot_left+plot_width/2 0.04 plot_width/2 slider_height],...
	'units','normalized',...
	'value',rn,...
	'userdata',duration-st,...
	'callback','tcexp_cb(5)');
rn_label = uicontrol(gcf,...
	'style','text',...
	'position',[plot_left+plot_width/2 0.01, plot_width/4, slider_height],...
	'units','normalized',...
	'string','range');
rn_text = uicontrol(gcf,...
	'style','edit',...
	'position',[plot_left+3*plot_width/4 0.01, plot_width/4, slider_height],...
	'units','normalized',...
	'string',num2str(rn),...
	'userdata',rn,...
	'callback',['tcexp_cb(7),tcexplore(' str_quote file_name str_quote ',2)']);
label_text = uicontrol(gcf,...
	'style','text',...
	'backgroundcolor', 'k',...
	'foregroundcolor', 'w',...
	'position',[.4 .93 .26 0.04],...
	'units','normalized',...;
	'string',['Range: ' num2str(st) 'ms to ' num2str(st+rn) 'ms']);

% tools that maneuver the displayed data throught time
full_rev = uicontrol(gcf,...
	'style','push',...
	'position',[plot_left plot_bottom+plot_height 0.05 0.05],...
	'units','normalized',...;
	'string','rev',...
	'callback',['tcexp_cb(8),tcexplore(' str_quote file_name str_quote ',2)']);
half_fwd = uicontrol(gcf,...
	'style','push',...
	'position',[plot_left+0.05 plot_bottom+plot_height 0.05 0.05],...
	'units','normalized',...;
	'string','half',...
	'callback',['tcexp_cb(9),tcexplore(' str_quote file_name str_quote ',2)']);
half_fwd = uicontrol(gcf,...
	'style','push',...
	'position',[plot_left+plot_width-0.10 plot_bottom+plot_height 0.05 0.05],...
	'units','normalized',...;
	'string','half',...
	'callback',['tcexp_cb(10),tcexplore(' str_quote file_name str_quote ',2)']);
full_fwd = uicontrol(gcf,...
	'style','push',...
	'position',[plot_left+plot_width-0.05 plot_bottom+plot_height 0.05 0.05],...,t
	'units','normalized',...;
	'string','fwd',...
	'callback',['tcexp_cb(11),tcexplore(' str_quote file_name str_quote ',2)']);

% tools to analyze the displayed data
cf_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left .88 analyze_width standard_height],...
	'units','normalized',...;
	'string','CF',...
	'userdata', frequency,...
	'callback', 'measure(1);');
Q10_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.82 analyze_width standard_height],...
	'units','normalized',...;
	'string','Q10',...
	'callback', 'sharp(10);');
Q20_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.76 analyze_width standard_height],...
	'units','normalized',...;
	'string','Q20',...
	'callback', 'sharp(20);');
Q30_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.70 analyze_width standard_height],...
	'units','normalized',...;
	'string','Q30',...
	'callback', 'sharp(30);');
Q40_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.64 analyze_width standard_height],...
	'units','normalized',...;
	'string','Q40',...
	'callback', 'sharp(40);');
Qall_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.58 analyze_width standard_height],...
	'units','normalized',...;
	'backgroundcolor', [.8 .7 .2],...
	'string','All',...
	'callback', 'sharp(10);, sharp(20);, sharp(30);, sharp(40);, latency(0);, histogram(2);');
latency_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.52 analyze_width standard_height],...
	'units','normalized',...;
	'string','Lat.',...
	'callback', 'latency(0)');
histo_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.46 analyze_width standard_height],...
	'units','normalized',...;
	'string','Histo',...
	'callback', 'histogram(0);');
rate_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.40 analyze_width standard_height],...
	'units','normalized',...;
	'string','Rate',...
	'callback', 'rate');
contour_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.34 analyze_width standard_height],...
	'units','normalized',...;
	'string','Contour',...
	'userdata', raw_display,...
	'callback', 'tccnewer');
measure_button = uicontrol(gcf,...
	'style','push',...
	'position',[analyze_left 0.28 analyze_width standard_height],...
	'units','normalized',...;
	'string','M',...
	'userdata', spon,...
	'callback', 'measure(0)');


% tools to modify to graphic display of the data
smooth_box = uicontrol(gcf,...
	'style','checkbox',...
	'position',[box_left 0.5 box_width standard_height],...
	'units','normalized',...;
	'value', smooth,...
	'string','Smooth');
spontaneous_box = uicontrol(gcf,...
	'style','checkbox',...
	'position',[box_left 0.44 box_width standard_height],...
	'units','normalized',...;
	'callback',['tcexplore(' str_quote file_name str_quote ',2)'],...
	'value', spontaneous,...
	'string','Spont');
percent_spont_text = uicontrol(gcf,...
	'style','edit',...
	'position',[box_left+0.02 0.38 box_width-.02 standard_height],...
	'units','normalized',...
	'string', percent_spontaneous);
percent_spont_label = uicontrol(gcf,...
	'style','text',...
	'position',[box_left+0.02 0.32 box_width-.02 standard_height],...
	'backgroundcolor', 'k',...
	'foregroundcolor', 'w',...
	'horizontalalignment', 'left',...
	'units','normalized',...;
	'string', '% Spont');
line_box = uicontrol(gcf,...
	'style','checkbox',...
	'position',[box_left 0.26 box_width standard_height],...
	'units','normalized',...;
	'value', line,...
	'callback',['tcexplore(' str_quote file_name str_quote ',2)'],...
	'string','Line');
interpolate_box = uicontrol(gcf,...
	'style','checkbox',...
	'position',[box_left 0.20 box_width standard_height],...
	'units','normalized',...;
	'value', interpolate,...
	'string','Interpolate',...
	'userdata', frequency);
blind_box = uicontrol(gcf,...
	'style','checkbox',...
	'position',[box_left 0.14 box_width standard_height],...
	'units','normalized',...;
	'value', blind,...
	'string','Blind');
display_button = uicontrol(gcf,...
	'style','push',...
	'position',[box_left 0.02 box_width standard_height],...
	'units','normalized',...;
	'string','Display',...
	'callback',['tcexplore(' str_quote file_name str_quote ',2)']);

% miscellaneous buttons
save_button = uicontrol(gcf,...
	'style','push',...
	'position',[box_left 0.9 box_width standard_height],...
	'units','normalized',...;
	'string','Save',...
	'userdata', attributes,...
	'callback', 'saveattrib(1)',...
	'backgroundcolor', save_color);
attributes_button = uicontrol(gcf,...
	'style','push',...
	'position',[box_left 0.84 box_width standard_height],...
	'units','normalized',...;
	'string','Attr',...
	'userdata', display,...
	'callback', 'dispattrib;');
movie_button = uicontrol(gcf,...
	'style','push',...
	'position',[box_left 0.78 box_width standard_height],...
	'units','normalized',...;
	'backgroundcolor', [1 .3 .1],...
	'string','Movie',...
	'callback', 'tcmovie(0)');
nextc_button = uicontrol(gcf,...
	'style','push',...
	'position',[box_left 0.7 box_width standard_height],...
	'units','normalized',...;
	'backgroundcolor', [.8 .2 .1],...
	'string','Nextc',...
	'callback', 'nextc');
exp_text = uicontrol(gcf,...
	'style','edit',...
	'position',[(bar_left) 0.955 .21 0.04],...
	'units','normalized',...;
	'backgroundcolor', save_color,...
	'string',exp);
filename_label = uicontrol(gcf,...
	'style','text',...
	'position',[0 .05 .12 0.03],...
	'backgroundcolor', 'k',...
	'foregroundcolor', 'w',...
	'horizontalalignment', 'left',...
	'units','normalized',...;
	'string', 'File Name:');
filename_text = uicontrol(gcf,...
	'style','text',...
	'position',[0 0 .12 0.04],...
	'units','normalized',...;
	'horizontalalignment', 'right',...
	'userdata', file_name,...
	'string', file_name(1:(length(file_name)-4)));

% save all relevant handles

ui_handles(ST_SLIDER)		= st_slider;
ui_handles(ST_TEXT)		= st_text;
ui_handles(RN_SLIDER)		= rn_slider;
ui_handles(RN_TEXT)		= rn_text;

ui_handles(CF_BUTTON)		= cf_button;
ui_handles(MEASURE_BUTTON)	= measure_button;
ui_handles(CONTOUR_BUTTON)	= contour_button;

ui_handles(SMOOTH_BOX)		= smooth_box;
ui_handles(SPONTANEOUS_BOX)	= spontaneous_box;
ui_handles(PERCENT_SPONT)	= percent_spont_text;
ui_handles(LINE_BOX)		= line_box;
ui_handles(INTERPOLATE_BOX)	= interpolate_box;
ui_handles(BLIND_BOX)		= blind_box;

ui_handles(ATTRIBUTES)		= attributes_button;
ui_handles(SAVE_BUTTON)		= save_button;
ui_handles(EXP_TEXT)		= exp_text;
ui_handles(FILENAME_TEXT)	= filename_text;
ui_handles(H_AXIS)		= h_axis;

set(figure(1),'userdata',ui_handles);
index=get_file_index(file_name);
put(index,1);
disp('Ready.')

if exist('extatten') == 1
	put(extatten, 4);
end
