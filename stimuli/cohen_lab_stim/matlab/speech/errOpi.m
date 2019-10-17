%
%function  [Err0,errpi] = errOpi(H)
%	
%	FILE NAME 	: ERROPI
%	DESCRIPTION 	: Finds the Maximum Pasband Error 
%			  of a Filter at w=0 and w=pi.
%
%	H		: Filter Frequency responce
%	Err0		: Maximum Pasband Error at w=0
%	Errpi		: Maximum Passband Error at w=pi
%
function  [Err0,Errpi] = errOpi(H)

%Data length
N=length(H);

%Finding Error at w=0
j=2;
while ~(abs(1-H(j))>=abs(1-H(j+1)) & abs(1-H(j))>=abs(1-H(j-1)))
	j=j+1;
end
Err0=abs(H(j)-1);

%Finding Error at w=pi
j=N/2+2;
while ~(H(j)>=H(j+1) & H(j)>=H(j-1)) 
	j=j-1;
end
Errpi=abs(H(j));

