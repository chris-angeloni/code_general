% M-file to read binary tuning curve (.dtc) files and 
%	plot.


%fid = fopen('c:\tms&dt\mixed\c2017\sc931100.dtc');
%fid = fopen('c:\m86\cs086001.dtc');
%fid = fopen('cs999015.dtc');
fid = fopen('cs119402.dtc')


H1 = fread(fid, 70, 'char');    %read file title as 16 bit character
H2 = fread(fid, 93, 'int16');   %read the rest of header

[L, count] = fread(fid, 'short');	%read data

status = fclose(fid);

disp(' ')
header  = sprintf('%c', H1(1:69));
disp('file:')
disp(header)


%to construct tuning curve array T from 1-d latency array L,
%	and plot it.



l = 5;			%l for numbers of spikes in given cell
%l = 95;		%l for latency of first spike in a cell
T = zeros(15, 45);	%the tuning curve array

for ii = 1:15
	T(ii, 1:45) = L((l):2: (l + 89))';

l = l+184;		%to begin next intensity
end



figure
xmin = 5;
xmax = 50;
ymin = 0;
ymax = 15.5;
axis([xmin xmax ymin ymax])

for freqs = 1:45	%intensities loop
	for inten = 1:15	%frequencies loop
		spk = T(inten, freqs);
		if spk >0
			hold on
			x1 = freqs;
			y1 = inten;
			a = spk*(.1);		%a and b simply to scale
			b = 2.3*a;		%  crosses to spike count.
			plot([x1, x1], [(y1-a), (y1+a)], 'g')
			plot([(x1-b), (x1+b)], [y1, y1], 'g')
		end
	end
end
hold off 
	
