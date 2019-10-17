%
%function  [ilow,ihigh] = findtw(H,flag)
%	
%	FILE NAME 	: findTW
%	DESCRIPTION 	: Finds the Tranzition Width of a Filter.
%			  Returns the vector indeces for the cutoff points.
%	FUNCTION CALL	: findTW(H)
%	ilow		: Index for lower cutoff point
%	ihigh		: Index for upper cuttoff point
%	H		: Filter Frequency responce
%	Flag		: Determines the ATT criterion:
%		      1 : Standard.
%		      2 : Roark modified. 
%
function  [ilow,ihigh] = findtw(H,flag)

M=length(H);
maxE=finderr(H,flag);

i=1;
while (H(i) > .5)
	i=i+1;
end

while ~(H(i)>1-maxE & H(i+1)<=1-maxE) & i<M-1,
	i=i-1;
end

%Index for the low Frequency Cuttoff
ilow=i;

while i < M-1 & ~(H(i)>maxE & H(i+1)<=maxE),
	i=i+1;
end

%Index for the low Frequency Cuttoff
ihigh=i;


