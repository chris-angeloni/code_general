function rm_display = rmbkgnd(display,spont)
% rm_display= rmbkgnd(display,spont)
% A utility to remove the background activity
% in an organized way from a 2d tuning curve.
% spont is the number of background spikes
% to remove per row of frequencies.

rm_display = display;

i = find(rm_display==0);
rm_display(i) = inf * ones(size(i));
[r,c] = size(rm_display);

for n = 1:r,
	s = spont;
	while s > 0,
		y = min(rm_display(n,:));
		i = find(rm_display(n,:) == y);
		if y*length(i) <= s
			% kill all i's
			rm_display(n,i) = inf * ones(size(i));
			s = s - y*length(i);
		else
			% equally distribute the pain of s among the i's
			rm_display(n,i) = (y - s/length(i)) * ones(size(i));
			s = 0;
		end
	end
end

i = find(rm_display==inf);
rm_display(i) = 0 * ones(size(i));

