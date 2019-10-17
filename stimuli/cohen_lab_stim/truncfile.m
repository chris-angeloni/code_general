%function []=truncfile(infile,outfile,dL,L,M,ftype)
%
%       FILE NAME       : TRUNC FILE
%       DESCRIPTION     : Truncates a binary file to length L
%
%       infile		: Input file name
%	outfile		: Output file name
%	dL		: Offset (Number of Samples)
%	L		: File Length (Number of samples) 
%	M		: Segment Length
%	ftype		: File Type : 'int16' , 'float' , etc ...
%
function []=truncfile(infile,outfile,dL,L,M,ftype)

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'w');

%Advancing dL samples
if strcmp(ftype,'int16')
	bytes=2;	
else strcmp(ftype,'float')
	bytes=4;
end
fseek(fidin,dL*bytes,-1);

%Truncating File
for k=1:floor(L/M)
	X=fread(fidin,M,ftype);
	fwrite(fidout,X,ftype);
end
X=fread(fidin,L-floor(L/M)*M,ftype);
fwrite(fidout,X,ftype);

%Closing all files
fclose('all');
