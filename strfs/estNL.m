function [x,y,mdl,ahat,mfit] = estNL(x,y,ops);

%% function [x,y,mdl,ahat,mfit] = estNL(x,y,ops);
%
% this function fits an exponential to predicted versus measured
% firing rates to estimate a neurons nonlinearity. for cleanliness,
% removes outliers using Mahalanobis distance
%
% INPUT:
%  x: linear convolution prediction
%  y: actual spike histogram (** NEEDS TO BE IN SPIKE COUNTS **)
%  ops: struct with fitting options
%  ops.nbins: number of histogram bins to use
%  ops.fs: sampling rate
%  ops.weighting: weighted fit or not (true/false)
%  ops.model: model type ('exponential','sigmoid')
%  ops.includeZero: include bins with 0 fr in fit (true/false)
%
% OUTPUT:
%  x: prediction bins
%  y: binned fr
%  mdl: function handle for exponential
%  ahat: model parameters from fitting
%  mfit: minfunc fit

warning off
x0 = x;
y0 = y;

% check for inputs
if ~isfield(ops,'fs') | isempty(ops.fs)
    error('Must supply sampling rate in ops.fs!');
end
if ~isfield(ops,'nbins') | isempty(ops.nbins)
    ops.nbins = 50;
end
if ~isfield(ops,'weight') | isempty(ops.weight)
    ops.weight = true;
end
if ~isfield(ops,'model') | isempty(ops.model)
    ops.model = 'exponential';
end
if ~isfield(ops,'includeZero') | isempty(ops.includeZero)
    ops.includeZero = true;
end

%% histogram eq
% bin the linear prediction with default binning
[n,edges,bins] = histcounts(x,ops.nbins);

% count spikes in each bin
nl = zeros(1,max(bins));
for i = 1:length(nl)
    nl(i) = sum(y(bins == i));
end

% total time for each bin
bt = (1/ops.fs) * n;

% firing rate per bin (nspikes / bin time)
y = nl ./ bt;

% bin centers
x = edges(1:end-1) - diff(edges)/2;

% if specified, remove values above the mean that are 0
if ~ops.includeZero
    y(y==0 & x>0) = nan;
end

% remove nans
x(isnan(y)) = [];
n(isnan(y)) = [];
y(isnan(y)) = [];


if ~isfield(ops,'skipfit') | isempty(ops.skipfit)



    % force weights with no values to 1
    n(n==0) = 1;


    if ~logical(ops.weight)
        % if we're not weighting, set all the weights to be the same
        n = ones(size(n));
        xf = x; yf = y;
    else
        % otherwise, weight everything by repmatting
        xf = []; yf = [];
        for i = 1:length(n)
            xf = [xf; repmat(x(i),n(i),1)];
            yf = [yf; repmat(y(i),n(i),1)];
        end
    end


    %% model setup
    if strcmp(ops.model,'exponential')
        % exponential model
        mdl = @(a,x)(a(1) + a(2)*exp((x-a(4))*a(3)));
        
        % parameter grid search
        a0 = [repmat(min(yf),5,1) linspace(10,.001,5)' linspace(1,.01,5)' repmat(mean(xf),5,1)];
        lb = [0 .001 -inf min(xf)];
        ub = [max(yf) inf inf max(xf)];
        
    elseif strcmp(ops.model,'sigmoid')
        % sigmoid model
        mdl = @(a,x)(a(1) + a(2) ./ (1 + exp(-(x-a(4)).*a(3))));
        
        % starting parameters and bounds
        a0 = [repmat(min(yf),5,1) linspace(max(yf),min(yf),5)' linspace(2,.01,5)' repmat(mean(xf),5,1)];
        lb = [0 .001 0 -inf];
        ub = [max(yf) inf max(yf) inf];
        
    end

    if isempty(yf) | isempty(xf)
        error('x or y is empty!');
        
    elseif any(isnan([yf(:); xf(:)]))
        fprintf('Found nan!')
        keyboard
        
    else
        
        % unique parameter grid
        u1 = unique(a0(:,1));
        u2 = unique(a0(:,2));
        u3 = unique(a0(:,3));
        u4 = unique(a0(:,4));
                
        % try fmincon grid search
        try
            
            % grid search
            clear ah fv ef o;
            for j = 1:length(u2)
                for k = 1:length(u3)
                    for i = 1:length(u1)
                        for ii = 1:length(u4)
                                                        
                            t0 = tic;
                            
                            % fit using fmincon
                            options = optimoptions('fmincon',...
                                                   'Algorithm','sqp',...
                                                   'Display','off');
                            %'Outputfcn',@(x,optimValues,state)outfun(x,optimValues,state,t0));
                            
                            if strcmp(ops.model,'exponential')
                                p0 = [a0(i,1) a0(j,2) a0(k,3) a0(ii,4)];
                            else
                                p0 = [a0(i,1) a0(j,2) a0(k,3) a0(ii,4)];
                            end
                            [ah(:,i,j,k,ii),fv(i,j,k,ii),ef(i,j,k,ii)] = ...
                                fmincon(@(a)(norm(yf'-mdl(a,xf'))),p0,...
                                        [],[],[],[],lb,ub,[], ...
                                        options);
                        end
                    end
                end
            end
            
            % find starting parameters yielding the best fit
            [~,mi] = min(fv(:));
            [i,j,k,ii] = ind2sub(size(fv),mi);
            
            % failure case
            if sum(ef(:)>0) == 0
                fprintf(['Grid search failed to converge... trying minFunc ' ...
                         'instead... ']);
                
                if strcmp(ops.model,'exponential')
                    a0 = [min(y); .5; .01; 0];
                else
                    a0 = [min(y); .5; .01; 0];
                end
                
                keyboard
                
                % fit using minFunc
                options = [];
                options.display = 'none';
                options.numDiff = 1;
                [ahat,f,exitflag,output] = minFunc(@(a)(norm(yf'-mdl(a,xf'))), ...
                                                   a0,options);
                
                if exitflag < 1
                    fprintf('Ugh, still not fit... use current ahat...\n');
                    
                else
                    fprintf('it worked!\n');
                    
                end
                
            else
                % output parameters
                ahat = ah(:,i,j,k,ii);
                
            end
            
            
            % if fmincon errored out, just use minFunc
            if strcmp(ops.model,'exponential')
                a0 = [min(y); .5; .01; 0];
            else
                a0 = [min(y); max(y); .1; 0];
            end
            options = [];
            options.display = 'none';
            options.numDiff = 1;
            [mfit.ahat,mfit.f,mfit.exitflag,mfit.output] = minFunc(...
                @(a)(norm(yf'-mdl(a,xf'))),a0,options);
            mfit.options = options;
            
            
        catch ME
            rethrow(ME);
            % if fmincon errored out, just use minFunc
            if strcmp(ops.model,'exponential')
                a0 = [min(y); .5; .01; 0];
            else
                a0 = [min(y); max(y); .1; 0];
            end
            options = [];
            options.display = 'none';
            options.numDiff = 1;
            [ahat,f,exitflag,output] = minFunc(@(a)(norm(yf'-mdl(a,xf'))), ...
                                               a0,options);
            
        end
        
    end

else
    
    mdl = [];
    ahat = [];
    mfit = [];
    
end

    
    
    
    

%% exit fmincon if too much time has elapsed
function stop = outfun(x,optimValues,state,t0)

stop = false;
stop = toc(t0) > 20;

end
    
    

    


%      % fit using minFunc
%      options = [];
%      options.display = 'none';
%      options.numDiff = 1;
%      [ahat,f,exitflag,output] = minFunc(@(a)(norm(yf'-mdl(a,xf'))), ...
%                                         a0',options);

debug = false;

if debug
    figure
    hold on
    scatter(x,y)
    x1 = linspace(min(x),max(x),100);
    y1 = mdl(ahat,x1);
    plot(x1,y1);
    y0 = mdl(a0,x1);
    plot(x1,y0);
    
    keyboard
    
end

end







