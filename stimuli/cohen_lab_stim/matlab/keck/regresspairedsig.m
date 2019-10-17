%
%function [H,t,DF]=regresspairedsig(X1,Y1,X2,Y2,alpha,NB,tail,flag)
%
%       FILE NAME       : REGRESS PAIRED SIG
%       DESCRIPTION     : Tests for the null hypothesis that two data
%                         samples have identical slopes using linear
%                         regression. Uses a paired t-test to determine
%                         whether the mean slopes are the same (Null
%                         Hypothesis, H=0) or not (Alternative Hypothesis,
%                         H=1). Requires that one choose the regression
%                         algorithm.
%
%       X1,Y1           : Data Arrays 1
%       X2,Y2           : Data Arrays 2
%       alpha           : Significance value
%       NB              : Number of bootstrap itterations (typically > 100;
%                         Default==100)
%       tail            : Type of test (default=='both'). 
%                         For all tests the null hypothesis (H0) is
%                               B1==B2  (slope 1 = slope 2)
%
%                         If tail=='right' alternative hypothesis is 
%                               B1>B2   (slope 1 > slope 2)
%
%                         If tail=='left' alternative hypothesis is 
%                               B1<B2   (slope 1 < slope 2)
%
%                         If tail=='both' alternative hypothesis is 
%                               B1~=B2 (i.e., slopes are not equal)
%       flag            : Used to choose the linear regression algorithm.
%                           ROBUSTFIT if flag==1
%                           POLYFIT   if flag==2
%                           (Defualt=1)
%
%Returned Variables
%       H               : Result from test slopes are the same (Null 
%                         hypothesis). H=0, null hypothesis cannot be
%                         rejected at alpha value. H=1, null hypothesis can
%                         be rejected at alpha value.
%       t               : t-statitistic
%       DF              : Degrees of freedom
%
%(C) Monty A. Escabi, December 2015
%
function [H,t,DF]=regresspairedsig(X1,Y1,X2,Y2,alpha,NB,tail,flag)

%Input Arg
if nargin<6
    NB=100;
end
if nargin<7
    tail='both';
end
if nargin<8
    flag=1;
end

%Bootstrapping robust regression to determine SE
B1=[];
B2=[];
N1=length(Y1);
N2=length(Y2);
for k=1:NB
    i1=randsample(N1,N1,1);
    i2=randsample(N2,N2,1);
    if flag==1
        B1 = [B1; robustfit(X1(i1),Y1(i1))'];
        B2 = [B2; robustfit(X2(i2),Y2(i2))'];
    else 
        B1=[B1; polyfit(X1(i1),Y1(i1),1)];
        B2=[B2; polyfit(X2(i2),Y2(i2),1)];
    end
end
if flag==1
    B1=B1(:,2);         %Bootstrapped Slopes 
    B2=B2(:,2);         %Bootstrapped Slopes
else
    B1=B1(:,1);         %Bootstrapped Slopes 
    B2=B2(:,1);         %Bootstrapped Slopes
end
%Computing t-statistics, Welch test, assumes unequal sample size and
%unequal variance. However, still OK if the sample sizes and variances are
%equal. Note that Im computing the SE via bootstrap
S1=std(B1);                                                             %Standard error for slope 1
S2=std(B2);                                                             %Standard error for slope 2
Sx1x2=sqrt(S1^2 + S2^2);                                                %Combined SE
t=(mean(B1)-mean(B2))/Sx1x2;                                            %t-statistic
DF=ceil((S1^2 + S2^2)^2 / ( (S1^2)^2/(N1-1) + (S2^2)^2/(N2-1) ));       % Welch?Satterthwaite equation for DF

%Performing t-test
if ~strcmp(tail,'both')
    alpha=alpha/2;
end
tc=tinv(1-alpha,DF);                                                    %Critical t value
if strcmp(tail,'both') & abs(t)>=tc
    H=1;
elseif strcmp(tail,'both') & abs(t)<tc
    H=0;
elseif strcmp(tail,'right') & t>=tc
     H=1;
elseif strcmp(tail,'right') & t<tc
     H=0;
elseif strcmp(tail,'left') & -t>=tc
     H=1;
else strcmp(tail,'left') & -t<tc
     H=0;
 end