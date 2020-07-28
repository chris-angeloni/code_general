function h = barploterr(X, E, w, c)
%
%barploterr(X, E, [w=1, c='k'])
%
% Plots bar graph of the means in X with errors E.
% The optional w defines the error bar width.
% The optional c defines the error bar colour.
%

if nargin < 3
    w = 1;
    c = 'k';
elseif nargin < 4
    c = 'k';
end

% Work out bar position
ng = size(X,1);
nb = size(X,2);
[b g]=meshgrid(1:nb, 1:ng);
gw = min(0.8, nb/(nb+1.5));
x = g - gw/2 + (2*b-1) * gw / (2*nb); 

% Plot bars with errors
hold on
h = bar(X);
if find(size(X)==1)
    x = (1:length(X))';
else
    x = x'; x = x(:);
end
X = X'; X = X(:);
E = E'; E = E(:);
errorbar(x, X, E, 'linewidth', w, 'color', c, 'linestyle', 'none');
hold off
set(gca, 'xtick', 1:ng);
if ng > 1
    xlim([0.5 ng+0.5]);
end
