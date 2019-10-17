function[est,estall]=jackest(x,estfun,h,varargin)  
%      [est,estall]=jackest(x,estfun,h,PAR1,...)
%
%      Parameter estimation based on the "Jackknife" procedure
%          
%     Inputs:
%           x - input vector data 
%      estfun - the estimator of the parameter given as a Matlab function
%           h - number of elements in a block that is to be deleted. 
%               see jackrsp.m (defult h=1) 
%    PAR1,... - other parameters than x to be passed to estfun
%
%     Outputs:            
%         est - the jackknifed estimate
%      estall - the estimate based on the whole sample 
%  
%     Example:
%
%     [est,estall]=jackest(randn(10,1),'trimmean',1,20);
 
%  Created by A. M. Zoubir and D. R. Iskander
%  May 1998
%
%  References:
% 
%  Efron, B.  Bootstrap Methods. Another Look at the Jackknife. 
%             The Annals of Statistics, Vol. 7, pp. 1-26, 1979.
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
if (exist('h')~=1), h=1; end;
x=x(:);
N=length(x);   
estall=feval(estfun,x,pstring{:});
esti=feval(estfun,jackrsp(x,h),pstring{:}); 
%keyboard
psv=N*estall-(N-1).*esti;
est=mean(psv);   
  
