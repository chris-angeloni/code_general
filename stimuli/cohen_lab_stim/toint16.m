%
%function []=toint16(filename,X)
%	
%	FILE NAME 	: TOINT16
%	DESCRIPTION 	: Converts an array X to a binary 'int16' file
%
%	filename	: Output File
%       X		: Input Signal
%
function []=toint16(filename,X)

%Opening Output Files
fid=fopen(filename, 'a');

%Saving Output File 
fwrite(fid,X,'int16');

%Closing Output File
fclose(fid);
