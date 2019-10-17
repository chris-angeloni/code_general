%function [nz]=findzcd(x)
%	
%	FILE NAME 	: FINDZCD
%	DESCRIPTION 	: Finds DownWard going Zero Crossing
%
%	x		: Input Signal
%	nz		: Array of ZC indeces 
%
function [nz]=findzc(x)

%Finding ZC
l=find(x>0);
k=find(diff(l)>1);
nz=l(k);
