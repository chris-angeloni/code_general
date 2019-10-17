%       DESCRIPTION     : T-test for significance

function [SIG]=Ttest(alpha,mu1,sigma1,mu2,sigma2,n1,n2)


t_value = tinv(1-alpha,n1+n2-2);
sw=sqrt((sigma1^2*(n1-1)+sigma2^2*(n2-1))/(n1+n2-2));
t=(mu1-mu2)/sw/sqrt(1/n1+1/n2);

if abs(t)>t_value
    SIG=1;  % mu1 != mu2
else
    SIG=0;  % mu1 = mu2
end

    