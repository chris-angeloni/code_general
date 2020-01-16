function [x_orig,y_orig,mdl,ahat,p,dm] = estNLFR(fr,frh,npoints,weighting,model,thresh);

%% function [x,y,mdl,ahat,p] = estNLFR(fr,frh,pct,thresh);
%
% this function fits an exponential to predicted versus measured
% firing rates to estimate a neurons nonlinearity. for cleanliness,
% removes outliers using Mahalanobis distance
%
% INPUT:
%  fr: actual firing rate
%  frh: predicted firing rate (should be same sampling as fr)
%  pct: resolution of data sampling for prediction distribution
%  thresh: Mahalanobis distance threshold
%  model: 'exponential' or 'sigmoid'
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
        %y = y(~isnan(y));
        %x = x(~isnan(y));
        %n = n(~isnan(y));
        
        % if there is a spike rate above linear prediction 0 that
        % is 0, set it to nan
        y(y==0) = nan;
                        
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

% force weights with no values to 1
n(n==0) = 1;

if exist('weighting','var')
    if isempty(weighting) || ~logical(weighting)
        % if we're not weighting, set all the weights to be the same
        n = ones(size(n));
    end
end

if ~exist('model','var') | strcmp(model,'exponential')
    % exponential model
    mdl = @(a,x)(a(1) + a(2)*exp(x*a(3)));
    
    a01 = [nanmean(y);nanmax(y)/nanmax(x);.05];
    a02 = [nanmean(y);nanmean(y)/nanmean(x);.05];
    a03 = [nanmean(y);.3;.05];
    a04 = [nanmean(y);0;.01];
    ahat = [nan nan nan];
    
elseif strcmp(model,'sigmoid')
    % sigmoid model
    mdl = @(a,x)(a(1) + a(2) ./ (1 + exp(-(x-a(3)).*a(4))));
    
    a01 = [nanmean(y);nanmax(y)/nanmax(x);nanmean(x);.05];;
    a02 = [nanmean(y);nanmean(y)/nanmean(x);nanmean(x);.05];
    a03 = [nanmean(y);.3;nanmean(x);.05];
    a04 = [nanmean(y);0;nanmean(x);.05];
    ahat = [nan nan nan nan];
    
end

if isempty(y)
    y = nan(size(x));
    y_orig = y;
end

if ~all(isnan(y))
    % fit nonlinearity
    try        
        a0 = a01;
        [ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0,'Weights',n);
        
    catch ME
        try
            a0 = a02;
            [ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0,'Weights',n);
            
        catch ME
            try
                a0 = a03;
                [ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0,'Weights',n);
            
            catch ME
                try
                    a0 = a04;
                    [ahat,r,J,cov,mse] = nlinfit(x,y,mdl,a0,'Weights',n);
                
                catch ME
                    keyboard
                    
                end
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
    
else
    
    p.y1 = nan;
    p.yend  = nan;
    p.y0  = nan;
    p.slope0x  = nan;
    p.slopeAll  = nan;
    p.offset  = nan;
    p.baseline  = nan;
    p.slope02  = nan;
    p.slope01  = nan;
    
end




%  hold on
%  scatter(x,y)
%  x1 = linspace(min(x),max(x),100);
%  y1 = mdl(ahat,x1);
%  plot(x1,y1);