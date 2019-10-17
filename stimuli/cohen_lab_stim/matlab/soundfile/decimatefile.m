%function [] = decimatefile(infile,outfile,L,ftype,M)
%
%	FILE NAME 	: DECIMATE
%	DESCRIPTION 	: Decimates a File by an integer factor L
%
%	infile		: Input data file
%	outfile		: Output data file
%	L		: Downsampling factor
%	ftype		: File Type , 'int16' or 'float'
%			  Default = 'int16'
%	M 		: Block Size
%			  Default = 128*1024
%
function [] = decimatefile(infile,outfile,L,ftype,M)

%Checking Input Arguments
if nargin < 4
	ftype='int16';
	M=1024*128;
elseif nargin < 5
	M=1024*128;
end

%Making M an integer multiple of L
M=ceil(M/L)*L;

%Opening Input and Output File
fidin=fopen(infile);
fidout=fopen(outfile,'w');

%Loading File and Decimating
while ~feof(fidin)
	X=fread(fidin,M,ftype);
	fwrite(fidout,X(1:L:length(X)),ftype);
end

%Closing Files
fclose('all');
