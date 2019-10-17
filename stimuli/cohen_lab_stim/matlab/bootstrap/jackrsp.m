function[y]=jackrsp(x,h)  
%      y=jackrsp(x,h)
%
%      The procedure known as a "Jackknife" forms a matrix of size 
%      (g-1)*h by g from the input vector x of length g*h. The 
%      input vector is first divided into "g" blocks of size  "h".
%      Each column of the matrix is formed  by deleting a block 
%      from the input. The standard version of the Jackknife is 
%      when h=1.
%      
%     Inputs:
%          x - input vector data 
%          h - number of elements in a block that is to be deleted 
%              (default h=1)
%     Output:
%          y - the output matrix of the data
%  
%     Example:
%
%     y=jackrsp(randn(10,1));

%  Created by A. M. Zoubir and  D. R. Iskander
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

if (exist('h')~=1), h=1; end;

x=x(:);
N=length(x);
g=N/h;
if rem(N,h)~=0,
  error('The length of the input vector must be divisible by h')
  return
end;
y=zeros((g-1)*h,g);
for ii=1:g,
  y(:,ii)=x([1:ii*h-h ii*h+1:N]);
end; 

