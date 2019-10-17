function[H]=boottest(x,statfun,vzero,type,alpha,B1,B2,varargin)
%           
%      D=boottest(x,statfun,v_0,type,alpha,B1,B2,PAR1,...)
%
%      Hypothesis test for a characteristic (parameter) 'v'
%      of an unknown distribution  based on the bootstrap  
%      resampling procedure and pivoted test statistics
%
%     Inputs:
%           x - input vector data 
%     statfun - the estimator of the parameter given as a Matlab function
%        v_0  - the value of 'v' under the null hypothesis
%        type - the type of hypothesis test.
%
%               For type=1:   H: v=v_0   against K: v~=v_0
%                (two-sided hypothesis test)      
%               For type=2:   H: v<=v_0  against K: v>v_0      
%                (one-sided hypothesis test)   
%               For type=3:   H: v>=v_0  against K: v<v_0   
%                (one-sided hypothesis test) 
%               (default type=1)           
%      alpha  - the level of the test (default alpha=0.05)  
%          B1 - number of bootstrap resamplings
%               (default B1=99)
%          B2 - number of bootstrap resamplings for variance 
%               estimation (nested bootstrap) 
%               (default B2=25)  
%    PAR1,... - other parameters than x to be passed to statfun
%
%     Outputs:
%          D - The output of the test. 
%               D=0: retain the null hypothesis
%               D=1: reject the null hypothesis
%
%     Example:
%
%     D = boottest(randn(10,1),'mean',0);


%  Created by A. M. Zoubir and D. R. Iskander
%  May 1998
%
%  References:
% 
%  Efron, B.and Tibshirani, R.  An Introduction to the Bootstrap.
%               Chapman and Hall, 1993.
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
if (exist('B2')~=1), B2=25; end;
if (exist('B1')~=1), B1=99; end;
if (exist('alpha')~=1), alpha=0.05; end;
if (exist('type')~=1), type=1; end;
if (exist('vzero')~=1), 
  error('Proivde the value of the paramter under the null hypothesis'); 
end;

x=x(:);
vhat=feval(statfun,x,pstring{:});
bstat=bootstrp(B2,statfun,x,pstring{:});

if type==1,
  T=abs(vhat-vzero)./std(bstat);
else
  T=(vhat-vzero)./std(bstat);
end;

[vhatstar,ind]=bootstrp(B1,statfun,x,pstring{:});
bstats=bootstrp(B2,statfun,x(ind),pstring{:});

M=(B1+1)*(1-alpha);

if type==1, 
  tvec=abs(vhatstar-vhat)./std(bstats)';       
  st=sort(tvec);  
  if T>st(M), H=1; else H=0; end;
elseif type==2,
  tvec=(vhatstar-vhat)./std(bstats)'; 
  st=sort(tvec);      
  if T>st(M), H=1; else H=0; end;   
elseif type==3,
  tvec=(vhatstar-vhat)./std(bstats)';       
  st=sort(tvec);
  if T<st(M), H=1; else H=0; end;      
end;
