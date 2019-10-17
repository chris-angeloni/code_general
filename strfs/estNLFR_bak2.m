function [x_orig,y_orig,mdl,ahat,p,dm,mdli] = estNLFR(fr,frh,npoints,thresh)

%% function [x,y,mdl,ahat,p] = estNLFR(fr,frh,pct,thresh);
%
% this function fits an exponential to predicted versus measured
% firing rates to estimate a neurons nonlinearity. for cleanliness,
% removes outliers using Mahalanobis distance
%
% INPUT:
%  fr: actual firing rate
%  frh: predicted firing rate (should be same sampling as fr)
%  npoints: number of histogram samples to use
%  thresh: Mahalanobis distance threshold
%
% OUTPUT:
%  x: prediction bins
%  y: binned fr
%  mdl: function handle for exponential
%  ahat: model parameters from fitting
%  p: various parameters for each fit (start and end values, zero values, slopes, etc)

warning off

% smooth estimate and original fr
%fr = SmoothGaus(fr,3);
%frh = SmoothGaus(frh,3);

% by default, do matching with averaging
x = frh;
y = fr;



if exist('npoints','var')
    
    % if specified, do histogram equalization (sort of)
    if ~isempty(npoints)
               
        % generate bins
        edges = linspace(min(frh),max(frh),npoints);
                   
         % find mean fr for each bin
        [n,~,bins] = histcounts(frh,edges);
        %[~,edges,bins] = histcounts(fr,2000);
        nl = zeros(1,max(bins));
        for i = 1:length(nl)
            nl(i) = mean(fr(bins == i));
        end
        centers = edges(1:end-1) + diff(edges)/2;
        x = centers(1:end);
        y = nl(1:end);
        
        
%         keyboard
%         
%         %% ryans original code
%         nfrh = (frh - mean(frh)) / std(frh);
%         sortBin = sort(nfrh);
%         
%         nfr = (fr - min(fr)) / (max(fr) - min(fr));
%         nfrh = (nfrh - min(nfrh)) / (max(nfrh) - min(nfrh));
%         
%         [J,T] = histeq(nfrh,histcounts(nfr));
%         
%         % edges
%         nSp05 = ceil(sum(spikeT)*.05);
%         edges = (sortBin(nSp05):0.1:sortBin(end-nSp05));
%         centers = edges(1:end-1) + diff(edges)/2;
%         edges(1) = -Inf; edges(end) = Inf;
%         
%         % binning
%         [~,bins] = histc(nfrh,edges);
%         nl = zeros(1,max(bins));
%         bins(end+1:length(fr)) = -1;
%         for i = 1:length(nl)
%             nl(i) = mean(fr(bins == i));
%         end
%         centers = centers(2:end-1);
%         nl = nl(2:end-1);
                
    end
    
end


% outlier detection
if exist('thresh','var')
    % compute Mahalanobis distance
    m = [mean(x) mean(y);mean(x) mean(y)];
    Y = [x' y'];
    dm = mahal(Y,Y);

    % remove outliers based on distance
    x_orig = x;
    y_orig = y;
    ind = dm < thresh;
    x = x(ind);
    y = y(ind);
    n = n(ind);
else
    dm = [];
    x_orig = x;
    y_orig = y;
    n = n;
end

% fit nonlinearity
mdl = @(a,x)( a(1) + a(2) .* exp((x.*a(3))) );
mdli = @(a,y)( log((y-a(1))./a(2)) ./ a(3) );
a0 = [0.1;.1;3];
[ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0,'Weights',n);

% compute some parameters
x1 = x(1);
x2 = x(end);
p.y1 = mdl(ahat,x1);
p.yend = mdl(ahat,x2);
p.y0 = mdl(ahat,0);

% slope from y0 to max
p.slope0x = (p.yend - p.y0) / (x2-0);

% slope from bottom to top
p.slopeAll = (p.yend-p.y1) / (x2-x1);

% offset
p.offset = ahat(1) + ahat(2);

% baseline
p.baseline = mdl(ahat,-10000);

% slope from 0 to 2
y2 = mdl(ahat,2);
p.slope02 = (y2-p.y0) / (2-0);

% slop from 0 to 1
y1 = mdl(ahat,1);
p.slope01 = (y1-p.y0) / (1-0);

%  hold on
%  scatter(x,y)
%  x1 = linspace(min(x),max(x),100);
%  y1 = mdl(ahat,x1);
%  plot(x1,y1);