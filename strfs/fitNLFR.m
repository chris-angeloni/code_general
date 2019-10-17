function [x,y,mdl,ahat,p] = fitNLFR(fr,frh,t);

%% function [x,y,mdl,ahat,p] = estNLFR(fr,frh,t);
%
% this function fits an exponential to predicted versus measured
% firing rates to estimate a neurons nonlinearity

warning off

% smooth estimate and original fr
fr = SmoothGaus(fr,3);
frh = SmoothGaus(frh,3);

% sort and bin the x axis
sortBins = sort(frh);
ndata = round(.01*length(fr)); % 1% of data
edges = sortBins(1:ndata:end);
centers = edges(1:end-1) + diff(edges)/2;
edges(1) = -Inf; edges(end) = Inf;

% find mean fr for each bin
[~,bins] = histc(frh,edges);
nl = zeros(1,max(bins));
for i = 1:length(nl)
    nl(i) = mean(fr(bins(1:end) == i));
end
x = centers(1:end);
y = nl(1:end);

% fit nonlinearity
mdl = @(a,x)(a(1) + a(2)*exp(x*a(3)));
a0 = [0.1;0.3;0.1];
[ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0);

% compute some parameters
x1 = x(1);
x2 = x(end);
p.y1 = mdl(ahat,x1);
p.yend = mdl(ahat,x2);
p.y0 = mdl(ahat,0);

% slope from y0 to max
p.slope0x = x2 / (p.yend - p.y0);

% slope from bottom to top
p.slopeAll = (x2-x1) / (p.yend-p.y1);

% offset
p.offset = ahat(1) + ahat(2);

% baseline
p.baseline = mdl(ahat,-10000);

% slope from 0 to 2
y2 = mdl(ahat,2);
p.slope02 = (2-0) / (y2-p.y0);

%  hold on
%  scatter(x,y)
%  x1 = linspace(min(x),max(x),100);
%  y1 = mdl(ahat,x1);
%  plot(x1,y1);