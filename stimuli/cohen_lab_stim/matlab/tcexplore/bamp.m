function bamp(a)

ui_handles = get(figure(1),'userdata');
haxis = ui_handles(8);
amps = get (haxis, 'userdata');
disp(' ')
disp('Click on Best Amplitude.')
figure(2)
[bamp, bampr] =ginput(1);
disp(' ')
if bamp<.5|bampr<0|bamp>length(amps)
	put(0, 28);
	put(0, 29);
	disp('Best Amplitude set to zero!')
else
	put(bampr, 28);
	put(amps(bamp), 29);
	disp(['Best Amp= ' num2str(amps(bamp)) ' ; Best Amp Rate= ' num2str(bampr)])
end
figure(1)
