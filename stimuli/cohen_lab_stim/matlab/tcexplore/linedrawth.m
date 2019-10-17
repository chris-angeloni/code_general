function linedraw(xlab,ylab,rm_display)

xlo = min(xlab); xhi = max(xlab);
ylo = min(ylab); yhi = max(ylab);
xstep = (xhi-xlo)/(size(rm_display,2)-1);
ystep = (yhi-ylo)/(size(rm_display,1)-1);
xticks = xlo:xstep:xhi;
yticks = ylo:ystep:yhi;

[r c]=find(rm_display); % r,c are row and column vectors for each non-zero point in rm_display
i = find(rm_display); % index into all non-zeros points
h = rm_display(i)'; % value of each non-zero point in same coordinates as r,c

x = [xticks(c); xticks(c)]; % x coordinates for all vertical lines
h = h * ystep / 10; % scale h
y = [yticks(r) + ystep/2; yticks(r) + ystep/2 - h];

line(x,y,'color','y', 'linewidth', 1.5)
