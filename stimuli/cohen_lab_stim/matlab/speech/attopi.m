%
%function  [Err0,errpi] = errOpi(H)
%	
%	FILE NAME 	: finderr
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
L=3;
j=2;
HO=abs(1-H);
count=0;
if HO(j)>HO(j+1)
	count=count+1;
	while ~( count==L )
		j=j+1;
		if HO(j)>HO(j+1) & HO(j)>HO(j-1)
			count=count+1;
		end 
	end
else
	while ~( count==L )
		j=j+1;

		if HO(j)>HO(j+1) & HO(j)>HO(j-1)
			count=count+1;
		end 
	end
end
Err0=HO(j);

%Finding Error at w=pi
j=N/2+2;
count=0;
if H(j)>H(j+1)
	count=count+1;
	while ~( count==L )
		j=j+1;
		if H(j)>H(j+1) & H(j)>H(j-1)
			count=count+1;
		end 
	end
else
	while ~( count==L )
		j=j+1;
		if H(j)>H(j+1) & H(j)>H(j-1)
			count=count+1;
		end 
	end
end
Errpi=abs(H(j));


Errpi=mean(H(N/2:N/2+100))
Err0=mean(HO(1:100));
