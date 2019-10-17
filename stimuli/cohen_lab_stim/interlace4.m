%
%function []=interlace4(infile1,infile2,infile3,infile4,outfile,M)
%
%       FILE NAME       : INTERLACE
%       DESCRIPTION     : Interlaces 4 'int16' files
%			  Assumes both files are the same 
%			  length and 'int16' format.
%
%       infile1         : Input File 1
%	infile2		: Input File 2
%	infile3		: Input File 3
%	infile4		: Input File 4
%	outfile		: Output File
%	M		: Buffer Length : Optional (512K Default)
%
function []=interlace4(infile1,infile2,infile3,infile4,outfile,M)

%Checking Input Arguments
if nargin<6
	M=1024*512;
end

%Opening Input and Output Files
fidin1=fopen(infile1,'r');
fidin2=fopen(infile2,'r');
fidin3=fopen(infile3,'r');
fidin4=fopen(infile4,'r');
fidout=fopen(outfile,'w');

%Reading and Saving data
M=2^(round(log2(M)))/2;
Y=zeros(4*M,1);
while ~feof(fidin1) & ~feof(fidin2) & ~feof(fidin3) & ~feof(fidin4)
	x1=fread(fidin1,M,'int16');
	x2=fread(fidin2,M,'int16');
	x3=fread(fidin3,M,'int16');
	x4=fread(fidin4,M,'int16');
	Y(1:4:4*length(x1))=x1(1:length(x1));
	Y(2:4:4*length(x2))=x2(1:length(x2));
	Y(3:4:4*length(x3))=x3(1:length(x3));
	Y(4:4:4*length(x4))=x4(1:length(x4));
	fwrite(fidout,Y(1:4*length(x1)),'int16');
end

%Closing All Files
fclose('all');
