%function [Imageout] = inorm(Imagein)
%
%	FILE NAME 	: INORM
%	DESCRIPTION 	: Normalizes from 0 to 255 an image and converts 
%			  all values to (int)
%
function [Imageout] = inorm(Imagein)

%Finiding max and min
maxi=max(max(Imagein));
mini=min(min(Imagein));

%Normalizing
Imageout=round(255*(Imagein-mini)/(maxi-mini));
