function[H]=boottestvs(x,statfun,vzero,type,alpha,B1,B2,B3,varargin)
%      D=boottestvs(x,statfun,v_0,type,alpha,B1,B2,B3,PAR1,...)
%  
%       Hypothesis test for a characteristic (parameter) 'v'
%      of an unknown distribution  based on the bootstrap  
%      resampling procedure and variance stabilisation (VS).
%
%     Inputs:
%           x - input vector data 
%     statfun - the estimator of the parameter given as a Matlab function
%        v_0  - the value of vartheta under the null hypothesis
%        type - the type of hypothesis test.
%
%               For type=1:   H: v=v_0   against K: v~=v_0
%                (two-sided hypothesis test)      
%               For type=2:   H: v<=v_0  against K: v>v_0      
%                (one-sided hypothesis test)   
%               For type=3:   H: v>=v_0  against K: v<v_0   
%                (one-sided hypothesis test) 
%               (default type=1)           
%      alpha  - determines the level of the test
%               (default alpha=0.05)  
%         B1  - numbers of bootstrap resamplings for VS 
%               (default B1=100) 
%         B2  - numbers of bootstrap resamplings for VS 
%               (default B2=25) 
%         B3  - number of bootstrap resamplings
%               (default B3=99)           
%    PAR1,... - other parameters than x to be passed to statfun
%
%     Outputs:
%           D - The output of the test. 
%               D=0: retain the null hypothesis
%               D=1: reject the null hypothesis
%
%     Example:
%
%     D = boottestvs(randn(10,1),'mean',0);

%  Created by A. M. Zoubir and D. R. Iskander
%  May 1998
%
%  References:
% 
%  Efron, B.and Tibshirani, R.  An Introduction to the Bootstrap.
%               Chapman and Hall, 1993.
%
%  Tibshirani, R. Variance Stabilisation and the Bootstrap. 
%               Biometrika,  Vol.75, pp. 433-444, (1988).
%
%  Zoubir, A.M. Bootstrap: Theory and Applications. Proceedings 
%               of the SPIE 1993 Conference on Advanced  Signal 
%               Processing Algorithms, Architectures and Imple-
%               mentations. pp. 216-235, San Diego, July  1993.
%
%  Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application
%               in Signal Processing. IEEE Signal Processing Magazine, 
%               Vol. 15, No. 1, pp. 55-76, 1998.


pstring=varargin;
if (exist('B3')~=1), B3=99; end;
if (exist('B2')~=1), B2=25; end;
if (exist('B1')~=1), B1=100; end;
if (exist('alpha')~=1), alpha=0.05; end;
if (exist('type')~=1), type=1; end;
if (exist('vzero')~=1), 
  error('Proivde the value of the paramter under the null hypothesis'); 
end;

x=x(:);
vhat=feval(statfun,x,pstring{:});

[vhatstar,ind]=bootstrp(B1,statfun,x,pstring{:});
bstats=bootstrp(B2,statfun,x(ind),pstring{:});
sigmastar2=var(bstats);

[statsort,sigmasort,sigmasm2]=smooth(vhatstar',sigmastar2,B1/200);

a=statsort;
b=sigmasm2.^(-1/2);
h=zeros(1,B1);
h(1)=0;  
for i=2:B1,
   h(i)=h(i-1)+(a(i)-a(i-1))*(b(i)+b(i-1))/2;
end;

[vhatstar1,ind1]=bootstrp(B3,statfun,x,pstring{:});

ind=find(vhatstar1>=a(1) & vhatstar1<=a(B1));
ind1=find(vhatstar1<a(1));
ind2=find(vhatstar1>a(B1));
newv=vhatstar1(ind);
newvs=vhatstar1(ind1);
newvl=vhatstar1(ind2);
hvec(ind)=interp1(a,h,newv)';
hvec(ind1)=(h(2)-h(1))/(a(2)-a(1))*(newvs-a(1))+h(1);
hvec(ind2)=(h(B1)-h(B1-1))/(a(B1)-a(B1-1))*(newvl-a(B1-1))+h(B1-1);
  
p=find(a>vhat);
if isempty(p)
  hvhat=(h(B1)-h(B1-1))/(a(B1)-a(B1-1))*(vhat-a(B1-1))+h(B1-1);
elseif p(1)==1,
  hvhat=(h(2)-h(1))/(a(2)-a(1))*(vhat-a(1))+h(1);
else  
  hvhat=interp1(a,h,vhat);
end;

p=find(a>vzero);
if isempty(p)
  hvzero=(h(B1)-h(B1-1))/(a(B1)-a(B1-1))*(vzero-a(B1-1))+h(B1-1);
elseif p(1)==1,
  hvzero=(h(2)-h(1))/(a(2)-a(1))*(vzero-a(1))+h(1);
else  
  hvzero=interp1(a,h,vzero);
end;
M=(B3+1)*(1-alpha);
if type==1, 
    Tstar=abs(hvec-hvhat);   
    T=abs(hvhat-hvzero);
    ST=sort(Tstar);
    if T>ST(M), H=1; else H=0; end;
elseif type==2,
    Tstar=(hvec-hvhat);   
    T=(hvhat-hvzero);
    ST=sort(Tstar);
    if T>ST(M), H=1; else H=0; end;
elseif type==3,
    Tstar=(hvec-hvhat);   
    T=(hvhat-hvzero);
    ST=sort(Tstar);
    if T<ST(M), H=1; else H=0; end;             
end;    

    

   








