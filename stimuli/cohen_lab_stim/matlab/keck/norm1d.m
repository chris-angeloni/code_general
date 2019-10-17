%function [y] = norm1d(x)
%
%	FILE NAME 	: NORM1D
%	DESCRIPTION 	: Normalizes from 0 to 1 the vector x 
%
function [y] = norm1d(x)

%Finiding max and min
maxx=max(x);
minx=min(x);

%Normalizing
y=(x-minx)/(maxx-minx);
