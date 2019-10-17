function[y,q]=segments(x,L,M)
%      [y,Q]=segments(X,L,M)
%
%      Given the data samples X=(x_1,x_2,...,x_N),     
%      the program obtains Q overlapping (M<L) or 
%      non-overlapping (M>=L) segments, each of L samples 
%      in the form of a matrix "y" of L rows and Q columns. 
%        _______________    
%       |______ L ______| .....                     
%       |___ M ___|______ L ______| .....         
%       |___ M ___|___ M ___|______ L ______| .....
%
%      The procedure is used for the block of blocks bootstrap.
%        
%     Inputs:
%          X - input vector data 
%          L - number of elements in a segment
%          M - shift size (i.e. L-M is the size of overlap)               
%     Output:
%          y - the output matrix of the data
%          Q - number of output segments

%  Created by A. M. Zoubir and  D. R. Iskander
%  May 1998
%
%  References:
% 
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

x=x(:); 
N=length(x);
q=fix((N-L)/M)+1;
y=zeros(L,q);
for ii=1:q,   
  y(:,ii)=x((ii-1)*M+1:(ii-1)*M+L);
end;  




