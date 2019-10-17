function tcmovie_cb(action)
% function tcmovie_cb(action)
% rev 0.1 hwm 26sep

ui_handles = get(gcf,'userdata'); % get handles to all objects
rate_text = ui_handles(1);
fwd = ui_handles(2);
rev = ui_handles(3);

if action == 1 % change frame rate
	v = fix(sscanf(get(rate_text,'string'),'%f'));
	set(rate_text,'userdata',v);
elseif action == 2 % forward play
	movie(get(fwd,'userdata'),1,get(rate_text,'userdata'))
elseif action == 3 % reverse play
	movie(fliplr(get(fwd,'userdata')),1,get(rate_text,'userdata'))
elseif action == 4 % forward play once
	movie(get(fwd,'userdata'),0)
end

