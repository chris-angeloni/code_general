function [x_orig,y_orig,mdl,ahat,p,dm] = estNLFR_sigmoid(fr,frh,npoints,weighting,thresh)

%% function [x_orig,y_orig,mdl,ahat,p,dm] = estNLFR_sigmoid(fr,frh,npoints,weighting,thresh)
%
% this function fits a sigmoid to predicted versus measured
% firing rates to estimate a neurons nonlinearity. for cleanliness, can
% remove outliers using Mahalanobis distance
%
% INPUT:
%  fr: actual firing rate
%  frh: predicted firing rate (should be same sampling as fr)
%  npoints: resolution of data sampling for prediction distribution
%  weighting: boolean to determine whether to weight by the number of bins
%  thresh: Mahalanobis distance threshold
%
% OUTPUT:
%  x: prediction bins
%  y: binned fr
%  mdl: function handle for exponential
%  ahat: model parameters from fitting
%  p: various parameters for each fit (start and end values, zero values, slopes, etc)
%  dm: Mahalanobis distance of each point

warning off

% smooth estimate and original fr
%fr = SmoothGaus(fr,3);
%frh = SmoothGaus(frh,3);

% by default, do point matching
x = frh;
y = fr;

if exist('npoints','var')
    
    % if specified, do histogram equalization
    if ~isempty(npoints)

        % find mean fr for each bin
        [n,edges,bins] = histcounts(frh,npoints);
        nl = zeros(1,max(bins));
        for i = 1:length(nl)
            nl(i) = mean(fr(bins(1:end) == i));
        end
        x = edges(1:end-1) - diff(edges)/2;
        y = nl(1:end);
        
        % remove nans
        y = y(~isnan(y));
        x = x(~isnan(y));
        n = n(~isnan(y));
                        
    end
    
end


% outlier detection
if exist('thresh','var')
    % compute Mahalanobis distance
    m = [mean(x) mean(y);mean(x) mean(y)];
    nI = ~isnan(y);
    Y = [x(nI)' y(nI)'];
    dm = mahal(Y,Y);
    
    if any(isinf(Y))
        keyboard
    end

    % remove outliers based on distance
    n = n(nI);
    x_orig = x(nI);
    y_orig = y(nI);
    ind = dm < thresh;
    x = x(ind);
    y = y(ind);
else
    dm = [];
    n = n;
    x_orig = x;
    y_orig = y;
end

if isempty(x) || isempty(y)
    disp('NO DATA');
    keyboard
end

% force weights with no values to 1
n(n==0) = 1;

if exist('weighting','var')
    if isempty(weighting) || ~logical(weighting)
        % if we're not weighting, set all the weights to be the same
        n = ones(size(n));
    end
end

% fit nonlinearity
try
    mdl = @(a,x)(a(1) + a(2) ./ (1 + exp(-(x-a(3)).*a(4))));
    a0 = [mean(y);max(y)/max(x);mean(x);.05];    %[mean(y);.3;.05]; %[mean(y);max(y)/max(x);.05]; %[mean(y);mean(y)/mean(x);.05];
    [ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0,'Weights',n);
catch ME
    try
        mdl = @(a,x)(a(1) + a(2) ./ (1 + exp(-(x-a(3)).*a(4))));
        a0 = [mean(y);mean(y)/mean(x);mean(x);.05];
        [ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0,'Weights',n);
    catch ME
        try
            mdl = @(a,x)(a(1) + a(2) ./ (1 + exp(-(x-a(3)).*a(4))));
            a0 = [mean(y);.3;mean(x);.05];
            [ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0,'Weights',n);
        catch ME
            keyboard
        end
    end
end

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