%function [] = appendfile(infile,outfile,N,ftype,M)
%
%	FILE NAME 	: APPEND FILE
%	DESCRIPTION 	: Appends N coppies of infile together and stores 
%			  to outfile
%
%	infile		: Input data file
%	outfile		: Output data file
%	N 		: Number of Copies of itself
%	ftype		: File Type : 'int16', 'float', etc ... 
%	M		: Block size
%
function [] = appendfile(infile,outfile,N,ftype,M)

%Opening Files
fidin=fopen(infile);
fidout=fopen(outfile,'w');

%Reading Infile N times and Saving to Outfile
for k=1:N 
	frewind(fidin);
	while ~feof(fidin)
		X=fread(fidin,M,ftype);
		fwrite(fidout,X,ftype); 
	end
end

%Closing Files
fclose('all');
