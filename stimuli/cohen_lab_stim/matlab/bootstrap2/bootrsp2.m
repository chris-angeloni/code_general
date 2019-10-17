function[out1,out2]=bootrsp2(in1,in2,B)
%       [out1,out2]=bootrsp2(in1,in2,B)
% 
%   Bootstrap  resampling  procedure for bivariate data. 
%
%     Inputs:
%       in1 - input data (first variate) 
%       in2 - input data (second variate). If in2 is not 
%             provided the function runs bootrsp.m by default.
%         B - number of bootstrap resamples (default B=1)        
%     Outputs
%      out1 - B bootstrap resamples of the first variate
%      out2 - B bootstrap resamples of the second variate
%
%   For a vector input data of size [N,1], the  resampling 
%   procedure produces a matrix of size [N,B] with columns 
%   being resamples of the input vector.
%
%   Example:
%
%   [out1,out2]=bootrsp2(randn(10,1),randn(10,1),10);

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


if (exist('B')~=1), B=1;  end;
if (exist('in2')~=1) & (exist('in1')==1), 
   out1=bootrsp(in1,B); out2=0;
   return
end;
if (exist('in1')~=1), error('Provide input data'); end;
s1=size(in1); s2=size(in2);

if length(s1)>2 | length(s2)>2, 
  error('Input data can be vectors or a 2D matrices only'); 
end;

if any(s1-s2)~=0 & any(s1-fliplr(s2))~=0,
  error('Input vectors or matrices must be of the same size')
end;
if s1==fliplr(s2),
  in2=in2.';
end;
if min(s1)==1,  
  ind=ceil(max(s1)*rand(max(s1),B));
  out1=in1(ind); out2=in2(ind);    
else         
  ind=ceil(s1(1)*s1(2)*rand(s1(1),s1(2),B));
  out1=in1(ind);
  out2=in2(ind); 
end;

