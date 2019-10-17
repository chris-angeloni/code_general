function [H]=sigtestz(mu1,sigma1,n1,mu2,sigma2,n2,alpha)

% DESCRIPTION       : test whether two sets or data could have the same mean
% when the standard deviations are known.

% mu1, sigma1, n1   : mean, standard deviation and number of samples of
% data1
% mu2, sigma2, n2   : mean, standard deviation and number of samples of
% data2
% alpha             : significance level 

% H                 : H=0: null hypothesis (mu1=mu2) cannaot be rejected at the
% alpha significance level;  H=1:null hypothesis can be reject at the alpha
% significace level.

% (c) Yi Zheng, Aug 2007

if nargin<7
    alpha=0.05;
end

z = (mu1-mu2)/sqrt(sigma1^2+sigma2^2);
z_alpha = 1.96;  % at the 0.05 level of significance

if abs(z)>=z_alpha 
    H=1;
else
    H=0;
end
