%
%function []=addfilemag(infile1,infile2,outfile,ftype,M)
%
%       FILE NAME   : ADD FILE MAG
%       DESCRIPTION : Adds two 'int16' or 'float' files so as to compute 
%                     the magnitude
%
%                                    sqrt(x1^2+x2^2)
%
%                     where x1 and x2 are the signals inside infile1
%                     and infile2. The output is stored in a single
%                     file of the same type.
%
%       infile1     : Input File 1
%       infile2		: Input File 2
%       outfile		: Output File
%       ftype		: File Type : 'int16', 'float', etc ...
%                     Default - 'int16'
%       M           : Buffer Length - Optional (1024*512 Default)
%
function []=addfilemag(infile1,infile2,outfile,ftype,M)

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
		fwrite(fidout,sqrt(X1.^2+X2.^2),ftype);
	end
end

%Closing Files
fclose('all');