function [x_sort, y_sort, y_sm] = smooth(x, y, w)
%          [x_sort, y_sort, y_sm] = smooth(x, y, w);
%          A running line smoother that fits the data by linear 
%          least squares. Used to compute the variance stabilising 
%          transformation.
%
%    Inputs:  
%          x - one or more columns of covariates
%          y - one column of response for each column of covariate
%          w - span, proportion of data in symmetric centred window
%              
%   Outputs: 
%     x_sort - sorted columns of x
%     y_sort - values of y associated with x_sort
%       y_sm - smoothed version of y
%
%  Note: If inputs are row vectors, operation is carried out row-wise.

%  Created by A. M. Zoubir and Hwa-Tung Ong, 1996
%
% References
%
% Hastie, T.J. and Tibshirani, R.J. Generalised additive models.
%                Chapman and Hall, 1990.  
%
% Zoubir, A.M.   Bootstrap: Theory and Applications. Proceedings 
%                of the SPIE 1993 Conference on Advanced  Signal 
%                Processing Algorithms, Architectures and Imple-
%                mentations. pp. 216-235, San Diego, July  1993.
%
%  Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application
%               in Signal Processing. IEEE Signal Processing Magazine, 
%               Vol. 15, No. 1, pp. 55-76, 1998.

if any(size(x) ~= size(y))
    error('Input matrices must be the same length.'),
end

[nr,nc] = size(x);
n=nr;
if (nr==1) x=x';y=y';n=nc;nc=1; end
y_sm = zeros(n,nc);
[x_sort,order] = sort(x);
for i = 1:nc y_sort(:,i) = y(order(:,i),i); end
k = fix(w*n/2);

for i = 1:n
    window = max(i-k,1):min(i+k,n);
    xwin = x_sort(window,:);
    ywin = y_sort(window,:);
    xbar = mean(xwin);
    ybar = mean(ywin);
    copy = ones(length(window),1);
    x_mc = xwin - copy*xbar;    % mc = mean-corrected
    y_mc = ywin - copy*ybar;
    y_sm(i,:) = sum(x_mc.*y_mc)./sum(x_mc.*x_mc) .* (x_sort(i,:)-xbar) + ybar;
end

if (nr==1) x_sort=x_sort';y_sort=y_sort';y_sm=y_sm'; end
