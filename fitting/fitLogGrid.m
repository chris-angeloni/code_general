function [params,mdl,threshold,sensitivity,fmcon,minfun,pthresh] = fitLogGrid(x,y,p0,weights,ngrid,perfthresh,lb,ub)

%% function [params,mdl,threshold,sensitivity,fmcon,minfun] = fitLogGrid(x,y,p0,weights,ngrid,perfthresh,lb,ub)
%
% This function fits a psychometric curve to data using a logistic
% function using constrained optimization, fmincon, with a grid search:
%
%   y = gamma + (1-gamma-lambda) .* ( 1 / (1 + exp(-(-alpha+beta.*x))) )
%
% where:
%   alpha = x-offset (JND = alpha/beta)
%   beta = slope (sensitivity)
%   gamma = guess rate (FA) -- constrained between 0 and 1
%   lambda = lapse rate (misses when the task is easy) -- constrained between 0 and 1
%
% INPUTS:
%  x,y: x and y data points to fit (eg. x = target SNR, y = p(response))
%  p0: starting parameters to try in addition to grid search
%  weights: optional weight for each observation
%  ngrid: number of interpolation points for grid search
%  perfthresh: optional performance criterion to evaluate threshold
%  lb/ub: lower and upper parameter bounds
%
% OUTPUTS:
%  params: the fit parameters [alpha,beta,gamma,lambda]
%  mdl: logistic equation
%  threshold: alpha/beta, or the steepest part of the curve, aka JND
%  sensitivity: beta, or the slope
%  fmcon: struct with some info about the fitting and grid search
%  minfun: minFunc fitting results (really quick search algorithm, but unconstrained)


% model
mdl = @(a,x) (a(3) + (1-a(3)-a(4)) .* (1 ./ (1 + exp(-(-a(1)+(a(2).*x))))));

if nargin == 0
    % return just the model, set all other args to empty
    params = mdl;
    mdl = [];
    threshold = [];
    sensitivity = [];
    fmcon = [];
    minfun = [];
    
else

    % fit options
    options = optimoptions('fmincon',...
                           'OptimalityTolerance', 1e-10,...
                           'StepTolerance', 1e-10, ...
                           'ConstraintTolerance', 1e-10,...
                           'Algorithm','active-set',...
                           'Display','notify');

    % force x and y to be rows
    if size(x,1) ~= 1
        x = x';
    end
    if size(y,1) ~= 1
        y = y';
    end
    
    % set weights to be 1 by default
    if ~exist('weights','var') | isempty(weights)
        weights = ones(size(x));
    end

    % make values close to 0 and 1 be slightly less for fitting
    y(y == 0) = .001;
    y(y == 1) = .999;
    
    % remove nans
    x(isnan(y)) = [];
    weights(isnan(y)) = [];
    y(isnan(y)) = [];

    % assign weights
    ynew = [];
    xnew = [];
    for i = 1:length(x)
        ynew = [ynew repmat(y(i),1,weights(i))];
        xnew = [xnew repmat(x(i),1,weights(i))];
    end
    y = ynew;
    x = xnew;

    % set up search limits
    if ~exist('lb','var') | isempty(lb)
        lb = [min(x) .001 0 0];
    end
    if ~exist('ub','var') | isempty(ub)
        ub = [max(x) 10 1 1];
    end

    % grid points to try for each tunable parameter
    if ~exist('ngrid','var') | isempty(ngrid)
        ngrid = 10;
    end
    grid1 = linspace(min(x),max(x),ngrid);
    grid2 = logspace(log10(.01),log10(5),ngrid);

    if exist('p0','var') & ~isempty(p0)
        grid1 = [p0(1) grid1];
        grid2 = [p0(2) grid2];
    end

    % grid search
    for i = 1:length(grid1)
        for j = 1:length(grid2)
            
            p0 = [grid1(i) grid2(j) min(y) 1-max(y)];
            
            [p(i,j,:) f(i,j) e(i,j) o(i,j)] = fmincon(...
                @(p) norm(y-mdl(p,x)),p0',[],[],[],[],lb,ub,[], options);
            
        end
    end

    % find min error
    [mf,mi] = min(f(:));
    [i,j] = ind2sub(size(f),mi);

    % save out stuff
    params = squeeze(p(i,j,:));
    threshold = params(1)/params(2);
    sensitivity = params(2);
    
    % performance threshold
    if exist('perfthresh','var') & ~isempty(perfthresh)
        xf = linspace(min(x),max(x),100);
        yf = mdl(params,xf);
        [~,mi] = min(abs(yf-perfthresh));
        pthresh = xf(mi);
    else
        pthresh = [];
    end

    % grid results
    fmcon.gridMin = [i,j];
    fmcon.minErr = mf;
    fmcon.fval = f;
    fmcon.exitflag = e;
    fmcon.output = o;
    fmcon.options = options;


    if exist('minFunc')
        % fit with minfunc for good measure (its fast, very little
        % overhead...)
        options = [];
        options.display = 'none';
        options.numDiff = 1;
        [minfun.params,minfun.fval,minfun.exitflag,minfun.output] = ...
            minFunc(@(p) norm(y-mdl(p,x)),[grid1(i) grid2(j) min(y) 1-max(y)]',options);
        minfun.options = options;
    else
        minfun = [];
    end

end