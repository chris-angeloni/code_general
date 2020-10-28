function [params,mdl,tau,fmcon,minfun] = fitExpGrid(x,y,p0,weights)

%% function [params,mdl,tau,fmcon,minfun] = fitExp(x,y,p0,weights)
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
%  fmcon: struct with some info about the fitting


% fitting model and options
mdl = @(a,x) (a(1)+a(2).*exp(-x./a(3)));
options = optimoptions('fmincon',...
                       'MaxFunctionEvaluations',1000,...
                       'OptimalityTolerance', 1e-6,...
                       'StepTolerance', 1e-6, ...
                       'ConstraintTolerance', 1e-6,...
                       'Algorithm','active-set',...
                       'Display','notify');

% force x and y to be rows
if size(x,1) ~= 1
    x = x';
end
if size(y,1) ~= 1
    y = y';
end

% remove nans
x(isnan(y)) = [];
y(isnan(y)) = [];

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

% set up the search grid
if ~exist('p0','var')
    p0 = [];
end
nsearchpoints = 10;
grid(1,:) = repmat(min(y),1,nsearchpoints);
grid(2,:) = linspace(1,range(y)*10,nsearchpoints);
grid(3,:) = linspace(min(x),max(x),nsearchpoints);

% add supplied starting point to search grid
if size(p0,1) == 1
    p0 = p0';
end
grid = [p0 grid];

% set up search limits
lb = [min(y) -inf 0];
ub = [max(y) inf max(x)];

% grid search
for i = 1:size(grid,2)
    for j = 1:size(grid,2)
        
        a0 = [grid(1,1) grid(2,i) grid(3,j)];
        [p(i,j,:) f(i,j) e(i,j) o(i,j)] = fmincon(...
            @(p) immse(y,mdl(p,x)),a0',[],[],[],[],lb,ub,[],options);
        
    end
end

% find min error
[mf,mi] = min(f(:));
[i,j] = ind2sub(size(f),mi);

% output parameters
params = squeeze(p(i,j,:));
tau = params(3);

% fmincon fitting data
fmcon.searchgrid = grid;
fmcon.lowerbound = lb;
fmcon.upperbound = ub;
fmcon.paramgrid = p;
fmcon.fvalgrid = f;
fmcon.fvalmin = mf;
fmcon.parammin = [i j];
fmcon.options = options;

% fit with minfun, using best parameters from fmincon
options = [];
options.display = 'none';
options.numDiff = 1;
[minfun.params,minfun.fval,minfun.exitflag,minfun.output] = ...
    minFunc(@(p) immse(y,mdl(p,x)),params,options);
minfun.options = options;
