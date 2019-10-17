function sharp(ampdiff);

%	function sharp(ampdiff)
% Sharp determines the Q-values, bandwidth, and asymmetry of
% the tuning curve at threshold plus the amplitude determined
% by ampdiff.

ui_handles = get (gcf, 'userdata');
haxis = ui_handles(8);
cf_button = ui_handles(9);
frequency = get (cf_button, 'userdata');
amps = get (haxis, 'userdata');
CF = getatval(2);
Threshold = getatval(3);

if CF ==0  %If there is no CF, then get one.
	disp(' ')
	disp('Click on CF of the tuning curve.')
	point=ginput(1);
	text(point(1), point(2), '.', 'color', 'k', 'horizontalalignment', 'left')
	CF= min(frequency)*(2^((log2(max(frequency)/min(frequency))* (point(1,1)))));
	Threshold= point(1,2);
	put(CF, 2);
	put(Threshold, 3);
end

ampx=(Threshold+ampdiff);
if ampx <= max(amps);
	lnx=line([0 1], [ampx ampx]);
	set(lnx, 'color', 'r');
	disp(' ')
	disp('Click two points on the line at each side of the tuning curve.')
	disp('Left first, then right.')
	Qpoints=ginput(2);
	disp(' ')
	disp('Ready.')
	A= min(frequency)*(2^((log2(max(frequency)/min(frequency))* (Qpoints(1,1)))));
	B= min(frequency)*(2^((log2(max(frequency)/min(frequency))* (Qpoints(2,1)))));
	Qbandwidth=abs(B-A);
	bandwidth = abs(log2(B/A));
	Q=(CF)/Qbandwidth;
	asym= (log2(B/CF)) -(log2(CF/A));
	delete(lnx);
	if ampdiff == 10
		put(Q, 6);
		put(A, 7);
		put(B, 8);
		put(bandwidth, 9);
		put(asym, 10);
	elseif ampdiff == 20
		put(Q, 11);
		put(A, 12);
		put(B, 13);
		put(bandwidth, 14);
		put(asym, 15);
	elseif ampdiff == 30
		put(Q, 16);
		put(A, 17);
		put(B, 18);
		put(bandwidth, 19);
		put(asym, 20);
	elseif ampdiff == 40
		put(Q, 21);
		put(A, 22);
		put(B, 23);
		put(bandwidth, 24);
		put(asym, 25);
	else
		ampdiff
		Q
		A
		B
		bandwidth
		asym
	end
else disp ('Not within data range.')

end
