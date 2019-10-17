function[H]=boottestnp(x,statfun,vzero,type,alpha,B,varargin)
%           
%      D=boottestnp(x,statfun,v_0,type,alpha,B,PAR1,...)
%
%      Hypothesis test for a characteristic (parameter) 'v'
%      of an unknown distribution  based on the bootstrap  
%      resampling procedure and unpivoted test statistics
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
%           B - number of bootstrap resamplings
%               (default B1=99)           
%    PAR1,... - other parameters than x to be passed to statfun
%
%     Outputs:
%           D - The output of the test. 
%               D=0: retain the null hypothesis
%               D=1: reject the null hypothesis
%
%     Example:
%
%     D = boottestnp(randn(10,1),'mean',0);



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
if (exist('B')~=1), B=99; end;
if (exist('alpha')~=1), alpha=0.05; end;
if (exist('type')~=1), type=1; end;
if (exist('vzero')~=1), 
  error('Proivde the value of the paramter under the null hypothesis'); 
end;

x=x(:);
vhat=feval(statfun,x,pstring{:});

if type==1,
  T=abs(vhat-vzero);
else
  T=vhat-vzero;
end;

[vhatstar,ind]=bootstrp(B,statfun,x,pstring{:});

M=(B+1)*(1-alpha);

if type==1, 
  tvec=abs(vhatstar-vhat);       
  st=sort(tvec);  
  if T>st(M), H=1; else H=0; end;
elseif type==2,
  tvec=vhatstar-vhat; 
  st=sort(tvec);      
  if T>st(M), H=1; else H=0; end;   
elseif type==3,
  tvec=vhatstar-vhat;       
  st=sort(tvec);
  if T<st(M), H=1; else H=0; end;      
end;
