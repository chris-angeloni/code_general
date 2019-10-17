function tcexplore_cb(action)
% function tcexplore_cb(action)
% all of the callback functions for tcexplore
% rev 0.1 hwm 26sep

ST_SLIDER	= 2; % st value
ST_TEXT		= 4; % needed in callback
RN_SLIDER	= 5; % rn value
RN_TEXT		= 7; % needed in callback

ui_handles = get(gcf,'userdata'); % get handles to all objects
st_slider = ui_handles(ST_SLIDER);
st_text = ui_handles(ST_TEXT);
rn_slider = ui_handles(RN_SLIDER);
rn_text = ui_handles(RN_TEXT);

st = get(st_slider,'value');
rn = get(rn_slider,'value');  

if action == ST_SLIDER % start slider
	v = floor(get(st_slider,'value'));
	set(st_slider,'value',v)
	set(st_text,'string',num2str(v))
elseif action == ST_TEXT % start editable text
	% must ensure text is converted to an integer
	v = floor(sscanf(get(st_text,'string'),'%f'));
	max = get(st_slider,'userdata'); % max value is stored in the slider userdata
	if (v < 1) | (v > max)
		v = get(st_slider,'value');
	end
	set(st_slider,'value',v);
	set(st_text,'string',num2str(v))
elseif action == RN_SLIDER % range slider
	v = floor(get(rn_slider,'value'));
	set(rn_slider,'value',v);
	set(rn_text,'string',num2str(v))
elseif action == RN_TEXT % start editable text
	% must ensure text is converted to an integer
	v = floor(sscanf(get(rn_text,'string'),'%f'));
	max = get(rn_slider,'userdata'); % max value is stored in the slider userdata
	if (v < 1) | (v > max)
		v = get(rn_slider,'value');
	end
	set(rn_slider,'value',v);
	set(rn_text,'string',num2str(v))
elseif action == 8 % full reverse step
	if (st - rn) > 0
		st = st - rn;
	end
elseif action == 9 % half reverse step
	if (st - floor(rn/2)) > 0
		st = st - floor(rn/2);
	end
elseif action == 10 % half forward step
	if (st + floor(rn/2)) <= get(st_slider,'userdata')
		st = st + floor(rn/2);
	end
elseif action == 11 % full forward step
	if (st + rn) <= get(st_slider,'userdata')
		st = st + rn;
	end
end

if (action >= 8) & (action <= 11) % change the sliders to reflect the steps
	set(st_slider,'value',st)
	set(st_text,'string',num2str(st))
end
