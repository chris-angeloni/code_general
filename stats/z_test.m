function [p,Z] = z_test(y1,y2,n1,n2)

%% function [p,Z] = z_test(y1,y2,n1,n2)

% performs two-tailed z-test to test whether proportions within
% two populations significantly differ

% p1 = y1 / n1;
% p2 = y2 / n2;
% 
% p_hat = (y1 + y2) / (n1 + n2);
% Z = ((p1 - p2) - 0) / sqrt(p_hat * (1 - p_hat) * (1/n1 + 1/n2));
% 
% p = 2 * normcdf(Z);

if nargin == 2
    % if only two inputs, check if they are vectors
    if numel(y1) > 1 & numel(y2) > 1
        % check if they are binary
        if all(ismember(y1,1) | ismember(y1,0)) & ...
                all(ismember(y2,1) | ismember(y2,0))
            n1 = numel(y1);
            n2 = numel(y2);
            y1 = sum(y1);
            y2 = sum(y2);
        else
            error('z_test.m: Vector inputs must contain only 0 or 1.');
        end
    else
        error('z_test.m: Requires counts for y1 and y2.');
    end
elseif nargin ~= 2 & nargin ~= 4
    error(['z_test.m: Input either 2 binary vectors or counts and ' ...
           'population numbers for each sample.']);
end
  
p1 = y1 / n1;
p2 = y2 / n2;

p_hat = (y1 + y2) / (n1 + n2);
Z = ((p1 - p2) - 0) / sqrt(p_hat * (1 - p_hat) * (1/n1 + 1/n2));

p = 2 * normcdf(-abs(Z));


