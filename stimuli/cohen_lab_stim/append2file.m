%
%function [] = append2file(file1,file2,ftype,M)
%
%	FILE NAME 	: APPEND 2 FILE
%	DESCRIPTION 	: Appends File1 to File2
%
%	file1		: Input data file 
%	file2		: File to append to (Output)
%	ftype		: File Type : 'int16', 'float', etc ... 
%	M		: Block size ( Default = 1024*128 )
%
function [] = append2file(file1,file2,ftype,M)

%Input Arguments
if nargin<4
	M=1024*128;
end

%Opening Files
fid2=fopen(file2,'a');
fid1=fopen(file1);

%Appending File2 to File1 
while ~feof(fid1)
	X=fread(fid1,M,ftype);
	fwrite(fid2,X,ftype);
end

%Closing Files
fclose('all');
