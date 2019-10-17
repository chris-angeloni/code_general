%
%function []=flipfile(infile,outfile,type,M)
%
%       FILE NAME       : FLIP FILE
%       DESCRIPTION     : Rearanges 'infile' so that data is flipped
%			  from left to right 
%
%       infile	        : Input File
%	outfile		: Output File
%	type		: Data Type , 'float' , 'int16' , etc . . .
%	M		: Buffer Length - Optional (1024*512 Default)
%
function []=flipfile(infile,outfile,type,M)

%Checking Input Arguments
if nargin<4
        M=1024*512;
end

%Opening Infile
fidin=fopen(infile,'r');
fidout=fopen(outfile,'w');

%Searching For file length
L=0;
count=0;	
while ~feof(fidin)
	x=fread(fidin,M,type);
	L=L+length(x);
	count=count+1;
end

%Flipping the data
i=0;
while i<count
	if strcmp(type,'float')
		fseek(fidin,( -i*M-mod(L,M) )*4,1);
	elseif strcmp(type,'int16')
		fseek(fidin,( -i*M-mod(L,M) )*2,1);
	end
	x=fread(fidin,M,type);
	fwrite(fidout,flipud(x),type);
	i=i+1;
end

%Closing Files
fclose('all');
