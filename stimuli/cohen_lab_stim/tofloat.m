%
%function []=tofloat(filename,X)
%	
%	FILE NAME 	: TOFLOAT
%	DESCRIPTION 	: Converts an array X to a binary 'float' file
%			  Appends Data for subsequent saves
%
%	filename	: Output File
%       X		: Input Signal
%
function []=tofloat(filename,X)

%Opening Output Files
fid=fopen(filename, 'a');

%Saving Output File 
fwrite(fid,X,'float');

%Closing Output File
fclose(fid);
