%function []=int2float(infile,outfile,M)
%
%       FILE NAME       : INT 2 FLOAT
%       DESCRIPTION     : Converts a binary 'int16' file to binary 'float'
%
%       infile		: Input file name
%	outfile		: Output file name 
%	M		: Segment Length
%
function []=int2float(infile,outfile,M)

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'a');

%Converting to 'float'
fseek(fidin,0,-1);
while ~feof(fidin)
	X=fread(fidin,M,'int16');
	fwrite(fidout,X,'float');
end

%Closing Files
fclose(fidin);
fclose(fidout);

