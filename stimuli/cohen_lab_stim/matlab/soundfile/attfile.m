%
%function []=attfile(infile,outfile,ATT,type,M)
%
%       FILE NAME       : ATT FILE
%       DESCRIPTION     : Attenuates the data in infile
%
%       infile	        : Input File
%	outfile		: Output File
%	ATT		: Attenuation in dB
%	type		: Data Type , 'float' , 'int16' , etc . . .
%	M		: Buffer Length - Optional (1024*512 Default)
%
function []=attfile(infile,outfile,ATT,type,M)

%Checking Input Arguments
if nargin<5
        M=1024*512;
end

%Opening Infile
fidin=fopen(infile,'r');
fidout=fopen(outfile,'w');

%Attenuating File
while ~feof(fidin)
	X=fread(fidin,M,type);
	if strcmp(type,'int16')
		X=round(X*10.^(-ATT/20));
	else
		X=X*10.^(-ATT/20);
	end
	fwrite(fidout,X,type);
end

%Closing Files
fclose('all');
