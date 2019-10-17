%
%function []=addfile(infile1,infile2,outfile,ftype,M)
%
%       FILE NAME       : ADD FILE
%       DESCRIPTION     : Adds two 'int16' or 'float' files to form a single 'int16'
%			  output file
%
%       infile1	        : Input File 1
%	infile2		: Input File 2
%	outfile		: Output File
%	ftype		: File Type : 'int16', 'float', etc ...
%			  Default - 'int16'
%	M		: Buffer Length - Optional (1024*512 Default)
%
function []=addfile(infile1,infile2,outfile,ftype,M)

%Checking Input Arguments
if nargin<4
	ftype='int16';
        M=1024*512;
elseig nargin<5
        M=1024*512;
end

%Opening Infile
fid1=fopen(infile1,'r');
fid2=fopen(infile2,'r');
fidout=fopen(outfile,'w');

%Adding the data files
while ~( feof(fid1) | feof(fid2) )
	X1=fread(fid1,M,ftype);
	X2=fread(fid2,M,ftype);
	if length(X1)==length(X2)
		fwrite(fidout,X1+X2,ftype);
	end
end

%Closing Files
fclose('all');
