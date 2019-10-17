%function [s]=boxdim(x,delta)
% 
%	FILE NAME       : Box Dim
%	DESCRIPTION     : Box counting dimmension
% 
%       x               : Input Signal
%	delta		: Scale to evaluate dimmension 0<delta<1
%	s		: Dimmension at scale delta
%
function [s]=boxdim(x,delta)

%Normalizing Function to [0,1]
x=norm1d(x)*.99+.005;
N=length(x);

%Finding Box Counting Dimmension
dN=min(delta*N);

%Binning into segments of delta on abscisa
for k=1:floor(N/dN)
	xk(1:dN,k)=x((k-1)*dN+1:(k-1)*dN+dN)';
end

%Grid of delta
grid=0:delta:1;

%finding Number of boxes which cover x 
Nd=0;
for k=1:floor(N/dN)
	boxmin=max( find( grid < min(xk(:,k)) ) );
	boxmax=min( find( grid > max(xk(:,k)) ) );
	Nd=Nd+(boxmax-boxmin);
end

%Box counting dimmendion at scale delta
s=-log(Nd)/log(delta);



