function [params,mdl,threshold,sensitivity,FIT] = fitLogUnc(x,y,p0,weights)

%% function [params,mdl,threshold,sensitivity,FIT] = fitLogUnc(x,y,p0,weights)
%
% This function fits a psychometric curve to data using a logistic
% function using an unconstrained optimization algorithm called by minFunc:
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
%
% OUTPUTS:
%  params: the fit parameters [alpha,beta,gamma,lambda]
%  mdl: logistic equation
%  threshold: alpha/beta, or the steepest part of the curve, aka JND
%  sensitivity: beta, or the slope
%  FIT: struct with some info about the fitting


% fitting model and options
mdl = @(a,x) (a(3) + (1-a(3)-a(4)) .* (1 ./ (1 + exp(-(-a(1)+(a(2).*x))))));
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

% make values close to 0 and 1 be slightly less for fitting
y(y == 0) = .001;
y(y == 1) = .999;

if exist('weights','var') & ~isempty(weights)
    ynew = [];
    xnew = [];
    for i = 1:length(x)
        ynew = [ynew repmat(y(i),1,weights(i))];
        xnew = [xnew repmat(x(i),1,weights(i))];
    end
    y = ynew;
    x = xnew;
end

% initialization
if ~exist('p0','var') | isempty(p0)
    p0 = [0 ...
          mean(diff(y))/mean(diff(x))*10 ...
          min(y) ...
          1-max(y)];
end

options = [];
options.display = 'none';
options.numDiff = 1;
[params,fval,exitflag,output] = minFunc(@(p) norm(y-mdl(p,x)),p0',options);

threshold = params(1)/params(2);
sensitivity = params(2);

FIT.finalFuncVal = fval;
FIT.optimFunc = @(p) norm(y-mdl(p,x));
FIT.exitflag = exitflag;
FIT.output = output;
FIT.options = options;
FIT.p0 = p0;
