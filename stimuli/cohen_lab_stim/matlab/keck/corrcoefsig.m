%
%function [H,Z,Zc,R1,R2]=corrcoefsig(X1,Y1,X2,Y2,alpha,tail)
%
%       FILE NAME       : CORR COEF SIG
%       DESCRIPTION     : Tests for the null hypothesis that two data
%                         samples have identical correlation coefficients.
%                         Uses a Fisher Z-Score transform.
%
%       X1,Y1           : Data Arrays 1
%       X2,Y2           : Data Arrays 2
%       alpha           : significance value
%       tail            : Type of test (default=='both'). 
%                         For all tests the null hypothesis (H0) is
%                               R1==R2
%
%                         If tail=='right' alternative hypothesis is 
%                               R1>R2
%
%                         If tail=='left' alternative hypothesis is 
%                               R1<R2
%
%                         If tail=='both' alternative hypothesis is 
%                               R1~=R2 (i.e., Rs are not equal)
%
%Returned Variables
%       H               : Result from test. H=0, null hypothesis cannot be
%                         rejected at alpha value. H=1, null hypothesis can
%                         be rejected at alpha value.
%       Z               : z-value
%       Zc              : Critical z-value
%       R1              : Corr Coef for sample 1
%       R2              : Corr Coef for sample 2
%
%(C) Monty A. Escabi, March 2012
%
function [H,Z,Zc,R1,R2]=corrcoefsig(X1,Y1,X2,Y2,alpha,tail)

%Input Arg
if nargin<6
    tail='both';
end

%Computing Correlation Coefficient
R1=corrcoef(X1,Y1);
R1=R1(1,2);
R2=corrcoef(X2,Y2);
R2=R2(1,2);

%Fisher Transfrom and Z-score
N1=length(X1);
N2=length(X2);
Z1=1/2*log((1+R1)/(1-R1));
Z2=1/2*log((1+R2)/(1-R2));
Z=(Z1 - Z2)/sqrt(1/(N1-3)+1/(N2-3));

%Checking for significance that r1-r2 not equal to zero
if ~strcmp(tail,'both')
    alpha=alpha/2;
end
Zc=tinv(1-alpha,inf);   %Critical Z value
if strcmp(tail,'both') & abs(Z)>=Zc
    H=1;
elseif strcmp(tail,'both') & abs(Z)<Zc
    H=0;
elseif strcmp(tail,'right') & Z>=Zc
     H=1;
elseif strcmp(tail,'right') & Z<Zc
     H=0;
elseif strcmp(tail,'left') & -Z>=Zc
     H=1;
else strcmp(tail,'left') & -Z<Zc
     H=0;
 end