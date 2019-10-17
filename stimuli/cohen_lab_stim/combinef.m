%
%function []=combinef(infilehead,outfile)
%
%       FILE NAME       : COMBINE F
%       DESCRIPTION     : Combines a numbered sequence of 'int16' files
%			  Used for taking 'BLOCKED' Files and converting 
%			  to a single file
% 
%       infile		: Input file name header
%	outfile		: Output file name
%
function []=combinef(infilehead,outfile)

%Opening Outfile
fidout=fopen(outfile,'w');

%Writing Output File
i=1;
while exist([infilehead '_b' num2str(i) '.raw'])
	
	%Opening infile
	fidin=fopen([infilehead '_b' num2str(i) '.raw'],'r');
	
	while ~feof(fidin)
		X=fread(fidin,1024*128,'int16');
		fwrite(fidout,X,'int16');
	end

	%Closing Infile
	fclose(fidin);
	i=i+1;

end

%Closing Outfile
fclose(fidout);
