function saveattrib(crap)

ui_handles = get(figure(1), 'userdata');
save_button = ui_handles(22);
attributes = get(save_button, 'userdata');
exp= ui_handles(19);
expfile= get(exp, 'string');
expfile= [expfile '.mat']
column_labels= 'filename	CF	Threshold	Latency	Q10	A10	B10	Bandwidth10	Asym10	Q30	A30	B30	Bandwidth30	Asym30	Q40	A40	B40	Bandwidth40	Asym40	MaxRate	MaxRateAmp	MaxRateCF	MaxRateCFAmp	RateSlope1	RateSlope2	NonMonotonic';
if exist(expfile) == 2
	eval(['load ' expfile])
	data = [data; attributes]
	eval(['save ' expfile ' data column_labels'])
	disp(['Saved as: ' expfile])
	disp(' ')
	disp('Ready.')
else
	data = attributes
	eval(['save ' expfile ' data column_labels'])
	disp('Experiment File Not Found. New File Created.')
	disp(['Saved as: ' expfile])
	disp(' ')
	disp('Ready.')
end
set(save_button, 'userdata', []);