function [params,mdl,tau,FIT] = fitExp(x,y,p0,lb,ub,weights)

%% function [params,mdl,tau,FIT] = fitExp(x,y,p0,lb,ub,weights)
%
% This function fits an exponential curve to data using the function: 
%
%   y = a + b .* exp(-x/c )
%
% where:
%   a = y-offset
%   b = scaling factor
%   c = time constant tau
%
% INPUTS:
%  x,y: x and y data points to fit (eg. x = time, y = response)
%
% OUTPUTS:
%  params: the fit parameters 
%  mdl: equation
%  tau: the fit time constant
%  FIT: struct with some info about the fitting


% fitting model and options
mdl = @(a,x) (a(1)+a(2).*exp(-x./a(3)));
options = optimoptions('fmincon',...
                       'MaxFunctionEvaluations',1000,...
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
    p0 = [min(y) 1 mean(x)];
end
if ~exist('lb','var') | isempty(lb)
    lb = [min(y) -inf 0];
end
if ~exist('ub','var') | isempty(ub)
    ub = [max(y) inf 10*max(x)];
end

% fit
[params,fval,exitflag,output] = fmincon(...
    @(p) norm(y-mdl(p,x)),p0,[],[],[],[],lb,ub,[],options);

tau = params(3);

FIT.finalFuncVal = fval;
FIT.optimFunc = @(p) norm(y-mdl(p,x));
FIT.exitflag = exitflag;
FIT.output = output;
FIT.options = options;
FIT.p0 = p0;