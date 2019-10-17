%
%function []=interlace(infile1,infile2,outfile,M)
%
%       FILE NAME       : INTERLACE
%       DESCRIPTION     : Interlaces 'infile1' as the right audio 
%			  channel and 'infile2' as the left audio 
%			  channel. Assumes both files are the same 
%			  length and 'int16' format.
%
%       infile1         : Input File 1
%	infile2		: Input File 2
%	outfile		: Output File
%	M		: Buffer Length : Optional (512K Default)
%
function []=interlace(infile1,infile2,outfile,M)

%Checking Input Arguments
if nargin<4
	M=1024*512;
end

%Opening Input and Output Files
fidin1=fopen(infile1,'r');
fidin2=fopen(infile2,'r');
fidout=fopen(outfile,'w');

%Reading and Saving data
M=2^(round(log2(M)))/2;
Y=zeros(2*M,1);
while ~feof(fidin1) & ~feof(fidin2)
	x1=fread(fidin1,M,'int16');
	x2=fread(fidin2,M,'int16');
	Y(1:2:2*length(x1))=x1(1:length(x1));
	Y(2:2:2*length(x1))=x2(1:length(x2));
	MM=min(length(x1),length(x2));
	fwrite(fidout,Y(1:2*MM),'int16');
end

%Closing Files
fclose('all');
