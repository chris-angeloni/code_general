%function []=sprfloat2int(infile,outfile,M)
%
%       FILE NAME       : SPR FLOAT 2 INT
%       DESCRIPTION     : Converts an SPR 'float' file to 'int16'
%
%       infile		: Input file name
%	outfile		: Output file name 
%	M		: Segment Length
%
function []=sprflaot2int(infile,outfile,M)

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'a');

%Converting to 'int16'
fseek(fidin,0,-1);
while ~feof(fidin)
	X=fread(fidin,M,'float');
	fwrite(fidout,round((X+.5)*2*1024*32*.99),'int16');
end

%Closing Files
fclose(fidin);
fclose(fidout);

