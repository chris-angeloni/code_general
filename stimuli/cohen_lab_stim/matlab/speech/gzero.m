%
%function [tzc] = gzero(t1,t2,xs,Ts,NZC,alpha,m,wc,N)
%
%       FILE NAME       : G ZERO
%       DESCRIPTION     : Gradient method zero extraction Method
%			  Used in Conjunction with WITCARD and 
%			  H (ER Filter)
%
%       t1		: NZC*Ts
%       t2		: (NZC+1)*Ts
%	xs		: x(NZC-N:NZC+N-1)
%	Ts		: Sampling Period
%	NZC		: Zero Crossing Location
%	alpha		: Filter transition width parameter
%	m		: Filer Smoothing Parameter
%	wc		: Filter Frequncy
%	N		: Filter order / 2
%	epsilon		: Zero Finding Precission
%
function [tzc] = gzero(t1,t2,xs,Ts,NZC,alpha,m,wc,N,epsilon)

%Finding Updated Value
x1=xs(N+1);
x2=xs(N+2);
t3=t2 - x2*(t2-t1)/(x2-x1);
x3 = witcard(xs,t3,NZC,Ts,alpha,m,wc,N);
epsilon=1E-8;

while abs(x3)>epsilon

	if x3>0 

		t2=t3;
		x2=x3;
		t3=t2 - x2*(t2-t1)/(x2-x1);
		x3 = witcard(xs,t3,NZC,Ts,alpha,m,wc,N);

	elseif x3<0

		t1=t3;
		x1=x3;
		t3=t2 - x2*(t2-t1)/(x2-x1);
		x3 = witcard(xs,t3,NZC,Ts,alpha,m,wc,N);

	end

end

tzc=t3;



