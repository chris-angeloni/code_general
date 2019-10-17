ui_handles = get (figure(1), 'userdata');
measure_button = ui_handles(15);
spont = get(measure_button, 'userdata');
if isempty(spont)
	spont=0;
end
spont
contour_button = ui_handles(16);
rm_display = get(contour_button, 'userdata');
figure(2)
clf;
maxrate=max(max(rm_display));
[cta, handa]=contour(rm_display,[(maxrate/4)+(spont/15)]);
hold on;
ctb=contour(rm_display,[(maxrate/2)+(spont/15)]);
% ctaln=line(cta(1,:)', cta(2,:)') ;
set(handa, 'color', 'm');
% cta(1,:)
ylabel('Amplitude')
xlabel('Frequency')
hold off;
colormap(jet);
