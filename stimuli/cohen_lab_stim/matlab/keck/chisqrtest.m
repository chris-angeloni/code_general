%
%function [H,p,X2,V]=chisqrtest(X1,X2,alpha,MinX,MaxX,N)
%
%   FILE NAME   : CHI SQR TEST
%   DESCRIPTION : Chi Square Goodness of Fit Test. Compares two
%                 distributions for the data from X1 and X2.
%
%   X1          : Data 1 (Data for reference distribution, e.g., randn(1,1024*128))
%   X2          : Data 2 (Test distribution)
%   alpha       : Significance level for test
%   MinX        : Lower limit for histogram
%   MaxX        : Upper limit for histogram
%   N           : Number of histogram bins (Default, uses sample bins that
%                 are 0.3*sigma) 
%
%RETURNED VARIABLES
%   H           : Null Hypothesis (distributions are the same), accept if H=0,
%                 reject if H=1
%   p           : Significance Level, p-value
%   X2          : Chi Square Value
%   V           : degrees of freedom
%
%	For details see Zar Eq. 22.1, Pg. 463
%
function [H,p,X2,V]=chisqrtest(X1,X2,alpha,MinX,MaxX,N)

%Input arguments
if nargin<6
    sigma=std(X1);
    %dX=sigma/3;
    dX=sigma/2;
    N=ceil((MaxX-MinX)/dX);
end

%Comparing to Distribution from NonCausal Random Samples (Zar, Eq. 22.1,
%Pg. 463)
X=(0:N-1)/(N-1)*(MaxX-MinX)+MinX;
P1=hist(X1,X);
P2=hist(X2,X);
P1=P1/sum(P1)*sum(P2);

%Removing outlier points, see Zar pg. 470 for details
i=find(P1>2 & P2>2);
%i=find(P2>0);
%i=find(P2>0 & P1>0);
P1=P1(i(2:length(i)-1));
P2=P2(i(2:length(i)-1));


%Computing X^2
X2=sum((P1-P2).^2./P2);

%Finding Significance Level
V=length(X)-1;
p=1-chi2cdf(X2,V);
if p<alpha
    H=1;
else
    H=0;
end