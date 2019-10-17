%function [Iout] = toimg(Iin,Min,Max)
%
%	FILE NAME 	: TO IMG 
%	DESCRIPTION 	: Converts a matrix so that it is compatible 
%			  with the imagesc matlab function
%
%	Iin		: Input image matrix
%	Iout		: Output image matrix
%
%Optional
%	Min, Min	: Used for normalizing relative to Min and Max		
%
function [Iout] = toimg(Iin,Min,Max)

if nargin < 2
	Min=min(min(Iin));
	Max=max(max(Iin));
elseif nargin < 3
	Max=max(max(Iin));
end

Iout=round((Iin-Min)/(Max-Min)*63+1);
Iout=rot90(Iout');
