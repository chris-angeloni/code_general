%
%function  [Err] = finderr(H,flag)
%	
%	FILE NAME 	: finderr
%	DESCRIPTION 	: Finds the Maximum Pasband Error 
%			  of a Filter.
%	FUNCTION CALL	: finderr(Faxis,H)
%	H		: Filter Frequency responce.
%	Err		: Maximum Pasband Error.
%	Flag		: Determines the ATT criterion:
%		     -1 : Standard.
%		     -2 : Roark modified. 
%
function  [Err] = finderr(H,flag)

L=length(H);
if flag == -1,
	Err=0;
	i=2;
	while H(i) > .5 & i < L-2
		if ( H(i) > H(i-1) & H(i) > H(i+1) ) | ( H(i) < H(i-1) & H(i) < H(i+1) )
			if abs(H(i) - 1) > Err
				Err=abs(H(i) - 1);
			end
		end 
		i=i+1;
	end
elseif flag==-2,
	i=1;
	while H(i)>.5
		i=i+1;
	end

	while ~(H(i)>H(i+1) & H(i) > H(i-1))
		i=i-1;
	end
	Pbi=i;
	delta1=max(H(1:Pbi))-1;
	
	if H(Pbi) > 1
		delta2=1-min(H(1:Pbi));
	else
		delta2=H(Pbi)-min(H(1:Pbi));
	end

	Err=max([delta1 delta2]);
end
