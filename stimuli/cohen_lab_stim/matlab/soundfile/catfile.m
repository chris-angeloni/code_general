%
%function []=catfile(infile1,infile2,outfile,ftype,M)
%
%       FILE NAME       : CAT FILE
%       DESCRIPTION     : Concatenates two files to form a single
%			  output file
%
%       infile1	        : Input File 1
%	infile2		: Input File 2
%	outfile		: Output File
%	ftype		: File Type : 'int16', 'float', etc ...
%			  Default - 'int16'
%	M		: Buffer Length - Optional (1024*512 Default)
%
function []=catfile(infile1,infile2,outfile,ftype,M)

%Checking Input Arguments
if nargin<4
	ftype='int16';
        M=1024*512;
elseif nargin<5
        M=1024*512;
end

%Opening Infile
fid1=fopen(infile1,'r');
fid2=fopen(infile2,'r');
fidout=fopen(outfile,'w');

%Concatenating the data files
while ~feof(fid1)
	X=fread(fid1,M,ftype);
	fwrite(fidout,X,ftype);
end
while ~feof(fid2)
	X=fread(fid2,M,ftype);
	fwrite(fidout,X,ftype);
end

%Closing Files
fclose('all');
