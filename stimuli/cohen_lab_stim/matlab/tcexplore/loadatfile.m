function loadatfile(atfile)

ui_handles = get(figure(1), 'userdata');
save_button = ui_handles(22);
attributes = get(save_button, 'userdata');
eval(['load ' atfile])
if exist('data')
	set(save_button, 'userdata', data);
else
	w = findstr(atfile,'.');
	if isempty(w)==0
		atfile=atfile(1:(w-1));
	end
	eval(['data= ' atfile ';'])
	set(save_button, 'userdata', data);
end
