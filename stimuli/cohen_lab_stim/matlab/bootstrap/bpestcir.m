function[est,estvar]=bpestcir(x,estfun,L1,M1,Q1,L2,M2,Q2,B,varargin)
%        [est,estvar]=bpestcir(X,estfun,L1,M1,Q1,L2,M2,Q2,B,PAR1,...)
%
%        The program calculates the estimate and the variance 
%        of an estimator of a parameter from the input vector X.
%        The algorithm is based  on a circular block bootstrap 
%        and is suitable when the data is weakly correlated. 
%        
%     Inputs:
%           x - input vector data 
%      estfun - the estimator of the parameter given as a Matlab function
%          L1 - number of elements in the first block (see "segmcirc.m")
%          M1 - shift size in the first block
%          Q1 - number of segments in the first block
%          L2 - number of elements in the second block (see "segmcirc.m")
%          M2 - shift size in the second block
%          Q2 - number of segments in the second block
%           B - number of bootstrap resamplings (default B=99)
%    PAR1,... - other parameters than x to be passed to estfun
%
%     Outputs:  
%         est - estimate of the parameter
%      estvar - variance of the estimator  
%
%     Example:
%
%     [est,estvar]=bpestcir(randn(1000,1),'mean',50,50,50,10,10,10);

%  Created by A. M. Zoubir and D. R. Iskander
%  May 1998
%
%  References:
% 
% Politis, N.P. and Romano, J.P. Bootstrap Confidence Bands for  Spectra
%           and Cross-Spectra. IEEE Transactions on  Signal  Processing,
%           Vol. 40, No. 5, 1992. 
%
% Zhang, Y. et. al. Bootstrapping Techniques in the Estimation of Higher
%           Order Cumulants from Short Data Records. (Proceedings of the
%           International Conference on  Acoustics,  Speech  and  Signal 
%           Processing, ICASSP-93, Vol. IV, pp. 200-203.
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
x=x(:);
QL=segmcirc(x,L1,M1,Q1);
estm=feval(estfun,QL,pstring{:});
beta=segmcirc(estm,L2,M2,Q2);
ind=bootrsp(1:Q2,B);
Y=beta(ind);
estsm=mean(Y);
est=mean(estsm);
estvar=var(estsm);
 
   


