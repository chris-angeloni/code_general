%function []=sprint2float(infile,outfile,M)
%
%       FILE NAME       : SPR INT 2 FLOAT
%       DESCRIPTION     : Converts an SPR 'int16' file to 'float'
%
%       infile		: Input file name
%	outfile		: Output file name 
%	M		: Segment Length
%
function []=sprint2float(infile,outfile,M)

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'a');

%Converting to 'float'
fseek(fidin,0,-1);
while ~feof(fidin)
	X=fread(fidin,M,'int16');
	fwrite(fidout,X/.99/1024/32/2-.5,'float');
end

%Closing Files
fclose(fidin);
fclose(fidout);

